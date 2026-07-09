import 'package:flutter/material.dart';

import '../models/language_options.dart';
import '../models/lesson_chat.dart';
import '../models/lesson_runtime.dart';
import '../models/lesson_session.dart';
import '../models/lesson_start_selection.dart';
import '../models/user_settings.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';

enum LessonTutorStatus {
  loading,
  ready,
  thinking,
  listening,
  speaking,
  error,
}

enum LessonMessageKind {
  user,
  tutor,
  system,
}

class _LessonActionAvailability {
  const _LessonActionAvailability({
    required this.canSendText,
    required this.canToggleRecordingPlaceholder,
    required this.canUsePlaceholders,
    required this.canFinishLesson,
  });

  final bool canSendText;
  final bool canToggleRecordingPlaceholder;
  final bool canUsePlaceholders;
  final bool canFinishLesson;
}

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
  static const _comingNextMessage = 'Coming next in a future lesson update.';

  late final AuthService _authService;
  final TextEditingController _messageController = TextEditingController();
  late bool _isStarting;
  bool _startInFlight = false;
  bool _isLoadingScenario = false;
  bool _isSending = false;
  bool _isRecordingPlaceholderActive = false;
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
    LessonStartSelection selection,
  ) async {
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
      _isRecordingPlaceholderActive = false;
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
      _isRecordingPlaceholderActive = false;
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

  LessonTutorStatus get _tutorStatus {
    if (_lessonLoadError != null || _sendError != null) {
      return LessonTutorStatus.error;
    }
    if (_isStarting || _isLoadingScenario) {
      return LessonTutorStatus.loading;
    }
    if (_isSending) {
      return LessonTutorStatus.thinking;
    }
    if (_isRecordingPlaceholderActive) {
      return LessonTutorStatus.listening;
    }
    if (_startResult?.isReady ?? false) {
      return LessonTutorStatus.ready;
    }
    return LessonTutorStatus.loading;
  }

  _LessonActionAvailability get _actionAvailability {
    final lessonReady = (_startResult?.isReady ?? false) &&
        !_isLoadingScenario &&
        _scenario != null &&
        _settings != null;
    return _LessonActionAvailability(
      canSendText: lessonReady && !_isSending,
      canToggleRecordingPlaceholder: lessonReady && !_isSending,
      canUsePlaceholders: lessonReady,
      canFinishLesson: lessonReady,
    );
  }

  String get _tutorDisplayName {
    final tutorId = _settings?.selectedTutorId.trim() ?? '';
    if (tutorId.isEmpty) return 'Tutor';
    final words = tutorId
        .split(RegExp(r'[_\-\s]+'))
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
      final lower = part.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).toList(growable: false);
    return words.isEmpty ? 'Tutor' : words.join(' ');
  }

  void _showComingNext(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$label: $_comingNextMessage')),
      );
  }

  void _toggleRecordingPlaceholder() {
    if (!_actionAvailability.canToggleRecordingPlaceholder) return;
    setState(() {
      _isRecordingPlaceholderActive = !_isRecordingPlaceholderActive;
    });
    final label = _isRecordingPlaceholderActive
        ? 'Recording placeholder'
        : 'Recording stopped';
    _showComingNext(label);
  }

  void _handleFutureAction(String label) {
    if (!_actionAvailability.canUsePlaceholders) return;
    _showComingNext(label);
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _statusTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (selection != null) ...[
                Text('Level: ${selection.level}'),
                Text('Topic: ${selection.topicTitle}'),
                Text('Situation: ${selection.situation}'),
                const SizedBox(height: 12),
              ],
              _SessionStartStatusView(
                isStarting: _isStarting,
                result: _startResult,
                hasSelection: selection != null,
                onRetry: _isStarting ? null : _startLessonSession,
              ),
              const SizedBox(height: 12),
              if (_startResult?.isReady ?? false)
                Expanded(
                  child: _LessonChatPanel(
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
                    tutorStatus: _tutorStatus,
                    tutorDisplayName: _tutorDisplayName,
                    actionAvailability: _actionAvailability,
                    isRecordingPlaceholderActive: _isRecordingPlaceholderActive,
                    onToggleRecordingPlaceholder: _toggleRecordingPlaceholder,
                    onFutureAction: _handleFutureAction,
                  ),
                ),
            ],
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
    required this.tutorStatus,
    required this.tutorDisplayName,
    required this.actionAvailability,
    required this.isRecordingPlaceholderActive,
    required this.onToggleRecordingPlaceholder,
    required this.onFutureAction,
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
  final LessonTutorStatus tutorStatus;
  final String tutorDisplayName;
  final _LessonActionAvailability actionAvailability;
  final bool isRecordingPlaceholderActive;
  final VoidCallback onToggleRecordingPlaceholder;
  final void Function(String label) onFutureAction;

  @override
  Widget build(BuildContext context) {
    if (isLoadingScenario) {
      return const Center(
        child: CircularProgressIndicator(key: Key('lesson-runtime-loading')),
      );
    }

    if (lessonLoadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TutorHeader(
            displayName: tutorDisplayName,
            status: tutorStatus,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
              ),
            ),
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
    final setupMessage = scenario!.lessonSetup.setupMessage;
    final goal = scenario!.learningGoal.goal;
    final lessonContext = scenario!.situation.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 148),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TutorHeader(
                  displayName: tutorDisplayName,
                  status: tutorStatus,
                ),
                const SizedBox(height: 12),
                Card(
                  key: const Key('lesson-scenario-card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (setupMessage.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(setupMessage),
                        ],
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            key: const Key('lesson-chat-transcript'),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Send the first message to begin this text lesson.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final alignment = message.isTutor
                          ? Alignment.centerLeft
                          : Alignment.centerRight;
                      final background = message.isTutor
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
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
        ),
        const SizedBox(height: 12),
        if (sendError != null) ...[
          Text(
            sendError!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        _LessonActionPanel(
          actionAvailability: actionAvailability,
          isRecordingPlaceholderActive: isRecordingPlaceholderActive,
          onToggleRecordingPlaceholder: onToggleRecordingPlaceholder,
          onFutureAction: onFutureAction,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const Key('lesson-input'),
                controller: controller,
                enabled: actionAvailability.canSendText,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (actionAvailability.canSendText) {
                    onSend();
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type your message',
                ),
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = actionAvailability.canSendText &&
                    value.text.trim().isNotEmpty;
                return FilledButton(
                  key: const Key('lesson-send-button'),
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
    required this.kind,
  });

  const _LessonChatMessage.user(this.text) : kind = LessonMessageKind.user;

  const _LessonChatMessage.bot(this.text) : kind = LessonMessageKind.tutor;

  final String text;
  final LessonMessageKind kind;

  bool get isUser => kind == LessonMessageKind.user;
  bool get isTutor => kind == LessonMessageKind.tutor;
  bool get isBot => isTutor;
}

class _TutorHeader extends StatelessWidget {
  const _TutorHeader({
    required this.displayName,
    required this.status,
  });

  final String displayName;
  final LessonTutorStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('lesson-tutor-header'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              key: const Key('lesson-avatar'),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusLabel(status),
                    key: const Key('lesson-tutor-status'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(LessonTutorStatus status) {
    switch (status) {
      case LessonTutorStatus.loading:
        return 'Loading';
      case LessonTutorStatus.ready:
        return 'Ready';
      case LessonTutorStatus.thinking:
        return 'Thinking';
      case LessonTutorStatus.listening:
        return 'Listening';
      case LessonTutorStatus.speaking:
        return 'Speaking';
      case LessonTutorStatus.error:
        return 'Error';
    }
  }
}

class _LessonActionPanel extends StatelessWidget {
  const _LessonActionPanel({
    required this.actionAvailability,
    required this.isRecordingPlaceholderActive,
    required this.onToggleRecordingPlaceholder,
    required this.onFutureAction,
  });

  final _LessonActionAvailability actionAvailability;
  final bool isRecordingPlaceholderActive;
  final VoidCallback onToggleRecordingPlaceholder;
  final void Function(String label) onFutureAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('lesson-action-controls'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          key: const Key('lesson-action-scroll'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              OutlinedButton.icon(
                key: const Key('lesson-action-record'),
                onPressed: actionAvailability.canToggleRecordingPlaceholder
                    ? onToggleRecordingPlaceholder
                    : null,
                icon: Icon(
                  isRecordingPlaceholderActive ? Icons.stop : Icons.mic_none,
                ),
                label: Text(
                  isRecordingPlaceholderActive ? 'Stop recording' : 'Record',
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('lesson-action-play-voice'),
                onPressed: actionAvailability.canUsePlaceholders
                    ? () => onFutureAction('Play voice')
                    : null,
                icon: const Icon(Icons.volume_up_outlined),
                label: const Text('Play voice'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('lesson-action-hint'),
                onPressed: actionAvailability.canUsePlaceholders
                    ? () => onFutureAction('Hint')
                    : null,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Hint'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('lesson-action-translation'),
                onPressed: actionAvailability.canUsePlaceholders
                    ? () => onFutureAction('Translation')
                    : null,
                icon: const Icon(Icons.translate),
                label: const Text('Translation'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('lesson-action-feedback'),
                onPressed: actionAvailability.canUsePlaceholders
                    ? () => onFutureAction('Feedback / Review')
                    : null,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Feedback / Review'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const Key('lesson-action-finish'),
                onPressed: actionAvailability.canFinishLesson
                    ? () => onFutureAction('Finish lesson')
                    : null,
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Finish lesson'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
