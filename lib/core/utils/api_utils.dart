import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/models/models.dart';

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://task-app-api-qhip.onrender.com';
  static const String apiPath = '/api';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

Future<DashboardResponse> getDashboardData() async {
  try {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.apiPath}/task/dashboard',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardResponse.fromJson(json);
    } else {
      throw ApiException(
        'Failed to fetch dashboard data',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<ProjectResponse> getProjects() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.apiPath}/project'),
      headers: {'Content-Type': 'application/json'},
    );

    print('projects: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ProjectResponse.fromJson(json);
    } else {
      throw ApiException(
        'Failed to fetch projects',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<TaskGroupResponse> getTaskGroups() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.apiPath}/task-group'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return TaskGroupResponse.fromJson(json);
    } else {
      throw ApiException(
        'Failed to fetch task groups',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<CreateTaskResponse> createTask({
  required int taskGroupId,
  required int projectId,
  required String projectTitle,
  required String title,
  String? description,
  String? startedAt,
  String? endedAt,
  String status = 'pending',
}) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.apiPath}/task/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'taskGroupId': taskGroupId,
        'projectId': projectId,
        'projectTitle': projectTitle,
        'title': title,
        'description': description,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'status': status,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CreateTaskResponse.fromJson(json);
    } else {
      throw ApiException(
        'Failed to create task',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}
