import '../demo_data.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

/// Fatal data-layer failure (message already user friendly).
class RepositoryException implements Exception {
  RepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Outcome of a full load cycle.
class FetchResult {
  const FetchResult({
    required this.tasks,
    required this.isOffline,
    this.notice,
  });

  final List<Task> tasks;
  final bool isOffline;

  /// Optional banner message, e.g. why cached/demo data is being shown.
  final String? notice;
}

/// Outcome of a mutation: [synced] is false when the change is queued for
/// later synchronisation (offline).
class MutationResult {
  const MutationResult({required this.task, required this.synced});

  final Task task;
  final bool synced;
}

abstract class TaskRepository {
  Future<FetchResult> loadTasks();
  Future<MutationResult> createTask(Task task);
  Future<MutationResult> updateTask(Task task);
  Future<MutationResult> deleteTask(Task task);

  /// Number of queued mutations still waiting to reach the server.
  int get pendingSyncCount;
}

/// Offline-first repository.
///
/// 1. Try to flush queued mutations, then fetch from the REST API.
/// 2. On success → persist to the local cache.
/// 3. On transport/API failure → serve the cache (or bundled demo data) with
///    an explanatory notice instead of crashing.
///
/// Mutations always apply locally first (optimistic UI) and are queued in an
/// outbox when the server is unreachable.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required this._api, required this._storage});

  final ApiService _api;
  final LocalStorageService _storage;

  List<Task>? _cache;
  List<Map<String, dynamic>>? _outbox;
  bool _flushing = false;

  @override
  int get pendingSyncCount => _loadOutbox().length;

  List<Map<String, dynamic>> _loadOutbox() =>
      _outbox ??= _storage.readOutbox();

  @override
  Future<FetchResult> loadTasks() async {
    try {
      await _flushOutbox();
      final dynamic raw = await _api.getList('tasks');
      if (raw is! List) {
        throw ApiException('Format data dari server tidak dikenali.');
      }
      final List<Task> tasks = raw
          .map<Task>(
            (dynamic item) => Task.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .where((Task task) => task.id.isNotEmpty)
          .toList();
      _cache = tasks;
      await _storage.saveTasks(tasks);
      return FetchResult(tasks: tasks, isOffline: false);
    } on ApiException catch (error) {
      final List<Task>? cached = _cache ?? _storage.readTasks();
      if (cached != null && cached.isNotEmpty) {
        _cache = cached;
        final String suffix = _loadOutbox().isEmpty
            ? 'Menampilkan data tersimpan.'
            : 'Menampilkan data lokal — perubahanmu aman.';
        return FetchResult(
          tasks: cached,
          isOffline: true,
          notice: '${error.message} $suffix',
        );
      }
      // Nothing cached yet: seed the bundled demo set so the UI stays usable.
      final List<Task> seed = DemoData.tasks();
      _cache = seed;
      await _storage.saveTasks(seed);
      return FetchResult(
        tasks: seed,
        isOffline: true,
        notice:
            '${error.message} Memuat data contoh lokal — semua fitur tetap bisa dicoba.',
      );
    }
  }

  @override
  Future<MutationResult> createTask(Task task) async {
    final List<Task> tasks = _applyLocal(task);
    final bool persisted = await _storage.saveTasks(tasks);

    try {
      final dynamic raw = await _api.post('tasks', task.toJson());
      final Task synced =
          raw is Map ? Task.fromJson(Map<String, dynamic>.from(raw)) : task;
      _cache = _applyLocal(synced, base: tasks);
      await _storage.saveTasks(_cache!);
      return MutationResult(task: synced, synced: true);
    } on ApiException {
      await _enqueue('create', task.toJson());
      if (!persisted) {
        throw RepositoryException('Gagal menyimpan tugas di perangkat. Coba lagi.');
      }
      return MutationResult(task: task, synced: false);
    }
  }

  @override
  Future<MutationResult> updateTask(Task task) async {
    final Task stamped = task.copyWith(updatedAt: DateTime.now());
    final List<Task> tasks = _applyLocal(stamped);
    final bool persisted = await _storage.saveTasks(tasks);

    try {
      await _api.patch('tasks/${stamped.id}', stamped.toJson());
      return MutationResult(task: stamped, synced: true);
    } on ApiException {
      await _enqueue('update', stamped.toJson());
      if (!persisted) {
        throw RepositoryException(
            'Gagal menyimpan perubahan di perangkat. Coba lagi.');
      }
      return MutationResult(task: stamped, synced: false);
    }
  }

  @override
  Future<MutationResult> deleteTask(Task task) async {
    final List<Task> tasks = List<Task>.from(_current())
      ..removeWhere((Task t) => t.id == task.id);
    _cache = tasks;
    final bool persisted = await _storage.saveTasks(tasks);

    try {
      await _api.delete('tasks/${task.id}');
      return MutationResult(task: task, synced: true);
    } on ApiException {
      await _enqueue('delete', <String, dynamic>{'id': task.id});
      if (!persisted) {
        throw RepositoryException(
            'Gagal menghapus tugas dari perangkat. Coba lagi.');
      }
      return MutationResult(task: task, synced: false);
    }
  }

  List<Task> _current() => _cache ?? _storage.readTasks() ?? <Task>[];

  /// Returns a new list with [task] inserted or replaced.
  List<Task> _applyLocal(Task task, {List<Task>? base}) {
    final List<Task> tasks = List<Task>.from(base ?? _current());
    final int index = tasks.indexWhere((Task t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    _cache = tasks;
    return tasks;
  }

  Future<void> _enqueue(String type, Map<String, dynamic> payload) async {
    _loadOutbox().add(<String, dynamic>{'type': type, 'payload': payload});
    await _storage.saveOutbox(_outbox!);
  }

  /// Pushes queued mutations one by one; stops at the first failure so the
  /// remaining ops stay ordered for the next attempt.
  Future<void> _flushOutbox() async {
    final List<Map<String, dynamic>> outbox = _loadOutbox();
    if (_flushing || outbox.isEmpty) return;
    _flushing = true;
    try {
      while (outbox.isNotEmpty) {
        final Map<String, dynamic> op = outbox.first;
        final Map<String, dynamic> payload =
            Map<String, dynamic>.from(op['payload'] as Map);
        switch (op['type'] as String?) {
          case 'create':
            await _api.post('tasks', payload);
          case 'update':
            await _api.patch('tasks/${payload['id']}', payload);
          case 'delete':
            await _api.delete('tasks/${payload['id']}');
          default:
            break;
        }
        outbox.removeAt(0);
        await _storage.saveOutbox(outbox);
      }
    } on ApiException {
      // Keep the remaining ops queued; retried on the next load/connectivity
      // change.
    } finally {
      _flushing = false;
    }
  }
}