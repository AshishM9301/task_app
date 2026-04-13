enum TaskPriority { low, medium, high }

enum TaskType { work, personal, low }

enum TaskStatus { pending, inProgress, in_progress, completed, failed }

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime startedAt;
  final DateTime endedAt;
  final String status;
  final TaskPriority? priority;
  final TaskType? taskType;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? taskGroupId;
  final String? projectTitle;
  final int? projectId;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.startedAt,
    required this.endedAt,
    required this.status,
    this.priority,
    this.taskType,
    required this.createdAt,
    this.completedAt,
    this.taskGroupId,
    this.projectTitle,
    this.projectId,
  });

  factory Task.fromApiJson(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] ?? json['Id'] ?? 0).toString(),
      title: json['title'] ?? json['Title'] ?? '',
      description: json['description'] ?? json['Description'],
      startedAt: _parseDate(json['started_at'] ?? json['startedAt'] ?? json['StartedAt']),
      endedAt: _parseDate(json['ended_at'] ?? json['endedAt'] ?? json['EndedAt']),
      status: json['status'] ?? json['Status'] ?? 'pending',
      createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? json['CreatedAt']),
      completedAt: json['completed_at'] ?? json['completedAt'] ?? json['CompletedAt'] != null
          ? _parseDate(json['completed_at'] ?? json['completedAt'] ?? json['CompletedAt'])
          : null,
      taskGroupId: json['task_group_id'] ?? json['taskGroupId'] ?? json['TaskGroupId'],
      projectTitle: json['project_title'] ?? json['projectTitle'] ?? json['ProjectTitle'],
      projectId: json['project_id'] ?? json['projectId'] ?? json['ProjectId'],
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  factory Task.fromDbMap(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] ?? 0).toString(),
      title: json['title'] ?? '',
      description: json['description'],
      startedAt: _parseDate(json['started_at']),
      endedAt: _parseDate(json['ended_at']),
      status: json['status'] ?? 'pending',
      createdAt: _parseDate(json['created_at']),
      completedAt: json['completed_at'] != null ? _parseDate(json['completed_at']) : null,
      taskGroupId: json['task_group_id'],
      projectTitle: json['project_title'],
      projectId: json['project_id'],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startedAt,
    DateTime? endedAt,
    String? status,
    TaskPriority? priority,
    TaskType? taskType,
    DateTime? createdAt,
    DateTime? completedAt,
    int? taskGroupId,
    String? projectTitle,
    int? projectId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      taskType: taskType ?? this.taskType,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      taskGroupId: taskGroupId ?? this.taskGroupId,
      projectTitle: projectTitle ?? this.projectTitle,
      projectId: projectId ?? this.projectId,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
}
