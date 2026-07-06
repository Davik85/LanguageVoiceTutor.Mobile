import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/lesson_access_decision.dart';
import '../models/tutor_options.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import '../services/tutor_options_service.dart';
import 'lesson_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    AuthService? authService,
    TutorOptionsService? tutorOptionsService,
  })  : _authService = authService,
        _tutorOptionsService = tutorOptionsService;

  static const String routeName = '/home';
  final AuthService? _authService;
  final TutorOptionsService? _tutorOptionsService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final TutorOptionsService _tutorOptionsService;
  LessonAccessDecision? _lessonAccess;
  bool _isCheckingLessonAccess = false;
  String? _lessonAccessError;
  TutorOptions? _tutorOptions;
  bool _isLoadingTutorOptions = true;
  String? _tutorOptionsError;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _tutorOptionsService = widget._tutorOptionsService ??
        TutorOptionsService(apiClient: HttpApiClient());
    _loadTutorOptions();
  }

  Future<void> _loadTutorOptions() async {
    setState(() {
      _isLoadingTutorOptions = true;
      _tutorOptionsError = null;
    });

    try {
      final options = await _tutorOptionsService.fetchTutorOptions();
      if (!mounted) return;
      setState(() => _tutorOptions = options);
    } on ApiException {
      if (!mounted) return;
      setState(() => _tutorOptionsError =
          'Practice options are unavailable right now. Please try again later.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _tutorOptionsError =
          'Practice options are unavailable right now. Please try again later.');
    } finally {
      if (mounted) setState(() => _isLoadingTutorOptions = false);
    }
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
          TutorOptionsCard(
            options: _tutorOptions,
            error: _tutorOptionsError,
            isLoading: _isLoadingTutorOptions,
            onRetry: _loadTutorOptions,
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

class TutorOptionsCard extends StatelessWidget {
  const TutorOptionsCard({
    super.key,
    required this.options,
    required this.error,
    required this.isLoading,
    required this.onRetry,
  });

  final TutorOptions? options;
  final String? error;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson catalog',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Text('Loading practice options...')
            else if (options != null && options!.hasAnyOptions) ...[
              Text('Available option groups: ${options!.optionGroupCount}'),
              if (options!.studyLanguages.isNotEmpty)
                Text('Study languages: ${_preview(options!.studyLanguages)}'),
              if (options!.levels.isNotEmpty)
                Text('Levels: ${_preview(options!.levels)}'),
              if (options!.topics.isNotEmpty)
                Text('Topics: ${_preview(options!.topics)}'),
              if (options!.scenarios.isNotEmpty)
                Text('Scenarios: ${_preview(options!.scenarios)}'),
              if (options!.modes.isNotEmpty)
                Text('Modes: ${_preview(options!.modes)}'),
            ] else if (error != null) ...[
              Text(error!),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ] else
              const Text('No practice options are available yet.'),
          ],
        ),
      ),
    );
  }

  static String _preview(List<String> values) {
    final shown = values.take(3).join(', ');
    final remaining = values.length - 3;
    return remaining > 0 ? '$shown, +$remaining more' : shown;
  }
}
