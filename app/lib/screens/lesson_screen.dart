import 'package:flutter/material.dart';

import '../models/language_options.dart';
import '../models/lesson_chat.dart';
import '../models/lesson_runtime.dart';
import '../models/lesson_session.dart';
import '../models/lesson_start_selection.dart';
import '../models/user_settings.dart';
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
  final TextEditingController _messageController = TextEditingController();
  late bool _isStarting;
  bool _startInFlight = false;
  bool _isLoadingScenario = false;
  bool _isSending = false;
  LessonSessionStartResult? _startResult;
  LessonRuntimeScenario? _scenario;
  UserSettings? _settings;
  String? _lessonLoadError;
  String? _sendError;
  final List<_LessonChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _isStarting = widget.selection != null;
    if (widget.selection != null) {
      _startLessonSession(showLoadingState: false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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

    if (result.isReady) {
      await _loadLessonRuntime(selection, result.session!);
    }

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
        request: StartLessonSessionRequest(
          lessonContentId: selection.lessonContentId,
          studyLanguage: studyLanguage,
          topicId: selection.topicId,
          topicTitle: selection.topicTitle,
          subtopicId: selection.subtopicId,
          subtopicTitle: selection.subtopicTitle,
          level: selection.level,
          selectedContextId: selection.selectedContextId,
          selectedContextTitle: selection.selectedContextTitle,
          modeUsed: selection.modeUsed,
        ),
      );
    } catch (_) {
      return LessonSessionStartResult.failed();
    }
  }

  Future<void> _loadLessonRuntime(
    LessonStartSelection selection,
    LessonSessionResponse session,
  ) async {
    if (!mounted) return;
    setState(() {
      _isLoadingScenario = true;
      _lessonLoadError = null;
      _sendError = null;
      _scenario = null;
      _settings = null;
      _messages.clear();
    });

    try {
      final settings = await _authService.fetchUserSettings();
      final scenario = await _authService.fetchLessonRuntimeScenario(
        scenarioKey: selection.lessonContentId,
      );
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _scenario = scenario;
        _isLoadingScenario = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingScenario = false;
        _lessonLoadError = _safeErrorMessage(
          error,
          fallback: 'Could not load lesson content. Please try again.',
        );
      });
    }
  }

  Future<String> _studyLanguage() async {
    try {
      final settings = await _authService.fetchUserSettings();
      return LanguageOptions.backendStudyLanguageNameFor(
        settings.studyLanguage,
      );
    } catch (_) {
      return LanguageOptions.backendStudyLanguageNameFor(null);
    }
  }

  Future<void> _retryLessonRuntime() async {
    final selection = widget.selection;
    final session = _startResult?.session;
    if (selection == null || session == null || _isLoadingScenario) return;
    await _loadLessonRuntime(selection, session);
  }

  Future<void> _sendMessage() async {
    final selection = widget.selection;
    final session = _startResult?.session;
    final scenario = _scenario;
    final settings = _settings;
    final text = _messageController.text.trim();
    if (selection == null ||
        session == null ||
        scenario == null ||
        settings == null ||
        _isSending) {
      return;
    }

    if (text.isEmpty) {
      setState(() {
        _sendError = 'Please enter a message.';
      });
      return;
    }

    final userMessage = _LessonChatMessage.user(text);
    final lastBotMessage = _messages.lastWhere(
      (message) => message.isBot,
      orElse: () => const _LessonChatMessage.bot(''),
    );
    final updatedMessages = [..._messages, userMessage];
    final learnerTurnCount =
        updatedMessages.where((message) => message.isUser).length;
    final request = LessonChatRequest.fromScenario(
      scenario: scenario,
      levelProfile: scenario.levelProfileFor(selection.level),
      selectedLevel: selection.level,
      topicTitle: selection.topicTitle,
      subtopicTitle: selection.subtopicTitle,
      userMessage: text,
      lastBotMessage: lastBotMessage.text,
      nativeLanguageName:
          LanguageOptions.backendNativeLanguageNameFor(settings.nativeLanguage),
      targetLanguageId:
          LanguageOptions.studyLanguageIdFor(settings.studyLanguage),
      targetLanguageName:
          LanguageOptions.backendStudyLanguageNameFor(settings.studyLanguage),
      targetLanguageNativeName:
          LanguageOptions.backendStudyLanguageNameFor(settings.studyLanguage),
      targetLanguageCode:
          LanguageOptions.studyLanguageIdFor(settings.studyLanguage),
      userDisplayName: '',
      learnerTurnCount: learnerTurnCount,
      recentMessages: _recentConversationMessages(updatedMessages),
      backendSessionId: session.lessonSessionId,
      selectedContextTitle: selection.selectedContextTitle ?? '',
    );

    setState(() {
      _isSending = true;
      _sendError = null;
      _messages
        ..clear()
        ..addAll(updatedMessages);
      _messageController.clear();
    });

    final result = await _authService.sendLessonChatReply(request: request);
    if (!mounted) return;

    if (!result.isSuccess || result.reply == null) {
      setState(() {
        _isSending = false;
        _sendError = result.message;
      });
      return;
    }

    final botText = result.reply!.botReply.trim();
    setState(() {
      _isSending = false;
      _sendError = null;
      if (botText.isNotEmpty) {
        _messages.add(_LessonChatMessage.bot(botText));
      }
    });

    await _persistChatMessages(
      sessionId: session.lessonSessionId,
      studyLanguage: session.studyLanguage,
      userText: text,
      botText: botText,
      turnNumber: learnerTurnCount,
    );
  }

  Future<void> _persistChatMessages({
    required String sessionId,
    required String studyLanguage,
    required String userText,
    required String botText,
    required int turnNumber,
  }) async {
    try {
      await _authService.persistLessonSessionMessage(
        sessionId: sessionId,
        request: CreateLessonSessionMessageRequest(
          role: 'user',
          text: userText,
          source: 'typed',
          turnNumber: turnNumber,
          isValidLessonTurn: true,
          studyLanguage: studyLanguage,
        ),
      );
      if (botText.isNotEmpty) {
        await _authService.persistLessonSessionMessage(
          sessionId: sessionId,
          request: CreateLessonSessionMessageRequest(
            role: 'assistant',
            text: botText,
            source: 'bot_reply',
            turnNumber: turnNumber,
            isValidLessonTurn: false,
            studyLanguage: studyLanguage,
          ),
        );
      }
    } catch (_) {
      // Live chat remains primary if persistence is unavailable.
    }
  }

  List<LessonRecentConversationMessage> _recentConversationMessages(
    List<_LessonChatMessage> messages,
  ) {
    const limit = 8;
    final slice = messages.length <= limit
        ? messages
        : messages.sublist(messages.length - limit);
    return slice
        .where((message) => message.text.trim().isNotEmpty)
        .map(
          (message) => LessonRecentConversationMessage(
            sender: message.isBot ? 'Tutor' : 'User',
            text: message.text,
          ),
        )
        .toList(growable: false);
  }

  String _safeErrorMessage(Object error, {required String fallback}) {
    if (error is Exception) {
      final text = error.toString();
      if (text.isNotEmpty) {
        final normalized = text.replaceFirst('Exception: ', '');
        return normalized;
      }
    }
    return fallback;
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
                    'Topic: ${selection.topicTitle}',
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
                if (_startResult?.isReady ?? false)
                  _LessonChatPanel(
                    selection: selection,
                    scenario: _scenario,
                    isLoadingScenario: _isLoadingScenario,
                    lessonLoadError: _lessonLoadError,
                    onRetryLoad: _retryLessonRuntime,
                    messages: _messages,
                    sendError: _sendError,
                    isSending: _isSending,
                    controller: _messageController,
                    onSend: _sendMessage,
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

class _LessonChatPanel extends StatelessWidget {
  const _LessonChatPanel({
    required this.selection,
    required this.scenario,
    required this.isLoadingScenario,
    required this.lessonLoadError,
    required this.onRetryLoad,
    required this.messages,
    required this.sendError,
    required this.isSending,
    required this.controller,
    required this.onSend,
  });

  final LessonStartSelection? selection;
  final LessonRuntimeScenario? scenario;
  final bool isLoadingScenario;
  final String? lessonLoadError;
  final Future<void> Function() onRetryLoad;
  final List<_LessonChatMessage> messages;
  final String? sendError;
  final bool isSending;
  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    if (isLoadingScenario) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (lessonLoadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(lessonLoadError!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              onRetryLoad();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry lesson content'),
          ),
        ],
      );
    }

    if (selection == null || scenario == null) {
      return const SizedBox.shrink();
    }

    final title = scenario!.metadata.subtopic.isNotEmpty
        ? scenario!.metadata.subtopic
        : selection!.situation;
    final goal = scenario!.learningGoal.goal;
    final lessonContext = scenario!.situation.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (goal.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(goal),
                ],
                if (lessonContext.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(lessonContext),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(minHeight: 180),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: messages.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Send the first message to begin this text lesson.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final alignment = message.isBot
                        ? Alignment.centerLeft
                        : Alignment.centerRight;
                    final background = message.isBot
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(context).colorScheme.primaryContainer;
                    return Align(
                      alignment: alignment,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                ),
        ),
        if (isSending) ...[
          const SizedBox(height: 12),
          const Text(
            'Tutor is thinking...',
            textAlign: TextAlign.center,
          ),
        ],
        if (sendError != null) ...[
          const SizedBox(height: 12),
          Text(
            sendError!,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          enabled: !isSending,
          minLines: 1,
          maxLines: 4,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) {
            if (!isSending) {
              onSend();
            }
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type your message',
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final canSend = !isSending && value.text.trim().isNotEmpty;
            return FilledButton(
              onPressed: canSend
                  ? () {
                      onSend();
                    }
                  : null,
              child: Text(isSending ? 'Sending...' : 'Send'),
            );
          },
        ),
      ],
    );
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

class _LessonChatMessage {
  const _LessonChatMessage({
    required this.text,
    required this.isBot,
  });

  const _LessonChatMessage.user(this.text) : isBot = false;

  const _LessonChatMessage.bot(this.text) : isBot = true;

  final String text;
  final bool isBot;

  bool get isUser => !isBot;
}
