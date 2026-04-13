import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AppFirebaseOptions {
  AppFirebaseOptions._();

  static const String appId = '1:285882102553:android:2d74072d87c6eac8498b88';
  static const String apiKey = 'AIzaSyAdghO6XOHUeJwkSKffVfmmFMmZTK58rJk';
  static const String projectId = 'task-app-8a439';
  static const String messagingSenderId = '285882102553';
  static const String authDomain = 'task-app-8a439.firebaseapp.com';

  static FirebaseOptions get webOptions => FirebaseOptions(
        appId: appId,
        apiKey: apiKey,
        projectId: projectId,
        authDomain: authDomain,
        messagingSenderId: messagingSenderId,
      );

  static FirebaseOptions get androidOptions => FirebaseOptions(
        appId: appId,
        apiKey: apiKey,
        projectId: projectId,
        messagingSenderId: messagingSenderId,
        authDomain: authDomain,
      );
}

Future<void> initializeFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: AppFirebaseOptions.webOptions,
      );
    } else {
      await Firebase.initializeApp(
        options: AppFirebaseOptions.androidOptions,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization error (app will work without auth): $e');
  }
}