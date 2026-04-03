import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/api_utils.dart';
import '../../../core/utils/auth_api.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _syncWithApiOrSignOut(credential.user);
    } on FirebaseAuthException catch (e) {
      await _showError(_friendlyAuthMessage(e));
    } catch (e) {
      await _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithEmailPassword() async {
    // Kept for backward compatibility; UI now uses RegisterScreen.
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      await _syncWithApiOrSignOut(userCredential.user);
    } on FirebaseAuthException catch (e) {
      await _showError(_friendlyAuthMessage(e));
    } catch (e) {
      print(e);
      await _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncWithApiOrSignOut(User? user) async {
    if (user == null) {
      await _showError('Login failed. Please try again.');
      return;
    }

    try {
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Missing Firebase ID token');
      }
      await syncFirebaseUserWithApi(idToken: idToken);
    } catch (e) {
      // Don't immediately sign out on transient errors (CORS/network/server down).
      // Only sign out when the server indicates the token is invalid/unauthorized.
      if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403)) {
        await FirebaseAuth.instance.signOut();
      }
      await _showError(
        'Login succeeded, but syncing with the server failed. Please try again.',
      );
    }
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor.withOpacity(0.08),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue to your profile.',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          autofillHints: const [AutofillHints.password],
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _isLoading
                              ? null
                              : _loginWithEmailPassword,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : _registerWithEmailPassword,
                          child: const Text('Create account'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('or'),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _loginWithGoogle,
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Continue with Google'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
