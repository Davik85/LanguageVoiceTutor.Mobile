import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/lesson_start_selection.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session_models.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
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
    LessonSessionStartResult? startResult,
    this.startGate,
  })
      : startResult = startResult ??
            LessonSessionStartResult.ready(
              const LessonSessionResponse(
                status: 'ready',
                lessonSessionId: 's1',
              ),
            ),
        super(apiClient: FakeApiClient(), storage: MemoryStorage());

  final LessonSessionStartResult startResult;
  final Completer<void>? startGate;
  final startCalls = <Map<String, String>>[];

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
  Future<UserSettings> fetchUserSettings() async => const UserSettings(
        nativeLanguage: 'en',
        studyLanguage: 'es',
        explanationLanguage: 'en',
        speechVoice: 'nova',
        speechSpeed: 1.0,
        conversationModeEnabled: true,
        selectedTutorId: 'lana',
      );

  @override
  Future<LessonSessionStartResult> startLessonSession(
    String lessonContentId,
    String studyLanguage,
  ) async {
    startCalls.add({
      'lessonContentId': lessonContentId,
      'studyLanguage': studyLanguage,
    });
    await startGate?.future;
    return startResult;
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

Widget _home({FakeAuthService? authService}) => MaterialApp(
      home: HomeScreen(authService: authService ?? FakeAuthService()),
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

  testWidgets('travel lesson starts backend session and shows ready state',
      (tester) async {
    final startGate = Completer<void>();
    final auth = FakeAuthService(startGate: startGate);
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

    expect(find.text('Starting lesson…'), findsOneWidget);

    startGate.complete();
    await tester.pumpAndSettle();

    expect(find.text('Lesson started'), findsOneWidget);
    expect(find.text('Lesson session is ready'), findsOneWidget);
    expect(find.text('Level: A1 Beginner'), findsOneWidget);
    expect(find.text('Topic: Travel'), findsOneWidget);
    expect(find.text('Situation: Airport check-in'), findsOneWidget);
    expect(auth.startCalls, [
      {'lessonContentId': 'airport_check_in', 'studyLanguage': 'Spanish'}
    ]);
    expect(
      find.text(
        'Text chat is coming next. Voice, TTS, and AI tutor replies are intentionally not implemented in this version.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('/api/lesson-chat/reply'), findsNothing);
  });

  testWidgets('non-travel lesson skeleton uses friendly situations',
      (tester) async {
    await tester.pumpWidget(_home());
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
    expect(find.text('Level: A2 Elementary'), findsOneWidget);
    expect(find.text('Topic: Daily Life'), findsOneWidget);
    expect(find.text('Situation: Introductions'), findsOneWidget);
  });

  testWidgets('lesson start access denied shows free-limit message',
      (tester) async {
    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        startResult: LessonSessionStartResult.accessDenied,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A2 Elementary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily Life'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Introductions'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'You have used today’s free lesson. Please try again tomorrow or upgrade.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('lesson start active conflict shows friendly message',
      (tester) async {
    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        startResult: LessonSessionStartResult.activeLessonExists,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A2 Elementary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily Life'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Introductions'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'You already have an active lesson on another device. Finish it there before starting a new one.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('lesson start backend failure shows retry message',
      (tester) async {
    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        startResult: LessonSessionStartResult.unavailable,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A2 Elementary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily Life'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Introductions'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Could not start the lesson. Please check your connection and try again.',
      ),
      findsOneWidget,
    );
  });
}
