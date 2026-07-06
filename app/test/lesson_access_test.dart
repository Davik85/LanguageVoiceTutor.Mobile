import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/lesson_access_decision.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class RecordingApiClient implements ApiClient {
  RecordingApiClient({required this.getResponse, this.postResponse});

  final ApiResponse Function(String path, String? accessToken) getResponse;
  final ApiResponse Function(String path, Map<String, dynamic>? body)?
      postResponse;
  final requests = <({String method, String path, String? accessToken})>[];

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    requests.add((method: 'GET', path: path, accessToken: accessToken));
    return getResponse(path, accessToken);
  }

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    requests.add((method: 'POST', path: path, accessToken: accessToken));
    return postResponse?.call(path, body) ??
        const ApiResponse(statusCode: 500, body: '{}');
  }
}

class MemoryStorage implements SessionStorage {
  MemoryStorage({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  bool cleared = false;

  @override
  Future<void> clear() async {
    cleared = true;
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}

class FakeAuthService extends AuthService {
  FakeAuthService({required this.lessonAccess, this.failure})
      : super(
          apiClient: RecordingApiClient(
            getResponse: (_, __) =>
                const ApiResponse(statusCode: 500, body: '{}'),
          ),
          storage: MemoryStorage(),
        );

  final LessonAccessDecision? lessonAccess;
  final ApiException? failure;

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
  Future<LessonAccessDecision> fetchLessonAccessDecision() async {
    if (failure != null) throw failure!;
    return lessonAccess!;
  }
}

String lessonAccessJson({required bool canStartNewLesson}) => '''
{
  "userId":"u1",
  "canStartNewLesson":$canStartNewLesson,
  "premiumActive":false,
  "trialActive":true,
  "freeLessonUsedToday":false,
  "freeLessonRemainingToday":1,
  "enforcementEnabled":true,
  "decision":"${canStartNewLesson ? 'allowed' : 'blocked'}",
  "reason":"${canStartNewLesson ? 'Trial access is active.' : 'Daily free lesson limit reached.'}",
  "source":"backend",
  "checkedAtUtc":"2026-07-06T12:00:00Z",
  "extraField":"ignored"
}
''';

void main() {
  test('lesson access response parsing tolerates extra fields', () {
    final decision = LessonAccessDecision.fromJson({
      'userId': 'u1',
      'canStartNewLesson': true,
      'premiumActive': false,
      'trialActive': true,
      'freeLessonUsedToday': false,
      'freeLessonRemainingToday': 1,
      'enforcementEnabled': true,
      'decision': 'allowed',
      'reason': 'Trial access is active.',
      'source': 'backend',
      'checkedAtUtc': '2026-07-06T12:00:00Z',
      'extra': 'ignored',
    });

    expect(decision.canStartNewLesson, isTrue);
    expect(decision.decision, 'allowed');
    expect(decision.reason, 'Trial access is active.');
    expect(decision.freeLessonRemainingToday, 1);
    expect(decision.checkedAtUtc, DateTime.parse('2026-07-06T12:00:00Z'));
  });

  test('authenticated lesson access request sends bearer token', () async {
    final apiClient = RecordingApiClient(
      getResponse: (path, accessToken) => ApiResponse(
        statusCode: 200,
        body: lessonAccessJson(canStartNewLesson: true),
      ),
    );
    final authService = AuthService(
      apiClient: apiClient,
      storage: MemoryStorage(accessToken: 'access-token'),
    );

    await authService.fetchLessonAccessDecision();

    expect(apiClient.requests.single.path, '/api/me/lesson-access');
    expect(apiClient.requests.single.accessToken, 'access-token');
  });

  test('lesson access service refreshes on 401 and succeeds', () async {
    var lessonAccessCalls = 0;
    final storage = MemoryStorage(
      accessToken: 'expired-token',
      refreshToken: 'refresh-token',
    );
    final apiClient = RecordingApiClient(
      getResponse: (path, accessToken) {
        lessonAccessCalls++;
        if (lessonAccessCalls == 1) {
          return const ApiResponse(statusCode: 401, body: '{}');
        }
        return ApiResponse(
          statusCode: 200,
          body: lessonAccessJson(canStartNewLesson: true),
        );
      },
      postResponse: (path, body) => const ApiResponse(
        statusCode: 200,
        body: '{"accessToken":"new-access-token","tokenType":"Bearer","expiresAtUtc":"2026-07-06T13:00:00Z","refreshToken":"new-refresh-token","refreshTokenExpiresAtUtc":"2026-08-06T12:00:00Z","user":{"userId":"u1","email":"user@example.com","createdAt":"2026-07-01T12:00:00Z"}}',
      ),
    );

    final decision = await AuthService(apiClient: apiClient, storage: storage)
        .fetchLessonAccessDecision();

    expect(decision.canStartNewLesson, isTrue);
    expect(storage.accessToken, 'new-access-token');
    expect(apiClient.requests.map((request) => request.path), [
      '/api/me/lesson-access',
      '/api/auth/refresh',
      '/api/me/lesson-access',
    ]);
  });

  test('lesson access service clears session when refresh fails', () async {
    final storage = MemoryStorage(
      accessToken: 'expired-token',
      refreshToken: 'refresh-token',
    );
    final apiClient = RecordingApiClient(
      getResponse: (_, __) => const ApiResponse(statusCode: 401, body: '{}'),
      postResponse: (_, __) => const ApiResponse(statusCode: 401, body: '{}'),
    );

    await expectLater(
      AuthService(apiClient: apiClient, storage: storage)
          .fetchLessonAccessDecision(),
      throwsA(isA<ApiException>()),
    );
    expect(storage.cleared, isTrue);
  });

  testWidgets('home screen shows allowed lesson access', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          authService: FakeAuthService(
            lessonAccess: LessonAccessDecision.fromJson({
      'userId': 'u1',
      'canStartNewLesson': true,
      'premiumActive': false,
      'trialActive': true,
      'freeLessonUsedToday': false,
      'freeLessonRemainingToday': 1,
      'enforcementEnabled': true,
      'decision': 'allowed',
      'reason': 'Trial access is active.',
      'checkedAtUtc': '2026-07-06T12:00:00Z',
            }),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Check lesson access'));
    await tester.pumpAndSettle();

    expect(find.text('You can start a lesson'), findsOneWidget);
    expect(find.text('Trial access is active.'), findsOneWidget);
    expect(find.text('Free lessons remaining today: 1'), findsOneWidget);
  });

  testWidgets('home screen shows blocked lesson access', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          authService: FakeAuthService(
            lessonAccess: LessonAccessDecision.fromJson({
      'userId': 'u1',
      'canStartNewLesson': false,
      'premiumActive': false,
      'trialActive': false,
      'freeLessonUsedToday': true,
      'freeLessonRemainingToday': 0,
      'enforcementEnabled': true,
      'decision': 'blocked',
      'reason': 'Daily free lesson limit reached.',
      'checkedAtUtc': '2026-07-06T12:00:00Z',
            }),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Check lesson access'));
    await tester.pumpAndSettle();

    expect(find.text('You cannot start a new lesson right now'), findsOneWidget);
    expect(find.text('Daily free lesson limit reached.'), findsOneWidget);
    expect(find.text('Free lessons remaining today: 0'), findsOneWidget);
  });
}
