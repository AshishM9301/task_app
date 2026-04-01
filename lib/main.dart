import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/route_observer.dart';
import 'presentation/widgets/widgets.dart';

void main() {
  runApp(const MyApp());
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
      home: const MainScreen(),
    );
  }
}
