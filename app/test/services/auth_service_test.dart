import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
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
}
