import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/lesson_access_decision.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import 'lesson_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, AuthService? authService})
      : _authService = authService;

  static const String routeName = '/home';
  final AuthService? _authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  LessonAccessDecision? _lessonAccess;
  bool _isCheckingLessonAccess = false;
  String? _lessonAccessError;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
  }

  Future<void> _checkLessonAccess() async {
    setState(() {
      _isCheckingLessonAccess = true;
      _lessonAccessError = null;
    });

    try {
      final lessonAccess = await _authService.fetchLessonAccessDecision();
      if (!mounted) return;
      setState(() => _lessonAccess = lessonAccess);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Please sign in again.') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (_) => false,
        );
        return;
      }
      setState(() => _lessonAccessError =
          'Unable to check lesson access right now. Please try again.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _lessonAccessError =
          'Unable to check lesson access right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isCheckingLessonAccess = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Welcome to the Language Voice Tutor mobile shell.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          LessonAccessCard(
            lessonAccess: _lessonAccess,
            error: _lessonAccessError,
            isChecking: _isCheckingLessonAccess,
            onCheckLessonAccess: _checkLessonAccess,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, LessonScreen.routeName),
            icon: const Icon(Icons.school),
            label: const Text('Open Lesson'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class LessonAccessCard extends StatelessWidget {
  const LessonAccessCard({
    super.key,
    required this.lessonAccess,
    required this.error,
    required this.isChecking,
    required this.onCheckLessonAccess,
  });

  final LessonAccessDecision? lessonAccess;
  final String? error;
  final bool isChecking;
  final VoidCallback onCheckLessonAccess;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson access',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (isChecking)
              const Text('Checking lesson access...')
            else if (lessonAccess != null) ...[
              Text(lessonAccess!.canStartNewLesson
                  ? 'You can start a lesson'
                  : 'You cannot start a new lesson right now'),
              const SizedBox(height: 4),
              Text(lessonAccess!.displayReason),
              const SizedBox(height: 4),
              Text(
                  'Free lessons remaining today: ${lessonAccess!.freeLessonRemainingToday}'),
            ] else if (error != null)
              Text(error!)
            else
              const Text(
                  'Check with the backend before starting a new lesson.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isChecking ? null : onCheckLessonAccess,
              child: const Text('Check lesson access'),
            ),
          ],
        ),
      ),
    );
  }
}
