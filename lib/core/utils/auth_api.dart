import 'api_utils.dart';

Future<void> syncFirebaseUserWithApi({required String idToken}) async {
  // POST /api/auth/firebase (Firebase identity)
  try {
    await apiClient.postJson(
      '${ApiConstants.apiPath}/auth/firebase',
      idToken: idToken,
      body: const <String, dynamic>{},
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: ${e.toString()}');
  }
}

