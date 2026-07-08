import 'package:flutter/material.dart';

import '../models/language_options.dart';
import '../models/lesson_session.dart';
import '../models/lesson_start_selection.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    this.selection,
    AuthService? authService,
  }) : _authService = authService;

  static const String routeName = '/lesson';

  final LessonStartSelection? selection;
  final AuthService? _authService;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final AuthService _authService;
  late bool _isStarting;
  bool _startInFlight = false;
  LessonSessionStartResult? _startResult;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _isStarting = widget.selection != null;
    if (widget.selection != null) {
      _startLessonSession(showLoadingState: false);
    }
  }

  Future<void> _startLessonSession({bool showLoadingState = true}) async {
    final selection = widget.selection;
    if (selection == null || _startInFlight) return;

    _startInFlight = true;
    if (showLoadingState && mounted) {
      setState(() {
        _isStarting = true;
        _startResult = null;
      });
    }

    final result = await _startSelectedLesson(selection);

    if (!mounted) return;
    setState(() {
      _isStarting = false;
      _startResult = result;
      _startInFlight = false;
    });
  }

  Future<LessonSessionStartResult> _startSelectedLesson(
      LessonStartSelection selection) async {
    try {
      final studyLanguage = await _studyLanguage();
      return await _authService.startLessonSession(
        lessonContentId: selection.lessonContentId,
        studyLanguage: studyLanguage,
      );
    } catch (_) {
      return LessonSessionStartResult.failed();
    }
  }

  Future<String> _studyLanguage() async {
    try {
      final settings = await _authService.fetchUserSettings();
      return LanguageOptions.studyLanguageIdFor(settings.studyLanguage);
    } catch (_) {
      return LanguageOptions.defaultLanguageId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _statusTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (selection != null) ...[
                  Text(
                    'Level: ${selection.level}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Topic: ${selection.topic}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Situation: ${selection.situation}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                _SessionStartStatusView(
                  isStarting: _isStarting,
                  result: _startResult,
                  hasSelection: selection != null,
                  onRetry: _isStarting ? null : _startLessonSession,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Text chat is coming next.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _statusTitle {
    if (_isStarting) return 'Starting lesson...';
    if (_startResult?.isReady ?? false) return 'Lesson started';
    return 'Lesson placeholder';
  }
}

class _SessionStartStatusView extends StatelessWidget {
  const _SessionStartStatusView({
    required this.isStarting,
    required this.result,
    required this.hasSelection,
    required this.onRetry,
  });

  final bool isStarting;
  final LessonSessionStartResult? result;
  final bool hasSelection;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (!hasSelection) {
      return const Text(
        'Choose a level, topic, and situation to start a lesson.',
        textAlign: TextAlign.center,
      );
    }

    if (isStarting) {
      return const Center(child: CircularProgressIndicator());
    }

    final result = this.result;
    if (result == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(result.message, textAlign: TextAlign.center),
        if (!result.isReady) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ],
    );
  }
}
