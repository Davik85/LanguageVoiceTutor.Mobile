import 'package:flutter/material.dart';

import '../models/language_options.dart';
import '../models/lesson_session_models.dart';
import '../models/lesson_start_selection.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, this.selection, this.authService});

  static const String routeName = '/lesson';

  final LessonStartSelection? selection;
  final AuthService? authService;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final AuthService _authService;
  LessonSessionStartResult? _startResult;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? createAuthService();
    if (widget.selection != null) {
      _startLessonSession();
    }
  }

  Future<void> _startLessonSession() async {
    final selection = widget.selection;
    if (selection == null) return;

    setState(() {
      _isStarting = true;
      _startResult = null;
    });

    try {
      final settings = await _authService.fetchUserSettings();
      final studyLanguage = studyLanguageEnglishName(settings.studyLanguage);
      final result = await _authService.startLessonSession(
        selection.situationId,
        studyLanguage,
      );
      if (!mounted) return;
      setState(() => _startResult = result);
    } catch (_) {
      if (!mounted) return;
      final result = await _startWithDefaultStudyLanguage(selection);
      if (!mounted) return;
      setState(() => _startResult = result);
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<LessonSessionStartResult> _startWithDefaultStudyLanguage(
    LessonStartSelection selection,
  ) =>
      _authService.startLessonSession(
        selection.situationId,
        studyLanguageEnglishName(LanguageOptions.defaultLanguageId),
      );

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _titleText,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (selection != null) ...[
                Text('Level: ${selection.level}', textAlign: TextAlign.center),
                Text('Topic: ${selection.topic}', textAlign: TextAlign.center),
                Text(
                  'Situation: ${selection.situation}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              if (_isStarting) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 12),
                const Text(
                  'Starting lesson…',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Text chat is coming next. Voice, TTS, and AI tutor replies are intentionally not implemented in this version.',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _titleText {
    if (_startResult?.isReady ?? false) return 'Lesson started';
    return 'Lesson';
  }

  String get _statusText {
    final result = _startResult;
    if (result != null) return result.message;
    if (widget.selection == null) return 'Choose a lesson to start.';
    return 'Could not start the lesson. Please try again.';
  }
}
