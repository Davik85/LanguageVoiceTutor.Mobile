import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/lesson_access_decision.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/models/tutor_options.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';
import 'package:language_voice_tutor_mobile/services/tutor_options_service.dart';

class RecordingApiClient implements ApiClient {
  RecordingApiClient(this.response);

  final ApiResponse response;
  String? requestedPath;
  String? accessToken;

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    requestedPath = path;
    this.accessToken = accessToken;
    return response;
  }

  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
}

class FakeTutorOptionsService extends TutorOptionsService {
  FakeTutorOptionsService({this.options, this.failure})
      : super(apiClient: RecordingApiClient(
            const ApiResponse(statusCode: 500, body: '{}')));

  final TutorOptions? options;
  final ApiException? failure;

  @override
  Future<TutorOptions> fetchTutorOptions() async {
    if (failure != null) throw failure!;
    return options!;
  }
}

class FakeAuthService extends AuthService {
  FakeAuthService()
      : super(
          apiClient: RecordingApiClient(
            const ApiResponse(statusCode: 500, body: '{}'),
          ),
          storage: _MemoryStorage(),
        );

  @override
  Future<AuthUser> loadCurrentUser() async => AuthUser(
        userId: 'user-1',
        email: 'user@example.com',
        displayName: 'User',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async =>
      SubscriptionStatus(
        userId: 'user-1',
        premiumActive: false,
        trialActive: false,
        freeLessonUsedToday: 0,
        freeLessonRemainingToday: 1,
        checkedAtUtc: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        enforcementEnabled: true,
      );

  @override
  Future<LessonAccessDecision> fetchLessonAccessDecision() async =>
      LessonAccessDecision.fromJson({'canStartNewLesson': false});
}

class _MemoryStorage implements SessionStorage {
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

void main() {
  test('tutor options response parsing tolerates extra fields', () {
    final options = TutorOptions.fromJson({
      'studyLanguages': [
        {'code': 'es', 'name': 'Spanish', 'extra': 'ignored'},
        {'code': 'fr', 'displayName': 'French'}
      ],
      'levels': ['Beginner', {'level': 'Intermediate'}],
      'topics': [
        {'topicId': 'travel', 'topicTitle': 'Travel'}
      ],
      'scenarios': [
        {'scenarioKey': 'restaurant', 'scenarioTitle': 'Restaurant'}
      ],
      'contexts': [
        {'selectedContextId': 'casual', 'contextTitle': 'Casual'}
      ],
      'tutors': [
        {'id': 'maria', 'name': 'Maria'}
      ],
      'modes': ['Guided'],
      'futureField': {'anything': true},
    });

    expect(options.studyLanguages, ['Spanish', 'French']);
    expect(options.levels, ['Beginner', 'Intermediate']);
    expect(options.topics, ['Travel']);
    expect(options.scenarios, ['Restaurant']);
    expect(options.contexts, ['Casual']);
    expect(options.tutors, ['Maria']);
    expect(options.modes, ['Guided']);
    expect(options.hasAnyOptions, isTrue);
  });

  test('service calls public tutor options endpoint without auth token', () async {
    final apiClient = RecordingApiClient(const ApiResponse(
      statusCode: 200,
      body: '{"studyLanguages":["Spanish"],"levels":["Beginner"]}',
    ));

    final options =
        await TutorOptionsService(apiClient: apiClient).fetchTutorOptions();

    expect(apiClient.requestedPath, '/api/tutor-options');
    expect(apiClient.accessToken, isNull);
    expect(options.studyLanguages, ['Spanish']);
  });

  test('service returns sanitized failure on non-success', () async {
    final service = TutorOptionsService(
      apiClient: RecordingApiClient(
        const ApiResponse(statusCode: 500, body: '{"internal":"details"}'),
      ),
    );

    expect(
      service.fetchTutorOptions(),
      throwsA(isA<ApiException>().having(
        (error) => error.message,
        'message',
        'Unable to load practice options right now.',
      )),
    );
  });

  testWidgets('home widget displays loaded catalog summary', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        authService: FakeAuthService(),
        tutorOptionsService: FakeTutorOptionsService(
          options: const TutorOptions(
            studyLanguages: ['Spanish', 'French'],
            levels: ['Beginner'],
            topics: ['Travel', 'Food'],
            scenarios: ['Restaurant'],
            contexts: [],
            tutors: [],
            modes: ['Guided'],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Lesson catalog'), findsOneWidget);
    expect(find.text('Study languages: Spanish, French'), findsOneWidget);
    expect(find.text('Levels: Beginner'), findsOneWidget);
    expect(find.text('Topics: Travel, Food'), findsOneWidget);
  });

  testWidgets('home widget displays friendly unavailable state', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        authService: FakeAuthService(),
        tutorOptionsService: FakeTutorOptionsService(
          failure: const ApiException('raw backend details'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Lesson catalog'), findsOneWidget);
    expect(
      find.text(
        'Practice options are unavailable right now. Please try again later.',
      ),
      findsOneWidget,
    );
    expect(find.text('raw backend details'), findsNothing);
  });
}
