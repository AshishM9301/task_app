import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/models.dart';

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:5000';

  // static const String baseUrl = 'https://task-app-api-qhip.onrender.com';
  static const String apiPath = '/api';
  static const String guestKeyHeader = 'X-Guest-Key';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiClient {
  static const _guestKeyPrefsKey = 'guest_key';
  final http.Client _http;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Uri _uri(String path, {Map<String, String>? query}) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    return (query == null || query.isEmpty)
        ? uri
        : uri.replace(queryParameters: query);
  }

  Map<String, String> _baseHeaders() => const {
    'Content-Type': 'application/json',
  };

  Future<String> _ensureGuestKey() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_guestKeyPrefsKey);
    if (existing != null && existing.trim().isNotEmpty) return existing;

    final res = await _http.post(
      _uri('${ApiConstants.apiPath}/guest'),
      headers: _baseHeaders(),
    );
    final body = _tryDecodeJson(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _apiExceptionFromResponse(
        res.statusCode,
        body,
        fallback: 'Failed to create guest key',
      );
    }

    final guestKey = _extractGuestKey(body);
    if (guestKey == null || guestKey.trim().isEmpty) {
      throw const ApiException('Guest key response missing guestKey');
    }

    await prefs.setString(_guestKeyPrefsKey, guestKey);
    return guestKey;
  }

  Future<Map<String, String>> _headers({
    bool needsGuestKey = false,
    String? guestKey,
    String? idToken,
    Map<String, String>? extra,
  }) async {
    final headers = <String, String>{..._baseHeaders()};
    if (needsGuestKey) {
      final key = guestKey ?? await _ensureGuestKey();
      headers[ApiConstants.guestKeyHeader] = key;
    }
    if (idToken != null && idToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  dynamic _tryDecodeJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }

  String? _extractGuestKey(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final direct = decoded['guestKey'];
      if (direct is String) return direct;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final nested = data['guestKey'];
        if (nested is String) return nested;
      }
    }
    return null;
  }

  ApiException _apiExceptionFromResponse(
    int statusCode,
    dynamic decoded, {
    required String fallback,
  }) {
    // Common error shape:
    // { "error": { "status": 401, "message": "..." } }
    if (decoded is Map<String, dynamic>) {
      final err = decoded['error'];
      if (err is Map<String, dynamic>) {
        final msg = err['message'];
        final st = err['status'];
        if (msg is String) {
          return ApiException(msg, statusCode: (st is int) ? st : statusCode);
        }
      }

      final msg = decoded['message'];
      if (msg is String && msg.trim().isNotEmpty) {
        return ApiException(msg, statusCode: statusCode);
      }
    }
    return ApiException(fallback, statusCode: statusCode);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    bool needsGuestKey = false,
    String? guestKey,
    String? idToken,
  }) async {
    final res = await _http.get(
      _uri(path, query: query),
      headers: await _headers(
        needsGuestKey: needsGuestKey,
        guestKey: guestKey,
        idToken: idToken,
      ),
    );
    final decoded = _tryDecodeJson(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException('Invalid JSON response', statusCode: res.statusCode);
    }
    throw _apiExceptionFromResponse(
      res.statusCode,
      decoded,
      fallback: 'Request failed',
    );
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, String>? query,
    bool needsGuestKey = false,
    String? guestKey,
    String? idToken,
  }) async {
    final res = await _http.get(
      _uri(path, query: query),
      headers: await _headers(
        needsGuestKey: needsGuestKey,
        guestKey: guestKey,
        idToken: idToken,
      ),
    );
    final decoded = _tryDecodeJson(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is List<dynamic>) return decoded;
      throw ApiException('Invalid JSON response', statusCode: res.statusCode);
    }
    throw _apiExceptionFromResponse(
      res.statusCode,
      decoded,
      fallback: 'Request failed',
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? query,
    bool needsGuestKey = false,
    String? guestKey,
    String? idToken,
    Object? body,
  }) async {
    final res = await _http.post(
      _uri(path, query: query),
      headers: await _headers(
        needsGuestKey: needsGuestKey,
        guestKey: guestKey,
        idToken: idToken,
      ),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    final decoded = _tryDecodeJson(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException('Invalid JSON response', statusCode: res.statusCode);
    }
    throw _apiExceptionFromResponse(
      res.statusCode,
      decoded,
      fallback: 'Request failed',
    );
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    bool needsGuestKey = false,
    String? guestKey,
    String? idToken,
    Object? body,
  }) async {
    final res = await _http.patch(
      _uri(path),
      headers: await _headers(
        needsGuestKey: needsGuestKey,
        guestKey: guestKey,
        idToken: idToken,
      ),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    final decoded = _tryDecodeJson(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException('Invalid JSON response', statusCode: res.statusCode);
    }
    throw _apiExceptionFromResponse(
      res.statusCode,
      decoded,
      fallback: 'Request failed',
    );
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    bool needsGuestKey = false,
    String? guestKey,
    String? idToken,
  }) async {
    final res = await _http.delete(
      _uri(path),
      headers: await _headers(
        needsGuestKey: needsGuestKey,
        guestKey: guestKey,
        idToken: idToken,
      ),
    );
    final decoded = _tryDecodeJson(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException('Invalid JSON response', statusCode: res.statusCode);
    }
    throw _apiExceptionFromResponse(
      res.statusCode,
      decoded,
      fallback: 'Request failed',
    );
  }

  Future<String> getPlainText(String path) async {
    final res = await _http.get(_uri(path), headers: const {});
    if (res.statusCode >= 200 && res.statusCode < 300) return res.body;
    final decoded = _tryDecodeJson(res.body);
    throw _apiExceptionFromResponse(
      res.statusCode,
      decoded,
      fallback: 'Request failed',
    );
  }
}

final ApiClient apiClient = ApiClient();

Future<String> getHelloWorld() async {
  // Health endpoint is outside /api
  return apiClient.getPlainText('/test');
}

Future<String> ensureGuestKey() async {
  return apiClient._ensureGuestKey();
}

Future<DashboardResponse> getDashboardData() async {
  try {
    final json = await apiClient.getJson(
      '${ApiConstants.apiPath}/task/dashboard',
      needsGuestKey: true,
    );

    return DashboardResponse.fromJson(json);
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<ProjectResponse> getProjects() async {
  try {
    final json = await apiClient.getJson('${ApiConstants.apiPath}/project');
    return ProjectResponse.fromJson(json);
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<TaskGroupResponse> getTaskGroups() async {
  try {
    final json = await apiClient.getJson('${ApiConstants.apiPath}/task-group');
    return TaskGroupResponse.fromJson(json);
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> createTaskGroup({
  required Map<String, dynamic> body,
}) async {
  try {
    return await apiClient.postJson(
      '${ApiConstants.apiPath}/task-group/create',
      body: body,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<CreateTaskResponse> createTask({
  required int taskGroupId,
  int? projectId,
  String? projectTitle,
  required String title,
  String? description,
  String? startedAt,
  String? endedAt,
  String status = 'pending',
}) async {
  try {
    final json = await apiClient.postJson(
      '${ApiConstants.apiPath}/task/create',
      needsGuestKey: true,
      body: {
        'taskGroupId': taskGroupId,
        if (projectId != null) 'projectId': projectId,
        if (projectTitle != null) 'projectTitle': projectTitle,
        'title': title,
        if (description != null) 'description': description,
        if (startedAt != null) 'startedAt': startedAt,
        if (endedAt != null) 'endedAt': endedAt,
        'status': status,
      },
    );
    return CreateTaskResponse.fromJson(json);
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<TasksByDateResponse> getTasksByDate({
  required String date,
  String? status,
}) async {
  try {
    final json = await apiClient.getJson(
      '${ApiConstants.apiPath}/task/by-date',
      needsGuestKey: true,
      query: {'date': date, if (status != null) 'status': status},
    );
    return TasksByDateResponse.fromJson(json);
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<TaskHistoryResponse> getTaskHistory({
  required int page,
  required int limit,
  required String dateRange,
}) async {
  try {
    final json = await apiClient.getJson(
      '${ApiConstants.apiPath}/task/history',
      needsGuestKey: true,
      query: <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'dateRange': dateRange,
      },
    );
    return TaskHistoryResponse.fromJson(json);
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> getAllTasks() async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/task/all',
      needsGuestKey: true,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

// Firebase: Me
Future<Map<String, dynamic>> getMe({required String idToken}) async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/me',
      idToken: idToken,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> patchMe({
  required String idToken,
  String? displayName,
  String? photoUrl,
}) async {
  try {
    return await apiClient.patchJson(
      '${ApiConstants.apiPath}/me',
      idToken: idToken,
      body: {
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

// Firebase: Friends
Future<Map<String, dynamic>> searchFriends({
  required String idToken,
  required String q,
}) async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/friends/search',
      idToken: idToken,
      query: {'q': q},
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> requestFriend({
  required String idToken,
  required Map<String, dynamic> body,
}) async {
  try {
    return await apiClient.postJson(
      '${ApiConstants.apiPath}/friends/request',
      idToken: idToken,
      body: body,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> getIncomingFriendRequests({
  required String idToken,
}) async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/friends/requests/incoming',
      idToken: idToken,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> getOutgoingFriendRequests({
  required String idToken,
}) async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/friends/requests/outgoing',
      idToken: idToken,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> acceptFriendRequest({
  required String idToken,
  required String requestId,
}) async {
  try {
    return await apiClient.postJson(
      '${ApiConstants.apiPath}/friends/requests/$requestId/accept',
      idToken: idToken,
      body: const <String, dynamic>{},
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> rejectFriendRequest({
  required String idToken,
  required String requestId,
}) async {
  try {
    return await apiClient.postJson(
      '${ApiConstants.apiPath}/friends/requests/$requestId/reject',
      idToken: idToken,
      body: const <String, dynamic>{},
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> getFriends({required String idToken}) async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/friends',
      idToken: idToken,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> deleteFriend({
  required String idToken,
  required String friendUserId,
}) async {
  try {
    return await apiClient.deleteJson(
      '${ApiConstants.apiPath}/friends/$friendUserId',
      idToken: idToken,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

// Firebase + guestKey: Sharing
Future<Map<String, dynamic>> getTasksSharedWithMe({
  required String idToken,
}) async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/tasks/shared-with-me',
      idToken: idToken,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> shareTask({
  required String idToken,
  required String taskId,
  required Map<String, dynamic> body,
  String? guestKey,
}) async {
  try {
    return await apiClient.postJson(
      '${ApiConstants.apiPath}/tasks/$taskId/share',
      idToken: idToken,
      needsGuestKey: true,
      guestKey: guestKey,
      body: body,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> getTaskShares({
  required String idToken,
  required String taskId,
  String? guestKey,
}) async {
  try {
    return await apiClient.getJson(
      '${ApiConstants.apiPath}/tasks/$taskId/shares',
      idToken: idToken,
      needsGuestKey: true,
      guestKey: guestKey,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

Future<Map<String, dynamic>> deleteTaskShare({
  required String idToken,
  required String taskId,
  required String targetUserId,
  String? guestKey,
}) async {
  try {
    return await apiClient.deleteJson(
      '${ApiConstants.apiPath}/tasks/$taskId/shares/$targetUserId',
      idToken: idToken,
      needsGuestKey: true,
      guestKey: guestKey,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}
