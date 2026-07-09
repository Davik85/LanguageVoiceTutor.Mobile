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
    LessonRuntimeScenario? scenario,
    this.settingsFailure,
    this.scenarioFailure,
    this.studyLanguage = 'es',
  })  : lessonStartResult = lessonStartResult ?? _readyLessonStartResult(),
        replyResult = replyResult ?? _defaultReplyResult(),
        scenario = scenario ?? _runtimeScenario(),
        super(apiClient: FakeApiClient(), storage: MemoryStorage());

  final Completer<LessonSessionStartResult>? lessonStartCompleter;
  final LessonSessionStartResult lessonStartResult;
  final Completer<LessonChatReplyResult>? replyCompleter;
  final LessonChatReplyResult replyResult;
  final LessonRuntimeScenario scenario;
  final ApiException? settingsFailure;
  final ApiException? scenarioFailure;
  final String studyLanguage;

  int startLessonSessionCallCount = 0;
  int fetchScenarioCallCount = 0;
  int sendLessonChatReplyCallCount = 0;
  StartLessonSessionRequest? lastStartRequest;
  LessonChatRequest? lastLessonChatRequest;
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
  Future<void> persistLessonSessionMessage({
    required String sessionId,
    required CreateLessonSessionMessageRequest request,
  }) async {
    persistedMessages.add(request);
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

LessonSessionStartResult _readyLessonStartResult() =>
    LessonSessionStartResult.ready(
      const LessonSessionResponse(
        lessonSessionId: 'session-1',
        lessonContentId: 'everyday_english_introductions',
        studyLanguage: 'Spanish',
      ),
    );

LessonRuntimeScenario _runtimeScenario() => LessonRuntimeScenario.fromJson({
      'id': 'everyday_english_introductions',
      'metadata': {
        'topic': 'Daily Life',
        'subtopic': 'Introductions',
        'lessonType': 'guided_roleplay',
      },
      'lessonSetup': {
        'setupMessage': 'Today we will practice introductions.',
      },
      'learningGoal': {
        'goal':
            'The user can introduce themselves and ask simple personal questions.',
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
        'opening': 'Hi! What is your name?',
        'firstUserTask': 'Say your name.',
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
        'lessonPhase': 'active_roleplay',
        'hasWrapUpStarted': false,
      },
    });

LessonChatReplyResult _defaultReplyResult() => LessonChatReplyResult.success(
      const LessonChatReplyResponse(
        botReply: 'Hi! Nice to meet you. Where are you from?',
        isLessonComplete: false,
      ),
    );

Widget _home({FakeAuthService? authService}) => MaterialApp(
      home: HomeScreen(authService: authService ?? FakeAuthService()),
    );

Widget _lessonScreen(FakeAuthService authService) => MaterialApp(
      home: LessonScreen(
        authService: authService,
        selection: _introLessonSelection,
      ),
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

Future<void> _showAction(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('selecting a situation starts lesson and loads text chat',
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

    expect(find.text('Starting lesson...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(auth.startLessonSessionCallCount, 1);

    startCompleter.complete(_readyLessonStartResult());
    await tester.pumpAndSettle();

    expect(find.text('Lesson started'), findsOneWidget);
    expect(find.text('Lesson session is ready.'), findsOneWidget);
    expect(find.text('Introductions'), findsWidgets);
    expect(find.byKey(const Key('lesson-input')), findsOneWidget);
    expect(_sendButton(), findsOneWidget);
    expect(auth.fetchScenarioCallCount, 1);
    expect(auth.lastStartRequest?.lessonContentId,
        'everyday_english_introductions');
  });

  testWidgets('send button is disabled for blank input', (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(_sendButton());
    expect(button.onPressed, isNull);
  });

  testWidgets('send button and loading state prevent duplicate sends',
      (tester) async {
    final replyCompleter = Completer<LessonChatReplyResult>();
    final auth = FakeAuthService(replyCompleter: replyCompleter);

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await _showAction(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pump();

    expect(auth.sendLessonChatReplyCallCount, 1);
    expect(find.text('Thinking'), findsOneWidget);
    expect(find.text('Sending...'), findsOneWidget);
    final button = tester.widget<FilledButton>(_sendButton());
    expect(button.onPressed, isNull);

    replyCompleter.complete(_defaultReplyResult());
    await tester.pumpAndSettle();
  });

  testWidgets('user text is shown in the chat after send', (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello, my name is Sam.');
    await tester.pump();
    await _showAction(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pump();

    expect(find.text('Hello, my name is Sam.'), findsOneWidget);
    expect(auth.lastLessonChatRequest?.userMessage, 'Hello, my name is Sam.');
  });

  testWidgets('bot reply text is shown after a successful backend response',
      (tester) async {
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
    await _showAction(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();

    expect(find.text('Hi Sam! Nice to meet you.'), findsOneWidget);
    expect(auth.persistedMessages, hasLength(2));
    expect(auth.persistedMessages.first.role, 'user');
    expect(auth.persistedMessages.last.role, 'assistant');
  });

  testWidgets('tutor header renders with avatar, name, and ready status',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-tutor-header')), findsOneWidget);
    expect(find.byKey(const Key('lesson-avatar')), findsOneWidget);
    expect(find.text('Lana'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets(
      'tutor status changes to thinking during reply and returns to ready',
      (tester) async {
    final replyCompleter = Completer<LessonChatReplyResult>();
    final auth = FakeAuthService(replyCompleter: replyCompleter);

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await _showAction(tester, _sendButton());
    await tester.tap(_sendButton());
    await tester.pump();

    expect(find.text('Thinking'), findsOneWidget);

    replyCompleter.complete(_defaultReplyResult());
    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('future action buttons render', (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-action-record')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-play-voice')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-hint')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-translation')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-feedback')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-finish')), findsOneWidget);
  });

  testWidgets('future action buttons stay local and do not call backend',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    final initialSendCount = auth.sendLessonChatReplyCallCount;
    final initialPersistCount = auth.persistedMessages.length;
    final initialScenarioCount = auth.fetchScenarioCallCount;

    await _showAction(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pump();
    expect(find.text('Listening'), findsOneWidget);
    expect(find.text('Stop recording'), findsOneWidget);

    await _showAction(tester, find.byKey(const Key('lesson-action-record')));
    await tester.tap(find.byKey(const Key('lesson-action-record')));
    await tester.pump();

    await _showAction(
        tester, find.byKey(const Key('lesson-action-play-voice')));
    await tester.tap(find.byKey(const Key('lesson-action-play-voice')));
    await tester.pump();
    await _showAction(tester, find.byKey(const Key('lesson-action-hint')));
    await tester.tap(find.byKey(const Key('lesson-action-hint')));
    await tester.pump();
    await _showAction(
        tester, find.byKey(const Key('lesson-action-translation')));
    await tester.tap(find.byKey(const Key('lesson-action-translation')));
    await tester.pump();
    await _showAction(tester, find.byKey(const Key('lesson-action-feedback')));
    await tester.tap(find.byKey(const Key('lesson-action-feedback')));
    await tester.pump();
    await _showAction(tester, find.byKey(const Key('lesson-action-finish')));
    await tester.tap(find.byKey(const Key('lesson-action-finish')));
    await tester.pump();

    expect(find.textContaining('Coming next in a future lesson update.'),
        findsOneWidget);
    expect(auth.sendLessonChatReplyCallCount, initialSendCount);
    expect(auth.persistedMessages.length, initialPersistCount);
    expect(auth.fetchScenarioCallCount, initialScenarioCount);
  });

  testWidgets('layout foundation widgets are present', (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lesson-tutor-header')), findsOneWidget);
    expect(find.byKey(const Key('lesson-scenario-card')), findsOneWidget);
    expect(find.byKey(const Key('lesson-chat-transcript')), findsOneWidget);
    expect(find.byKey(const Key('lesson-action-controls')), findsOneWidget);
    expect(find.byKey(const Key('lesson-input')), findsOneWidget);
    expect(_sendButton(), findsOneWidget);
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
    expect(find.text('Error'), findsOneWidget);
  });
}
