import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/firebase/firebase_auth_service.dart';
import '../data/utils/api_service.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuthService? _authService;
  bool _isInitialized = false;

  User? get user => _authService?.currentUser;
  bool get isAuthenticated => user != null;
  bool get isLoading => false;
  String? get error => null;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    try {
      _authService = FirebaseAuthService();
      _authService!.authStateChanges.listen((firebaseUser) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthProvider init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _notifyListeners() {
    notifyListeners();
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (_authService == null) return;

    try {
      final result = await _authService!.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (result.success) {
        await _syncWithBackend();
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
    }

    notifyListeners();
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (_authService == null) return;

    try {
      final result = await _authService!.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      if (result.success) {
        await _syncWithBackend();
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
    }

    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    if (_authService == null) return;

    try {
      final result = await _authService!.signInWithGoogle();

      if (result.success) {
        await _syncWithBackend();
      }
    } catch (e) {
      debugPrint('Google sign in error: $e');
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    if (_authService == null) return;
    try {
      await _authService!.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
    notifyListeners();
  }

  Future<void> _syncWithBackend() async {
    final currentUser = user;
    if (currentUser == null) return;

    try {
      final idToken = await currentUser.getIdToken();
      if (idToken != null) {
        ApiService().setFirebaseToken(idToken);
      }
    } catch (e) {
      debugPrint('Failed to sync with backend: $e');
    }
  }

  void clearError() {
    notifyListeners();
  }
}
