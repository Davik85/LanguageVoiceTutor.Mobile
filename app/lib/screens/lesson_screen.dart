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
  ready,
  thinking,
  listening,
  speaking,
  error,
}

enum LessonMessageKind {
  user,
  tutor,
}

class _LessonActionAvailability {
  const _LessonActionAvailability({
    required this.canSendText,
    required this.canToggleRecordingPlaceholder,
    required this.canUsePlaceholders,
    required this.canUseHintPlaceholder,
  });

  final bool canSendText;
  final bool canToggleRecordingPlaceholder;
  final bool canUsePlaceholders;
  final bool canUseHintPlaceholder;
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
  static const _neutralOpeningFallback = 'Your lesson is ready.';
  static const _initialContextVariantLimit = 3;

  late final AuthService _authService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _transcriptController = ScrollController();
  late bool _isStarting;
  bool _startInFlight = false;
  bool _isLoadingScenario = false;
  bool _isSending = false;
  bool _isFinishing = false;
  bool _isCompleted = false;
  bool _isRecordingPlaceholderActive = false;
  bool _isSpeakingPlaceholderActive = false;
  LessonSessionStartResult? _startResult;
  LessonRuntimeScenario? _scenario;
  UserSettings? _settings;
  String? _lessonLoadError;
  String? _sendError;
  String? _finishError;
  LessonSummaryResponse? _lessonSummary;
  LessonCompletionStatus? _summaryStatus;
  final List<_LessonChatMessage> _messages = [];
  final Set<Future<void>> _pendingMessagePersistence = {};

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
    _transcriptController.dispose();
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
      _isSpeakingPlaceholderActive = false;
      _messages.clear();
    });

    try {
      final settings = await _authService.fetchUserSettings();
      final scenario = await _authService.fetchLessonRuntimeScenario(
        scenarioKey: selection.lessonContentId,
      );
      final openingMessage = _buildInitialTutorMessage(
        scenario: scenario,
      );
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _scenario = scenario;
        _messages.add(openingMessage);
        _isLoadingScenario = false;
      });
      _scrollTranscriptToBottom();
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

  _LessonChatMessage _buildInitialTutorMessage({
    required LessonRuntimeScenario scenario,
  }) {
    final openingParts = <String>[];
    final openingLine = scenario.conversationFlow.opening.trim().isNotEmpty
        ? scenario.conversationFlow.opening.trim()
        : scenario.lessonSetup.setupMessage.trim();
    final goal = scenario.learningGoal.goal.trim();

    if (openingLine.isNotEmpty) {
      openingParts.add(openingLine);
    }
    if (goal.isNotEmpty) {
      openingParts.add('Goal: $goal');
    }

    final scenarioChoices = scenario.controlledVariation.contextVariants
        .take(_initialContextVariantLimit)
        .map((variant) => variant.title.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    if (scenarioChoices.isNotEmpty) {
      openingParts.add(
        [
          'Choose a situation:',
          ...scenarioChoices.indexed.map(
            (entry) => '${entry.$1 + 1}. ${entry.$2}',
          ),
        ].join('\n'),
      );
    }

    final subtopicTitle = scenario.metadata.subtopic.trim();
    if (subtopicTitle.isNotEmpty) {
      openingParts.add(
        'Or suggest your own situation about ${subtopicTitle.toLowerCase()}.',
      );
    }

    final openingText = openingParts.isEmpty
        ? _neutralOpeningFallback
        : openingParts.join('\n\n');

    return _LessonChatMessage.tutor(openingText);
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

  Future<void> _sendMessage([String? overrideText]) async {
    final selection = widget.selection;
    final session = _startResult?.session;
    final scenario = _scenario;
    final settings = _settings;
    final text = (overrideText ?? _messageController.text).trim();
    if (selection == null ||
        session == null ||
        scenario == null ||
        settings == null ||
        _isSending ||
        _isFinishing ||
        _isCompleted) {
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
      orElse: () => const _LessonChatMessage.tutor(''),
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
      _isSpeakingPlaceholderActive = false;
      _messages
        ..clear()
        ..addAll(updatedMessages);
      if (overrideText == null) {
        _messageController.clear();
      }
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
        _messages.add(_LessonChatMessage.tutor(botText));
      }
    });
    _scrollTranscriptToBottom();

    _trackMessagePersistence(_persistChatMessages(
      sessionId: session.lessonSessionId,
      studyLanguage: session.studyLanguage,
      userText: text,
      botText: botText,
      turnNumber: learnerTurnCount,
    ));
  }

  void _trackMessagePersistence(Future<void> operation) {
    _pendingMessagePersistence.add(operation);
    operation.whenComplete(() => _pendingMessagePersistence.remove(operation));
  }

  Future<void> _waitForPendingMessagePersistence() async {
    final pending = List<Future<void>>.of(_pendingMessagePersistence);
    if (pending.isEmpty) return;
    // Persistence is best-effort during live chat. Before finish, wait only
    // for writes already started; failures and a bounded timeout never retry
    // or duplicate writes, and backend completion remains authoritative.
    await Future.wait(pending)
        .timeout(const Duration(seconds: 5), onTimeout: () => <void>[]);
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
        return text.replaceFirst('Exception: ', '');
      }
    }
    return fallback;
  }

  LessonTutorStatus get _tutorStatus {
    if (_lessonLoadError != null || _sendError != null) {
      return LessonTutorStatus.error;
    }
    if (_isSpeakingPlaceholderActive) {
      return LessonTutorStatus.speaking;
    }
    if (_isSending || _isStarting || _isLoadingScenario) {
      return LessonTutorStatus.thinking;
    }
    if (_isRecordingPlaceholderActive) {
      return LessonTutorStatus.listening;
    }
    return LessonTutorStatus.ready;
  }

  _LessonActionAvailability get _actionAvailability {
    final lessonReady = (_startResult?.isReady ?? false) &&
        !_isLoadingScenario &&
        _scenario != null &&
        _settings != null;
    return _LessonActionAvailability(
      canSendText: lessonReady && !_isSending && !_isFinishing && !_isCompleted,
      canToggleRecordingPlaceholder:
          lessonReady && !_isSending && !_isFinishing && !_isCompleted,
      canUsePlaceholders: lessonReady && !_isFinishing && !_isCompleted,
      canUseHintPlaceholder:
          lessonReady && !_isSending && !_isFinishing && !_isCompleted,
    );
  }

  bool get _canFinish =>
      (_startResult?.isReady ?? false) &&
      !_isLoadingScenario &&
      !_isSending &&
      !_isRecordingPlaceholderActive &&
      !_isFinishing &&
      !_isCompleted;

  Future<void> _confirmFinishLesson() async {
    if (!_canFinish) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish lesson?'),
        content: const Text('Finish this lesson and view your summary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue lesson'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finish lesson'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _finishLesson();
  }

  Future<void> _finishLesson() async {
    final session = _startResult?.session;
    if (session == null || !_canFinish) return;
    setState(() {
      _isFinishing = true;
      _finishError = null;
      _isRecordingPlaceholderActive = false;
      _isSpeakingPlaceholderActive = false;
    });
    await _waitForPendingMessagePersistence();
    if (!mounted) return;
    final turns = _messages.where((message) => message.isUser).length;
    final result = await _authService.finishLessonSession(
      sessionId: session.lessonSessionId,
      validTurnCount: turns,
    );
    if (!mounted) return;
    if (result.isCompleted) {
      setState(() {
        _isFinishing = false;
        _isCompleted = true;
        _lessonSummary = result.summary;
        _summaryStatus = result.status;
      });
      return;
    }
    setState(() {
      _isFinishing = false;
      _finishError = result.status == LessonCompletionStatus.authRequired
          ? 'Please sign in again to finish the lesson.'
          : result.status == LessonCompletionStatus.notFound
              ? 'This lesson session is no longer available.'
              : 'Could not finish the lesson. Please check your connection and try again.';
    });
  }

  String get _tutorDisplayName =>
      _displayNameForTutorId(_settings?.selectedTutorId ?? '');

  String _displayNameForTutorId(String tutorId) {
    final normalized = tutorId.trim().toLowerCase();
    if (normalized.isEmpty) return 'Tutor';
    return switch (normalized) {
      'lana' => 'Lana',
      'nelli' => 'Nelli',
      'david' => 'David',
      _ => normalized
          .split(RegExp(r'[_\-\s]+'))
          .where((part) => part.trim().isNotEmpty)
          .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
          .join(' '),
    };
  }

  String get _compactLevel {
    final selectionLevel = widget.selection?.level.trim() ?? '';
    final runtimeLevel = _scenario?.runtimeContent.resolvedLevelId.trim() ?? '';
    for (final candidate in [runtimeLevel, selectionLevel]) {
      final match = RegExp(r'\b(A1|A2|B1|B2|C1|C2)\b').firstMatch(candidate);
      if (match != null) return match.group(1)!;
    }
    return selectionLevel.isEmpty ? 'Level' : selectionLevel;
  }

  void _showComingNext(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$label: $_comingNextMessage')),
      );
  }

  void _scrollTranscriptToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_transcriptController.hasClients) return;
      _transcriptController.animateTo(
        _transcriptController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  void _toggleRecordingPlaceholder() {
    if (!_actionAvailability.canToggleRecordingPlaceholder) return;
    setState(() {
      _isRecordingPlaceholderActive = !_isRecordingPlaceholderActive;
      _isSpeakingPlaceholderActive = false;
    });
    _showComingNext(
      _isRecordingPlaceholderActive
          ? 'Recording placeholder'
          : 'Recording stopped',
    );
  }

  void _handleFutureAction(String label, {bool speaking = false}) {
    if (!_actionAvailability.canUsePlaceholders) return;
    setState(() {
      _isSpeakingPlaceholderActive = speaking;
      if (speaking) {
        _isRecordingPlaceholderActive = false;
      }
    });
    _showComingNext(label);
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    return Scaffold(
      body: SafeArea(
        child: selection == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Choose a level, topic, and situation to start a lesson.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _isCompleted
                ? _LessonSummaryView(
                    summary: _lessonSummary,
                    status: _summaryStatus ??
                        LessonCompletionStatus.summaryLoadError,
                    onDone: () => Navigator.of(context).maybePop(),
                    onRetrySummary: _retrySummary,
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: _LessonWorkspace(
                            selection: selection,
                            scenario: _scenario,
                            tutorDisplayName: _tutorDisplayName,
                            tutorStatus: _tutorStatus,
                            compactLevel: _compactLevel,
                            isStarting: _isStarting,
                            startResult: _startResult,
                            lessonLoadError: _lessonLoadError,
                            isLoadingScenario: _isLoadingScenario,
                            messages: _messages,
                            sendError: _sendError,
                            isSending: _isSending,
                            controller: _messageController,
                            actionAvailability: _actionAvailability,
                            isRecordingPlaceholderActive:
                                _isRecordingPlaceholderActive,
                            isFinishing: _isFinishing,
                            canFinish: _canFinish,
                            finishError: _finishError,
                            onBack: () => Navigator.of(context).maybePop(),
                            onFinish: _confirmFinishLesson,
                            onRetryStart: _isStarting
                                ? null
                                : () => _startLessonSession(),
                            onRetryLoad: _retryLessonRuntime,
                            transcriptController: _transcriptController,
                            onMessageAction: _handleFutureAction,
                            onToggleRecordingPlaceholder:
                                _toggleRecordingPlaceholder,
                            onHint: () => _handleFutureAction('Hint'),
                            onSend: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<void> _retrySummary() async {
    final session = _startResult?.session;
    if (session == null) return;
    final result = await _authService.loadLessonSummary(
        sessionId: session.lessonSessionId);
    if (!mounted) return;
    setState(() {
      _lessonSummary = result.summary;
      _summaryStatus = result.status;
    });
  }
}

class _LessonWorkspace extends StatelessWidget {
  const _LessonWorkspace({
    required this.selection,
    required this.scenario,
    required this.tutorDisplayName,
    required this.tutorStatus,
    required this.compactLevel,
    required this.isStarting,
    required this.startResult,
    required this.lessonLoadError,
    required this.isLoadingScenario,
    required this.messages,
    required this.sendError,
    required this.isSending,
    required this.transcriptController,
    required this.controller,
    required this.actionAvailability,
    required this.isRecordingPlaceholderActive,
    required this.isFinishing,
    required this.canFinish,
    required this.finishError,
    required this.onBack,
    required this.onFinish,
    required this.onRetryStart,
    required this.onRetryLoad,
    required this.onMessageAction,
    required this.onToggleRecordingPlaceholder,
    required this.onHint,
    required this.onSend,
  });

  final LessonStartSelection selection;
  final LessonRuntimeScenario? scenario;
  final String tutorDisplayName;
  final LessonTutorStatus tutorStatus;
  final String compactLevel;
  final bool isStarting;
  final LessonSessionStartResult? startResult;
  final String? lessonLoadError;
  final bool isLoadingScenario;
  final List<_LessonChatMessage> messages;
  final String? sendError;
  final bool isSending;
  final ScrollController transcriptController;
  final TextEditingController controller;
  final _LessonActionAvailability actionAvailability;
  final bool isRecordingPlaceholderActive;
  final bool isFinishing;
  final bool canFinish;
  final String? finishError;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final VoidCallback? onRetryStart;
  final Future<void> Function() onRetryLoad;
  final void Function(String label, {bool speaking}) onMessageAction;
  final VoidCallback onToggleRecordingPlaceholder;
  final VoidCallback onHint;
  final Future<void> Function([String? overrideText]) onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _TutorHeader(
            displayName: tutorDisplayName,
            status: tutorStatus,
            compactLevel: compactLevel,
            topic: scenario?.metadata.topic.isNotEmpty ?? false
                ? scenario!.metadata.topic
                : selection.topicTitle,
            onBack: onBack,
            canFinish: canFinish,
            onFinish: onFinish,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _LessonBody(
                      isStarting: isStarting,
                      startResult: startResult,
                      onRetryStart: onRetryStart,
                      lessonLoadError: lessonLoadError,
                      isLoadingScenario: isLoadingScenario,
                      onRetryLoad: onRetryLoad,
                      transcriptController: transcriptController,
                      messages: messages,
                      actionAvailability: actionAvailability,
                      onMessageAction: onMessageAction,
                    ),
                  ),
                  if (sendError != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        sendError!,
                        key: const Key('lesson-send-error'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                  if (finishError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(finishError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error)),
                    ),
                  if (isFinishing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Finishing lesson...',
                          key: Key('lesson-finishing-label')),
                    ),
                  _LessonComposer(
                    controller: controller,
                    canSendText: actionAvailability.canSendText,
                    canRecord: actionAvailability.canToggleRecordingPlaceholder,
                    canHint: actionAvailability.canUseHintPlaceholder,
                    isSending: isSending || isFinishing,
                    isRecordingPlaceholderActive: isRecordingPlaceholderActive,
                    onToggleRecordingPlaceholder: onToggleRecordingPlaceholder,
                    onHint: onHint,
                    onSend: onSend,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonBody extends StatelessWidget {
  const _LessonBody({
    required this.isStarting,
    required this.startResult,
    required this.onRetryStart,
    required this.lessonLoadError,
    required this.isLoadingScenario,
    required this.onRetryLoad,
    required this.transcriptController,
    required this.messages,
    required this.actionAvailability,
    required this.onMessageAction,
  });

  final bool isStarting;
  final LessonSessionStartResult? startResult;
  final VoidCallback? onRetryStart;
  final String? lessonLoadError;
  final bool isLoadingScenario;
  final Future<void> Function() onRetryLoad;
  final ScrollController transcriptController;
  final List<_LessonChatMessage> messages;
  final _LessonActionAvailability actionAvailability;
  final void Function(String label, {bool speaking}) onMessageAction;

  @override
  Widget build(BuildContext context) {
    if (isStarting) {
      return const Center(
        child: CircularProgressIndicator(key: Key('lesson-start-loading')),
      );
    }

    final start = startResult;
    if (start != null && !start.isReady) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(start.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetryStart,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (isLoadingScenario) {
      return const Center(
        child: CircularProgressIndicator(key: Key('lesson-runtime-loading')),
      );
    }

    if (lessonLoadError != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(lessonLoadError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                onRetryLoad();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry lesson content'),
            ),
          ],
        ),
      );
    }

    return _LessonTranscript(
      controller: transcriptController,
      messages: messages,
      actionAvailability: actionAvailability,
      onMessageAction: onMessageAction,
    );
  }
}

class _LessonTranscript extends StatelessWidget {
  const _LessonTranscript({
    required this.controller,
    required this.messages,
    required this.actionAvailability,
    required this.onMessageAction,
  });

  final ScrollController controller;
  final List<_LessonChatMessage> messages;
  final _LessonActionAvailability actionAvailability;
  final void Function(String label, {bool speaking}) onMessageAction;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your lesson is ready.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      key: const Key('lesson-chat-transcript'),
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = messages[index];
        return _LessonMessageBubble(
          message: message,
          actionAvailability: actionAvailability,
          onMessageAction: onMessageAction,
        );
      },
    );
  }
}

class _LessonMessageBubble extends StatelessWidget {
  const _LessonMessageBubble({
    required this.message,
    required this.actionAvailability,
    required this.onMessageAction,
  });

  final _LessonChatMessage message;
  final _LessonActionAvailability actionAvailability;
  final void Function(String label, {bool speaking}) onMessageAction;

  @override
  Widget build(BuildContext context) {
    final isTutor = message.isTutor;
    final colorScheme = Theme.of(context).colorScheme;
    final alignment = isTutor ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isTutor
        ? colorScheme.surfaceContainerHigh
        : colorScheme.primaryContainer;
    final textColor =
        isTutor ? colorScheme.onSurface : colorScheme.onPrimaryContainer;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: isTutor
                    ? [
                        IconButton(
                          key: const Key(
                              'lesson-message-action-tutor-translate'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Translation',
                          onPressed: actionAvailability.canUsePlaceholders
                              ? () => onMessageAction('Translation')
                              : null,
                          icon: const Icon(Icons.translate, size: 18),
                        ),
                        IconButton(
                          key: const Key('lesson-message-action-tutor-voice'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Play voice',
                          onPressed: actionAvailability.canUsePlaceholders
                              ? () => onMessageAction(
                                    'Play voice',
                                    speaking: true,
                                  )
                              : null,
                          icon: const Icon(Icons.volume_up_outlined, size: 18),
                        ),
                      ]
                    : [
                        IconButton(
                          key:
                              const Key('lesson-message-action-user-translate'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Translation',
                          onPressed: actionAvailability.canUsePlaceholders
                              ? () => onMessageAction('Translation')
                              : null,
                          icon: const Icon(Icons.translate, size: 18),
                        ),
                        IconButton(
                          key: const Key('lesson-message-action-user-feedback'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Feedback',
                          onPressed: actionAvailability.canUsePlaceholders
                              ? () => onMessageAction('Feedback')
                              : null,
                          icon:
                              const Icon(Icons.mode_comment_outlined, size: 18),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonComposer extends StatelessWidget {
  const _LessonComposer({
    required this.controller,
    required this.canSendText,
    required this.canRecord,
    required this.canHint,
    required this.isSending,
    required this.isRecordingPlaceholderActive,
    required this.onToggleRecordingPlaceholder,
    required this.onHint,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSendText;
  final bool canRecord;
  final bool canHint;
  final bool isSending;
  final bool isRecordingPlaceholderActive;
  final VoidCallback onToggleRecordingPlaceholder;
  final VoidCallback onHint;
  final Future<void> Function([String? overrideText]) onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('lesson-action-controls'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              OutlinedButton(
                key: const Key('lesson-action-record'),
                onPressed: canRecord ? onToggleRecordingPlaceholder : null,
                child: Icon(
                  isRecordingPlaceholderActive ? Icons.stop : Icons.mic_none,
                ),
              ),
              const SizedBox(width: 8),
              if (canHint)
                OutlinedButton.icon(
                  key: const Key('lesson-action-hint'),
                  onPressed: onHint,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Hint'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('lesson-input'),
                  controller: controller,
                  enabled: canSendText,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (canSendText) {
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
                  final canPressSend =
                      canSendText && value.text.trim().isNotEmpty;
                  return FilledButton(
                    key: const Key('lesson-send-button'),
                    onPressed: canPressSend
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
      ),
    );
  }
}

class _LessonChatMessage {
  const _LessonChatMessage.user(this.text) : kind = LessonMessageKind.user;

  const _LessonChatMessage.tutor(this.text) : kind = LessonMessageKind.tutor;

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
    required this.compactLevel,
    required this.topic,
    required this.onBack,
    required this.canFinish,
    required this.onFinish,
  });

  final String displayName;
  final LessonTutorStatus status;
  final String compactLevel;
  final String topic;
  final VoidCallback onBack;
  final bool canFinish;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tutorInitial =
        displayName.isEmpty ? 'T' : displayName.substring(0, 1);
    final statusColor = switch (status) {
      LessonTutorStatus.ready => colorScheme.onSurfaceVariant,
      LessonTutorStatus.thinking => colorScheme.primary,
      LessonTutorStatus.listening => colorScheme.tertiary,
      LessonTutorStatus.speaking => colorScheme.secondary,
      LessonTutorStatus.error => colorScheme.error,
    };
    return Container(
      key: const Key('lesson-tutor-header'),
      clipBehavior: Clip.antiAlias,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.35),
                  radius: 0.95,
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.88),
                    colorScheme.surface.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              key: const Key('lesson-avatar'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.24),
                    colorScheme.surface.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -36,
                    top: 28,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 140, height: 140),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        key: const Key('lesson-action-finish'),
                        tooltip: 'Finish lesson',
                        onPressed: canFinish ? onFinish : null,
                        icon: const Icon(Icons.flag_outlined),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 28,
                    bottom: -32,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 128, height: 128),
                    ),
                  ),
                  Center(
                    child: Text(
                      tutorInitial,
                      key: const Key('lesson-avatar-placeholder'),
                      style: textTheme.displayLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        key: const Key('lesson-back-button'),
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        _HeaderMetaChip(
                          key: const Key('lesson-meta-summary'),
                          label: '$compactLevel · $topic',
                        ),
                        if (displayName.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _HeaderMetaChip(
                            key: const Key('lesson-meta-tutor'),
                            label: displayName,
                            trailing: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonSummaryView extends StatelessWidget {
  const _LessonSummaryView({
    required this.summary,
    required this.status,
    required this.onDone,
    required this.onRetrySummary,
  });

  final LessonSummaryResponse? summary;
  final LessonCompletionStatus status;
  final VoidCallback onDone;
  final Future<void> Function() onRetrySummary;

  @override
  Widget build(BuildContext context) {
    final ready = status == LessonCompletionStatus.summaryReady &&
        (summary?.isReady ?? false);
    final unavailable = status == LessonCompletionStatus.summaryUnavailable;
    final canRetrySummary = status == LessonCompletionStatus.summaryLoadError;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            key: const Key('lesson-summary-scroll'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lesson summary',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                if (!ready) ...[
                  const Text('Lesson completed',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(unavailable
                      ? 'Your lesson was saved, but a summary could not be created for this lesson.'
                      : status == LessonCompletionStatus.authRequired
                          ? 'Please sign in again to load your lesson summary.'
                          : 'Your lesson was saved, but we could not load the summary right now.'),
                  const SizedBox(height: 20),
                  if (canRetrySummary)
                    OutlinedButton.icon(
                      onPressed: onRetrySummary,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry summary'),
                    ),
                ] else ...[
                  _SummaryContext(summary: summary!),
                  if (summary!.summary?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 20),
                    Text(summary!.summary!),
                  ],
                  _SummarySection('Strengths', summary!.strengths),
                  _SummarySection('Improvements', summary!.improvements),
                  _SummarySection('Vocabulary', summary!.vocabulary),
                  _SummarySection('Grammar', summary!.grammar),
                  _SummarySection('Next steps', summary!.nextSteps),
                ],
                const SizedBox(height: 28),
                FilledButton(onPressed: onDone, child: const Text('Done')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryContext extends StatelessWidget {
  const _SummaryContext({required this.summary});
  final LessonSummaryResponse summary;
  @override
  Widget build(BuildContext context) {
    final parts = [summary.level, summary.topicTitle, summary.subtopicTitle]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? const SizedBox.shrink() : Text(parts.join(' · '));
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection(this.title, this.items);
  final String title;
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _HeaderMetaChip extends StatelessWidget {
  const _HeaderMetaChip({
    super.key,
    required this.label,
    this.trailing,
  });

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
