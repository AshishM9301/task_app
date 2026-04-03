import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/utils/api_utils.dart';
import 'main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _initGuestIfNeeded();
  }

  Future<void> _initGuestIfNeeded() async {
    // When not logged in, create/load the guestKey right away so task APIs work immediately.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return;
    try {
      await ensureGuestKey(); // POST /api/guest (only if not already stored)
    } catch (_) {
      // If guest init fails, the app can still render; API calls will surface errors later.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guest-first: authentication is optional.
    // Profile tab will prompt for login when needed.
    return const MainScreen();
  }
}

