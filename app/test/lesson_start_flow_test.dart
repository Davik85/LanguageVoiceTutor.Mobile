import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/audio_transcription.dart';
import 'package:language_voice_tutor_mobile/models/lesson_chat.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';
import 'package:language_voice_tutor_mobile/models/lesson_start_selection.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/models/translation.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/models/voice_scenario_resolution.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/screens/lesson_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';
import 'package:language_voice_tutor_mobile/services/learner_audio_recording_service.dart';
import 'package:language_voice_tutor_mobile/services/learner_microphone_permission_service.dart';

class FakeLearnerRecorder implements LearnerAudioRecorderAdapter {
  bool active = false;
  @override
  Future<void> cancel() async => active = false;
  @override
  Future<void> dispose() async => active = false;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<bool> get isRecording async => active;
  @override
  Future<void> start({
    required String path,
    required LearnerRecordingConfig config,
  }) async {
    active = true;
  }

  @override
  Future<String?> stop() async {
    active = false;
    return null;
  }
}

class FakeSuccessfulRecordingService extends LearnerAudioRecordingService {
  FakeSuccessfulRecordingService() : super(recorder: FakeLearnerRecorder());

  bool recording = false;

  @override
  Future<String> createTemporaryWavPath() async => 'fake.wav';

  @override
  Future<void> start(String path) async => recording = true;

  @override
  Future<String?> stop() async {
    recording = false;
    return 'fake.wav';
  }

  @override
  Future<void> cancel() async => recording = false;

  @override
  Future<bool> get isRecording async => recording;

  @override
  Future<LearnerWavValidationResult> validateWavFile(String path) async =>
      const LearnerWavValidationResult(
        isValid: true,
        duration: Duration(seconds: 1),
      );

  @override
  Future<void> deleteFile(String? path) async {}

  @override
  Future<void> dispose() async {}
}

class FakeLearnerMicrophonePermissionService
    implements LearnerMicrophonePermissionService {
  FakeLearnerMicrophonePermissionService({required this.statuses});

  final List<LearnerMicrophonePermissionStatus> statuses;
  Object? checkError;
  Object? requestError;
  int checkCalls = 0;
  int requestCalls = 0;
  int openSettingsCalls = 0;

  LearnerMicrophonePermissionStatus get _nextStatus => statuses.isEmpty
      ? LearnerMicrophonePermissionStatus.denied
      : statuses.removeAt(0);

  @override
  Future<LearnerMicrophonePermissionStatus> check() async {
    checkCalls++;
    if (checkError != null) throw checkError!;
    return _nextStatus;
  }

  @override
  Future<LearnerMicrophonePermissionStatus> request() async {
    requestCalls++;
    if (requestError != null) throw requestError!;
    return _nextStatus;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCalls++;
    return true;
  }
}

class FakeApiClient implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 200, body: '{}');

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 200, body: '{}');
}

class FakeAuthService extends AuthService {
  FakeAuthService({
    this.lessonStartCompleter,
    LessonSessionStartResult? lessonStartResult,
    this.replyCompleter,
    LessonChatReplyResult? replyResult,
    this.hintCompleter,
    LessonChatHintResult? hintResult,
    this.translationCompleter,
    TranslationResult? translationResult,
    LessonRuntimeScenario? scenario,
    this.settingsFailure,
    this.scenarioFailure,
    this.finishCompleter,
    LessonCompletionResult? finishResult,
    this.abandonCompleter,
    LessonSessionAbandonResult? abandonResult,
    LessonCompletionResult? summaryResult,
    List<Completer<void>>? persistenceCompleters,
    this.persistenceFailure,
    this.studyLanguage = 'es',
    this.currentLevel = 'A1',
    this.transcriptionText = 'Hello there',
    this.voiceScenarioResponse,
    this.voiceScenarioFailure = false,
  })  : lessonStartResult = lessonStartResult ?? _readyLessonStartResult(),
        replyResult = replyResult ?? _defaultReplyResult(),
        hintResult = hintResult ?? _defaultHintResult(),
        translationResult = translationResult ?? _defaultTranslationResult(),
        finishResult =
            finishResult ?? LessonCompletionResult.summaryUnavailable(),
        abandonResult = abandonResult ?? LessonSessionAbandonResult.abandoned(),
        summaryResult = summaryResult ??
            finishResult ??
            LessonCompletionResult.summaryUnavailable(),
        persistenceCompleters = persistenceCompleters ?? [],
        scenario = scenario ?? _runtimeScenario(),
        super(apiClient: FakeApiClient(), storage: MemoryStorage());

  final Completer<LessonSessionStartResult>? lessonStartCompleter;
  final LessonSessionStartResult lessonStartResult;
  final Completer<LessonChatReplyResult>? replyCompleter;
  final LessonChatReplyResult replyResult;
  final Completer<LessonChatHintResult>? hintCompleter;
  final LessonChatHintResult hintResult;
  final Completer<TranslationResult>? translationCompleter;
  final TranslationResult translationResult;
  final LessonRuntimeScenario scenario;
  final ApiException? settingsFailure;
  final ApiException? scenarioFailure;
  final Completer<LessonCompletionResult>? finishCompleter;
  final LessonCompletionResult finishResult;
  final Completer<LessonSessionAbandonResult>? abandonCompleter;
  final LessonSessionAbandonResult abandonResult;
  final LessonCompletionResult summaryResult;
  final List<Completer<void>> persistenceCompleters;
  final Object? persistenceFailure;
  final String studyLanguage;
  final String currentLevel;
  final String transcriptionText;
  final VoiceScenarioSemanticResponse? voiceScenarioResponse;
  final bool voiceScenarioFailure;

  int startLessonSessionCallCount = 0;
  int fetchScenarioCallCount = 0;
  int sendLessonChatReplyCallCount = 0;
  int requestLessonChatHintCallCount = 0;
  int requestTranslationCallCount = 0;
  int finishLessonSessionCallCount = 0;
  int abandonLessonSessionCallCount = 0;
  int loadLessonSummaryCallCount = 0;
  int transcribeCallCount = 0;
  int resolveVoiceScenarioCallCount = 0;
  int? lastValidTurnCount;
  StartLessonSessionRequest? lastStartRequest;
  LessonChatRequest? lastLessonChatRequest;
  LessonChatRequest? lastHintRequest;
  TranslationRequest? lastTranslationRequest;
  final persistedMessages = <CreateLessonSessionMessageRequest>[];

  @override
  Future<AuthUser> loadCurrentUser() async => AuthUser(
        userId: 'u1',
        email: 'user@example.com',
        createdAt: DateTime.parse('2026-07-01T12:00:00Z'),
      );

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async =>
      SubscriptionStatus(
        userId: 'u1',
        premiumActive: false,
        trialActive: false,
        freeLessonUsedToday: 0,
        freeLessonRemainingToday: 1,
        checkedAtUtc: DateTime.parse('2026-07-06T12:00:00Z'),
        enforcementEnabled: true,
      );

  @override
  Future<UserSettings> fetchUserSettings() async {
    if (settingsFailure != null) throw settingsFailure!;
    return UserSettings(
      nativeLanguage: 'en',
      studyLanguage: studyLanguage,
      explanationLanguage: 'en',
      speechVoice: 'nova',
      speechSpeed: 1.0,
      conversationModeEnabled: true,
      selectedTutorId: UserSettings.defaultTutorId,
      currentLevel: currentLevel,
    );
  }

  @override
  Future<LessonSessionStartResult> startLessonSession({
    required StartLessonSessionRequest request,
  }) async {
    startLessonSessionCallCount += 1;
    lastStartRequest = request;
    return lessonStartCompleter?.future ?? lessonStartResult;
  }

  @override
  Future<LessonRuntimeScenario> fetchLessonRuntimeScenario({
    required String scenarioKey,
  }) async {
    fetchScenarioCallCount += 1;
    if (scenarioFailure != null) throw scenarioFailure!;
    return scenario;
  }

  @override
  Future<AudioTranscriptionResult> transcribeLearnerAudio({
    required AudioTranscriptionRequest request,
  }) async {
    transcribeCallCount++;
    return AudioTranscriptionResult.success(transcriptionText);
  }

  @override
  Future<VoiceScenarioSemanticResult> resolveVoiceScenario({
    required String sessionId,
    required VoiceScenarioResolutionRequest request,
  }) async {
    resolveVoiceScenarioCallCount++;
    if (voiceScenarioFailure || voiceScenarioResponse == null) {
      return VoiceScenarioSemanticResult.failed();
    }
    return VoiceScenarioSemanticResult.success(voiceScenarioResponse!);
  }

  @override
  Future<LessonChatReplyResult> sendLessonChatReply({
    required LessonChatRequest request,
  }) async {
    sendLessonChatReplyCallCount += 1;
    lastLessonChatRequest = request;
    return replyCompleter?.future ?? replyResult;
  }

  @override
  Future<LessonChatHintResult> requestLessonChatHint({
    required LessonChatRequest request,
  }) async {
    requestLessonChatHintCallCount += 1;
    lastHintRequest = request;
    return hintCompleter?.future ?? hintResult;
  }

  @override
  Future<TranslationResult> requestTranslation({
    required TranslationRequest request,
  }) async {
    requestTranslationCallCount += 1;
    lastTranslationRequest = request;
    return translationCompleter?.future ?? translationResult;
  }

  @override
  Future<String> persistLessonSessionMessage({
    required String sessionId,
    required CreateLessonSessionMessageRequest request,
  }) async {
    persistedMessages.add(request);
    if (persistenceFailure != null) throw persistenceFailure!;
    if (persistenceCompleters.isNotEmpty) {
      await persistenceCompleters.removeAt(0).future;
    }
    return '00000000-0000-4000-8000-000000000001';
  }

  @override
  Future<LessonCompletionResult> finishLessonSession({
    required String sessionId,
    required int validTurnCount,
  }) async {
    finishLessonSessionCallCount += 1;
    lastValidTurnCount = validTurnCount;
    return finishCompleter?.future ?? finishResult;
  }

  @override
  Future<LessonSessionAbandonResult> abandonLessonSession({
    required String sessionId,
  }) async {
    abandonLessonSessionCallCount += 1;
    return abandonCompleter?.future ?? abandonResult;
  }

  @override
  Future<LessonCompletionResult> loadLessonSummary(
      {required String sessionId}) async {
    loadLessonSummaryCallCount += 1;
    return summaryResult;
  }
}

class MemoryStorage implements SessionStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

const _introLessonSelection = LessonStartSelection(
  level: 'A1 Beginner',
  topicId: '1',
  topicTitle: 'Daily Life',
  subtopicId: '101',
  subtopicTitle: 'Introductions',
  situation: 'Introductions',
  lessonContentId: 'everyday_english_introductions',
);

const _introLessonSelectionWithContext = LessonStartSelection(
  level: 'A1 Beginner',
  topicId: '1',
  topicTitle: 'Daily Life',
  subtopicId: '101',
  subtopicTitle: 'Introductions',
  situation: 'Introductions',
  lessonContentId: 'everyday_english_introductions',
  selectedContextId: 'new_neighbor',
  selectedContextTitle: 'Meeting a new neighbor',
);

LessonSessionStartResult _readyLessonStartResult() =>
    LessonSessionStartResult.ready(
      const LessonSessionResponse(
        lessonSessionId: 'session-1',
        lessonContentId: 'everyday_english_introductions',
        studyLanguage: 'Spanish',
      ),
    );

LessonRuntimeScenario _runtimeScenario({
  String exampleHint = 'Try: My name is Ana.',
  String lessonPhase = 'active_roleplay',
}) =>
    LessonRuntimeScenario.fromJson({
      'id': 'everyday_english_introductions',
      'metadata': {
        'topic': 'Daily Life',
        'subtopic': 'Introductions',
        'lessonType': 'guided_roleplay',
      },
      'lessonSetup': {
        'setupMessage': 'Tutor starts by greeting the learner.',
      },
      'learningGoal': {
        'goal':
            'you will learn to say your name, where you are from, and ask simple questions.',
      },
      'situation': {
        'description':
            'The user meets someone for the first time in a simple everyday situation.',
      },
      'targetLanguage': {
        'keyPhrases': ['Hi.', 'My name is...'],
        'grammarFocus': ['basic questions'],
      },
      'levelProfiles': {
        'A1 Beginner': {
          'difficultyNotes': 'Very simple English.',
          'tutorLanguageStyle': 'Use very short, clear questions.',
          'expectedUserResponse': 'One short introduction sentence.',
          'feedbackStrictness': 'Keep feedback very short.',
          'hintStrategy': 'Give a starter.',
          'correctionPriority': 'Name and place first.',
          'conversationDepth': 'Stay shallow.',
          'exampleGoodAnswer': 'My name is Ana.',
          'exampleStretchAnswer':
              'My name is Ana. I am from Brazil. Nice to meet you.',
          'addedKeyPhrases': ['Nice to meet you.'],
          'addedUsefulConstructions': ['Use My name is...'],
          'addedGrammarFocus': ['to be'],
          'softWrapUpAfterUserTurn': 10,
          'finalMessageAtUserTurn': 15,
        },
      },
      'conversationFlow': {
        'opening': 'Today we\'ll practice introductions.',
        'firstUserTask': 'Learner gives a short introduction.',
        'guidedPracticeFollowUpQuestions': ['Where are you from?'],
        'variationOrComplication': '',
        'correctionMoment': '',
        'wrapUpMessage': 'Nice work today.',
        'finalMessage': 'Great job. See you next time.',
        'wrapUpIntent': 'Wrap up the introduction.',
        'finalMessageIntent': 'End the lesson.',
      },
      'roleplayBeats': [
        {'id': 'beat-1', 'intent': 'Tutor greets the learner.'},
      ],
      'reciprocalQuestionHandling': {
        'ifUserAsksTutorName': 'My name is Alex.',
        'ifUserAsksSimplePersonalQuestion': 'I live nearby.',
        'mustNotIgnoreUserQuestion': true,
        'mustNotRefuseScenarioCompatibleQuestions': true,
      },
      'expectedScenarioProgression': ['Greet learner', 'Exchange names'],
      'aiTutorPromptInstructions': ['Keep tutor messages short.'],
      'promptTemplates': {'opening': 'Keep the greeting simple.'},
      'hintRules': {'exampleHint': exampleHint},
      'controlledVariation': {
        'contextVariants': [
          {
            'id': 'new_neighbor',
            'title': 'Meeting a new neighbor',
            'openingLine':
                'Hi! I\'m {tutorName}. I live next door. What\'s your name?',
            'contextConfirmationLine':
                'Great! Let\'s imagine you meet a new neighbor.',
            'openingIntent':
                'Tutor plays a friendly next-door neighbor who is meeting the learner for the first time.',
          },
          {
            'id': 'first_day_class',
            'title': 'First day at a language school',
            'openingLine':
                'Hi! I\'m {tutorName}. I\'m in this class too. What\'s your name?',
            'contextConfirmationLine':
                'Great! Let\'s imagine it is the first day at a language school.',
            'openingIntent':
                'Tutor plays a friendly classmate who is meeting the learner on the first day of class.',
          },
          {
            'id': 'hobby_club',
            'title': 'Meeting someone at a hobby club',
            'openingLine':
                'Hi! I\'m {tutorName}. Is this your first time at the club?',
            'contextConfirmationLine':
                'Great! Let\'s imagine you are meeting someone at a hobby club.',
            'openingIntent':
                'Tutor plays a friendly club member meeting the learner for the first time.',
          },
        ],
      },
      'runtimeContent': {
        'effectiveRuntimeSource': 'cms_published_snapshot',
        'contentPackSlug': 'static-json-v1',
        'versionNumber': 7,
        'snapshotHash': 'hash-123',
        'fallbackUsed': false,
        'scenarioKey': 'everyday_english_introductions',
        'resolvedLevelId': 'A1 Beginner',
        'softWrapUpAfterUserTurn': 10,
        'finalMessageAtUserTurn': 15,
        'lessonPhase': lessonPhase,
        'hasWrapUpStarted': false,
      },
    });

LessonChatReplyResult _defaultReplyResult() => LessonChatReplyResult.success(
      const LessonChatReplyResponse(
        botReply: 'Hi! Nice to meet you. Where are you from?',
        isLessonComplete: false,
      ),
    );

LessonChatHintResult _defaultHintResult() => LessonChatHintResult.success(
      const LessonChatHintResponse(hintText: 'Try a short greeting.'),
    );

TranslationResult _defaultTranslationResult() => TranslationResult.success(
      const TranslationResponse(translatedText: 'Hola, ¿cómo estás?'),
    );

Widget _home({FakeAuthService? authService}) => MaterialApp(
      home: HomeScreen(authService: authService ?? FakeAuthService()),
    );

Widget _lessonScreen(
  FakeAuthService authService, {
  LessonStartSelection selection = _introLessonSelection,
  LearnerAudioRecordingService? recordingService,
  LearnerMicrophonePermissionService? microphonePermissionService,
  TextScaler? textScaler,
}) =>
    MaterialApp(
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
      home: LessonScreen(
        authService: authService,
        recordingService: recordingService,
        microphonePermissionService: microphonePermissionService,
        selection: selection,
      ),
    );

Widget _lessonScreenWithHome(FakeAuthService authService) => MaterialApp(
      initialRoute: '/lesson',
      routes: {
        '/': (_) => const Scaffold(body: Text('Home')),
        '/lesson': (_) => LessonScreen(
              authService: authService,
              selection: _introLessonSelection,
            ),
      },
    );

Future<void> _expectVisibleAfterScroll(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (!tester.any(finder)) {
    await tester.scrollUntilVisible(
      finder,
      500,
      scrollable: find.byType(Scrollable),
    );
  }
  expect(finder, findsOneWidget);
}

Finder _sendButton() => find.byKey(const Key('lesson-send-button'));

Future<void> _showWidget(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _openTextComposer(WidgetTester tester) async {
  if (tester.any(find.byKey(const Key('lesson-input')))) return;
  final keyboard = find.byKey(const Key('lesson-action-keyboard'));
  await _showWidget(tester, keyboard);
  await tester.tap(keyboard);
  await tester.pumpAndSettle();
}

Future<void> _autoSendOneRecording(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('lesson-auto-send-voice-switch')));
  await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
  await tester.tap(find.byKey(const Key('lesson-action-record')));
  await tester
      .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 550)));
  await tester.pump();
  await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
  await tester.tap(find.byKey(const Key('lesson-action-record')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'hidden composer anchors action row near bottom SafeArea and transcript fills remaining space',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_lessonScreen(FakeAuthService()));
    await tester.pumpAndSettle();

    final surfaceRect = tester.getRect(
      find.byKey(const Key('lesson-chat-surface')),
    );
    final transcriptRect = tester.getRect(
      find.byKey(const Key('lesson-chat-transcript')),
    );
    final dockRect =
        tester.getRect(find.byKey(const Key('lesson-bottom-dock')));
    final actionRect =
        tester.getRect(find.byKey(const Key('lesson-action-row')));

    expect(find.byKey(const Key('lesson-input')), findsNothing);
    expect(dockRect.bottom, closeTo(surfaceRect.bottom, 0.1));
    expect(800 - dockRect.bottom, lessThan(24));
    expect(surfaceRect.bottom - actionRect.bottom, lessThan(16));
    expect(transcriptRect.bottom, closeTo(dockRect.top, 0.1));
    expect(transcriptRect.height, greaterThan(actionRect.height * 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'composer opens directly above action row and closes back to bottom-only dock',
      (tester) async {
    await tester.pumpWidget(_lessonScreen(FakeAuthService()));
    await tester.pumpAndSettle();

    final keyboard = find.byKey(const Key('lesson-action-keyboard'));
    final initialDockBottom =
        tester.getRect(find.byKey(const Key('lesson-bottom-dock'))).bottom;
    expect(find.byKey(const Key('lesson-input')), findsNothing);
    expect(find.byKey(const Key('lesson-send-button')), findsNothing);
    expect(keyboard, findsOneWidget);
    expect(find.byKey(const Key('lesson-chat-transcript')), findsOneWidget);

    await tester.tap(keyboard);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-input')), findsOneWidget);
    expect(find.byKey(const Key('lesson-send-button')), findsOneWidget);
    final composerRect = tester.getRect(
      find.byKey(const Key('lesson-text-composer')),
    );
    final actionRect =
        tester.getRect(find.byKey(const Key('lesson-action-row')));
    expect(composerRect.bottom, lessThanOrEqualTo(actionRect.top));
    expect(actionRect.top - composerRect.bottom, lessThanOrEqualTo(8));
    expect(
      tester.getRect(find.byKey(const Key('lesson-bottom-dock'))).bottom,
      closeTo(initialDockBottom, 0.1),
    );

    await tester.tap(keyboard);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-input')), findsNothing);
    expect(find.byKey(const Key('lesson-send-button')), findsNothing);
    expect(
      tester.getRect(find.byKey(const Key('lesson-bottom-dock'))).bottom,
      closeTo(initialDockBottom, 0.1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'software keyboard moves complete bottom dock above inset and leaves transcript scrollable',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(_lessonScreen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _openTextComposer(tester);
    final dockBottomBeforeKeyboard =
        tester.getRect(find.byKey(const Key('lesson-bottom-dock'))).bottom;

    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();

    final dockRect =
        tester.getRect(find.byKey(const Key('lesson-bottom-dock')));
    final composerRect = tester.getRect(
      find.byKey(const Key('lesson-text-composer')),
    );
    final actionRect =
        tester.getRect(find.byKey(const Key('lesson-action-row')));
    final transcriptRect = tester.getRect(
      find.byKey(const Key('lesson-chat-transcript')),
    );
    final transcript = tester.widget<SingleChildScrollView>(
      find.byKey(const Key('lesson-chat-transcript')),
    );

    expect(dockRect.bottom, lessThanOrEqualTo(800 - 280));
    expect(dockRect.bottom, lessThan(dockBottomBeforeKeyboard));
    expect(composerRect.top, greaterThanOrEqualTo(dockRect.top));
    expect(actionRect.bottom, lessThanOrEqualTo(dockRect.bottom));
    expect(transcriptRect.bottom, closeTo(dockRect.top, 0.1));
    expect(transcriptRect.height, greaterThan(0));
    expect(transcript.controller!.hasClients, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('voice preference row is painted directly on chat gradient',
      (tester) async {
    await tester.pumpWidget(_lessonScreen(FakeAuthService()));
    await tester.pumpAndSettle();

    final preferences = find.byKey(const Key('lesson-voice-preferences'));
    final surface = find.byKey(const Key('lesson-chat-surface'));
    final surfaceWidget = tester.widget<Container>(surface);
    final decoration = surfaceWidget.decoration! as BoxDecoration;

    expect(preferences, findsOneWidget);
    expect(find.ancestor(of: preferences, matching: surface), findsOneWidget);
    expect(decoration.gradient, isNotNull);
    expect(decoration.color, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Samsung-like keyboard viewport handles status choices and multiline composer',
      (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    final auth = FakeAuthService(
      studyLanguage: 'en',
      transcriptionText: 'meeting',
      voiceScenarioResponse: const VoiceScenarioSemanticResponse(
        decision: VoiceScenarioSemanticDecision.clarify,
        confidence: .55,
        candidateContextIds: ['new_neighbor', 'hobby_club'],
        clarificationText:
            'I heard an ambiguous situation.\nPlease choose the closest option below so the lesson can continue safely.',
      ),
    );
    await tester.pumpWidget(_lessonScreen(
      auth,
      textScaler: const TextScaler.linear(1.45),
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lesson-auto-send-voice-switch')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-send-error')), findsOneWidget);
    expect(find.byKey(const Key('lesson-voice-clarification-choices')),
        findsOneWidget);
    expect(find.byKey(const Key('lesson-input')), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('lesson-input')),
      'This is a longer draft\nthat spans several lines\nand keeps growing\nfor layout testing.',
    );
    await tester.pumpAndSettle();

    final transcript = tester.widget<SingleChildScrollView>(
      find.byKey(const Key('lesson-chat-transcript')),
    );
    expect(transcript.controller, isNotNull);
    expect(
        find.byKey(const Key('lesson-transcript-status-area')), findsOneWidget);
    for (final key in const [
      Key('lesson-action-record'),
      Key('lesson-action-hint'),
      Key('lesson-action-keyboard'),
    ]) {
      final control = find.byKey(key);
      await tester.ensureVisible(control);
      await tester.pumpAndSettle();
      expect(control.hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting a situation starts lesson and opens the workspace',
      (tester) async {
    final startCompleter = Completer<LessonSessionStartResult>();
    final auth = FakeAuthService(lessonStartCompleter: startCompleter);

    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Level: A1 Beginner'), findsOneWidget);
    await tester.tap(find.text('Daily Life'));
    await tester.pumpAndSettle();
    await _expectVisibleAfterScroll(tester, 'Introductions');

    await tester.tap(find.text('Introductions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('lesson-start-loading')), findsOneWidget);
    expect(auth.startLessonSessionCallCount, 1);

    startCompleter.complete(_readyLessonStartResult());
    await tester.pumpAndSettle();

    expect(find.text('Lesson started'), findsNothing);
    expect(find.text('Lesson session is ready.'), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byKey(const Key('lesson-tutor-header')), findsOneWidget);
    expect(find.byKey(const Key('lesson-chat-transcript')), findsOneWidget);
    expect(find.byKey(const Key('lesson-input')), findsNothing);
    expect(find.byKey(const Key('lesson-action-keyboard')), findsOneWidget);
    expect(auth.fetchScenarioCallCount, 1);
    expect(auth.lastStartRequest?.lessonContentId,
        'everyday_english_introductions');
    expect(auth.lastStartRequest?.level, 'A1 Beginner');
  });

  testWidgets('tutor header renders large avatar area and compact metadata',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final avatarFinder = find.byKey(const Key('lesson-avatar'));
    expect(avatarFinder, findsOneWidget);
    expect(tester.getSize(avatarFinder).height, greaterThanOrEqualTo(220));
    expect(find.text('Tutor'), findsOneWidget);
    expect(find.byKey(const Key('lesson-avatar-placeholder')), findsOneWidget);
    expect(find.byKey(const Key('lesson-meta-summary')), findsOneWidget);
    expect(find.text('A1 · Daily Life'), findsOneWidget);
    expect(find.text('Ready'), findsNothing);
    expect(find.text('Introductions'), findsNothing);
    expect(find.byKey(const Key('lesson-meta-situation')), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.text('Lana avatar area'), findsNothing);
    expect(find.text('Future animated GIF placeholder'), findsNothing);
    expect(find.text('Avatar'), findsNothing);
  });

  testWidgets('cms opening renders plain text scenario choices only',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.textContaining('Today we\'ll practice introductions.'),
        findsOneWidget);
    expect(find.textContaining('Goal:'), findsOneWidget);
    expect(find.textContaining('Choose a situation:'), findsOneWidget);
    expect(find.textContaining('1. Meeting a new neighbor'), findsOneWidget);
    expect(find.textContaining('2. First day at a language school'),
        findsOneWidget);
    expect(find.textContaining('3. Meeting someone at a hobby club'),
        findsOneWidget);
    expect(
        find.textContaining(
            'Or suggest your own situation about introductions.'),
        findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);
    expect(find.text('Tutor greets the learner.'), findsNothing);
    expect(find.text('Keep tutor messages short.'), findsNothing);
    expect(find.text('Keep the greeting simple.'), findsNothing);
    expect(find.textContaining('Tutor starts'), findsNothing);
    expect(find.textContaining('Learner gives'), findsNothing);
    expect(find.textContaining('roleplay'), findsNothing);
    expect(find.textContaining('opening intent'), findsNothing);
    expect(find.textContaining('expected scenario progression'), findsNothing);
  });

  testWidgets(
      'typed scenario choice starts the CMS roleplay without lesson chat reply',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), 'meeting a new neighbor');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.resolveVoiceScenarioCallCount, 0);
    expect(find.byKey(const Key('lesson-message-learner-context')),
        findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('lesson-message-learner-context')),
            matching: find.text('Meeting a new neighbor')),
        findsOneWidget);
    expect(find.byKey(const Key('lesson-message-cms-opening')), findsOneWidget);
    expect(auth.persistedMessages.where((m) => m.role == 'user'), hasLength(1));
    expect(auth.persistedMessages.where((m) => m.role == 'assistant'),
        hasLength(1));
    await tester.enterText(find.byType(TextField), 'My name is Sam.');
    await _showWidget(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(auth.resolveVoiceScenarioCallCount, 0);
    expect(
        auth.lastLessonChatRequest?.selectedContextVariantId, 'new_neighbor');
  });

  testWidgets('numeric scenario choice resolves the CMS context variant',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), '2');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.resolveVoiceScenarioCallCount, 0);
    expect(find.byKey(const Key('lesson-message-learner-context')),
        findsOneWidget);
    expect(find.text('First day at a language school'), findsOneWidget);
    expect(find.byKey(const Key('lesson-message-cms-opening')), findsOneWidget);
    expect(auth.persistedMessages, hasLength(2));
    await tester.enterText(find.byType(TextField), 'Hello.');
    await _showWidget(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(auth.lastLessonChatRequest?.selectedContextVariantId,
        'first_day_class');
  });

  testWidgets('context title ignores case and trailing punctuation',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), 'meeting a new neighbor.');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(find.byKey(const Key('lesson-message-learner-context')),
        findsOneWidget);
    expect(find.text('Meeting a new neighbor'), findsOneWidget);
    expect(find.byKey(const Key('lesson-message-cms-opening')), findsOneWidget);
    expect(auth.persistedMessages, hasLength(2));
    await tester.enterText(find.byType(TextField), 'Hello.');
    await _showWidget(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(
        auth.lastLessonChatRequest?.selectedContextVariantId, 'new_neighbor');
  });

  testWidgets('numeric context choice ignores trailing punctuation',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), '1.');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(find.byKey(const Key('lesson-message-learner-context')),
        findsOneWidget);
    expect(find.text('Meeting a new neighbor'), findsOneWidget);
    expect(find.byKey(const Key('lesson-message-cms-opening')), findsOneWidget);
    expect(auth.persistedMessages, hasLength(2));
    await tester.enterText(find.byType(TextField), 'Hello.');
    await _showWidget(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(
        auth.lastLessonChatRequest?.selectedContextVariantId, 'new_neighbor');
  });

  testWidgets('ready lesson shows Conversation mode without starting a session',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-conversation-mode-button')),
        findsOneWidget);
    expect(auth.startLessonSessionCallCount, 1);
    final conversationButton =
        find.byKey(const Key('lesson-conversation-mode-button'));
    await _showWidget(tester, conversationButton);
    await tester.tap(conversationButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversation-mode-record-button')),
        findsOneWidget);
    expect(find.textContaining('Conversation'), findsOneWidget);
    expect(auth.startLessonSessionCallCount, 1);
  });

  testWidgets('custom scenario context has no invented variant ID',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), 'Meeting a colleague');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(auth.lastLessonChatRequest?.selectedContextVariantId, isEmpty);
    expect(auth.lastLessonChatRequest?.selectedContextTitle,
        'Meeting a colleague');
  });

  testWidgets('selecting a context clears the pre-context Hint',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final hint = find.byKey(const Key('lesson-action-hint'));
    await _showWidget(tester, hint);
    await tester.tap(hint);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-hint-card')), findsOneWidget);

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-hint-card')), findsNothing);
    expect(auth.sendLessonChatReplyCallCount, 0);
  });

  testWidgets('send button is disabled for blank input', (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    final button = tester.widget<FilledButton>(_sendButton());
    expect(button.onPressed, isNull);
  });

  testWidgets(
      'pre-context Hint stays local and asks the learner to choose a situation',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final hint = find.byKey(const Key('lesson-action-hint'));
    await _showWidget(tester, hint);
    await tester.tap(hint);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-hint-card')), findsOneWidget);
    expect(
      find.text('Choose one of the situations above, or type your own.'),
      findsOneWidget,
    );
    expect(find.text('Try: My name is Ana.'), findsNothing);
    expect(auth.requestLessonChatHintCallCount, 0);
    expect(find.byKey(const Key('lesson-chat-transcript')), findsOneWidget);
    expect(auth.persistedMessages, isEmpty);
  });

  testWidgets(
      'CMS Hint is local only on the first active step after context selection',
      (tester) async {
    final auth = FakeAuthService(
      scenario: _runtimeScenario(),
    );
    await tester.pumpWidget(
      _lessonScreen(auth, selection: _introLessonSelectionWithContext),
    );
    await tester.pumpAndSettle();

    final hint = find.byKey(const Key('lesson-action-hint'));
    await _showWidget(tester, hint);
    await tester.tap(hint);
    await tester.pumpAndSettle();

    expect(find.text('Try: My name is Ana.'), findsOneWidget);
    expect(auth.requestLessonChatHintCallCount, 0);
    expect(auth.lastHintRequest?.selectedContextVariantId, isNull);
  });

  testWidgets('active Hint calls once without changing turns or persistence',
      (tester) async {
    final completer = Completer<LessonChatHintResult>();
    final auth = FakeAuthService(
      scenario: _runtimeScenario(exampleHint: ''),
      hintCompleter: completer,
    );
    await tester.pumpWidget(
      _lessonScreen(auth, selection: _introLessonSelectionWithContext),
    );
    await tester.pumpAndSettle();

    final hint = find.byKey(const Key('lesson-action-hint'));
    await _showWidget(tester, hint);
    await tester.tap(hint);
    await tester.pump();
    expect(auth.requestLessonChatHintCallCount, 1);
    expect(find.byKey(const Key('lesson-hint-loading')), findsOneWidget);
    completer.complete(_defaultHintResult());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-hint-card')), findsOneWidget);
    expect(auth.persistedMessages, isEmpty);
    expect(auth.lastValidTurnCount, isNull);
    expect(auth.lastHintRequest?.userMessage,
        'I need a hint for what to say next.');
    expect(auth.lastHintRequest?.selectedContextVariantId, 'new_neighbor');
    expect(
        auth.lastHintRequest?.selectedContextTitle, 'Meeting a new neighbor');
    await _showWidget(tester, find.byKey(const Key('lesson-hint-dismiss')));
    await tester.tap(find.byKey(const Key('lesson-hint-dismiss')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-hint-card')), findsNothing);
  });

  testWidgets('send button and loading state prevent duplicate sends',
      (tester) async {
    final replyCompleter = Completer<LessonChatReplyResult>();
    final auth = FakeAuthService(replyCompleter: replyCompleter);

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pump();

    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(find.text('Sending...'), findsOneWidget);
    final button = tester.widget<FilledButton>(_sendButton());
    expect(button.onPressed, isNull);

    replyCompleter.complete(_defaultReplyResult());
    await tester.pumpAndSettle();
  });

  testWidgets('typed send still works and bot reply renders', (tester) async {
    final auth = FakeAuthService(
      replyResult: LessonChatReplyResult.success(
        const LessonChatReplyResponse(
          botReply: 'Hi Sam! Nice to meet you.',
          isLessonComplete: false,
        ),
      ),
    );

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), 'Hello, my name is Sam.');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    await _expectVisibleAfterScroll(tester, 'Hello, my name is Sam.');
    expect(find.text('Hi Sam! Nice to meet you.'), findsOneWidget);
    expect(auth.lastLessonChatRequest?.userMessage, 'Hello, my name is Sam.');
    expect(auth.persistedMessages, hasLength(2));
    expect(auth.persistedMessages.first.role, 'user');
    expect(auth.persistedMessages.last.role, 'assistant');
  });

  testWidgets('tutor messages show translation and speaker icons',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-message-action-tutor-translate')),
        findsOneWidget);
    expect(find.byKey(const Key('lesson-message-action-tutor-voice')),
        findsOneWidget);
  });

  testWidgets('user messages show translation and feedback icons',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    await _showWidget(
        tester, find.byKey(const Key('lesson-message-action-user-translate')));
    expect(find.byKey(const Key('lesson-message-action-user-translate')),
        findsOneWidget);
    expect(find.byKey(const Key('lesson-message-action-user-feedback')),
        findsOneWidget);
  });

  testWidgets(
      'bottom global translation play voice and feedback buttons removed',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-action-play-voice')), findsNothing);
    expect(find.byKey(const Key('lesson-action-translation')), findsNothing);
    expect(find.byKey(const Key('lesson-action-feedback')), findsNothing);
    expect(find.byKey(const Key('lesson-action-finish')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-record')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-hint')), findsOneWidget);
  });

  testWidgets(
      'translation uses the selected tutor message without a lesson turn',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final initialSendCount = auth.sendLessonChatReplyCallCount;
    final initialPersistCount = auth.persistedMessages.length;
    await _showWidget(
        tester, find.byKey(const Key('lesson-message-action-tutor-translate')));
    await tester
        .tap(find.byKey(const Key('lesson-message-action-tutor-translate')));
    await tester.pumpAndSettle();
    expect(auth.requestTranslationCallCount, 1);
    expect(auth.lastTranslationRequest?.text,
        contains('Today we\'ll practice introductions.'));
    expect(auth.lastTranslationRequest?.targetLanguage, 'English');
    expect(auth.lastTranslationRequest?.sourceLanguageId, 'es');
    expect(find.text('Hola, ¿cómo estás?'), findsOneWidget);
    expect(auth.sendLessonChatReplyCallCount, initialSendCount);
    expect(auth.persistedMessages.length, initialPersistCount);

    await _showWidget(
        tester, find.byKey(const Key('lesson-message-action-tutor-voice')));
    await tester
        .tap(find.byKey(const Key('lesson-message-action-tutor-voice')));
    expect(find.textContaining('Coming next in a future lesson update.'),
        findsNothing);
    expect(auth.sendLessonChatReplyCallCount, initialSendCount);
    expect(auth.persistedMessages.length, initialPersistCount);
  });

  testWidgets('record starts locally without sending a lesson message',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth,
        recordingService:
            LearnerAudioRecordingService(recorder: FakeLearnerRecorder())));
    await tester.pumpAndSettle();

    final initialSendCount = auth.sendLessonChatReplyCallCount;
    final initialPersistCount = auth.persistedMessages.length;

    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, initialSendCount);
    expect(auth.persistedMessages.length, initialPersistCount);
  });

  testWidgets('safe English voice transcript is inserted with Auto-send off',
      (tester) async {
    final auth = FakeAuthService(
        studyLanguage: 'en', transcriptionText: 'Hello   there');
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('lesson-input')))
            .controller
            ?.text,
        'Hello there');
    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.persistedMessages, isEmpty);
  });

  testWidgets('safe Cyrillic homoglyph is normalized before composer insertion',
      (tester) async {
    final auth =
        FakeAuthService(studyLanguage: 'en', transcriptionText: 'Сat hello');
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('lesson-input')))
            .controller
            ?.text,
        'Cat hello');
  });

  testWidgets('safe English voice transcript submits once with Auto-send on',
      (tester) async {
    final auth = FakeAuthService(
      studyLanguage: 'en',
      transcriptionText: 'Custom café chat',
      voiceScenarioResponse: const VoiceScenarioSemanticResponse(
        decision: VoiceScenarioSemanticDecision.freeContext,
        confidence: .9,
        normalizedFreeContext: 'Custom café chat',
      ),
    );
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-auto-send-voice-switch')));
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(auth.persistedMessages.where((message) => message.role == 'user'),
        hasLength(1));
  });

  testWidgets('voice intent starts canonical CMS scenario without reply call',
      (tester) async {
    final auth = FakeAuthService(
      studyLanguage: 'en',
      transcriptionText: 'meeting and your neighbor',
      voiceScenarioResponse: const VoiceScenarioSemanticResponse(
        decision: VoiceScenarioSemanticDecision.publishedContext,
        confidence: .92,
        matchedContextId: 'new_neighbor',
      ),
    );
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-auto-send-voice-switch')));
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.resolveVoiceScenarioCallCount, 1);
    expect(auth.persistedMessages, hasLength(2));
    expect(find.byKey(const Key('lesson-message-learner-context')),
        findsOneWidget);
    expect(find.text('Meeting a new neighbor'), findsOneWidget);
    expect(find.byKey(const Key('lesson-message-cms-opening')), findsOneWidget);
  });

  testWidgets('exact voice title avoids backend semantic resolution',
      (tester) async {
    final auth = FakeAuthService(
      studyLanguage: 'en',
      transcriptionText: 'Meeting a new neighbor',
      voiceScenarioFailure: true,
    );
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await _autoSendOneRecording(tester);

    expect(auth.resolveVoiceScenarioCallCount, 0);
    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.persistedMessages, hasLength(2));
    expect(find.byKey(const Key('lesson-message-cms-opening')), findsOneWidget);
  });

  testWidgets('specific free voice scenario keeps context and has no variant',
      (tester) async {
    const freeContext = 'meeting a friend in a park';
    final auth = FakeAuthService(
      studyLanguage: 'en',
      transcriptionText: freeContext,
      voiceScenarioResponse: const VoiceScenarioSemanticResponse(
        decision: VoiceScenarioSemanticDecision.freeContext,
        confidence: .94,
        normalizedFreeContext: freeContext,
      ),
    );
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-auto-send-voice-switch')));
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(auth.resolveVoiceScenarioCallCount, 1);
    expect(auth.lastLessonChatRequest?.selectedContextTitle, freeContext);
    expect(auth.lastLessonChatRequest?.selectedContextVariantId, isEmpty);
    expect(auth.lastLessonChatRequest?.userMessage, freeContext);
  });

  testWidgets('ambiguous voice scenario only asks for clarification',
      (tester) async {
    final auth = FakeAuthService(
      studyLanguage: 'en',
      transcriptionText: 'meeting',
      voiceScenarioResponse: const VoiceScenarioSemanticResponse(
        decision: VoiceScenarioSemanticDecision.clarify,
        confidence: .55,
        candidateContextIds: ['new_neighbor', 'hobby_club'],
        clarificationText: 'Did you mean:',
      ),
    );
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-auto-send-voice-switch')));
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.resolveVoiceScenarioCallCount, 1);
    expect(auth.persistedMessages, isEmpty);
    expect(find.textContaining('Did you mean:'), findsOneWidget);
    expect(
        find.byKey(const Key('lesson-message-learner-context')), findsNothing);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const Key('lesson-action-record')))
            .onPressed,
        isNotNull);
    final choices = find.byKey(const Key('lesson-voice-clarification-choices'));
    expect(choices, findsOneWidget);
    final firstChoice = find.descendant(
      of: choices,
      matching: find.text('Meeting a new neighbor'),
    );
    await tester.ensureVisible(firstChoice);
    await tester.pumpAndSettle();
    await tester.tap(firstChoice);
    await tester.pumpAndSettle();
    expect(auth.resolveVoiceScenarioCallCount, 1);
    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.persistedMessages, hasLength(2));
  });

  testWidgets(
      'semantic endpoint failure preserves transcript and does not guess',
      (tester) async {
    const transcript = 'meeting neighbor';
    final auth = FakeAuthService(
      studyLanguage: 'en',
      transcriptionText: transcript,
      voiceScenarioFailure: true,
    );
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await _autoSendOneRecording(tester);

    expect(auth.resolveVoiceScenarioCallCount, 1);
    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.persistedMessages, isEmpty);
    expect(find.textContaining('temporarily unavailable'), findsOneWidget);
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('lesson-input')))
            .controller
            ?.text,
        transcript);
  });

  testWidgets('unsafe Cyrillic transcript preserves draft and restores record',
      (tester) async {
    final auth =
        FakeAuthService(studyLanguage: 'en', transcriptionText: 'Hello Привет');
    await tester.pumpWidget(_lessonScreen(
      auth,
      recordingService: FakeSuccessfulRecordingService(),
      microphonePermissionService: FakeLearnerMicrophonePermissionService(
        statuses: [LearnerMicrophonePermissionStatus.granted],
      ),
    ));
    await tester.pumpAndSettle();
    await _openTextComposer(tester);
    await tester.enterText(
        find.byKey(const Key('lesson-input')), 'Keep this draft');
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.pump();
    await _showWidget(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('lesson-input')))
            .controller
            ?.text,
        'Keep this draft');
    expect(
        find.text(
            'I could not recognize that clearly in English. Please try again.'),
        findsOneWidget);
    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.persistedMessages, isEmpty);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const Key('lesson-action-record')))
            .onPressed,
        isNotNull);
  });

  testWidgets('first microphone denial remains retryable and preserves draft',
      (tester) async {
    final auth = FakeAuthService();
    final permission = FakeLearnerMicrophonePermissionService(statuses: [
      LearnerMicrophonePermissionStatus.denied,
      LearnerMicrophonePermissionStatus.denied,
    ]);

    await tester.pumpWidget(_lessonScreen(
      auth,
      microphonePermissionService: permission,
      recordingService:
          LearnerAudioRecordingService(recorder: FakeLearnerRecorder()),
    ));
    await tester.pumpAndSettle();
    await _openTextComposer(tester);
    await tester.enterText(
        find.byKey(const Key('lesson-input')), 'Keep this draft');
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();

    expect(
        find.text(
            'Microphone access was not granted. Tap the microphone to try again.'),
        findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const Key('lesson-action-record')))
            .onPressed,
        isNotNull);
    expect(find.text('Keep this draft'), findsOneWidget);
    expect(permission.checkCalls, 1);
    expect(permission.requestCalls, 1);
    expect(auth.sendLessonChatReplyCallCount, 0);
    expect(auth.persistedMessages, isEmpty);
  });

  testWidgets('second microphone tap rechecks, requests, and starts recording',
      (tester) async {
    final recorder = FakeLearnerRecorder();
    final permission = FakeLearnerMicrophonePermissionService(statuses: [
      LearnerMicrophonePermissionStatus.denied,
      LearnerMicrophonePermissionStatus.denied,
      LearnerMicrophonePermissionStatus.denied,
      LearnerMicrophonePermissionStatus.granted,
    ]);
    await tester.pumpWidget(_lessonScreen(
      FakeAuthService(),
      microphonePermissionService: permission,
      recordingService: LearnerAudioRecordingService(recorder: recorder),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(permission.checkCalls, 2);
    expect(permission.requestCalls, 2);
  });

  testWidgets(
      'permanent microphone denial keeps settings action without requesting',
      (tester) async {
    final permission = FakeLearnerMicrophonePermissionService(
      statuses: [
        LearnerMicrophonePermissionStatus.permanentlyDenied,
        LearnerMicrophonePermissionStatus.permanentlyDenied,
      ],
    );
    await tester.pumpWidget(_lessonScreen(
      FakeAuthService(),
      microphonePermissionService: permission,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-open-microphone-settings')),
        findsOneWidget);
    expect(permission.requestCalls, 0);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const Key('lesson-action-record')))
            .onPressed,
        isNotNull);

    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(permission.checkCalls, 2);
    expect(permission.requestCalls, 0);
  });

  testWidgets('resume after Android settings clears granted permission error',
      (tester) async {
    final permission = FakeLearnerMicrophonePermissionService(statuses: [
      LearnerMicrophonePermissionStatus.permanentlyDenied,
      LearnerMicrophonePermissionStatus.granted,
    ]);
    await tester.pumpWidget(_lessonScreen(
      FakeAuthService(),
      microphonePermissionService: permission,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-open-microphone-settings')),
        findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('lesson-open-microphone-settings')), findsNothing);
    expect(
        find.text(
            'Microphone access is blocked. Open Android settings to enable it.'),
        findsNothing);
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });

  testWidgets('resume while still denied keeps the settings action',
      (tester) async {
    final permission = FakeLearnerMicrophonePermissionService(statuses: [
      LearnerMicrophonePermissionStatus.permanentlyDenied,
      LearnerMicrophonePermissionStatus.permanentlyDenied,
    ]);
    await tester.pumpWidget(_lessonScreen(
      FakeAuthService(),
      microphonePermissionService: permission,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-open-microphone-settings')),
        findsOneWidget);
    expect(permission.checkCalls, 2);
  });

  testWidgets('permission exception returns to retryable microphone state',
      (tester) async {
    final permission = FakeLearnerMicrophonePermissionService(statuses: []);
    permission.checkError = StateError('permission plugin failed');
    await tester.pumpWidget(_lessonScreen(
      FakeAuthService(),
      microphonePermissionService: permission,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pumpAndSettle();
    expect(
        find.text('Could not start recording. Please check your microphone.'),
        findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const Key('lesson-action-record')))
            .onPressed,
        isNotNull);
  });

  testWidgets(
      'user feedback action replaces the old placeholder after sending a message',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await _openTextComposer(tester);
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    final initialSendCount = auth.sendLessonChatReplyCallCount;
    final initialPersistCount = auth.persistedMessages.length;

    await _showWidget(
        tester, find.byKey(const Key('lesson-message-action-user-feedback')));
    await tester
        .tap(find.byKey(const Key('lesson-message-action-user-feedback')));
    await tester.pump();

    expect(find.textContaining('Coming next in a future lesson update.'),
        findsNothing);
    expect(auth.sendLessonChatReplyCallCount, initialSendCount);
    expect(auth.persistedMessages.length, initialPersistCount);
  });

  testWidgets('runtime scenario failure shows friendly retry state',
      (tester) async {
    final auth = FakeAuthService(
      scenarioFailure: const ApiException(
        'Could not load lesson content. Please try again.',
      ),
    );

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.text('Could not load lesson content. Please try again.'),
        findsOneWidget);
    expect(find.text('Retry lesson content'), findsOneWidget);
  });

  testWidgets('finish asks for confirmation and continues without a request',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    expect(find.text('Finish lesson?'), findsOneWidget);
    await tester.tap(find.text('Continue lesson'));
    await tester.pumpAndSettle();
    expect(auth.finishLessonSessionCallCount, 0);
  });

  testWidgets('visible Back confirms leaving and Stay makes no request',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lesson-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Leave lesson?'), findsOneWidget);
    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();

    expect(auth.abandonLessonSessionCallCount, 0);
    expect(find.byKey(const Key('lesson-action-keyboard')), findsOneWidget);
  });

  testWidgets('system Back uses the same leave confirmation', (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Leave lesson?'), findsOneWidget);
    expect(auth.abandonLessonSessionCallCount, 0);
  });

  testWidgets('leaving abandons once and returns home without finishing',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreenWithHome(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lesson-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave lesson'));
    await tester.pumpAndSettle();

    expect(auth.abandonLessonSessionCallCount, 1);
    expect(auth.finishLessonSessionCallCount, 0);
    expect(auth.loadLessonSummaryCallCount, 0);
    expect(auth.persistedMessages, isEmpty);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('abandon failure keeps the lesson open and allows retry',
      (tester) async {
    final auth = FakeAuthService(
      abandonResult: LessonSessionAbandonResult.failed(),
    );
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lesson-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Could not leave the lesson. Please try again.'),
        findsOneWidget);
    expect(find.byKey(const Key('lesson-action-keyboard')), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave lesson'));
    await tester.pumpAndSettle();
    expect(auth.abandonLessonSessionCallCount, 2);
  });

  testWidgets('finish sends once and shows unavailable completed state',
      (tester) async {
    final completer = Completer<LessonCompletionResult>();
    final auth = FakeAuthService(finishCompleter: completer);
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await _openTextComposer(tester);
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pump();
    expect(auth.finishLessonSessionCallCount, 1);
    expect(find.text('Finishing lesson...'), findsOneWidget);
    expect(tester.widget<FilledButton>(_sendButton()).onPressed, isNull);
    completer.complete(LessonCompletionResult.summaryUnavailable());
    await tester.pumpAndSettle();
    expect(find.text('Lesson completed'), findsOneWidget);
    expect(
        find.text(
            'Your lesson was saved, but a summary could not be created for this lesson.'),
        findsOneWidget);
    expect(find.text('Retry summary'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('summary-load error shows retry and loads the summary again',
      (tester) async {
    final auth = FakeAuthService(
      finishResult: LessonCompletionResult.summaryLoadError(),
      summaryResult: LessonCompletionResult.summaryLoadError(),
    );
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();

    expect(find.text('Retry summary'), findsOneWidget);
    expect(auth.loadLessonSummaryCallCount, 0);
    await tester.tap(find.text('Retry summary'));
    await tester.pumpAndSettle();
    expect(auth.loadLessonSummaryCallCount, 1);
  });

  testWidgets('Done exits the completed lesson', (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreenWithHome(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('scenario selection only finishes with zero valid learner turns',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();
    expect(auth.lastValidTurnCount, 0);
  });

  testWidgets('finish waits for pending user and tutor persistence',
      (tester) async {
    final userPersisted = Completer<void>();
    final tutorPersisted = Completer<void>();
    final auth = FakeAuthService(
      persistenceCompleters: [userPersisted, tutorPersisted],
    );
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await _openTextComposer(tester);
    await tester.enterText(find.byKey(const Key('lesson-input')), 'Hello');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    expect(auth.persistedMessages.length, 1);
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pump();
    expect(auth.finishLessonSessionCallCount, 0);
    userPersisted.complete();
    await tester.pump();
    expect(auth.persistedMessages.length, 2);
    expect(auth.finishLessonSessionCallCount, 0);
    tutorPersisted.complete();
    await tester.pumpAndSettle();
    expect(auth.finishLessonSessionCallCount, 1);
    expect(auth.lastValidTurnCount, 1);
    expect(auth.persistedMessages.map((message) => message.role),
        ['user', 'assistant']);
  });

  testWidgets('failed best-effort message persistence does not block finish',
      (tester) async {
    final auth = FakeAuthService(persistenceFailure: Exception('offline'));
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await _openTextComposer(tester);
    await tester.enterText(find.byKey(const Key('lesson-input')), 'Hello');
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();
    expect(auth.finishLessonSessionCallCount, 1);
  });

  testWidgets('ready summary renders backend learner content', (tester) async {
    final auth = FakeAuthService(
      finishResult:
          LessonCompletionResult.summaryReady(const LessonSummaryResponse(
        status: 'ready',
        level: 'A1',
        topicTitle: 'Daily Life',
        summary: 'You communicated clearly.',
        strengths: ['Clear greeting'],
        improvements: ['Use longer answers'],
        vocabulary: ['introduce'],
        grammar: ['I am from...'],
        nextSteps: ['Practice questions'],
      )),
    );
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson summary'), findsOneWidget);
    expect(find.text('You communicated clearly.'), findsOneWidget);
    final summarySurface = find.byKey(const Key('lesson-summary-scroll'));
    final summaryScrollable = find.descendant(
      of: summarySurface,
      matching: find.byType(Scrollable),
    );
    expect(summarySurface, findsOneWidget);
    expect(summaryScrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Clear greeting'),
      200,
      scrollable: summaryScrollable,
    );
    expect(find.text('Clear greeting'), findsOneWidget);
    expect(find.text('Use longer answers'), findsOneWidget);
    expect(find.text('introduce'), findsOneWidget);
    expect(find.text('I am from...'), findsOneWidget);
    expect(find.text('Practice questions'), findsOneWidget);
  });

  testWidgets('empty ready-summary sections are omitted', (tester) async {
    final auth = FakeAuthService(
      finishResult:
          LessonCompletionResult.summaryReady(const LessonSummaryResponse(
        status: 'ready',
        summary: 'Nice work.',
        strengths: ['Good effort'],
      )),
    );
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Strengths'), findsOneWidget);
    expect(find.text('Improvements'), findsNothing);
    expect(find.text('Vocabulary'), findsNothing);
    expect(find.text('Grammar'), findsNothing);
    expect(find.text('Next steps'), findsNothing);
  });

  testWidgets('finish failure restores the active lesson controls',
      (tester) async {
    final auth = FakeAuthService(finishResult: LessonCompletionResult.failed());
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await _openTextComposer(tester);
    await tester.enterText(find.byKey(const Key('lesson-input')), 'Hello');
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Could not finish the lesson. Please check your connection and try again.'),
        findsOneWidget);
    expect(tester.widget<FilledButton>(_sendButton()).onPressed, isNotNull);
  });

  testWidgets('completed lesson cannot send another message', (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish lesson'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-input')), findsNothing);
    expect(find.byKey(const Key('lesson-send-button')), findsNothing);
  });
}
