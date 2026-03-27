class Project {
  final int id;
  final String title;
  final String slug;

  const Project({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
    };
  }
}

class ProjectResponse {
  final bool success;
  final String message;
  final List<Project> data;

  const ProjectResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TaskGroupSimple {
  final int id;
  final String title;
  final String slug;

  const TaskGroupSimple({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory TaskGroupSimple.fromJson(Map<String, dynamic> json) {
    return TaskGroupSimple(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
    };
  }
}

class TaskGroupResponse {
  final bool success;
  final String message;
  final List<TaskGroupSimple> data;

  const TaskGroupResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TaskGroupResponse.fromJson(Map<String, dynamic> json) {
    return TaskGroupResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => TaskGroupSimple.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreatedTask {
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

  const CreatedTask({
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

  factory CreatedTask.fromJson(Map<String, dynamic> json) {
    return CreatedTask(
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

class CreateTaskResponse {
  final bool success;
  final String message;
  final CreatedTask data;

  const CreateTaskResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateTaskResponse.fromJson(Map<String, dynamic> json) {
    return CreateTaskResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: CreatedTask.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}