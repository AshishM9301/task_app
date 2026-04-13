import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});
}

class ApiService {
  // Android emulator uses 10.0.2.2 to reach host localhost
  // iOS simulator uses localhost
  // For release builds or real device, change this
  static String get baseUrl {
    try {
      print('baseUrl: ${dotenv.env['API_BASE_URL']}');
      return dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:5000/api';
    } catch (_) {
      return 'http://127.0.0.1:5000/api';
    }
  }
  String? _guestKey;
  String? _firebaseToken;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  void setGuestKey(String key) {
    _guestKey = key;
  }

  String? getGuestKey() => _guestKey;

  void setFirebaseToken(String token) {
    _firebaseToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_guestKey != null) {
      headers['x-guest-key'] = _guestKey!;
    }
    if (_firebaseToken != null) {
      headers['Authorization'] = 'Bearer $_firebaseToken';
    }
    return headers;
  }

  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic data) parser,
  ) async {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        success: body['success'] ?? true,
        message: body['message'] ?? '',
        data: body['data'] != null ? parser(body['data']) : null,
      );
    } else {
      throw ApiException(
        body['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }
  }

  // Auth Endpoints
  Future<ApiResponse<Map<String, dynamic>>> authWithFirebase() async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/firebase'),
      headers: _headers,
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> patchMe({
    String? displayName,
    String? photoUrl,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
      body: jsonEncode({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      }),
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  // Guest Endpoints
  Future<ApiResponse<String>> createGuest() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/guest'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _handleResponse(response, (data) => data['guestKey'] as String);
    } on Exception catch (e) {
      print('createGuest HTTP error: $e');
      return ApiResponse(success: false, message: 'Server unreachable: $e');
    }
  }

  // Task Group Endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllTaskGroups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/task-group'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createTaskGroup({
    required String title,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/task-group'),
      headers: _headers,
      body: jsonEncode({'title': title}),
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  // Task Endpoints
  Future<ApiResponse<Map<String, dynamic>>> createTask({
    required String title,
    required String description,
    required int taskGroupId,
    required String projectTitle,
    int? projectId,
    required DateTime startedAt,
    required DateTime endedAt,
    required String status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/task/create'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'taskGroupId': taskGroupId,
        'projectTitle': projectTitle,
        if (projectId != null) 'projectId': projectId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'status': status,
      }),
    );
    print('response: ${response.body}');
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAllTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/task'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTasksByDate({
    required String date,
    String? status,
  }) async {
    final queryParams = {
      'date': date,
      if (status != null) 'status': status,
    };
    final response = await http.get(
      Uri.parse('${baseUrl}/task/by-date?${Uri(queryParameters: queryParams).query}'),
      headers: _headers,
    );
    print('response: ${response.body}');
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTaskHistory({
    int page = 1,
    int limit = 10,
    String dateRange = 'all',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'dateRange': dateRange,
    };
    final response = await http.get(
      Uri.parse('${baseUrl}/task/history?${Uri(queryParameters: queryParams).query}'),
      headers: _headers,
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/task/dashboard'),
      headers: _headers,
    );
    print('url: ${Uri.parse('$baseUrl/task/dashboard').toString()}');
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTask({
    required int taskId,
    String? title,
    String? description,
    DateTime? startedAt,
    DateTime? endedAt,
    int? taskGroupId,
    String? projectTitle,
    int? projectId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/task/$taskId'),
      headers: _headers,
      body: jsonEncode({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (startedAt != null) 'startedAt': startedAt.toIso8601String(),
        if (endedAt != null) 'endedAt': endedAt.toIso8601String(),
        if (taskGroupId != null) 'taskGroupId': taskGroupId,
        if (projectTitle != null) 'projectTitle': projectTitle,
        if (projectId != null) 'projectId': projectId,
      }),
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTaskStatus({
    required int taskId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/task/$taskId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  // Project Endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/project'),
      headers: _headers,
    );
    print('response: ${response.body}');
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createProject({
    required String title,
    String? slug,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/project'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        if (slug != null) 'slug': slug,
      }),
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  // Friends Endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> searchFriends(String query) async {
    final response = await http.get(
      Uri.parse('${baseUrl}/friends/search?q=$query'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> sendFriendRequest(int targetUserId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/request'),
      headers: _headers,
      body: jsonEncode({'targetUserId': targetUserId}),
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listIncomingRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends/requests/incoming'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listOutgoingRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends/requests/outgoing'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<void>> acceptFriendRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/request/$requestId/accept'),
      headers: _headers,
    );
    return _handleResponse(response, (_) => null);
  }

  Future<ApiResponse<void>> rejectFriendRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/request/$requestId/reject'),
      headers: _headers,
    );
    return _handleResponse(response, (_) => null);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listFriends() async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<void>> removeFriend(int friendUserId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/friends/$friendUserId'),
      headers: _headers,
    );
    return _handleResponse(response, (_) => null);
  }

  // Task Share Endpoints
  Future<ApiResponse<Map<String, dynamic>>> shareTask({
    required int taskId,
    required int targetUserId,
    String permission = 'read',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/task/$taskId/share'),
      headers: _headers,
      body: jsonEncode({
        'targetUserId': targetUserId,
        'permission': permission,
      }),
    );
    return _handleResponse(response, (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listTaskShares(int taskId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/task/$taskId/shares'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<ApiResponse<void>> revokeTaskShare({
    required int taskId,
    required int targetUserId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/task/$taskId/shares/$targetUserId'),
      headers: _headers,
    );
    return _handleResponse(response, (_) => null);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listSharedWithMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/task/shared-with-me'),
      headers: _headers,
    );
    return _handleResponse(
      response,
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }
}