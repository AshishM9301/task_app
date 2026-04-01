class DashboardOverview {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final int completedPercentage;
  final int inProgressPercentage;
  final int pendingPercentage;

  const DashboardOverview({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
    required this.completedPercentage,
    required this.inProgressPercentage,
    required this.pendingPercentage,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalTasks: json['totalTasks'] as int,
      completedTasks: json['completedTasks'] as int,
      inProgressTasks: json['inProgressTasks'] as int,
      pendingTasks: json['pendingTasks'] as int,
      completedPercentage: json['completedPercentage'] as int,
      inProgressPercentage: json['inProgressPercentage'] as int,
      pendingPercentage: json['pendingPercentage'] as int,
    );
  }
}

class InProgressTask {
  final int id;
  final String title;
  final int taskGroupId;
  final String taskGroupTitle;
  final String taskGroupSlug;
  final String? description;
  final String? dueDate;
  final String? priority;
  final String? status;
  final String? createdAt;
  final String? completedAt;

  const InProgressTask({
    required this.id,
    required this.title,
    required this.taskGroupId,
    required this.taskGroupTitle,
    required this.taskGroupSlug,
    this.description,
    this.dueDate,
    this.priority,
    this.status,
    this.createdAt,
    this.completedAt,
  });

  factory InProgressTask.fromJson(Map<String, dynamic> json) {
    return InProgressTask(
      id: json['id'] as int,
      title: json['title'] as String,
      taskGroupId: json['task_group_id'] as int,
      taskGroupTitle: json['task_group_title'] as String,
      taskGroupSlug: json['task_group_slug'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }
}

class TaskGroup {
  final int id;
  final String title;
  final String slug;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final int completedPercentage;

  const TaskGroup({
    required this.id,
    required this.title,
    required this.slug,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
    required this.completedPercentage,
  });

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      totalTasks: json['totalTasks'] as int,
      completedTasks: json['completedTasks'] as int,
      inProgressTasks: json['inProgressTasks'] as int,
      pendingTasks: json['pendingTasks'] as int,
      completedPercentage: json['completedPercentage'] as int,
    );
  }
}

class DashboardData {
  final DashboardOverview overview;
  final List<InProgressTask> inProgressTasks;
  final List<TaskGroup> taskGroups;

  const DashboardData({
    required this.overview,
    required this.inProgressTasks,
    required this.taskGroups,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      overview: DashboardOverview.fromJson(json['overview'] as Map<String, dynamic>),
      inProgressTasks: (json['inProgressTasks'] as List<dynamic>)
          .map((e) => InProgressTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      taskGroups: (json['taskGroups'] as List<dynamic>)
          .map((e) => TaskGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardResponse {
  final bool success;
  final String message;
  final DashboardData data;

  const DashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: DashboardData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class TaskByDate {
  final int id;
  final int taskGroupId;
  final int projectId;
  final String projectTitle;
  final String title;
  final String? description;
  final String? startedAt;
  final String? endedAt;
  final String status;
  final String? createdAt;

  const TaskByDate({
    required this.id,
    required this.taskGroupId,
    required this.projectId,
    required this.projectTitle,
    required this.title,
    this.description,
    this.startedAt,
    this.endedAt,
    required this.status,
    this.createdAt,
  });

  factory TaskByDate.fromJson(Map<String, dynamic> json) {
    return TaskByDate(
      id: json['id'] as int,
      taskGroupId: json['task_group_id'] as int,
      projectId: json['project_id'] as int,
      projectTitle: json['project_title'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startedAt: json['started_at'] as String?,
      endedAt: json['ended_at'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );
  }
}

class TasksByDateData {
  final List<TaskByDate> tasks;

  const TasksByDateData({required this.tasks});

  factory TasksByDateData.fromJson(Map<String, dynamic> json) {
    return TasksByDateData(
      tasks: (json['data'] as List<dynamic>)
          .map((e) => TaskByDate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TasksByDateResponse {
  final bool success;
  final String message;
  final TasksByDateData data;

  const TasksByDateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TasksByDateResponse.fromJson(Map<String, dynamic> json) {
    return TasksByDateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TasksByDateData.fromJson(json),
    );
  }
}
