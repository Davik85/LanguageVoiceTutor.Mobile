import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/lesson_start_selection.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/models/tutor_options.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';
import 'package:language_voice_tutor_mobile/services/tutor_options_service.dart';

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
  FakeAuthService()
      : super(apiClient: FakeApiClient(), storage: MemoryStorage());

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
}

class FakeTutorOptionsService extends TutorOptionsService {
  FakeTutorOptionsService() : super(apiClient: FakeApiClient());

  @override
  Future<TutorOptions> fetchTutorOptions() async => const TutorOptions(tutors: [
        TutorOption(tutorId: 'nelli', displayName: 'Nelli', isActive: true),
      ]);
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

Widget _home() => MaterialApp(
      home: HomeScreen(
        authService: FakeAuthService(),
        tutorOptionsService: FakeTutorOptionsService(),
      ),
    );

void main() {
  test('lesson situation catalog uses product-friendly labels', () {
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
  });

  testWidgets('travel lesson skeleton reaches placeholder with selections',
      (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1 Beginner'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Topic'), findsOneWidget);
    expect(find.text('Daily Life'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Work & Business'), findsOneWidget);
    expect(find.text('Job Interview'), findsOneWidget);
    expect(find.text('Restaurant & Cafe'), findsOneWidget);
    expect(find.text('Free Conversation'), findsOneWidget);

    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Situation'), findsOneWidget);
    expect(find.text('Airport check-in'), findsOneWidget);
    expect(find.text('Hotel check-in'), findsOneWidget);
    expect(find.text('Asking for directions'), findsOneWidget);
    expect(find.text('Ordering transport'), findsOneWidget);
    expect(find.text('Lost luggage'), findsOneWidget);

    await tester.tap(find.text('Airport check-in'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson placeholder'), findsOneWidget);
    expect(find.text('Level: A1 Beginner'), findsOneWidget);
    expect(find.text('Topic: Travel'), findsOneWidget);
    expect(find.text('Situation: Airport check-in'), findsOneWidget);
    expect(
      find.text(
        'Placeholder lesson screen. Lesson runtime, voice recording, TTS, and AI tutor calls are intentionally not implemented.',
      ),
      findsOneWidget,
    );
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

    expect(find.text('Lesson placeholder'), findsOneWidget);
    expect(find.text('Level: A2 Elementary'), findsOneWidget);
    expect(find.text('Topic: Daily Life'), findsOneWidget);
    expect(find.text('Situation: Introductions'), findsOneWidget);
  });
}
