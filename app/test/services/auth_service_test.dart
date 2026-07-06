import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class FakeApiClient implements ApiClient {
  final calls = <String>[];
  final tokens = <String?>[];

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
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
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
}
