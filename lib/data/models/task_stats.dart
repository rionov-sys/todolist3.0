import '../models/task.dart';

/// Per-category completion entry for the "Kategori Paling Produktif" list.
class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.doneCount,
    required this.share,
  });

  final TaskCategory category;
  final int doneCount;

  /// Fraction of all completed tasks (0–1).
  final double share;
}

/// Snapshot of every number rendered on the Analytics screen, derived purely
/// from the task list (no server round-trip needed).
class TaskStats {
  const TaskStats({
    required this.total,
    required this.done,
    required this.inProgress,
    required this.todo,
    required this.overdue,
    required this.weekTotal,
    required this.weekDone,
    required this.weekPercent,
    required this.lastWeekPercent,
    required this.trend,
    required this.weekSeries,
    required this.streakDays,
    required this.points,
    required this.categoryStats,
  });

  final int total;
  final int done;
  final int inProgress;
  final int todo;

  /// Tasks still `todo` whose scheduled day is in the past.
  final int overdue;

  final int weekTotal;
  final int weekDone;
  final int weekPercent;
  final int lastWeekPercent;

  /// `weekPercent - lastWeekPercent` (null-safe; 0 when no baseline).
  final int trend;

  /// Completed tasks per weekday for the current week (Mon → Sun).
  final List<int> weekSeries;

  /// Consecutive days ending today (or yesterday) with ≥ 1 completed task.
  final int streakDays;

  final int points;
  final List<CategoryStat> categoryStats;

  factory TaskStats.from(List<Task> tasks, {DateTime? now}) {
    final DateTime today = _dateOnly(now ?? DateTime.now());
    final int weekStartOffset = (today.weekday - 1) % 7; // Monday = 0
    final DateTime weekStart = today.subtract(Duration(days: weekStartOffset));
    final DateTime lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final DateTime nextWeekStart = weekStart.add(const Duration(days: 7));

    bool onOrAfter(DateTime d, DateTime boundary) =>
        !d.isBefore(boundary);

    final List<Task> weekTasks = tasks
        .where((Task t) =>
            onOrAfter(t.date, weekStart) && t.date.isBefore(nextWeekStart))
        .toList();
    final List<Task> lastWeekTasks = tasks
        .where((Task t) =>
            onOrAfter(t.date, lastWeekStart) && t.date.isBefore(weekStart))
        .toList();

    int percentOf(List<Task> list) => list.isEmpty
        ? 0
        : (list.where((Task t) => t.isDone).length * 100 / list.length).round();

    final int weekDone =
        weekTasks.where((Task t) => t.isDone).length;
    final int streak = _streak(tasks, today);

    final List<int> series = List<int>.generate(7, (int i) {
      final DateTime day = weekStart.add(Duration(days: i));
      return tasks
          .where((Task t) => t.happensOn(day) && t.isDone)
          .length;
    });

    final int done = tasks.where((Task t) => t.isDone).length;
    final Map<TaskCategory, int> byCategory = <TaskCategory, int>{
      for (final TaskCategory c in TaskCategory.values) c: 0,
    };
    for (final Task t in tasks.where((Task t) => t.isDone)) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + 1;
    }
    final List<CategoryStat> categoryStats = byCategory.entries
        .map<CategoryStat>(
          (MapEntry<TaskCategory, int> e) => CategoryStat(
            category: e.key,
            doneCount: e.value,
            share: done == 0 ? 0 : e.value / done,
          ),
        )
        .where((CategoryStat s) => s.doneCount > 0)
        .toList()
      ..sort((CategoryStat a, CategoryStat b) => b.doneCount.compareTo(a.doneCount));

    return TaskStats(
      total: tasks.length,
      done: done,
      inProgress: tasks.where((Task t) => t.status == TaskStatus.inProgress).length,
      todo: tasks.where((Task t) => t.status == TaskStatus.todo).length,
      overdue: tasks
          .where((Task t) => t.status == TaskStatus.todo && t.date.isBefore(today))
          .length,
      weekTotal: weekTasks.length,
      weekDone: weekDone,
      weekPercent: percentOf(weekTasks),
      lastWeekPercent: percentOf(lastWeekTasks),
      trend: lastWeekTasks.isEmpty
          ? 0
          : percentOf(weekTasks) - percentOf(lastWeekTasks),
      weekSeries: series,
      streakDays: streak,
      points: tasks.where((Task t) => t.isDone).fold<int>(
            0,
            (int sum, Task t) => sum + t.points,
          ),
      categoryStats: categoryStats,
    );
  }

  static int _streak(List<Task> tasks, DateTime today) {
    bool hasDoneOn(DateTime day) =>
        tasks.any((Task t) => t.happensOn(day) && t.isDone);

    DateTime cursor = today;
    if (!hasDoneOn(cursor)) {
      // Grace period: yesterday still counts until today's first completion.
      cursor = today.subtract(const Duration(days: 1));
      if (!hasDoneOn(cursor)) return 0;
    }
    int streak = 0;
    while (hasDoneOn(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}