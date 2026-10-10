import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/task.dart';
import '../data/models/task_stats.dart';
import '../data/repositories/task_repository.dart';
import '../data/services/connectivity_service.dart';

/// Coarse UI lifecycle for data-driven screens.
enum LoadState { loading, loaded, failure }

/// Timeline segmented filter (mirrors the mocked chip bar).
enum TimelineStatusFilter { all, uncompleted, completed }

/// Result returned by every mutation so the UI can pick the right feedback.
enum MutationOutcome { success, successOffline, failure }

class ActionResult {
  const ActionResult(this.outcome, [this.message]);

  final MutationOutcome outcome;
  final String? message;

  bool get isFailure => outcome == MutationOutcome.failure;
}

/// Single source of truth for tasks, filters and derived statistics.
///
/// Uses the provider package's [ChangeNotifier]: lightweight, codegen-free and
/// easy to scope with `Provider.of` / `context.watch` / `context.read`.
class TaskProvider extends ChangeNotifier {
  TaskProvider({
    required this._repository,
    ConnectivityService? connectivity,
  }) {
    _connectivitySub =
        connectivity?.onlineStream().listen(_handleConnectivity);
  }

  final TaskRepository _repository;
  StreamSubscription<bool>? _connectivitySub;

  // --- Data / lifecycle -------------------------------------------------
  LoadState _loadState = LoadState.loading;
  String? _loadError;
  List<Task> _tasks = <Task>[];
  bool _isOffline = false;
  String? _notice;
  bool _isRefreshing = false;
  int _pendingSync = 0;

  // --- Home filters -----------------------------------------------------
  String _searchQuery = '';
  TaskStatus? _homeStatusFilter;

  // --- Timeline filters -------------------------------------------------
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TimelineStatusFilter _timelineStatusFilter = TimelineStatusFilter.all;
  TaskCategory? _timelineCategoryFilter;

  // --- Exposed state ----------------------------------------------------
  LoadState get loadState => _loadState;
  String? get loadError => _loadError;
  bool get isLoading => _loadState == LoadState.loading;
  bool get hasFatalError => _loadState == LoadState.failure;
  bool get isOffline => _isOffline;
  String? get notice => _notice;
  bool get isRefreshing => _isRefreshing;
  int get pendingSyncCount => _pendingSync;
  List<Task> get tasks => List<Task>.unmodifiable(_tasks);
  bool get isEmpty => _tasks.isEmpty;

  String get searchQuery => _searchQuery;
  TaskStatus? get homeStatusFilter => _homeStatusFilter;
  DateTime get selectedDate => _selectedDate;
  TimelineStatusFilter get timelineStatusFilter => _timelineStatusFilter;
  TaskCategory? get timelineCategoryFilter => _timelineCategoryFilter;

  bool get hasActiveTimelineFilter =>
      _timelineStatusFilter != TimelineStatusFilter.all ||
      _timelineCategoryFilter != null;

  bool get hasActiveHomeFilter =>
      _homeStatusFilter != null || _searchQuery.trim().isNotEmpty;

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  // --- Lifecycle --------------------------------------------------------

  /// Initial / retry load: shows the skeleton state.
  Future<void> load() async {
    _loadState = LoadState.loading;
    _loadError = null;
    notifyListeners();
    await _fetch();
  }

  /// Silent refresh (pull-to-refresh, auto re-sync): keeps current data
  /// visible while the request runs.
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await _fetch(preserveState: true);
  }

  /// Drops the in-memory list when the signed-in account changes, so one
  /// user's tasks can never leak into another user's session.
  void clear() {
    _tasks = <Task>[];
    _loadState = LoadState.loading;
    _loadError = null;
    _isOffline = false;
    _notice = null;
    _pendingSync = 0;
    _searchQuery = '';
    _homeStatusFilter = null;
    _timelineStatusFilter = TimelineStatusFilter.all;
    _timelineCategoryFilter = null;
    notifyListeners();
  }

  Future<void> _fetch({bool preserveState = false}) async {
    try {
      final FetchResult result = await _repository.loadTasks();
      _tasks = result.tasks
        ..sort(_bySchedule);
      _isOffline = result.isOffline;
      _notice = result.notice;
      _pendingSync = _repository.pendingSyncCount;
      _loadState = LoadState.loaded;
      _loadError = null;
    } on RepositoryException catch (error) {
      _loadError = error.message;
      if (!preserveState || _tasks.isEmpty) {
        _loadState = LoadState.failure;
      }
    } on Exception catch (error) {
      debugPrint('Unexpected load error: $error');
      _loadError = 'Terjadi kesalahan tak terduga. Coba lagi.';
      if (!preserveState || _tasks.isEmpty) {
        _loadState = LoadState.failure;
      }
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void _handleConnectivity(bool online) {
    if (!online) {
      if (!_isOffline) {
        _isOffline = true;
        _notice =
            'Anda sedang offline. Perubahan tetap tersimpan dan disinkronkan otomatis.';
        notifyListeners();
      }
      return;
    }
    if (_isOffline || _pendingSync > 0) {
      _isOffline = false;
      _notice = null;
      notifyListeners();
      // Connection restored → flush the outbox and pull fresh data.
      unawaited(refresh());
    }
  }

  // --- Mutations --------------------------------------------------------

  /// Creates a task (optimistic: applied locally first, remote best-effort).
  Future<ActionResult> addTask({
    required String title,
    required String description,
    required TaskCategory category,
    required TaskStatus status,
    required DateTime date,
    required String time,
    int estimateMinutes = 45,
    bool highPriority = false,
    String? tag,
    String? meta,
  }) async {
    final Task task = Task(
      id: 't_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      status: status,
      date: DateTime(date.year, date.month, date.day),
      time: time,
      estimateMinutes: estimateMinutes,
      highPriority: highPriority,
      tag: tag,
      meta: meta,
      updatedAt: DateTime.now(),
    );
    try {
      final MutationResult result = await _repository.createTask(task);
      _tasks = <Task>[..._tasks, result.task]..sort(_bySchedule);
      _pendingSync = _repository.pendingSyncCount;
      if (_pendingSync > 0) _isOffline = true;
      notifyListeners();
      return ActionResult(result.synced
          ? MutationOutcome.success
          : MutationOutcome.successOffline);
    } on RepositoryException catch (error) {
      return ActionResult(MutationOutcome.failure, error.message);
    }
  }

  /// Replaces a task with an edited copy.
  Future<ActionResult> updateTask(Task task) async {
    try {
      final MutationResult result = await _repository.updateTask(task);
      _replaceLocal(result.task);
      _pendingSync = _repository.pendingSyncCount;
      if (_pendingSync > 0) _isOffline = true;
      notifyListeners();
      return ActionResult(result.synced
          ? MutationOutcome.success
          : MutationOutcome.successOffline);
    } on RepositoryException catch (error) {
      return ActionResult(MutationOutcome.failure, error.message);
    }
  }

  /// Optimistic done/undone toggle with rollback on local storage failure.
  Future<ActionResult> toggleDone(Task task) async {
    final TaskStatus next = task.isDone
        ? (task.progress > 0 && task.progress < 100
            ? TaskStatus.inProgress
            : TaskStatus.todo)
        : TaskStatus.done;
    final Task updated =
        task.copyWith(status: next, updatedAt: DateTime.now());

    _replaceLocal(updated);
    notifyListeners();
    try {
      final MutationResult result = await _repository.updateTask(updated);
      _replaceLocal(result.task);
      _pendingSync = _repository.pendingSyncCount;
      if (_pendingSync > 0) _isOffline = true;
      notifyListeners();
      return ActionResult(result.synced
          ? MutationOutcome.success
          : MutationOutcome.successOffline);
    } on RepositoryException catch (error) {
      _replaceLocal(task); // roll back
      notifyListeners();
      return ActionResult(MutationOutcome.failure, error.message);
    }
  }

  /// Optimistic delete with rollback on local storage failure.
  Future<ActionResult> deleteTask(Task task) async {
    final List<Task> backup = List<Task>.from(_tasks);
    _tasks = _tasks.where((Task t) => t.id != task.id).toList();
    notifyListeners();
    try {
      final MutationResult result = await _repository.deleteTask(task);
      _pendingSync = _repository.pendingSyncCount;
      if (_pendingSync > 0) _isOffline = true;
      notifyListeners();
      return ActionResult(result.synced
          ? MutationOutcome.success
          : MutationOutcome.successOffline);
    } on RepositoryException catch (error) {
      _tasks = backup..sort(_bySchedule);
      notifyListeners();
      return ActionResult(MutationOutcome.failure, error.message);
    }
  }

  void _replaceLocal(Task task) {
    final int index = _tasks.indexWhere((Task t) => t.id == task.id);
    if (index >= 0) {
      _tasks = List<Task>.from(_tasks)..[index] = task;
    } else {
      _tasks = <Task>[..._tasks, task]..sort(_bySchedule);
    }
  }

  // --- Filter setters ---------------------------------------------------

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() => setSearchQuery('');

  void toggleHomeStatusFilter(TaskStatus? status) {
    _homeStatusFilter = _homeStatusFilter == status ? null : status;
    notifyListeners();
  }

  void clearHomeFilter() {
    _homeStatusFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void shiftWeek(int days) =>
      selectDate(_selectedDate.add(Duration(days: days)));

  void setTimelineStatusFilter(TimelineStatusFilter filter) {
    if (_timelineStatusFilter == filter) return;
    _timelineStatusFilter = filter;
    notifyListeners();
  }

  void setTimelineCategoryFilter(TaskCategory? category) {
    if (_timelineCategoryFilter == category) return;
    _timelineCategoryFilter = category;
    notifyListeners();
  }

  void resetTimelineFilters() {
    _timelineStatusFilter = TimelineStatusFilter.all;
    _timelineCategoryFilter = null;
    notifyListeners();
  }

  // --- Derived data -----------------------------------------------------

  DateTime get _today => DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day);

  /// Tasks scheduled for today, sorted by time.
  List<Task> get todayTasks => _tasks
      .where((Task t) => t.happensOn(_today))
      .toList()
    ..sort(_bySchedule);

  /// Horizontal "Tugas Hari Ini" carousel: up to 3 of today's tasks.
  List<Task> get featuredTasks {
    final List<Task> today = todayTasks;
    final List<Task> open = today.where((Task t) => !t.isDone).toList();
    final List<Task> done = today.where((Task t) => t.isDone).toList();
    return <Task>[...open, ...done].take(3).toList();
  }

  /// "Aktivitas Prioritas" list: today's tasks honouring search + status
  /// filter.
  List<Task> get homePriorityTasks {
    List<Task> list = todayTasks;
    if (_homeStatusFilter != null) {
      list =
          list.where((Task t) => t.status == _homeStatusFilter).toList();
    }
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((Task t) =>
              t.title.toLowerCase().contains(query) ||
              t.description.toLowerCase().contains(query) ||
              t.tag!.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  /// Counts shown under the three home status nodes (whole dataset).
  Map<TaskStatus, int> get statusCounts => <TaskStatus, int>{
        for (final TaskStatus status in TaskStatus.values)
          status: _tasks.where((Task t) => t.status == status).length,
      };

  /// "Kamu memiliki N tugas bulan ini".
  int get monthTaskCount => _tasks
      .where((Task t) =>
          t.date.month == _today.month && t.date.year == _today.year)
      .length;

  /// Timeline feed for the selected day, honouring both filter rows.
  List<Task> get timelineTasks {
    List<Task> list =
        _tasks.where((Task t) => t.happensOn(_selectedDate)).toList()
          ..sort(_bySchedule);
    switch (_timelineStatusFilter) {
      case TimelineStatusFilter.completed:
        list = list.where((Task t) => t.isDone).toList();
      case TimelineStatusFilter.uncompleted:
        list = list.where((Task t) => !t.isDone).toList();
      case TimelineStatusFilter.all:
        break;
    }
    if (_timelineCategoryFilter != null) {
      list = list
          .where((Task t) => t.category == _timelineCategoryFilter)
          .toList();
    }
    return list;
  }

  /// Status counts for the selected day (before filtering, so chip badges
  /// always show the full picture).
  Map<TimelineStatusFilter, int> get timelineStatusCounts {
    final List<Task> day = _tasks.where((Task t) => t.happensOn(_selectedDate)).toList();
    final int completed = day.where((Task t) => t.isDone).length;
    return <TimelineStatusFilter, int>{
      TimelineStatusFilter.all: day.length,
      TimelineStatusFilter.completed: completed,
      TimelineStatusFilter.uncompleted: day.length - completed,
    };
  }

  /// Category counts for the selected day (before filtering).
  Map<TaskCategory, int> get timelineCategoryCounts {
    final Map<TaskCategory, int> counts = <TaskCategory, int>{
      for (final TaskCategory c in TaskCategory.values) c: 0,
    };
    for (final Task t in _tasks.where((Task t) => t.happensOn(_selectedDate))) {
      counts[t.category] = (counts[t.category] ?? 0) + 1;
    }
    return counts;
  }

  int get timelineDayTotal =>
      _tasks.where((Task t) => t.happensOn(_selectedDate)).length;

  /// Analytics snapshot.
  TaskStats get stats => TaskStats.from(_tasks);

  Task? taskById(String id) {
    for (final Task t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  static int _bySchedule(Task a, Task b) {
    final int byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.time.compareTo(b.time);
  }
}