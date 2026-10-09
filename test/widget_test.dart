// Smoke test for the KeepGrinding shell: boots the real provider stack with
// in-memory fakes and verifies the bottom-nav wiring renders.
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:keepgrinding/data/models/task.dart';
import 'package:keepgrinding/data/repositories/task_repository.dart';
import 'package:keepgrinding/data/services/local_storage_service.dart';
import 'package:keepgrinding/main.dart';
import 'package:keepgrinding/state/task_provider.dart';

class _FakeRepository implements TaskRepository {
  _FakeRepository(this.tasks);

  List<Map<String, dynamic>> tasks;

  @override
  Future<FetchResult> loadTasks() async =>
      FetchResult(tasks: <Task>[], isOffline: true);

  @override
  Future<MutationResult> createTask(task) async =>
      MutationResult(task: task, synced: false);

  @override
  Future<MutationResult> updateTask(task) async =>
      MutationResult(task: task, synced: false);

  @override
  Future<MutationResult> deleteTask(task) async =>
      MutationResult(task: task, synced: false);

  @override
  int get pendingSyncCount => 0;
}

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Touch the real storage service so its contract stays covered.
  LocalStorageService(prefs);
  await tester.pumpWidget(
    ChangeNotifierProvider<TaskProvider>(
      create: (_) =>
          TaskProvider(repository: _FakeRepository([]))..load(),
      child: const KeepGrindingApp(),
    ),
  );
  // Shimmer skeletons repeat forever, so use bounded pumps instead of
  // pumpAndSettle (which would time out waiting for animation to end).
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('boots shell with header + bottom nav', (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.text('KeepGrinding'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('bottom nav switches screens', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Analytics'));
    await _settle(tester);
    expect(find.text('Progres Mingguan'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await _settle(tester);
    expect(find.text('PREFERENSI'), findsOneWidget);

    await tester.tap(find.text('Timeline'));
    await _settle(tester);
    expect(find.text('Tambah'), findsOneWidget);
  });
}

