import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/models/models.dart';

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:5000';
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
