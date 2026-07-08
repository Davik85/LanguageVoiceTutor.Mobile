import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class FakeApiClient implements ApiClient {
  final calls = <String>[];
  final tokens = <String?>[];
  final bodies = <Map<String, dynamic>?>[];
  final responses = <String, List<ApiResponse>>{};

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    calls.add('GET $path');
    tokens.add(accessToken);
    return const ApiResponse(
        statusCode: 200,
        body:
            '{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}');
  }

  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    calls.add('POST $path');
    tokens.add(accessToken);
    bodies.add(body);
    final queued = responses[path];
    if (queued != null && queued.isNotEmpty) return queued.removeAt(0);
    return const ApiResponse(
        statusCode: 200,
        body:
            '{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-06T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-06T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}');
  }
}

class MemoryStorage implements SessionStorage {
  String? access = 'access';
  String? refresh = 'refresh';

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }
}

void main() {
  const lessonSessionReadyBody =
      '{"lessonSessionId":"session-1","lessonContentId":"travel-airport","studyLanguage":"es"}';

  test('loadCurrentUser sends bearer access token through client abstraction',
      () async {
    final api = FakeApiClient();
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final user = await service.loadCurrentUser();

    expect(user.email, 'user@example.com');
    expect(api.calls, contains('GET /api/auth/me'));
    expect(api.tokens, contains('access'));
  });

  test('login stores returned tokens', () async {
    final storage = MemoryStorage()
      ..access = null
      ..refresh = null;
    final service = AuthService(apiClient: FakeApiClient(), storage: storage);

    await service.login('user@example.com', 'password');

    expect(storage.access, 'new-access');
    expect(storage.refresh, 'new-refresh');
  });

  test('password reset request posts without bearer token and parses message',
      () async {
    final api = FakeApiClient();
    api.responses['/api/auth/password-reset/request'] = [
      const ApiResponse(
          statusCode: 200,
          body:
              '{"message":"Password reset instructions were sent if this email is registered."}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final message = await service.requestPasswordReset('user@example.com');

    expect(api.calls, contains('POST /api/auth/password-reset/request'));
    expect(api.tokens.last, isNull);
    expect(api.bodies.last, {'email': 'user@example.com'});
    expect(message,
        'Password reset instructions were sent if this email is registered.');
  });

  test('password reset confirm posts without bearer token and parses message',
      () async {
    final api = FakeApiClient();
    api.responses['/api/auth/password-reset/confirm'] = [
      const ApiResponse(
          statusCode: 200, body: '{"message":"Password updated."}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final message =
        await service.confirmPasswordReset('reset-code', 'new-password');

    expect(api.calls, contains('POST /api/auth/password-reset/confirm'));
    expect(api.tokens.last, isNull);
    expect(api.bodies.last,
        {'token': 'reset-code', 'newPassword': 'new-password'});
    expect(message, 'Password updated.');
  });

  test('change password posts with bearer token', () async {
    final api = FakeApiClient();
    api.responses['/api/auth/password/change'] = [
      const ApiResponse(
          statusCode: 200, body: '{"message":"Password updated."}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final message = await service.changePassword('old', 'new', 'new');

    expect(api.calls, contains('POST /api/auth/password/change'));
    expect(api.tokens.last, 'access');
    expect(api.bodies.last, {
      'currentPassword': 'old',
      'newPassword': 'new',
      'confirmNewPassword': 'new'
    });
    expect(message, 'Password updated.');
  });

  test('change password refreshes and retries after 401', () async {
    final api = FakeApiClient();
    api.responses['/api/auth/password/change'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(
          statusCode: 200, body: '{"message":"Password updated."}'),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    await service.changePassword('old', 'new', 'new');

    expect(
        api.calls,
        containsAllInOrder([
          'POST /api/auth/password/change',
          'POST /api/auth/refresh',
          'POST /api/auth/password/change',
        ]));
    expect(api.tokens.where((token) => token != null).toList(),
        ['access', 'new-access']);
  });

  test('password operations do not surface raw backend errors', () async {
    final api = FakeApiClient();
    api.responses['/api/auth/password-reset/confirm'] = [
      const ApiResponse(
          statusCode: 500, body: '{"message":"raw token secret stack"}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    expect(
      () => service.confirmPasswordReset('bad', 'new'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message',
          'Something went wrong. Please try again.')),
    );
  });

  test('start lesson session request serializes backend fields only', () {
    const request = StartLessonSessionRequest(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(request.toJson(), {
      'lessonContentId': 'travel-airport',
      'studyLanguage': 'es',
    });
    expect(request.toJson().keys, ['lessonContentId', 'studyLanguage']);
  });

  test('startLessonSession sends authenticated lesson session POST', () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(statusCode: 200, body: lessonSessionReadyBody)
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(result.status, LessonSessionStartStatus.ready);
    expect(result.message, 'Lesson session is ready.');
    expect(api.calls, contains('POST /api/me/lesson-sessions'));
    expect(api.tokens.last, 'access');
    expect(api.bodies.last, {
      'lessonContentId': 'travel-airport',
      'studyLanguage': 'es',
    });
    expect(api.bodies.last!.keys, ['lessonContentId', 'studyLanguage']);
  });

  test('startLessonSession refreshes and retries after 401', () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: lessonSessionReadyBody),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(result.status, LessonSessionStartStatus.ready);
    expect(
        api.calls,
        containsAllInOrder([
          'POST /api/me/lesson-sessions',
          'POST /api/auth/refresh',
          'POST /api/me/lesson-sessions',
        ]));
    expect(api.tokens.where((token) => token != null).toList(),
        ['access', 'new-access']);
  });

  test('startLessonSession maps failed refresh to auth result', () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    api.responses['/api/auth/refresh'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(result.status, LessonSessionStartStatus.authRequired);
    expect(result.message, 'Please sign in again to start a lesson.');
  });

  test(
      'startLessonSession maps lesson access denied to friendly blocked result',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(
          statusCode: 403,
          body: '{"code":"lesson_access_denied","message":"raw quota detail"}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(result.status, LessonSessionStartStatus.blocked);
    expect(result.message,
        'You have used today’s free lesson. Please try again tomorrow or upgrade.');
  });

  test('startLessonSession maps active lesson to friendly conflict result',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(
          statusCode: 409,
          body: '{"code":"active_lesson_exists","message":"raw device id"}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(result.status, LessonSessionStartStatus.conflict);
    expect(result.message,
        'You already have an active lesson on another device. Finish it there before starting a new one.');
  });

  test('startLessonSession maps 5xx to friendly unavailable result', () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(
          statusCode: 503, body: '{"message":"database token stack"}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(result.status, LessonSessionStartStatus.unavailable);
    expect(result.message,
        'Could not start the lesson. Please check your connection and try again.');
  });

  test('startLessonSession does not surface raw backend error text', () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(
          statusCode: 400, body: '{"message":"raw token secret stack"}')
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(result.status, LessonSessionStartStatus.failed);
    expect(result.message, 'Could not start the lesson. Please try again.');
    expect(result.message, isNot(contains('raw token secret stack')));
  });

  test('startLessonSession does not call lesson chat reply endpoint', () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions'] = [
      const ApiResponse(statusCode: 200, body: lessonSessionReadyBody)
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    await service.startLessonSession(
      lessonContentId: 'travel-airport',
      studyLanguage: 'es',
    );

    expect(api.calls, isNot(contains('POST /api/lesson-chat/reply')));
  });
}
