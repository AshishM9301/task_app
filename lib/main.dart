import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/route_observer.dart';
import 'presentation/widgets/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(_FirebaseInitErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      navigatorObservers: [routeObserver],
      home: const AuthGate(),
    );
  }
}

class _FirebaseInitErrorApp extends StatelessWidget {
  final String error;
  const _FirebaseInitErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task App',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Firebase is not configured for Web',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To run on Edge, pass Firebase web options via --dart-define, or configure FlutterFire and generate firebase_options.dart.',
                ),
                const SizedBox(height: 12),
                const Text('Current error:'),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
