import 'package:flutter/foundation.dart';
import '../../data/utils/api_service.dart';

class GuestProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _guestKey;
  bool _isLoading = false;
  bool _isInitializing = false;
  String? _error;

  String? get guestKey => _guestKey ?? _apiService.getGuestKey();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGuestKey => guestKey != null;

  Future<void> initializeGuestKey() async {
    // Skip if already have key or already initializing
    if (hasGuestKey || _isInitializing) return;

    _isInitializing = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createGuest();
      if (response.success && response.data != null) {
        _guestKey = response.data;
        _apiService.setGuestKey(_guestKey!);
      } else {
        _error = response.message;
        debugPrint('Guest init failed: ${response.message}');
      }
    } catch (e, stack) {
      _error = e.toString();
      debugPrint('Guest init error: $e');
      debugPrint('Stack: $stack');
    } finally {
      _isLoading = false;
      _isInitializing = false;
      notifyListeners();
    }
  }

  void setGuestKey(String key) {
    _guestKey = key;
    _apiService.setGuestKey(key);
    notifyListeners();
  }

  void clearGuestKey() {
    _guestKey = null;
    notifyListeners();
  }
}