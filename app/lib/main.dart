import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'services/auth_service.dart';
import 'services/service_factory.dart';
import 'services/tutor_options_service.dart';
import 'screens/choose_level_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(LanguageVoiceTutorApp());
}

class LanguageVoiceTutorApp extends StatelessWidget {
  LanguageVoiceTutorApp({
    super.key,
    AuthService? authService,
    TutorOptionsService? tutorOptionsService,
  })  : _authService = authService ?? createAuthService(),
        _tutorOptionsService = tutorOptionsService;

  final AuthService _authService;
  final TutorOptionsService? _tutorOptionsService;

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
        HomeScreen.routeName: (_) => HomeScreen(
              authService: _authService,
              tutorOptionsService: _tutorOptionsService,
            ),
        ChooseLevelScreen.routeName: (_) => const ChooseLevelScreen(),
        LessonScreen.routeName: (_) => const LessonScreen(),
        SettingsScreen.routeName: (_) =>
            SettingsScreen(authService: _authService),
      },
    );
  }
}
