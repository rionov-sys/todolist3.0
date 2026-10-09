/// Task lifecycle states — matches the three home "category nodes".
enum TaskStatus {
  todo,
  inProgress,
  done;

  static TaskStatus fromName(String? value) => switch (value) {
        'inProgress' => TaskStatus.inProgress,
        'done' => TaskStatus.done,
        _ => TaskStatus.todo,
      };
}

/// Content groups used by category filters and statistics.
enum TaskCategory {
  meeting,
  wireframe,
  ui,
  dev;

  static TaskCategory fromName(String? value) => switch (value) {
        'wireframe' => TaskCategory.wireframe,
        'ui' => TaskCategory.ui,
        'dev' => TaskCategory.dev,
        _ => TaskCategory.meeting,
      };

  /// Registry key consumed by `CategoryVisualsRegistry.of`.
  String get visualsKey => name;
}

/// Domain entity for a single task item.
///
/// Serialization is intentionally defensive: unknown status/category strings
/// coming from a backend degrade to safe defaults instead of crashing the
/// whole list.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.date,
    required this.time,
    this.estimateMinutes = 45,
    this.progress = 0,
    this.highPriority = false,
    this.tag,
    this.meta,
    this.points = 10,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskStatus status;

  /// Scheduled day (time-of-day stripped).
  final DateTime date;

  /// Scheduled time as a 24h `HH:mm` string.
  final String time;

  final int estimateMinutes;

  /// Completion percentage shown on featured cards (0–100).
  final int progress;

  /// Drives the coral "highlighted" timeline treatment.
  final bool highPriority;

  /// Optional badge label; falls back to the category's short label.
  final String? tag;

  /// Footer metadata, e.g. "Google Meet Room 2".
  final String? meta;

  /// Productivity points awarded when completed.
  final int points;

  final DateTime? updatedAt;

  bool get isDone => status == TaskStatus.done;

  bool happensOn(DateTime day) =>
      date.year == day.year && date.month == day.month && date.day == day.day;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskStatus? status,
    DateTime? date,
    String? time,
    int? estimateMinutes,
    int? progress,
    bool? highPriority,
    String? Function()? tag,
    String? Function()? meta,
    int? points,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      date: date ?? this.date,
      time: time ?? this.time,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      progress: progress ?? this.progress,
      highPriority: highPriority ?? this.highPriority,
      tag: tag != null ? tag() : this.tag,
      meta: meta != null ? meta() : this.meta,
      points: points ?? this.points,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final DateTime date =
        DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now();
    return Task(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Tugas tanpa judul',
      description: (json['description'] as String?) ?? '',
      category: TaskCategory.fromName(json['category'] as String?),
      status: TaskStatus.fromName(json['status'] as String?),
      date: DateTime(date.year, date.month, date.day),
      time: (json['time'] as String?) ?? '09:00',
      estimateMinutes: (json['estimateMinutes'] as num?)?.toInt() ?? 45,
      progress: ((json['progress'] as num?)?.toInt() ?? 0).clamp(0, 100),
      highPriority: (json['highPriority'] as bool?) ?? false,
      tag: json['tag'] as String?,
      meta: json['meta'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 10,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'status': status.name,
        'date':
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': time,
        'estimateMinutes': estimateMinutes,
        'progress': progress,
        'highPriority': highPriority,
        if (tag != null) 'tag': tag,
        if (meta != null) 'meta': meta,
        'points': points,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  @override
  bool operator ==(Object other) => other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;
}