import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LanguageVoiceTutorApp());
}

class LanguageVoiceTutorApp extends StatelessWidget {
  const LanguageVoiceTutorApp({super.key, AuthService? authService})
      : _authService = authService;

  final AuthService? _authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => SplashScreen(authService: _authService),
        LoginScreen.routeName: (_) => LoginScreen(authService: _authService),
        HomeScreen.routeName: (_) => const HomeScreen(),
        LessonScreen.routeName: (_) => const LessonScreen(),
        SettingsScreen.routeName: (_) =>
            SettingsScreen(authService: _authService),
      },
    );
  }
}
