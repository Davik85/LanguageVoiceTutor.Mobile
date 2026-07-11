import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/lesson_chat.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';
import 'package:language_voice_tutor_mobile/models/lesson_start_selection.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/models/translation.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/screens/lesson_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

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

  int startLessonSessionCallCount = 0;
  int fetchScenarioCallCount = 0;
  int sendLessonChatReplyCallCount = 0;
  int requestLessonChatHintCallCount = 0;
  int requestTranslationCallCount = 0;
  int finishLessonSessionCallCount = 0;
  int abandonLessonSessionCallCount = 0;
  int loadLessonSummaryCallCount = 0;
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
}) =>
    MaterialApp(
      home: LessonScreen(
        authService: authService,
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

void main() {
  testWidgets('selecting a situation starts lesson and opens the workspace',
      (tester) async {
    final startCompleter = Completer<LessonSessionStartResult>();
    final auth = FakeAuthService(lessonStartCompleter: startCompleter);

    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1 Beginner'));
    await tester.pumpAndSettle();
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
    expect(find.byKey(const Key('lesson-input')), findsOneWidget);
    expect(_sendButton(), findsOneWidget);
    expect(auth.fetchScenarioCallCount, 1);
    expect(auth.lastStartRequest?.lessonContentId,
        'everyday_english_introductions');
  });

  testWidgets('tutor header renders large avatar area and compact metadata',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final avatarFinder = find.byKey(const Key('lesson-avatar'));
    expect(avatarFinder, findsOneWidget);
    expect(tester.getSize(avatarFinder).height, greaterThanOrEqualTo(220));
    expect(find.text('Lana'), findsOneWidget);
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

  testWidgets('typed scenario choice resolves before sending lesson chat reply',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'meeting a new neighbor');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(auth.lastLessonChatRequest?.userMessage, 'meeting a new neighbor');
    expect(
        auth.lastLessonChatRequest?.selectedContextVariantId, 'new_neighbor');
    expect(auth.lastLessonChatRequest?.selectedContextTitle,
        'Meeting a new neighbor');
    expect(auth.lastLessonChatRequest?.selectedContextOpeningLine, isNotEmpty);
  });

  testWidgets('numeric scenario choice resolves the CMS context variant',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(auth.lastLessonChatRequest?.selectedContextVariantId,
        'first_day_class');
    expect(auth.lastLessonChatRequest?.selectedContextTitle,
        'First day at a language school');
  });

  testWidgets('custom scenario context has no invented variant ID',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

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

    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-hint-card')), findsNothing);
    expect(
        auth.lastLessonChatRequest?.selectedContextVariantId, 'new_neighbor');
  });

  testWidgets('send button is disabled for blank input', (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

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
    await tester.pump();
    await tester.tap(find.byKey(const Key('lesson-action-hint')));
    await tester.pump();

    expect(find.textContaining('Coming next in a future lesson update.'),
        findsOneWidget);
    expect(auth.sendLessonChatReplyCallCount, initialSendCount);
    expect(auth.persistedMessages.length, initialPersistCount);
  });

  testWidgets('record placeholder stays local and switches status',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final initialSendCount = auth.sendLessonChatReplyCallCount;
    final initialPersistCount = auth.persistedMessages.length;

    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pump();

    expect(find.textContaining('Coming next in a future lesson update.'),
        findsOneWidget);
    expect(auth.sendLessonChatReplyCallCount, initialSendCount);
    expect(auth.persistedMessages.length, initialPersistCount);
    expect(find.byIcon(Icons.stop), findsOneWidget);
  });

  testWidgets(
      'user feedback action replaces the old placeholder after sending a message',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

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
    expect(find.byKey(const Key('lesson-input')), findsOneWidget);
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
    expect(find.byKey(const Key('lesson-input')), findsOneWidget);

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
