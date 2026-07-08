import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
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
    this.settingsFailure,
    this.studyLanguage = 'es',
  })  : lessonStartResult = lessonStartResult ?? _readyLessonStartResult(),
        super(apiClient: FakeApiClient(), storage: MemoryStorage());

  final Completer<LessonSessionStartResult>? lessonStartCompleter;
  final LessonSessionStartResult lessonStartResult;
  final ApiException? settingsFailure;
  final String studyLanguage;
  int startLessonSessionCallCount = 0;
  StartLessonSessionRequest? lastStartRequest;

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

const _airportLessonSelection = LessonStartSelection(
  level: 'A1 Beginner',
  topicId: '2',
  topicTitle: 'Travel',
  subtopicId: '201',
  subtopicTitle: 'Airport check-in',
  situation: 'Airport check-in',
  lessonContentId: 'travel_airport_check_in',
);

LessonSessionStartResult _readyLessonStartResult({
  String lessonContentId = 'travel_airport_check_in',
  String studyLanguage = 'Spanish',
}) =>
    LessonSessionStartResult.ready(
      LessonSessionResponse(
        lessonSessionId: 'session-1',
        lessonContentId: lessonContentId,
        studyLanguage: studyLanguage,
      ),
    );

Widget _home({FakeAuthService? authService}) => MaterialApp(
      home: HomeScreen(authService: authService ?? FakeAuthService()),
    );

Widget _lessonScreen(FakeAuthService authService) => MaterialApp(
      home: LessonScreen(
        authService: authService,
        selection: _airportLessonSelection,
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

Future<void> _scrollToVisible(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (tester.any(finder)) {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    return;
  }

  await tester.scrollUntilVisible(
    finder,
    -500,
    scrollable: find.byType(Scrollable),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('lesson situation catalog uses product-friendly labels', () {
    expect(lessonLevels.map((level) => level.id), [
      'a1',
      'a2',
      'b1',
      'b2',
    ]);
    expect(lessonTopics.map((topic) => topic.id), [
      'daily_life',
      'travel',
      'work_business',
      'job_interview',
      'restaurant_cafe',
      'free_conversation',
    ]);

    for (final topic in lessonTopics) {
      final situations = lessonSituationsByTopic[topic.label];
      expect(situations, isNotNull, reason: topic.label);
      expect(situations, isNotEmpty, reason: topic.label);
      for (final situation in situations!) {
        expect(situation.label, isNot(contains('Placeholder:')));
      }
    }

    expect(travelSituations.map((situation) => situation.label), [
      'Airport check-in',
      'Hotel check-in',
      'Asking for directions',
      'Ordering transport',
      'Lost luggage',
    ]);
  });

  test('situation card styles inherit the selected topic family', () {
    for (final topic in lessonTopics) {
      final topicStyle = lessonCardStyleForTopic(topic);
      final situationStyle = lessonCardStyleForSituationTopic(topic.label);

      expect(situationStyle.familyId, topicStyle.familyId, reason: topic.label);
    }

    expect(
      lessonCardStyleForSituationTopic('Travel').familyId,
      'topic-travel',
    );
  });

  testWidgets('home starts lesson selection skeleton', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('Start lesson'), findsOneWidget);
    expect(find.text('Open Lesson'), findsNothing);

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Level'), findsOneWidget);
    expect(find.text('A1 Beginner'), findsOneWidget);
    expect(find.text('A2 Elementary'), findsOneWidget);
    expect(find.text('B1 Intermediate'), findsOneWidget);
    expect(find.text('B2 Upper-Intermediate'), findsOneWidget);
    expect(find.byKey(const Key('lesson-level-card-a1')), findsOneWidget);
  });

  testWidgets('selecting a situation starts lesson session and shows success',
      (tester) async {
    final startCompleter = Completer<LessonSessionStartResult>();
    final auth = FakeAuthService(lessonStartCompleter: startCompleter);

    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1 Beginner'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Topic'), findsOneWidget);
    await _expectVisibleAfterScroll(tester, 'Daily Life');
    await _expectVisibleAfterScroll(tester, 'Travel');
    await _expectVisibleAfterScroll(tester, 'Work & Business');
    await _expectVisibleAfterScroll(tester, 'Job Interview');
    await _expectVisibleAfterScroll(tester, 'Restaurant & Cafe');
    await _expectVisibleAfterScroll(tester, 'Free Conversation');
    await _scrollToVisible(tester, 'Travel');
    expect(find.byKey(const Key('lesson-topic-card-travel')), findsOneWidget);

    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Situation'), findsOneWidget);
    await _expectVisibleAfterScroll(tester, 'Airport check-in');
    await _expectVisibleAfterScroll(tester, 'Hotel check-in');
    await _expectVisibleAfterScroll(tester, 'Asking for directions');
    await _expectVisibleAfterScroll(tester, 'Ordering transport');
    await _expectVisibleAfterScroll(tester, 'Lost luggage');
    await _scrollToVisible(tester, 'Airport check-in');
    expect(
      find.byKey(const Key('lesson-situation-card-airport_check_in')),
      findsOneWidget,
    );

    await tester.tap(find.text('Airport check-in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Starting lesson...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(auth.startLessonSessionCallCount, 1);
    expect(auth.lastStartRequest?.lessonContentId, 'travel_airport_check_in');
    expect(auth.lastStartRequest?.studyLanguage, 'Spanish');
    expect(auth.lastStartRequest?.level, 'A1 Beginner');
    expect(auth.lastStartRequest?.topicId, '2');
    expect(auth.lastStartRequest?.topicTitle, 'Travel');
    expect(auth.lastStartRequest?.subtopicId, '201');
    expect(auth.lastStartRequest?.subtopicTitle, 'Airport check-in');
    expect(auth.lastStartRequest?.modeUsed, 'text');

    startCompleter.complete(_readyLessonStartResult());
    await tester.pumpAndSettle();

    expect(find.text('Lesson started'), findsOneWidget);
    expect(find.text('Lesson session is ready.'), findsOneWidget);
    expect(find.text('Level: A1 Beginner'), findsOneWidget);
    expect(find.text('Topic: Travel'), findsOneWidget);
    expect(find.text('Situation: Airport check-in'), findsOneWidget);
    expect(find.text('Text chat is coming next.'), findsOneWidget);
    expect(find.textContaining('session-1'), findsNothing);
    expect(find.textContaining('/api/lesson-chat/reply'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Send'), findsNothing);
  });

  testWidgets('non-travel lesson skeleton uses friendly situations',
      (tester) async {
    final auth = FakeAuthService();

    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A2 Elementary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily Life'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Situation'), findsOneWidget);
    expect(find.text('Introductions'), findsOneWidget);
    expect(find.text('Asking for help'), findsOneWidget);
    expect(find.textContaining('Placeholder:'), findsNothing);

    await tester.tap(find.text('Introductions'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson started'), findsOneWidget);
    expect(find.text('Lesson session is ready.'), findsOneWidget);
    expect(find.text('Level: A2 Elementary'), findsOneWidget);
    expect(find.text('Topic: Daily Life'), findsOneWidget);
    expect(find.text('Situation: Introductions'), findsOneWidget);
    expect(
      auth.lastStartRequest?.lessonContentId,
      'everyday_english_introductions',
    );
    expect(auth.lastStartRequest?.studyLanguage, 'Spanish');
    expect(auth.lastStartRequest?.level, 'A2 Elementary');
    expect(auth.lastStartRequest?.topicId, '1');
    expect(auth.lastStartRequest?.topicTitle, 'Daily Life');
    expect(auth.lastStartRequest?.subtopicId, '101');
    expect(auth.lastStartRequest?.subtopicTitle, 'Introductions');
  });

  testWidgets('access denied result shows friendly service message',
      (tester) async {
    final result = LessonSessionStartResult.blocked();
    final auth = FakeAuthService(lessonStartResult: result);

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(auth.startLessonSessionCallCount, 1);
    expect(find.text(result.message), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('active lesson conflict result shows friendly service message',
      (tester) async {
    final result = LessonSessionStartResult.conflict();
    final auth = FakeAuthService(lessonStartResult: result);

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(auth.startLessonSessionCallCount, 1);
    expect(find.text(result.message), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('backend unavailable result shows friendly service message',
      (tester) async {
    final result = LessonSessionStartResult.unavailable();
    final auth = FakeAuthService(lessonStartResult: result);

    await tester.pumpWidget(_lessonScreen(auth));
    await tester.pumpAndSettle();

    expect(auth.startLessonSessionCallCount, 1);
    expect(find.text(result.message), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
