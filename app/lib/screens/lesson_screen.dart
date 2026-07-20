import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/language_options.dart';
import '../models/audio_speech.dart';
import '../models/audio_transcription.dart';
import '../models/lesson_chat.dart';
import '../models/lesson_runtime.dart';
import '../models/lesson_session.dart';
import '../models/lesson_start_selection.dart';
import '../models/study_language_definition.dart';
import '../models/translation.dart';
import '../models/user_settings.dart';
import '../models/voice_scenario_resolution.dart';
import 'conversation_mode_screen.dart';
import '../services/auth_service.dart';
import '../services/lesson_context_selection_resolver.dart';
import '../services/localized_lesson_text_service.dart';
import '../services/lesson_roleplay_opening_builder.dart';
import '../services/lesson_turn_request_builder.dart';
import '../services/mobile_transcription_request_builder.dart';
import '../services/tutor_avatar_preloader.dart';
import '../services/tutor_audio_playback_service.dart';
import '../services/tutor_speech_request_builder.dart';
import '../services/transcript_script_normalizer.dart';
import '../services/voice_scenario_intent_resolver.dart';
import '../widgets/tutor_avatar.dart';
import '../services/learner_audio_recording_service.dart';
import '../services/learner_microphone_permission_service.dart';
import '../services/service_factory.dart';

enum LessonTutorStatus {
  ready,
  thinking,
  listening,
  transcribing,
  speaking,
  error,
}

enum LearnerRecordingUiState {
  idle,
  requestingPermission,
  recording,
  stopping,
  transcribing,
  transcriptReady,
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
    required this.canUseFeedback,
    required this.canUseTranslation,
    required this.canUseTts,
    required this.canUseHint,
  });

  final bool canSendText;
  final bool canToggleRecordingPlaceholder;
  final bool canUsePlaceholders;
  final bool canUseFeedback;
  final bool canUseTranslation;
  final bool canUseTts;
  final bool canUseHint;
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    this.selection,
    AuthService? authService,
    TutorAudioPlaybackService? audioPlaybackService,
    LearnerAudioRecordingService? recordingService,
    LearnerMicrophonePermissionService? microphonePermissionService,
  })  : _authService = authService,
        _audioPlaybackService = audioPlaybackService,
        _recordingService = recordingService,
        _microphonePermissionService = microphonePermissionService;

  static const String routeName = '/lesson';

  final LessonStartSelection? selection;
  final AuthService? _authService;
  final TutorAudioPlaybackService? _audioPlaybackService;
  final LearnerAudioRecordingService? _recordingService;
  final LearnerMicrophonePermissionService? _microphonePermissionService;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with WidgetsBindingObserver {
  static const _hintFallbackUserMessage = 'I need a hint for what to say next.';

  late final AuthService _authService;
  late final TutorAudioPlaybackService _audioPlaybackService;
  late final LearnerAudioRecordingService _recordingService;
  late final LearnerMicrophonePermissionService _microphonePermissionService;
  late final StreamSubscription<void> _playbackCompletedSubscription;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _transcriptController = ScrollController();
  late bool _isStarting;
  bool _startInFlight = false;
  bool _isLoadingScenario = false;
  bool _isSending = false;
  bool _isHintLoading = false;
  bool _isFinishing = false;
  bool _isAbandoning = false;
  bool _isCompleted = false;
  bool _isAuthenticationRequired = false;
  bool _lessonSessionEnded = false;
  bool _autoSendVoice = false;
  bool _autoPlayBotVoice = false;
  bool _isTextComposerVisible = false;
  bool _automaticVoiceSubmissionInFlight = false;
  bool _composerContainsVoiceTranscript = false;
  int _recordingOperationGeneration = 0;
  LearnerRecordingUiState _recordingState = LearnerRecordingUiState.idle;
  String? _recordingFilePath;
  String _draftWhenRecordingStarted = '';
  DateTime? _recordingStartedAt;
  Timer? _recordingTimer;
  bool _transcriptionEligible = true;
  String? _recordingMessage;
  bool _showOpenMicrophoneSettings = false;
  LessonSessionStartResult? _startResult;
  LessonRuntimeScenario? _scenario;
  UserSettings? _settings;
  String? _lessonLoadError;
  String? _sendError;
  String? _hintText;
  String? _hintError;
  String? _selectedContextId;
  String? _selectedContextTitle;
  String? _customLearnerContext;
  List<LessonRuntimeContextVariant> _voiceClarificationChoices = const [];
  int _activeRoleplayLearnerTurnCount = 0;
  String? _finishError;
  LessonSummaryResponse? _lessonSummary;
  LessonCompletionStatus? _summaryStatus;
  final List<_LessonChatMessage> _messages = [];
  final Set<Future<void>> _pendingMessagePersistence = {};
  int? _activePlayingMessageId;
  int _playbackOperationGeneration = 0;
  static const _turnRequestBuilder = LessonTurnRequestBuilder();
  static const _transcriptionRequestBuilder =
      MobileTranscriptionRequestBuilder();
  static const _roleplayOpeningBuilder = LessonRoleplayOpeningBuilder();
  static const _speechRequestBuilder = TutorSpeechRequestBuilder();
  final _avatarPreloader = TutorAvatarPreloader();
  Future<bool>? _conversationAvatarPreload;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _audioPlaybackService =
        widget._audioPlaybackService ?? JustAudioTutorPlaybackService();
    _recordingService =
        widget._recordingService ?? LearnerAudioRecordingService();
    _microphonePermissionService = widget._microphonePermissionService ??
        PermissionHandlerLearnerMicrophonePermissionService();
    _playbackCompletedSubscription =
        _audioPlaybackService.completed.listen((_) => _onPlaybackCompleted());
    WidgetsBinding.instance.addObserver(this);
    _isStarting = widget.selection != null;
    _selectedContextId = widget.selection?.selectedContextId?.trim();
    _selectedContextTitle = widget.selection?.selectedContextTitle?.trim();
    if (widget.selection != null) {
      _startLessonSession(showLoadingState: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_cancelLearnerRecording(forDeparture: true));
    unawaited(_recordingService.dispose());
    unawaited(_disposeAudio());
    _messageController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_stopTutorPlayback());
      unawaited(_cancelLearnerRecording());
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshMicrophonePermissionAfterResume());
    }
  }

  Future<void> _disposeAudio() async {
    await _stopAndClearTutorAudio();
    await _playbackCompletedSubscription.cancel();
    await _audioPlaybackService.dispose();
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
      _hintText = null;
      _hintError = null;
      _isHintLoading = false;
      _isAuthenticationRequired = false;
      _lessonSessionEnded = false;
      _scenario = null;
      _settings = null;
      _recordingState = LearnerRecordingUiState.idle;
      _messages.clear();
      _voiceClarificationChoices = const [];
    });

    try {
      final settings = await _authService.fetchUserSettings();
      final scenario = await _authService.fetchLessonRuntimeScenario(
        scenarioKey: selection.lessonContentId,
      );
      _debugRuntimeDiagnostics(scenario, settings);
      final openingMessage = _buildInitialTutorMessage(
        scenario: scenario,
        studyLanguage: StudyLanguageDefinitions.resolve(settings.studyLanguage),
      );
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _scenario = scenario;
        _messages.add(openingMessage);
        _isLoadingScenario = false;
      });
      _warmTutorAvatars(settings);
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

  void _debugRuntimeDiagnostics(
    LessonRuntimeScenario scenario,
    UserSettings settings,
  ) {
    if (!kDebugMode) return;
    final runtime = scenario.runtimeContent;
    final tutor =
        scenario.tutorProfiles.cast<LessonRuntimeTutorProfile?>().firstWhere(
              (profile) =>
                  profile?.tutorId.trim().toLowerCase() ==
                  settings.selectedTutorId.trim().toLowerCase(),
              orElse: () => null,
            );
    final source = runtime.effectiveRuntimeSource.trim();
    debugPrint(
      'lesson_runtime scenarioId=${scenario.id} '
      'version=${runtime.versionNumber?.toString() ?? ''} '
      'tutorId=${tutor?.tutorId ?? settings.selectedTutorId} '
      'source=${source.isEmpty ? 'unknown' : source} '
      'tutorInstructionsPresent=${scenario.aiTutorPromptInstructions.isNotEmpty} '
      'tutorInstructionsLength=${scenario.aiTutorPromptInstructions.length} '
      'conversationFlowPresent=${scenario.conversationFlow.opening.trim().isNotEmpty} '
      'conversationFlowLength=${scenario.conversationFlow.opening.length} '
      'learningGoalPresent=${scenario.learningGoal.goal.trim().isNotEmpty} '
      'learningGoalLength=${scenario.learningGoal.goal.length} '
      'contextVariantsPresent=${scenario.controlledVariation.contextVariants.isNotEmpty} '
      'contextVariantsLength=${scenario.controlledVariation.contextVariants.length} '
      'openingPresent=${scenario.conversationFlow.opening.trim().isNotEmpty} '
      'openingLength=${scenario.conversationFlow.opening.length}',
    );
  }

  void _debugVoiceScenarioResolution({
    required String stage,
    required String decision,
    required int candidateCount,
    required bool matchedContextPresent,
    required double confidence,
    required bool hadContextBefore,
    required String action,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'voice_scenario_resolution stage=$stage decision=$decision '
      'candidateCount=$candidateCount '
      'matchedContextPresent=$matchedContextPresent '
      'confidence=${confidence.toStringAsFixed(3)} '
      'hadContextBefore=$hadContextBefore action=$action',
    );
  }

  void _warmTutorAvatars(UserSettings settings) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_avatarPreloader.preload(
        context: context,
        tutorId: settings.selectedTutorId,
        surface: TutorAvatarSurface.lessonChat,
      ));
      _conversationAvatarPreload ??= _avatarPreloader.preload(
        context: context,
        tutorId: settings.selectedTutorId,
        surface: TutorAvatarSurface.conversationMode,
      );
      if (mounted) setState(() {});
    });
  }

  _LessonChatMessage _buildInitialTutorMessage({
    required LessonRuntimeScenario scenario,
    required StudyLanguageDefinition studyLanguage,
  }) {
    return _LessonChatMessage.tutor(
      LocalizedLessonTextService.buildSetupMessage(
        scenario: scenario,
        studyLanguage: studyLanguage,
      ),
    );
  }

  Future<String> _studyLanguage() async {
    try {
      final settings = await _authService.fetchUserSettings();
      return StudyLanguageDefinitions.resolve(settings.studyLanguage)
          .englishName;
    } catch (_) {
      return StudyLanguageDefinitions.resolve(null).englishName;
    }
  }

  Future<void> _retryLessonRuntime() async {
    final selection = widget.selection;
    final session = _startResult?.session;
    if (selection == null || session == null || _isLoadingScenario) return;
    await _loadLessonRuntime(selection, session);
  }

  Future<void> _openConversationMode() async {
    final session = _startResult?.session;
    final scenario = _scenario;
    final settings = _settings;
    if (session == null || scenario == null || settings == null) return;
    final preload = _conversationAvatarPreload ??= _avatarPreloader.preload(
      context: context,
      tutorId: settings.selectedTutorId,
      surface: TutorAvatarSurface.conversationMode,
    );
    // Avatar warmup is optional. A missing/unsupported GIF must never block
    // entering Conversation mode.
    await preload.timeout(const Duration(milliseconds: 300),
        onTimeout: () => false);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationModeScreen(
          authService: _authService,
          audioPlaybackService: JustAudioTutorPlaybackService(),
          recordingService: LearnerAudioRecordingService(),
          microphonePermissionService:
              PermissionHandlerLearnerMicrophonePermissionService(),
          session: session,
          scenario: scenario,
          settings: settings,
          selectedContextTitle: _currentSelectedContextTitle,
          tutorDisplayName: _tutorDisplayName,
          initialTranscript: _messages
              .map((message) => message.text)
              .where((text) => text.trim().isNotEmpty)
              .toList(growable: false),
          onSubmitTranscript: (text) => _sendMessageInternal(
            overrideText: text,
            source: 'voice_transcript',
            suppressAutomaticPlayback: true,
          ),
          onHint: _requestConversationHint,
          onFinish: _confirmFinishLesson,
          ownsAudioPlaybackService: true,
        ),
      ),
    );
  }

  Future<String?> _requestConversationHint() async {
    await _requestHint();
    return _hintText;
  }

  Future<void> _sendMessage([String? overrideText]) async {
    await _sendMessageInternal(
      overrideText: overrideText,
      source: _composerContainsVoiceTranscript ? 'voice_transcript' : 'typed',
    );
  }

  Future<String?> _sendMessageInternal({
    String? overrideText,
    String source = 'typed',
    bool automaticVoiceSubmission = false,
    int? recordingGeneration,
    bool suppressAutomaticPlayback = false,
  }) async {
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
        (automaticVoiceSubmission &&
            (_automaticVoiceSubmissionInFlight ||
                recordingGeneration != _recordingOperationGeneration)) ||
        _isFinishing ||
        _isCompleted ||
        _lessonSessionEnded ||
        _isAuthenticationRequired) {
      return null;
    }

    if (text.isEmpty) {
      setState(() {
        _sendError = 'Please enter a message.';
      });
      return null;
    }

    final hadSelectedContextBeforeResolution = _hasSelectedContext;
    final studyLanguage =
        StudyLanguageDefinitions.resolve(settings.studyLanguage);
    var contextInput = text;
    VoiceScenarioDeterministicResult? voiceIntent;
    if (source == 'voice_transcript' && !hadSelectedContextBeforeResolution) {
      voiceIntent = VoiceScenarioIntentResolver.resolve(
        transcript: text,
        variants: scenario.controlledVariation.contextVariants,
        localizedTitlesById: {
          for (final variant in scenario.controlledVariation.contextVariants)
            variant.id: LocalizedLessonTextService.localizedScenarioTitle(
              variant,
              studyLanguage,
            ),
        },
      );
      if (voiceIntent.decision ==
          VoiceScenarioDeterministicDecision.unsafeTranscript) {
        const message = 'I could not recognize that clearly. Please try again.';
        _debugVoiceScenarioResolution(
          stage: 'deterministic',
          decision: 'unsafe',
          candidateCount: scenario.controlledVariation.contextVariants.length,
          matchedContextPresent: false,
          confidence: 1,
          hadContextBefore: false,
          action: 'review_text',
        );
        setState(() {
          _sendError = message;
          _recordingState = LearnerRecordingUiState.idle;
          _automaticVoiceSubmissionInFlight = false;
        });
        return message;
      }
      if (voiceIntent.decision ==
          VoiceScenarioDeterministicDecision.publishedScenario) {
        contextInput = voiceIntent.matchedVariant!.title;
        _debugVoiceScenarioResolution(
          stage: 'deterministic',
          decision: 'published',
          candidateCount: scenario.controlledVariation.contextVariants.length,
          matchedContextPresent: true,
          confidence: voiceIntent.confidence,
          hadContextBefore: false,
          action: 'start_cms',
        );
      } else {
        final semantic = await _authService.resolveVoiceScenario(
          sessionId: session.lessonSessionId,
          request: VoiceScenarioResolutionRequest(
            studyLanguage: studyLanguage.englishName,
            learnerLevel: selection.level,
            topicId: selection.topicId,
            subtopicId: selection.subtopicId,
            runtimeScenarioId: scenario.id,
            runtimeVersion: scenario.runtimeContent.versionNumber,
            recognizedText: text,
            candidates: scenario.controlledVariation.contextVariants
                .map((variant) => VoiceScenarioCandidateRequest(
                      id: variant.id,
                      title: variant.title,
                      description:
                          LocalizedLessonTextService.localizedScenarioTitle(
                        variant,
                        studyLanguage,
                      ),
                    ))
                .toList(growable: false),
          ),
        );
        if (!semantic.isSuccess) {
          final message = semantic.message!;
          _debugVoiceScenarioResolution(
            stage: 'backend_semantic',
            decision: 'failed',
            candidateCount: scenario.controlledVariation.contextVariants.length,
            matchedContextPresent: false,
            confidence: 0,
            hadContextBefore: false,
            action: 'review_text',
          );
          setState(() {
            _messageController.text = text;
            _isTextComposerVisible = true;
            _composerContainsVoiceTranscript = false;
            _sendError = message;
            _recordingState = LearnerRecordingUiState.idle;
            _automaticVoiceSubmissionInFlight = false;
          });
          return message;
        }
        final response = semantic.response!;
        final matched = response.matchedContextId == null
            ? null
            : scenario.controlledVariation.contextVariants
                .cast<LessonRuntimeContextVariant?>()
                .firstWhere(
                  (variant) => variant?.id == response.matchedContextId,
                  orElse: () => null,
                );
        final action = switch (response.decision) {
          VoiceScenarioSemanticDecision.publishedContext => 'start_cms',
          VoiceScenarioSemanticDecision.freeContext => 'start_free',
          VoiceScenarioSemanticDecision.clarify => 'clarify',
          VoiceScenarioSemanticDecision.unsafe => 'review_text',
        };
        final decision = switch (response.decision) {
          VoiceScenarioSemanticDecision.publishedContext => 'published',
          VoiceScenarioSemanticDecision.freeContext => 'free',
          VoiceScenarioSemanticDecision.clarify => 'clarify',
          VoiceScenarioSemanticDecision.unsafe => 'unsafe',
        };
        _debugVoiceScenarioResolution(
          stage: 'backend_semantic',
          decision: decision,
          candidateCount: scenario.controlledVariation.contextVariants.length,
          matchedContextPresent: matched != null,
          confidence: response.confidence,
          hadContextBefore: false,
          action: action,
        );
        if (response.decision ==
            VoiceScenarioSemanticDecision.publishedContext) {
          if (matched == null) {
            const message =
                'Scenario matching is temporarily unavailable. Review or edit the recognized text.';
            setState(() {
              _messageController.text = text;
              _isTextComposerVisible = true;
              _sendError = message;
              _recordingState = LearnerRecordingUiState.idle;
            });
            return message;
          }
          contextInput = matched.title;
        } else if (response.decision ==
            VoiceScenarioSemanticDecision.freeContext) {
          contextInput = response.normalizedFreeContext?.trim() ?? '';
          if (contextInput.isEmpty) {
            contextInput = text;
          }
        } else {
          final choices = response.candidateContextIds
              .map((id) => scenario.controlledVariation.contextVariants
                  .cast<LessonRuntimeContextVariant?>()
                  .firstWhere((variant) => variant?.id == id,
                      orElse: () => null))
              .whereType<LessonRuntimeContextVariant>()
              .take(2)
              .toList(growable: false);
          final choiceText = choices.indexed
              .map((entry) => '${entry.$1 + 1}. '
                  '${LocalizedLessonTextService.localizedScenarioTitle(entry.$2, studyLanguage)}')
              .join('\n');
          final backendClarification = response.clarificationText?.trim();
          final message = backendClarification?.isNotEmpty == true
              ? choiceText.isEmpty
                  ? backendClarification!
                  : '$backendClarification\n$choiceText'
              : response.decision == VoiceScenarioSemanticDecision.unsafe
                  ? 'I could not recognize that clearly. Please try again.'
                  : choiceText.isEmpty
                      ? 'Please name a specific situation, or say an option number.'
                      : 'Did you mean:\n$choiceText';
          setState(() {
            _isTextComposerVisible = true;
            _voiceClarificationChoices = choices;
            _sendError = message;
            _recordingState = LearnerRecordingUiState.idle;
            _automaticVoiceSubmissionInFlight = false;
          });
          return message;
        }
      }
    } else if (source == 'voice_transcript' && kDebugMode) {
      final selectedVariant = _selectedContextVariant(scenario);
      _debugVoiceScenarioResolution(
        stage: 'deterministic',
        decision: selectedVariant == null ? 'free' : 'published',
        candidateCount: 0,
        matchedContextPresent: selectedVariant != null,
        confidence: 1,
        hadContextBefore: true,
        action: 'normal_reply',
      );
    }
    final resolved = LessonContextSelectionResolver.resolve(
      scenario: scenario,
      currentSelectedContextId: _selectedContextId,
      currentSelectedContextTitle: _selectedContextTitle,
      learnerInput: contextInput,
      studyLanguage: studyLanguage,
    );
    _selectedContextId = resolved.selectedContextId;
    _selectedContextTitle = resolved.selectedContextTitle;
    _customLearnerContext =
        resolved.isCustomContext ? resolved.selectedContextTitle : null;
    _voiceClarificationChoices = const [];

    final useLocalCmsContextStart =
        !hadSelectedContextBeforeResolution && resolved.isKnownCmsContext;
    if (kDebugMode) {
      debugPrint(
        'context_branch inputResolved=${resolved.selectedContextVariant != null} '
        'knownContext=${resolved.isKnownCmsContext} '
        'customContext=${resolved.isCustomContext} '
        'isContextSelectionTurn=${resolved.isContextSelectionTurn} '
        'selectedContextBefore=$hadSelectedContextBeforeResolution '
        'selectedContextAfter=$_hasSelectedContext '
        'localCmsBranch=$useLocalCmsContextStart '
        'lessonReplyBranch=${!useLocalCmsContextStart}',
      );
    }

    if (useLocalCmsContextStart) {
      return _startKnownContextRoleplay(
        session: session,
        scenario: scenario,
        settings: settings,
        context: resolved,
        learnerText: contextInput,
        source: source,
      );
    }

    final userMessage = _LessonChatMessage.user(contextInput);
    final lastBotMessage = _messages.lastWhere(
      (message) => message.isBot,
      orElse: () => _LessonChatMessage.tutor(''),
    );
    final updatedMessages = [..._messages, userMessage];
    final learnerTurnCount = _activeRoleplayLearnerTurnCount + 1;
    final request = _turnRequestBuilder.build(
      scenario: scenario,
      settings: settings,
      selectedLevel: selection.level,
      userMessage: contextInput,
      lastBotMessage: lastBotMessage.text,
      learnerTurnCount: learnerTurnCount,
      recentMessages: _recentConversationMessages(updatedMessages),
      backendSessionId: session.lessonSessionId,
      context: resolved,
    );
    if (kDebugMode) {
      debugPrint(
        'lesson_chat_reply operation=reply '
        'session=${session.lessonSessionId} '
        'turn=${request.learnerTurnCount} '
        'source=$source '
        'isContextSelectionTurn=${request.isContextSelectionTurn} '
        'contextTitle=${request.selectedContextTitle.isNotEmpty} '
        'contextVariant=${request.selectedContextVariantId.isNotEmpty} '
        'lessonPhase=${request.lessonPhase} '
        'recentMessages=${request.recentMessages.length} '
        'lastBotPresent=${request.lastBotMessage.trim().isNotEmpty}',
      );
    }

    setState(() {
      _isSending = true;
      if (automaticVoiceSubmission) {
        _automaticVoiceSubmissionInFlight = true;
      }
      _sendError = null;
      _recordingState = LearnerRecordingUiState.idle;
      _hintText = null;
      _hintError = null;
      _messages
        ..clear()
        ..addAll(updatedMessages);
      if (overrideText == null) {
        _messageController.clear();
        _composerContainsVoiceTranscript = false;
      }
    });

    final result = await _authService.sendLessonChatReply(request: request);
    if (kDebugMode) {
      debugPrint(
        'lesson_chat_reply operation=reply_result '
        'status=${result.status} '
        'success=${result.isSuccess}',
      );
    }
    if (!mounted) return null;

    if (!result.isSuccess || result.reply == null) {
      setState(() {
        _isSending = false;
        _automaticVoiceSubmissionInFlight = false;
        _messages.removeWhere((message) => identical(message, userMessage));
        _sendError = result.message;
        if (automaticVoiceSubmission &&
            _messageController.text.trim().isEmpty &&
            recordingGeneration == _recordingOperationGeneration) {
          _messageController.text = text;
          _isTextComposerVisible = true;
        }
      });
      return null;
    }

    final botText = result.reply!.botReply.trim();
    final tutorMessage =
        botText.isEmpty ? null : _LessonChatMessage.tutor(botText);
    setState(() {
      _isSending = false;
      _automaticVoiceSubmissionInFlight = false;
      _sendError = null;
      if (tutorMessage != null) _messages.add(tutorMessage);
      _activeRoleplayLearnerTurnCount = learnerTurnCount;
    });
    _scrollTranscriptToBottom();

    final persistenceOperation = _persistChatMessages(
      sessionId: session.lessonSessionId,
      studyLanguage: session.studyLanguage,
      userMessage: userMessage,
      botText: botText,
      turnNumber: learnerTurnCount,
      source: source,
    );
    userMessage.persistenceOperation = persistenceOperation;
    _trackMessagePersistence(persistenceOperation);
    if (tutorMessage != null &&
        !suppressAutomaticPlayback &&
        _autoPlayBotVoice) {
      await _playTutorVoice(
        tutorMessage,
        purpose: AudioSpeechPurpose.lessonChatTts,
      );
    }
    return botText;
  }

  Future<String?> _startKnownContextRoleplay({
    required LessonSessionResponse session,
    required LessonRuntimeScenario scenario,
    required UserSettings settings,
    required LessonContextSelection context,
    required String learnerText,
    required String source,
  }) async {
    final variant = context.selectedContextVariant;
    if (variant == null) return null;
    final opening = _roleplayOpeningBuilder.buildKnownContextOpening(
      scenario: scenario,
      variant: variant,
      studyLanguage: StudyLanguageDefinitions.resolve(settings.studyLanguage),
      tutorDisplayName: _runtimeTutorDisplayName(settings),
    );
    if (opening.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            'cms_context_start contextMessageAdded=false openingMessageAdded=false contextPersistScheduled=false openingPersistScheduled=false lessonReplyCalled=false');
      }
      setState(() => _sendError = 'This lesson context is unavailable.');
      return null;
    }

    // Desktop records the resolved CMS title, not the learner's punctuation
    // or numeric shortcut, for known context selections.
    final userMessage = _LessonChatMessage.user(
      context.selectedContextLocalizedTitle?.trim().isNotEmpty == true
          ? context.selectedContextLocalizedTitle!.trim()
          : learnerText,
      isContextSelection: true,
    );
    final tutorMessage = _LessonChatMessage.tutor(opening, isCmsOpening: true);
    setState(() {
      _sendError = null;
      _hintText = null;
      _hintError = null;
      _recordingState = LearnerRecordingUiState.idle;
      _messages.addAll([userMessage, tutorMessage]);
      _activeRoleplayLearnerTurnCount = 0;
      if (source == 'typed' || _composerContainsVoiceTranscript) {
        _messageController.clear();
      }
      _composerContainsVoiceTranscript = false;
    });
    _scrollTranscriptToBottom();
    final persistence = _persistChatMessages(
      sessionId: session.lessonSessionId,
      studyLanguage: session.studyLanguage,
      userMessage: userMessage,
      botText: opening,
      turnNumber: 0,
      source: source,
    );
    userMessage.persistenceOperation = persistence;
    _trackMessagePersistence(persistence);
    if (kDebugMode) {
      debugPrint(
          'cms_context_start contextMessageAdded=true openingMessageAdded=true contextPersistScheduled=true openingPersistScheduled=true lessonReplyCalled=false');
    }
    return opening;
  }

  Future<void> _requestHint() async {
    final selection = widget.selection;
    final session = _startResult?.session;
    final scenario = _scenario;
    final settings = _settings;
    if (selection == null ||
        session == null ||
        scenario == null ||
        settings == null ||
        !_actionAvailability.canUseHint) {
      return;
    }

    if (!_hasSelectedContext) {
      setState(() {
        _hintError = null;
        _hintText = LocalizedLessonTextService.buildSetupContextHint(
          scenario: scenario,
          studyLanguage:
              StudyLanguageDefinitions.resolve(settings.studyLanguage),
        );
      });
      return;
    }

    if (_isFirstActiveRoleplayStep(scenario) &&
        _messages
            .where((message) => message.isUser && !message.isContextSelection)
            .isEmpty &&
        scenario.hintRules.exampleHint.trim().isNotEmpty) {
      setState(() {
        _hintError = null;
        _hintText = LocalizedLessonTextService.buildExampleHint(
          scenario.hintRules.exampleHint,
          StudyLanguageDefinitions.resolve(settings.studyLanguage),
        );
      });
      return;
    }

    final lastBotMessage = _messages.lastWhere(
      (message) => message.isBot,
      orElse: () => _LessonChatMessage.tutor(''),
    );
    final learnerTurnCount =
        _messages.where((message) => message.isUser).length;
    final request = _turnRequestBuilder.build(
      scenario: scenario,
      settings: settings,
      selectedLevel: selection.level,
      userMessage: _messageController.text.trim().isEmpty
          ? _hintFallbackUserMessage
          : _messageController.text.trim(),
      lastBotMessage: lastBotMessage.text,
      learnerTurnCount: learnerTurnCount,
      recentMessages: _recentConversationMessages(_messages),
      backendSessionId: session.lessonSessionId,
      context: LessonContextSelectionResolver.resolve(
        scenario: scenario,
        currentSelectedContextId: _selectedContextId,
        currentSelectedContextTitle: _currentSelectedContextTitle,
        learnerInput: '',
        studyLanguage: StudyLanguageDefinitions.resolve(settings.studyLanguage),
      ),
    );

    setState(() {
      _isHintLoading = true;
      _hintText = null;
      _hintError = null;
    });
    final result = await _authService.requestLessonChatHint(request: request);
    if (!mounted) return;
    setState(() {
      _isHintLoading = false;
      if (result.isSuccess && result.hint != null) {
        _hintText = result.hint!.hintText;
        _hintError = null;
      } else {
        _hintError = result.message;
        if (result.status == LessonChatHintStatus.authRequired) {
          _isAuthenticationRequired = true;
        }
        if (result.status == LessonChatHintStatus.notFound ||
            result.status == LessonChatHintStatus.conflict) {
          _lessonSessionEnded = true;
        }
      }
    });
  }

  bool _isFirstActiveRoleplayStep(LessonRuntimeScenario scenario) =>
      scenario.runtimeContent.lessonPhase.trim().toLowerCase() ==
      'active_roleplay';

  bool get _hasSelectedContext =>
      (_selectedContextId?.isNotEmpty ?? false) ||
      (_selectedContextTitle?.isNotEmpty ?? false) ||
      (_customLearnerContext?.isNotEmpty ?? false);

  String get _currentSelectedContextTitle =>
      _customLearnerContext ?? _selectedContextTitle ?? '';

  LessonRuntimeContextVariant? _selectedContextVariant(
    LessonRuntimeScenario scenario,
  ) {
    final selectedId = _selectedContextId;
    if (selectedId == null || selectedId.isEmpty) return null;
    for (final variant in scenario.controlledVariation.contextVariants) {
      if (variant.id == selectedId) return variant;
    }
    return null;
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
    required _LessonChatMessage userMessage,
    required String botText,
    required int turnNumber,
    String source = 'typed',
  }) async {
    try {
      final persistedUserMessageId =
          await _authService.persistLessonSessionMessage(
        sessionId: sessionId,
        request: CreateLessonSessionMessageRequest(
          role: 'user',
          text: userMessage.text,
          source: source,
          turnNumber: turnNumber,
          isValidLessonTurn: true,
          studyLanguage: studyLanguage,
        ),
      );
      userMessage.persistedBackendMessageId = persistedUserMessageId;
      userMessage.persistenceError = null;
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
      userMessage.persistenceError =
          'Feedback is not ready yet. Please try again.';
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
    if (_activePlayingMessageId != null) {
      return LessonTutorStatus.speaking;
    }
    if (_recordingState == LearnerRecordingUiState.recording) {
      return LessonTutorStatus.listening;
    }
    if (_recordingState == LearnerRecordingUiState.stopping ||
        _recordingState == LearnerRecordingUiState.transcribing) {
      return LessonTutorStatus.transcribing;
    }
    if (_isSending ||
        _isStarting ||
        _isLoadingScenario ||
        _isHintLoading ||
        _messages.any(
            (message) => message.isFeedbackLoading || message.isTtsLoading)) {
      return LessonTutorStatus.thinking;
    }
    if (_lessonLoadError != null || _sendError != null) {
      return LessonTutorStatus.error;
    }
    return LessonTutorStatus.ready;
  }

  _LessonActionAvailability get _actionAvailability {
    final lessonReady = (_startResult?.isReady ?? false) &&
        !_isLoadingScenario &&
        _scenario != null &&
        _settings != null;
    final hasPerMessageWork = _messages.any(
      (message) => message.isTranslationLoading || message.isFeedbackLoading,
    );
    final tutorAudioLoading = _messages.any((message) => message.isTtsLoading);
    final recordingBusy =
        _recordingState == LearnerRecordingUiState.requestingPermission ||
            _recordingState == LearnerRecordingUiState.recording ||
            _recordingState == LearnerRecordingUiState.stopping ||
            _recordingState == LearnerRecordingUiState.transcribing;
    return _LessonActionAvailability(
      canSendText: lessonReady &&
          !_isSending &&
          !_isFinishing &&
          !_isCompleted &&
          !_lessonSessionEnded &&
          !_isAuthenticationRequired &&
          !recordingBusy,
      canToggleRecordingPlaceholder: lessonReady &&
          !_isSending &&
          !_isHintLoading &&
          !hasPerMessageWork &&
          !tutorAudioLoading &&
          !_isAbandoning &&
          !_isFinishing &&
          !_isCompleted &&
          !_lessonSessionEnded &&
          !_isAuthenticationRequired &&
          (_recordingState == LearnerRecordingUiState.idle ||
              _recordingState == LearnerRecordingUiState.transcriptReady ||
              _recordingState == LearnerRecordingUiState.error ||
              _recordingState == LearnerRecordingUiState.recording),
      canUsePlaceholders: lessonReady &&
          !_isFinishing &&
          !_isCompleted &&
          !_lessonSessionEnded &&
          !_isAuthenticationRequired,
      canUseFeedback: lessonReady &&
          !_isFinishing &&
          !_isAbandoning &&
          !_isCompleted &&
          !_lessonSessionEnded &&
          !_isAuthenticationRequired,
      canUseTranslation: lessonReady &&
          !_isFinishing &&
          !_isAbandoning &&
          !_isCompleted &&
          !_lessonSessionEnded &&
          !_isAuthenticationRequired,
      canUseTts: lessonReady &&
          !_isFinishing &&
          !_isAbandoning &&
          !_isCompleted &&
          !_lessonSessionEnded &&
          !_isAuthenticationRequired,
      canUseHint: lessonReady &&
          !_isSending &&
          !_isHintLoading &&
          !_isFinishing &&
          !_isCompleted &&
          !_lessonSessionEnded &&
          !_isAuthenticationRequired,
    );
  }

  bool get _canFinish =>
      (_startResult?.isReady ?? false) &&
      !_isLoadingScenario &&
      !_isSending &&
      !_isHintLoading &&
      _recordingState != LearnerRecordingUiState.recording &&
      _recordingState != LearnerRecordingUiState.stopping &&
      _recordingState != LearnerRecordingUiState.transcribing &&
      !_isFinishing &&
      !_isCompleted;

  bool get _hasActiveLessonSession =>
      (_startResult?.isReady ?? false) && !_lessonSessionEnded && !_isCompleted;

  bool get _canAbandon =>
      _hasActiveLessonSession &&
      !_isSending &&
      !_isHintLoading &&
      !_isFinishing &&
      !_isLoadingScenario &&
      _recordingState != LearnerRecordingUiState.recording &&
      _recordingState != LearnerRecordingUiState.stopping &&
      _recordingState != LearnerRecordingUiState.transcribing &&
      !_isAbandoning;

  Future<void> _handleLeaveRequest() async {
    await _cancelLearnerRecording();
    if (!mounted) return;
    if (!_hasActiveLessonSession) {
      await Navigator.of(context).maybePop();
      return;
    }
    if (!_canAbandon) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave lesson?'),
        content: const Text(
          'Leaving ends this unfinished lesson without creating a summary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave lesson'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _abandonLesson();
  }

  Future<void> _abandonLesson() async {
    final session = _startResult?.session;
    if (session == null || !_canAbandon) return;
    await _cancelLearnerRecording(forDeparture: true);
    await _stopAndClearTutorAudio();
    setState(() {
      _isAbandoning = true;
      _hintText = null;
      _hintError = null;
      _sendError = null;
      _finishError = null;
      _recordingState = LearnerRecordingUiState.idle;
    });
    final result = await _authService.abandonLessonSession(
      sessionId: session.lessonSessionId,
    );
    if (!mounted) return;
    if (result.canLeave) {
      setState(() {
        _isAbandoning = false;
        _lessonSessionEnded = true;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _isAbandoning = false;
      _sendError = result.message;
      _isAuthenticationRequired =
          result.status == LessonSessionAbandonStatus.authRequired;
    });
  }

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
    await _cancelLearnerRecording(forDeparture: true);
    await _stopAndClearTutorAudio();
    setState(() {
      _isFinishing = true;
      _finishError = null;
      _recordingState = LearnerRecordingUiState.idle;
      _hintText = null;
      _hintError = null;
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
      _settings == null ? 'Tutor' : _runtimeTutorDisplayName(_settings!);

  String _runtimeTutorDisplayName(UserSettings settings) {
    final tutorId = settings.selectedTutorId.trim().toLowerCase();
    for (final profile in _scenario?.tutorProfiles ?? const []) {
      if (profile.tutorId.trim().toLowerCase() == tutorId &&
          profile.displayName.trim().isNotEmpty) {
        return profile.displayName.trim();
      }
    }
    return 'Tutor';
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

  void _scrollTranscriptToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_transcriptController.hasClients) return;
      final firstScroll = _transcriptController.animateTo(
        _transcriptController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      unawaited(firstScroll.whenComplete(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_transcriptController.hasClients) return;
          final position = _transcriptController.position;
          if (position.pixels < position.maxScrollExtent) {
            position.jumpTo(position.maxScrollExtent);
          }
        });
      }));
    });
  }

  Future<void> _toggleRecording() async {
    if (_recordingState == LearnerRecordingUiState.recording) {
      await _stopAndTranscribeRecording();
      return;
    }
    if (!_actionAvailability.canToggleRecordingPlaceholder) return;
    await _startRecording();
  }

  Future<void> _startRecording() async {
    await _stopTutorPlayback();
    if (!mounted ||
        _recordingState == LearnerRecordingUiState.recording ||
        !_actionAvailability.canToggleRecordingPlaceholder) {
      return;
    }
    setState(() {
      _recordingState = LearnerRecordingUiState.requestingPermission;
      _recordingMessage = null;
      _showOpenMicrophoneSettings = false;
      _draftWhenRecordingStarted = _messageController.text;
      _transcriptionEligible = true;
      _recordingOperationGeneration++;
    });
    try {
      var permission = await _microphonePermissionService.check();
      if (permission == LearnerMicrophonePermissionStatus.denied) {
        permission = await _microphonePermissionService.request();
      }
      if (!mounted || !_transcriptionEligible) return;
      if (permission != LearnerMicrophonePermissionStatus.granted) {
        setState(() {
          _recordingState = LearnerRecordingUiState.error;
          _recordingMessage = permission ==
                      LearnerMicrophonePermissionStatus.permanentlyDenied ||
                  permission == LearnerMicrophonePermissionStatus.restricted
              ? 'Microphone access is blocked. Open Android settings to enable it.'
              : 'Microphone access was not granted. Tap the microphone to try again.';
          _showOpenMicrophoneSettings = permission ==
                  LearnerMicrophonePermissionStatus.permanentlyDenied ||
              permission == LearnerMicrophonePermissionStatus.restricted;
        });
        return;
      }
      final path = await _recordingService.createTemporaryWavPath();
      await _recordingService.start(path);
      if (!mounted || !_transcriptionEligible) {
        await _recordingService.cancel();
        await _recordingService.deleteFile(path);
        return;
      }
      setState(() {
        _recordingFilePath = path;
        _recordingStartedAt = DateTime.now();
        _recordingState = LearnerRecordingUiState.recording;
        _showOpenMicrophoneSettings = false;
      });
      _recordingTimer?.cancel();
      _recordingTimer = Timer(const Duration(seconds: 30), () {
        unawaited(_stopAndTranscribeRecording());
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _recordingState = LearnerRecordingUiState.error;
          _recordingMessage =
              'Could not start recording. Please check your microphone.';
        });
      }
    } finally {
      if (mounted &&
          _recordingState == LearnerRecordingUiState.requestingPermission) {
        setState(() {
          _recordingState = LearnerRecordingUiState.idle;
          _recordingMessage = null;
          _showOpenMicrophoneSettings = false;
        });
      }
    }
  }

  Future<void> _stopAndTranscribeRecording() async {
    if (_recordingState != LearnerRecordingUiState.recording) return;
    _recordingTimer?.cancel();
    setState(() => _recordingState = LearnerRecordingUiState.stopping);
    final startedAt = _recordingStartedAt;
    final intendedPath = _recordingFilePath;
    try {
      final path = await _recordingService.stop() ?? intendedPath;
      final duration = startedAt == null
          ? Duration.zero
          : DateTime.now().difference(startedAt);
      if (path == null || duration < const Duration(milliseconds: 500)) {
        await _recordingService.deleteFile(path);
        if (mounted) {
          setState(() {
            _recordingState = LearnerRecordingUiState.error;
            _recordingMessage = 'Please record a slightly longer answer.';
          });
        }
        return;
      }
      if (duration > const Duration(seconds: 30)) {
        await _recordingService.deleteFile(path);
        if (mounted) {
          setState(() {
            _recordingState = LearnerRecordingUiState.error;
            _recordingMessage = 'Please keep recordings under 30 seconds.';
          });
        }
        return;
      }
      final wav = await _recordingService.validateWavFile(path);
      if (!wav.isValid) {
        await _recordingService.deleteFile(path);
        if (mounted) {
          setState(() {
            _recordingState = LearnerRecordingUiState.error;
            _recordingMessage = wav.reason;
          });
        }
        return;
      }
      if (!mounted || !_transcriptionEligible) return;
      await _transcribeRecording(path, _recordingOperationGeneration);
    } catch (_) {
      await _recordingService.deleteFile(intendedPath);
      if (mounted) {
        setState(() {
          _recordingState = LearnerRecordingUiState.error;
          _recordingMessage = 'Could not stop recording. Please try again.';
        });
      }
    } finally {
      _recordingStartedAt = null;
    }
  }

  Future<void> _transcribeRecording(
      String path, int operationGeneration) async {
    final session = _startResult?.session;
    final settings = _settings;
    if (session == null || settings == null) return;
    if (mounted) {
      setState(() => _recordingState = LearnerRecordingUiState.transcribing);
    }
    try {
      final result = await _authService.transcribeLearnerAudio(
        request: _transcriptionRequestBuilder.build(
          audioFilePath: path,
          backendSessionId: session.lessonSessionId,
          settings: settings,
          scenario: _scenario,
          selectedContextTitle: _currentSelectedContextTitle,
        ),
      );
      if (!mounted ||
          !_transcriptionEligible ||
          operationGeneration != _recordingOperationGeneration) {
        return;
      }
      if (!result.isSuccess || result.text == null) {
        setState(() {
          _recordingState = LearnerRecordingUiState.error;
          _recordingMessage = result.message;
          _isAuthenticationRequired =
              result.status == AudioTranscriptionStatus.authenticationRequired;
          _lessonSessionEnded =
              result.status == AudioTranscriptionStatus.sessionEnded;
        });
        return;
      }
      final normalizedTranscript = TranscriptScriptNormalizer.normalize(
        result.text!,
        isEnglish:
            StudyLanguageDefinitions.resolve(settings.studyLanguage).id == 'en',
      );
      if (kDebugMode) {
        debugPrint(
          'transcript_script surface=lesson_chat '
          'target=${StudyLanguageDefinitions.resolve(settings.studyLanguage).id} '
          'latin=${normalizedTranscript.latinLetterCount} '
          'cyrillic=${normalizedTranscript.cyrillicLetterCount} '
          'normalized=${normalizedTranscript.changed} '
          'unsafeMixed=${normalizedTranscript.unsafeMixedScript} '
          'action=${normalizedTranscript.unsafeMixedScript ? 'rejected' : 'accepted'}',
        );
      }
      if (normalizedTranscript.unsafeMixedScript) {
        if (!_hasSelectedContext) {
          _debugVoiceScenarioResolution(
            stage: 'deterministic',
            decision: 'unsafe',
            candidateCount:
                _scenario?.controlledVariation.contextVariants.length ?? 0,
            matchedContextPresent: false,
            confidence: 1,
            hadContextBefore: false,
            action: 'review_text',
          );
        }
        if (mounted) {
          setState(() {
            _recordingState = LearnerRecordingUiState.idle;
            _recordingMessage =
                'I could not recognize that clearly. Please try again.';
          });
        }
        return;
      }
      final transcriptText = normalizedTranscript.normalizedText;
      final draftChanged =
          _messageController.text != _draftWhenRecordingStarted;
      if (_autoSendVoice) {
        if (transcriptText.isNotEmpty) {
          await _sendMessageInternal(
            overrideText: transcriptText,
            source: 'voice_transcript',
            automaticVoiceSubmission: true,
            recordingGeneration: operationGeneration,
          );
        }
      } else if (_draftWhenRecordingStarted.trim().isNotEmpty || draftChanged) {
        final replace = await _confirmTranscriptReplacement();
        if (!mounted || !_transcriptionEligible) return;
        if (replace == true) {
          _messageController.text = transcriptText;
          _composerContainsVoiceTranscript = true;
        }
      } else {
        _messageController.text = transcriptText;
        _composerContainsVoiceTranscript = true;
      }
      if (mounted) {
        setState(() {
          if (!_autoSendVoice) _isTextComposerVisible = true;
          _recordingState = _autoSendVoice
              ? LearnerRecordingUiState.idle
              : LearnerRecordingUiState.transcriptReady;
          _recordingMessage = null;
        });
      }
    } catch (_) {
      if (mounted && _transcriptionEligible) {
        setState(() {
          _recordingState = LearnerRecordingUiState.error;
          _recordingMessage =
              'Connection failed while transcribing. Please try again.';
        });
      }
    } finally {
      await _recordingService.deleteFile(path);
      if (mounted) setState(() => _recordingFilePath = null);
    }
  }

  Future<bool?> _confirmTranscriptReplacement() => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace typed text?'),
          content: const Text(
              'Use the transcribed recording instead of your typed draft?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep typed text'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace typed text'),
            ),
          ],
        ),
      );

  Future<void> _cancelLearnerRecording({bool forDeparture = false}) async {
    _recordingTimer?.cancel();
    _recordingOperationGeneration++;
    _transcriptionEligible = false;
    final path = _recordingFilePath;
    if (_recordingState == LearnerRecordingUiState.recording ||
        _recordingState == LearnerRecordingUiState.requestingPermission ||
        _recordingState == LearnerRecordingUiState.stopping) {
      await _recordingService.cancel();
      await _recordingService.deleteFile(path);
      _recordingFilePath = null;
    }
    if (mounted && !forDeparture) {
      setState(() {
        _recordingState = LearnerRecordingUiState.idle;
        _recordingMessage = null;
        _transcriptionEligible = true;
      });
    }
  }

  Future<void> _openMicrophoneSettings() async {
    try {
      await _microphonePermissionService.openSettings();
    } catch (_) {
      // Keep the existing retryable permission message.
    }
  }

  Future<void> _refreshMicrophonePermissionAfterResume() async {
    try {
      final permission = await _microphonePermissionService.check();
      if (!mounted || permission != LearnerMicrophonePermissionStatus.granted) {
        return;
      }
      setState(() {
        _showOpenMicrophoneSettings = false;
        if (_recordingState == LearnerRecordingUiState.error) {
          _recordingState = LearnerRecordingUiState.idle;
          _recordingMessage = null;
        }
      });
    } catch (_) {}
  }

  Future<void> _playTutorVoice(
    _LessonChatMessage message, {
    AudioSpeechPurpose purpose = AudioSpeechPurpose.lessonChatTts,
  }) async {
    final session = _startResult?.session;
    final settings = _settings;
    if (!message.isTutor ||
        session == null ||
        settings == null ||
        !_actionAvailability.canUseTts ||
        message.isTtsLoading) {
      return;
    }
    if (_activePlayingMessageId == message.id) {
      await _stopTutorPlayback();
      return;
    }
    await _stopTutorPlayback();
    final playbackGeneration = ++_playbackOperationGeneration;
    var cachedPath = message.cachedTtsPath;
    if (cachedPath != null && !await File(cachedPath).exists()) {
      message.cachedTtsPath = null;
      cachedPath = null;
    }
    if (cachedPath == null) {
      setState(() {
        message.isTtsLoading = true;
        message.ttsError = null;
      });
      final result = await _authService.requestTutorSpeech(
        request: _speechRequestBuilder.build(
          text: message.text,
          settings: settings,
          backendSessionId: session.lessonSessionId,
          purpose: purpose,
        ),
      );
      if (!mounted || !_actionAvailability.canUseTts) return;
      if (!result.isSuccess || result.audioBytes == null) {
        setState(() {
          message.isTtsLoading = false;
          message.ttsError = result.message;
          if (result.status == AudioSpeechStatus.authenticationRequired) {
            _isAuthenticationRequired = true;
          }
          if (result.status == AudioSpeechStatus.sessionEnded) {
            _lessonSessionEnded = true;
          }
        });
        return;
      }
      try {
        final file = File(
          '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'language-voice-tutor-${message.id}-${DateTime.now().microsecondsSinceEpoch}.wav',
        );
        await file.writeAsBytes(result.audioBytes!, flush: true);
        cachedPath = file.path;
        if (!mounted || !_actionAvailability.canUseTts) {
          try {
            await file.delete();
          } catch (_) {}
          return;
        }
        message.cachedTtsPath = cachedPath;
      } catch (_) {
        if (mounted) {
          setState(() {
            message.isTtsLoading = false;
            message.ttsError = 'Could not play voice. Please try again.';
          });
        }
        return;
      }
    }
    if (!mounted) return;
    final playbackPath = cachedPath;
    try {
      final result = await _audioPlaybackService.playToCompletion(
        playbackPath,
        timeout: const Duration(seconds: 90),
        onStarted: () {
          if (!mounted || playbackGeneration != _playbackOperationGeneration) {
            return;
          }
          setState(() {
            message.isTtsLoading = false;
            message.isTtsPlaying = true;
            message.ttsError = null;
            _activePlayingMessageId = message.id;
          });
        },
      );
      if (!mounted || playbackGeneration != _playbackOperationGeneration) {
        return;
      }
      if (result.status != TutorPlaybackStatus.completed) {
        _clearTutorPlayback(message.id);
        setState(() {
          message.isTtsLoading = false;
          message.ttsError = result.status == TutorPlaybackStatus.stopped
              ? null
              : 'Could not play voice. Please try again.';
        });
      }
    } catch (_) {
      if (mounted && playbackGeneration == _playbackOperationGeneration) {
        setState(() {
          message.isTtsLoading = false;
          message.isTtsPlaying = false;
          message.ttsError = 'Could not play voice. Please try again.';
        });
      }
    }
  }

  void _onPlaybackCompleted() {
    if (!mounted) return;
    final activeId = _activePlayingMessageId;
    if (activeId == null) return;
    _clearTutorPlayback(activeId);
  }

  Future<void> _stopTutorPlayback() async {
    _playbackOperationGeneration++;
    final activeId = _activePlayingMessageId;
    if (activeId != null) _clearTutorPlayback(activeId);
    await _audioPlaybackService.stop();
  }

  void _clearTutorPlayback(int activeId) {
    if (!mounted) return;
    setState(() {
      if (_activePlayingMessageId == activeId) {
        _activePlayingMessageId = null;
      }
      for (final message in _messages) {
        if (message.id == activeId) message.isTtsPlaying = false;
      }
    });
  }

  Future<void> _stopAndClearTutorAudio() async {
    await _stopTutorPlayback();
    for (final message in _messages) {
      final path = message.cachedTtsPath;
      message.cachedTtsPath = null;
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    }
  }

  Future<void> _translateMessage(_LessonChatMessage message) async {
    final session = _startResult?.session;
    final settings = _settings;
    if (session == null ||
        settings == null ||
        !_actionAvailability.canUseTranslation) {
      return;
    }
    if (message.isTranslationLoading) return;
    if (message.isTranslationVisible) {
      setState(() => message.isTranslationVisible = false);
      return;
    }
    if (message.translatedText != null) {
      setState(() => message.isTranslationVisible = true);
      return;
    }

    setState(() {
      message.isTranslationLoading = true;
      message.translationError = null;
    });
    final studyLanguage =
        StudyLanguageDefinitions.resolve(settings.studyLanguage);
    final result = await _authService.requestTranslation(
      request: TranslationRequest(
        text: message.text,
        targetLanguage: LanguageOptions.backendNativeLanguageNameFor(
            settings.nativeLanguage),
        sourceLanguageId: studyLanguage.id,
        sourceLanguageName: studyLanguage.englishName,
        sourceLanguageNativeName: studyLanguage.nativeName,
        sourceLanguageCode: studyLanguage.transcriptionLanguageCode,
        backendSessionId: session.lessonSessionId,
      ),
    );
    if (!mounted || _isCompleted || _isAbandoning) return;
    setState(() {
      message.isTranslationLoading = false;
      if (result.isSuccess && result.translation != null) {
        message.translatedText = result.translation!.translatedText;
        message.isTranslationVisible = true;
        message.translationError = null;
      } else {
        message.translationError = result.message;
        if (result.status == TranslationStatus.authRequired) {
          _isAuthenticationRequired = true;
        }
        if (result.status == TranslationStatus.sessionEnded) {
          _lessonSessionEnded = true;
        }
      }
    });
  }

  Future<void> _requestFeedback(_LessonChatMessage message) async {
    final selection = widget.selection;
    final session = _startResult?.session;
    final scenario = _scenario;
    final settings = _settings;
    if (!message.isUser ||
        selection == null ||
        session == null ||
        scenario == null ||
        settings == null ||
        _isAuthenticationRequired ||
        _lessonSessionEnded ||
        _isAbandoning ||
        _isFinishing ||
        _isCompleted ||
        message.isFeedbackLoading) {
      return;
    }
    if (message.isFeedbackVisible) {
      setState(() => message.isFeedbackVisible = false);
      return;
    }
    if (message.feedback != null) {
      setState(() {
        message.isFeedbackVisible = true;
        message.feedbackError = null;
      });
      return;
    }
    setState(() {
      message.isFeedbackLoading = true;
      message.feedbackError = null;
    });
    final persistence = message.persistenceOperation;
    if (message.persistedBackendMessageId == null && persistence != null) {
      await persistence.timeout(const Duration(seconds: 5), onTimeout: () {});
    }
    if (!mounted || _isCompleted || _isAbandoning || _isFinishing) return;
    final persistedId = message.persistedBackendMessageId;
    if (persistedId == null || persistedId.isEmpty) {
      setState(() {
        message.isFeedbackLoading = false;
        message.feedbackError = 'Feedback is not ready yet. Please try again.';
      });
      return;
    }
    final lastBotMessage = _messages.lastWhere(
      (value) => value.isBot,
      orElse: () => _LessonChatMessage.tutor(''),
    );
    final learnerTurnCount = _messages.where((value) => value.isUser).length;
    final request = _turnRequestBuilder.build(
      scenario: scenario,
      settings: settings,
      selectedLevel: selection.level,
      userMessage: message.text,
      lastBotMessage: lastBotMessage.text,
      learnerTurnCount: learnerTurnCount,
      recentMessages: _recentConversationMessages(_messages),
      backendSessionId: session.lessonSessionId,
      context: LessonContextSelectionResolver.resolve(
        scenario: scenario,
        currentSelectedContextId: _selectedContextId,
        currentSelectedContextTitle: _currentSelectedContextTitle,
        learnerInput: '',
        studyLanguage: StudyLanguageDefinitions.resolve(settings.studyLanguage),
      ),
      sourceMessageId: message.id,
      sourcePersistedMessageId: persistedId,
      sourceMessageKind: 'user',
    );
    final result = await _authService.requestLessonFeedback(request: request);
    if (!mounted || _isCompleted || _isAbandoning) return;
    setState(() {
      message.isFeedbackLoading = false;
      if (result.isSuccess && result.feedback != null) {
        message.feedback = result.feedback;
        message.isFeedbackVisible = true;
        message.feedbackError = null;
      } else {
        message.feedbackError = result.message;
        if (result.status == LessonFeedbackStatus.authRequired) {
          _isAuthenticationRequired = true;
        }
        if (result.status == LessonFeedbackStatus.sessionEnded) {
          _lessonSessionEnded = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return PopScope(
      canPop: !_hasActiveLessonSession,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleLeaveRequest();
      },
      child: Theme(
        data: _lessonTheme(Theme.of(context)),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: SafeArea(
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
                                  tutorId: _settings?.selectedTutorId ?? '',
                                  tutorStatus: _tutorStatus,
                                  compactLevel: _compactLevel,
                                  isStarting: _isStarting,
                                  startResult: _startResult,
                                  lessonLoadError: _lessonLoadError,
                                  isLoadingScenario: _isLoadingScenario,
                                  messages: _messages,
                                  sendError: _sendError,
                                  voiceClarificationChoices:
                                      _voiceClarificationChoices,
                                  onSelectVoiceClarification: (variant) =>
                                      _sendMessageInternal(
                                    overrideText: variant.title,
                                    source: 'voice_transcript',
                                  ),
                                  hintText: _hintText,
                                  hintError: _hintError,
                                  isHintLoading: _isHintLoading,
                                  isSending: _isSending,
                                  controller: _messageController,
                                  actionAvailability: _actionAvailability,
                                  isRecordingPlaceholderActive:
                                      _recordingState ==
                                          LearnerRecordingUiState.recording,
                                  isTranscribing: _recordingState ==
                                      LearnerRecordingUiState.transcribing,
                                  recordingMessage: _recordingMessage,
                                  showOpenMicrophoneSettings:
                                      _showOpenMicrophoneSettings,
                                  onOpenMicrophoneSettings:
                                      _openMicrophoneSettings,
                                  isFinishing: _isFinishing,
                                  canFinish: _canFinish,
                                  finishError: _finishError,
                                  onBack: _handleLeaveRequest,
                                  onFinish: _confirmFinishLesson,
                                  onRetryStart: _isStarting
                                      ? null
                                      : () => _startLessonSession(),
                                  onRetryLoad: _retryLessonRuntime,
                                  transcriptController: _transcriptController,
                                  onPlayVoice: _playTutorVoice,
                                  onTranslateMessage: _translateMessage,
                                  onFeedback: _requestFeedback,
                                  onToggleRecordingPlaceholder: () {
                                    unawaited(_toggleRecording());
                                  },
                                  onHint: _requestHint,
                                  isTextComposerVisible: _isTextComposerVisible,
                                  onToggleTextComposer: () => setState(() {
                                    _isTextComposerVisible =
                                        !_isTextComposerVisible;
                                  }),
                                  onDismissHint: () =>
                                      setState(() => _hintText = null),
                                  onSend: _sendMessage,
                                  autoSendVoice: _autoSendVoice,
                                  autoPlayBotVoice: _autoPlayBotVoice,
                                  canOpenConversationMode:
                                      _actionAvailability.canUsePlaceholders,
                                  onAutoSendVoiceChanged: (value) =>
                                      setState(() => _autoSendVoice = value),
                                  onAutoPlayBotVoiceChanged: (value) =>
                                      setState(() => _autoPlayBotVoice = value),
                                  onOpenConversationMode: _openConversationMode,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _lessonTheme(ThemeData appTheme) {
    final neutralTheme = ThemeData(
      colorScheme: appTheme.colorScheme,
      useMaterial3: true,
    );
    return appTheme.copyWith(
      textTheme: neutralTheme.textTheme,
      primaryTextTheme: neutralTheme.primaryTextTheme,
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
    required this.tutorId,
    required this.tutorStatus,
    required this.compactLevel,
    required this.isStarting,
    required this.startResult,
    required this.lessonLoadError,
    required this.isLoadingScenario,
    required this.messages,
    required this.sendError,
    required this.voiceClarificationChoices,
    required this.onSelectVoiceClarification,
    required this.hintText,
    required this.hintError,
    required this.isHintLoading,
    required this.isSending,
    required this.transcriptController,
    required this.controller,
    required this.actionAvailability,
    required this.isRecordingPlaceholderActive,
    required this.isTranscribing,
    required this.recordingMessage,
    required this.showOpenMicrophoneSettings,
    required this.onOpenMicrophoneSettings,
    required this.isFinishing,
    required this.canFinish,
    required this.finishError,
    required this.onBack,
    required this.onFinish,
    required this.onRetryStart,
    required this.onRetryLoad,
    required this.onPlayVoice,
    required this.onTranslateMessage,
    required this.onFeedback,
    required this.onToggleRecordingPlaceholder,
    required this.onHint,
    required this.isTextComposerVisible,
    required this.onToggleTextComposer,
    required this.onDismissHint,
    required this.onSend,
    required this.autoSendVoice,
    required this.autoPlayBotVoice,
    required this.canOpenConversationMode,
    required this.onAutoSendVoiceChanged,
    required this.onAutoPlayBotVoiceChanged,
    required this.onOpenConversationMode,
  });

  final LessonStartSelection selection;
  final LessonRuntimeScenario? scenario;
  final String tutorDisplayName;
  final String tutorId;
  final LessonTutorStatus tutorStatus;
  final String compactLevel;
  final bool isStarting;
  final LessonSessionStartResult? startResult;
  final String? lessonLoadError;
  final bool isLoadingScenario;
  final List<_LessonChatMessage> messages;
  final String? sendError;
  final List<LessonRuntimeContextVariant> voiceClarificationChoices;
  final ValueChanged<LessonRuntimeContextVariant> onSelectVoiceClarification;
  final String? hintText;
  final String? hintError;
  final bool isHintLoading;
  final bool isSending;
  final ScrollController transcriptController;
  final TextEditingController controller;
  final _LessonActionAvailability actionAvailability;
  final bool isRecordingPlaceholderActive;
  final bool isTranscribing;
  final String? recordingMessage;
  final bool showOpenMicrophoneSettings;
  final Future<void> Function() onOpenMicrophoneSettings;
  final bool isFinishing;
  final bool canFinish;
  final String? finishError;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final VoidCallback? onRetryStart;
  final Future<void> Function() onRetryLoad;
  final Future<void> Function(_LessonChatMessage message) onPlayVoice;
  final Future<void> Function(_LessonChatMessage message) onTranslateMessage;
  final Future<void> Function(_LessonChatMessage message) onFeedback;
  final VoidCallback onToggleRecordingPlaceholder;
  final VoidCallback onHint;
  final bool isTextComposerVisible;
  final VoidCallback onToggleTextComposer;
  final VoidCallback onDismissHint;
  final Future<void> Function([String? overrideText]) onSend;
  final bool autoSendVoice;
  final bool autoPlayBotVoice;
  final bool canOpenConversationMode;
  final ValueChanged<bool> onAutoSendVoiceChanged;
  final ValueChanged<bool> onAutoPlayBotVoiceChanged;
  final VoidCallback onOpenConversationMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final chatGradient = colorScheme.brightness == Brightness.light
        ? const [Color(0xFFDCEFFA), Color(0xFFFFE4B5)]
        : const [Color(0xFF17384B), Color(0xFF493620)];
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!keyboardOpen)
            _TutorHeader(
              displayName: tutorDisplayName,
              tutorId: tutorId,
              status: tutorStatus,
              compactLevel: compactLevel,
              topic: scenario?.metadata.topic.isNotEmpty ?? false
                  ? scenario!.metadata.topic
                  : selection.topicTitle,
              onBack: onBack,
              canFinish: canFinish,
              onFinish: onFinish,
              canOpenConversationMode: canOpenConversationMode,
              onOpenConversationMode: onOpenConversationMode,
            ),
          Expanded(
            child: Container(
              key: const Key('lesson-chat-surface'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: chatGradient,
                  stops: const [0, 1],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  if (!keyboardOpen)
                    Padding(
                      key: const Key('lesson-voice-preferences'),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                  scale: 0.72,
                                  child: Switch(
                                    key: const Key(
                                        'lesson-auto-send-voice-switch'),
                                    value: autoSendVoice,
                                    onChanged: onAutoSendVoiceChanged,
                                  ),
                                ),
                                const Text('Auto-send voice'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                  scale: 0.72,
                                  child: Switch(
                                    key: const Key(
                                        'lesson-auto-play-bot-voice-switch'),
                                    value: autoPlayBotVoice,
                                    onChanged: onAutoPlayBotVoiceChanged,
                                  ),
                                ),
                                const Text('Auto-play bot voice'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
                      onPlayVoice: onPlayVoice,
                      onTranslateMessage: onTranslateMessage,
                      onFeedback: onFeedback,
                      bottomContent: Column(
                        key: const Key('lesson-transcript-status-area'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          if (voiceClarificationChoices.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Wrap(
                                key: const Key(
                                    'lesson-voice-clarification-choices'),
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: voiceClarificationChoices
                                    .map((variant) => ActionChip(
                                          label: Text(variant.title),
                                          onPressed: () =>
                                              onSelectVoiceClarification(
                                                  variant),
                                        ))
                                    .toList(growable: false),
                              ),
                            ),
                          if (hintError != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                hintError!,
                                key: const Key('lesson-hint-error'),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          if (hintText != null)
                            _LessonHintCard(
                              text: hintText!,
                              onDismiss: onDismissHint,
                            ),
                          if (isHintLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('Getting hint...',
                                  key: Key('lesson-hint-loading')),
                            ),
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
                          if (isTranscribing)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Transcribing recording...'),
                                ],
                              ),
                            ),
                          if (recordingMessage != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                recordingMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (showOpenMicrophoneSettings)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextButton(
                                key: const Key(
                                    'lesson-open-microphone-settings'),
                                onPressed: () =>
                                    unawaited(onOpenMicrophoneSettings()),
                                child: const Text('Open settings'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _LessonComposer(
                    controller: controller,
                    canSendText: actionAvailability.canSendText,
                    canRecord: actionAvailability.canToggleRecordingPlaceholder,
                    canHint: actionAvailability.canUseHint,
                    isSending: isSending || isFinishing || isHintLoading,
                    isRecordingPlaceholderActive: isRecordingPlaceholderActive,
                    isTextComposerVisible: isTextComposerVisible,
                    onToggleTextComposer: onToggleTextComposer,
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
    required this.onPlayVoice,
    required this.onTranslateMessage,
    required this.onFeedback,
    required this.bottomContent,
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
  final Future<void> Function(_LessonChatMessage message) onPlayVoice;
  final Future<void> Function(_LessonChatMessage message) onTranslateMessage;
  final Future<void> Function(_LessonChatMessage message) onFeedback;
  final Widget bottomContent;

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
      onPlayVoice: onPlayVoice,
      onTranslateMessage: onTranslateMessage,
      onFeedback: onFeedback,
      bottomContent: bottomContent,
    );
  }
}

class _LessonTranscript extends StatelessWidget {
  const _LessonTranscript({
    required this.controller,
    required this.messages,
    required this.actionAvailability,
    required this.onPlayVoice,
    required this.onTranslateMessage,
    required this.onFeedback,
    required this.bottomContent,
  });

  final ScrollController controller;
  final List<_LessonChatMessage> messages;
  final _LessonActionAvailability actionAvailability;
  final Future<void> Function(_LessonChatMessage message) onPlayVoice;
  final Future<void> Function(_LessonChatMessage message) onTranslateMessage;
  final Future<void> Function(_LessonChatMessage message) onFeedback;
  final Widget bottomContent;

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

    return SingleChildScrollView(
      key: const Key('lesson-chat-transcript'),
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          for (var index = 0; index < messages.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            _LessonMessageBubble(
              message: messages[index],
              actionAvailability: actionAvailability,
              onPlayVoice: onPlayVoice,
              onTranslateMessage: onTranslateMessage,
              onFeedback: onFeedback,
            ),
          ],
          bottomContent,
        ],
      ),
    );
  }
}

class _LessonMessageBubble extends StatelessWidget {
  const _LessonMessageBubble({
    required this.message,
    required this.actionAvailability,
    required this.onPlayVoice,
    required this.onTranslateMessage,
    required this.onFeedback,
  });

  final _LessonChatMessage message;
  final _LessonActionAvailability actionAvailability;
  final Future<void> Function(_LessonChatMessage message) onPlayVoice;
  final Future<void> Function(_LessonChatMessage message) onTranslateMessage;
  final Future<void> Function(_LessonChatMessage message) onFeedback;

  @override
  Widget build(BuildContext context) {
    final isTutor = message.isTutor;
    final colorScheme = Theme.of(context).colorScheme;
    final alignment = isTutor ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isTutor
        ? colorScheme.surface.withValues(alpha: 0.94)
        : colorScheme.primaryContainer.withValues(alpha: 0.94);
    final textColor =
        isTutor ? colorScheme.onSurface : colorScheme.onPrimaryContainer;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          key: message.isContextSelection
              ? const Key('lesson-message-learner-context')
              : message.isCmsOpening
                  ? const Key('lesson-message-cms-opening')
                  : null,
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(26),
              topRight: const Radius.circular(26),
              bottomLeft: Radius.circular(isTutor ? 8 : 26),
              bottomRight: Radius.circular(isTutor ? 26 : 8),
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
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
                          onPressed: actionAvailability.canUseTranslation
                              ? () => onTranslateMessage(message)
                              : null,
                          icon: const Icon(Icons.translate, size: 18),
                        ),
                        IconButton(
                          key: const Key('lesson-message-action-tutor-voice'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Play voice',
                          onPressed: actionAvailability.canUseTts
                              ? () => onPlayVoice(message)
                              : null,
                          icon: message.isTtsLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  message.isTtsPlaying
                                      ? Icons.stop_outlined
                                      : Icons.volume_up_outlined,
                                  size: 18,
                                ),
                        ),
                      ]
                    : [
                        IconButton(
                          key:
                              const Key('lesson-message-action-user-translate'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Translation',
                          onPressed: actionAvailability.canUseTranslation
                              ? () => onTranslateMessage(message)
                              : null,
                          icon: const Icon(Icons.translate, size: 18),
                        ),
                        IconButton(
                          key: const Key('lesson-message-action-user-feedback'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Feedback',
                          onPressed: actionAvailability.canUsePlaceholders
                              ? () => onFeedback(message)
                              : null,
                          icon:
                              const Icon(Icons.mode_comment_outlined, size: 18),
                        ),
                      ],
              ),
              if (message.ttsError != null) ...[
                const SizedBox(height: 4),
                Text(
                  message.ttsError!,
                  key: Key('lesson-message-voice-error-${message.id}'),
                  style: TextStyle(color: colorScheme.error, fontSize: 12),
                ),
              ],
              if (message.isTranslationLoading) ...[
                const SizedBox(height: 8),
                const SizedBox(
                  key: Key('lesson-message-translation-loading'),
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              if (message.isTranslationVisible &&
                  message.translatedText != null) ...[
                const SizedBox(height: 8),
                Text(
                  message.translatedText!,
                  key: Key('lesson-message-translation-${message.id}'),
                  style: TextStyle(
                    color: textColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (message.isFeedbackLoading) ...[
                const SizedBox(height: 8),
                const SizedBox(
                  key: Key('lesson-message-feedback-loading'),
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              if (message.feedbackError != null) ...[
                const SizedBox(height: 8),
                Text(message.feedbackError!,
                    key: Key('lesson-message-feedback-error-${message.id}'),
                    style: TextStyle(color: colorScheme.error)),
              ],
              if (message.isFeedbackVisible && message.feedback != null) ...[
                const SizedBox(height: 8),
                _FeedbackCard(feedback: message.feedback!),
              ],
              if (message.translationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  message.translationError!,
                  key: Key('lesson-message-translation-error-${message.id}'),
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonHintCard extends StatelessWidget {
  const _LessonHintCard({required this.text, required this.onDismiss});

  final String text;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('lesson-hint-card'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          IconButton(
            key: const Key('lesson-hint-dismiss'),
            tooltip: 'Dismiss hint',
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
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
    required this.isTextComposerVisible,
    required this.onToggleTextComposer,
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
  final bool isTextComposerVisible;
  final VoidCallback onToggleTextComposer;
  final VoidCallback onToggleRecordingPlaceholder;
  final VoidCallback onHint;
  final Future<void> Function([String? overrideText]) onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final compactButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(44, 38),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.35),
      ),
      foregroundColor: colorScheme.onSurfaceVariant,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.72),
      shape: const StadiumBorder(),
    );
    return Container(
      key: const Key('lesson-bottom-dock'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTextComposerVisible) ...[
            Row(
              key: const Key('lesson-text-composer'),
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
                      if (canSendText) onSend();
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surface.withValues(alpha: 0.9),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.65),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color:
                              colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      hintText: 'Type your message',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final canPressSend =
                        canSendText && value.text.trim().isNotEmpty;
                    return FilledButton(
                      key: const Key('lesson-send-button'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(64, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        visualDensity: VisualDensity.compact,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: canPressSend ? () => onSend() : null,
                      child: Text(isSending ? 'Sending...' : 'Send'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Align(
            key: const Key('lesson-action-row'),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      key: const Key('lesson-action-keyboard'),
                      style: compactButtonStyle,
                      onPressed: onToggleTextComposer,
                      child: Icon(
                        isTextComposerVisible
                            ? Icons.keyboard_hide_outlined
                            : Icons.keyboard_alt_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    key: const Key('lesson-action-record'),
                    style: compactButtonStyle.copyWith(
                      minimumSize: const WidgetStatePropertyAll(Size(52, 44)),
                    ),
                    onPressed: canRecord ? onToggleRecordingPlaceholder : null,
                    child: Icon(
                      isRecordingPlaceholderActive
                          ? Icons.stop
                          : Icons.mic_none,
                      size: 23,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      key: const Key('lesson-action-hint'),
                      style: compactButtonStyle,
                      onPressed: canHint ? onHint : null,
                      icon: const Icon(Icons.lightbulb_outline, size: 19),
                      label: const Text('Hint'),
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

class _LessonChatMessage {
  _LessonChatMessage.user(this.text, {this.isContextSelection = false})
      : kind = LessonMessageKind.user,
        id = _nextId++,
        isCmsOpening = false;

  _LessonChatMessage.tutor(this.text, {this.isCmsOpening = false})
      : kind = LessonMessageKind.tutor,
        id = _nextId++,
        isContextSelection = false;

  static int _nextId = 0;
  final int id;
  final String text;
  final LessonMessageKind kind;
  final bool isContextSelection;
  final bool isCmsOpening;
  bool isTranslationLoading = false;
  bool isTranslationVisible = false;
  String? translatedText;
  String? translationError;
  String? persistedBackendMessageId;
  String? persistenceError;
  Future<void>? persistenceOperation;
  bool isTtsLoading = false;
  bool isTtsPlaying = false;
  String? cachedTtsPath;
  String? ttsError;
  bool isFeedbackLoading = false;
  bool isFeedbackVisible = false;
  LessonFeedbackResponse? feedback;
  String? feedbackError;

  bool get isUser => kind == LessonMessageKind.user;
  bool get isTutor => kind == LessonMessageKind.tutor;
  bool get isBot => isTutor;
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});
  final LessonFeedbackResponse feedback;

  @override
  Widget build(BuildContext context) {
    final sections = <(String, String)>[
      ('Quick summary', feedback.shortText),
      ('Corrected version', feedback.correctedVersion),
      ('Grammar tip', feedback.grammarTip),
      ('Vocabulary tip', feedback.vocabularyTip),
      ('Culture tip', feedback.cultureTip),
      ('More natural version', feedback.naturalVersion),
    ].where((section) => section.$2.trim().isNotEmpty).toList();
    return Container(
      key: const Key('lesson-message-feedback-card'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1CB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECC45F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feedback',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF174A7C),
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          for (final section in sections) ...[
            _FeedbackSectionCard(title: section.$1, text: section.$2),
            if (section != sections.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _FeedbackSectionCard extends StatelessWidget {
  const _FeedbackSectionCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD5E3F2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF174A7C),
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 4),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

class _TutorHeader extends StatelessWidget {
  const _TutorHeader({
    required this.displayName,
    required this.tutorId,
    required this.status,
    required this.compactLevel,
    required this.topic,
    required this.onBack,
    required this.canFinish,
    required this.onFinish,
    required this.canOpenConversationMode,
    required this.onOpenConversationMode,
  });

  final String displayName;
  final String tutorId;
  final LessonTutorStatus status;
  final String compactLevel;
  final String topic;
  final VoidCallback onBack;
  final bool canFinish;
  final VoidCallback onFinish;
  final bool canOpenConversationMode;
  final VoidCallback onOpenConversationMode;

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
      LessonTutorStatus.transcribing => colorScheme.tertiary,
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
            child: TutorAvatar(
              key: const Key('lesson-avatar'),
              surface: TutorAvatarSurface.lessonChat,
              tutorId: tutorId,
              state: switch (status) {
                LessonTutorStatus.ready ||
                LessonTutorStatus.error =>
                  TutorAvatarState.idle,
                LessonTutorStatus.listening => TutorAvatarState.listening,
                LessonTutorStatus.transcribing => TutorAvatarState.transcribing,
                LessonTutorStatus.thinking => TutorAvatarState.thinking,
                LessonTutorStatus.speaking => TutorAvatarState.speaking,
              },
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              placeholder: Center(
                child: Text(
                  tutorInitial,
                  key: const Key('lesson-avatar-placeholder'),
                  style: textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                          const SizedBox(width: 8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.surface.withValues(alpha: 0.78),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              key: const Key('lesson-conversation-mode-button'),
                              tooltip: 'Open Conversation mode',
                              onPressed: canOpenConversationMode
                                  ? onOpenConversationMode
                                  : null,
                              icon: const Icon(Icons.open_in_full),
                            ),
                          ),
                        ],
                      ),
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
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          key: const Key('lesson-summary-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lesson summary',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF123D68),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              if (ready) _SummaryContext(summary: summary!),
              const SizedBox(height: 20),
              if (!ready) ...[
                _SummaryMessagePanel(
                  title: 'Lesson completed',
                  message: unavailable
                      ? 'Your lesson was saved, but a summary could not be created for this lesson.'
                      : status == LessonCompletionStatus.authRequired
                          ? 'Please sign in again to load your lesson summary.'
                          : 'Your lesson was saved, but we could not load the summary right now.',
                ),
                const SizedBox(height: 16),
                if (canRetrySummary)
                  Center(
                      child: OutlinedButton.icon(
                    onPressed: onRetrySummary,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry summary'),
                  )),
              ] else ...[
                if (summary!.summary?.trim().isNotEmpty ?? false) ...[
                  _SummaryMessagePanel(
                    title: 'What went well',
                    message: summary!.summary!,
                  ),
                  const SizedBox(height: 14),
                ],
                _SummarySection('Strengths', summary!.strengths),
                _SummarySection('Improvements', summary!.improvements),
                _SummarySection('Vocabulary', summary!.vocabulary),
                _SummarySection('Grammar', summary!.grammar),
                _SummarySection('Next steps', summary!.nextSteps),
              ],
              const SizedBox(height: 28),
              Center(
                child:
                    FilledButton(onPressed: onDone, child: const Text('Done')),
              ),
            ],
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
    return parts.isEmpty
        ? const SizedBox.shrink()
        : Text(
            parts.join(' · '),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF52718F),
                ),
          );
  }
}

class _SummaryMessagePanel extends StatelessWidget {
  const _SummaryMessagePanel({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD8E7F5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF174A7C),
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

class _SummarySection extends StatelessWidget {
  const _SummarySection(this.title, this.items);
  final String title;
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final isImprovement = title == 'Improvements';
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isImprovement ? const Color(0xFFFFF1CB) : const Color(0xFFF4F8FC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isImprovement
                ? const Color(0xFFECC45F)
                : const Color(0xFFD8E7F5),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF174A7C),
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                      child: Text(item,
                          style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ]),
      ),
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
