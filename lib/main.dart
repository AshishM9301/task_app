import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/firebase/firebase_options.dart';
import 'presentation/widgets/widgets.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: '.env');

  try {
    await initializeFirebase();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize GuestProvider before app starts to avoid race conditions
  final guestProvider = GuestProvider();
  await guestProvider.initializeGuestKey();

  runApp(MyApp(guestProvider: guestProvider));
}

class MyApp extends StatelessWidget {
  final GuestProvider guestProvider;

  const MyApp({super.key, required this.guestProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GuestProvider>.value(value: guestProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Task App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const MainScreen(),
      ),
    );
  }
}
