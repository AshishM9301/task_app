class TaskHistoryApiTask {
  final int id;
  final int taskGroupId;
  final int projectId;
  final String projectTitle;
  final String title;
  final String? description;
  final String? startedAt;
  final String? endedAt;
  final String status;
  final String createdAt;

  const TaskHistoryApiTask({
    required this.id,
    required this.taskGroupId,
    required this.projectId,
    required this.projectTitle,
    required this.title,
    this.description,
    this.startedAt,
    this.endedAt,
    required this.status,
    required this.createdAt,
  });

  factory TaskHistoryApiTask.fromJson(Map<String, dynamic> json) {
    return TaskHistoryApiTask(
      id: json['id'] as int,
      taskGroupId: json['task_group_id'] as int,
      projectId: json['project_id'] as int,
      projectTitle: json['project_title'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startedAt: json['started_at'] as String?,
      endedAt: json['ended_at'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

class TaskHistoryPagination {
  final int page;
  final int limit;
  final int totalTasks;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const TaskHistoryPagination({
    required this.page,
    required this.limit,
    required this.totalTasks,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory TaskHistoryPagination.fromJson(Map<String, dynamic> json) {
    return TaskHistoryPagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalTasks: json['totalTasks'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
    );
  }
}

class TaskHistoryData {
  final List<TaskHistoryApiTask> tasks;
  final TaskHistoryPagination pagination;

  const TaskHistoryData({required this.tasks, required this.pagination});

  factory TaskHistoryData.fromJson(Map<String, dynamic> json) {
    return TaskHistoryData(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TaskHistoryApiTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: TaskHistoryPagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

class TaskHistoryResponse {
  final bool success;
  final String message;
  final TaskHistoryData data;

  const TaskHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TaskHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TaskHistoryResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TaskHistoryData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

