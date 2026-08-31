import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/services/restore_credentials_platform.dart';
import 'package:language_voice_tutor_mobile/services/restore_credentials_service.dart';
import 'package:language_voice_tutor_mobile/services/restore_credentials_state.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _Api implements ApiClient {
  _Api(this.responses);
  final List<ApiResponse> responses;
  final calls = <String>[];
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) =>
      throw UnimplementedError();
  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    calls.add(path);
    return responses.removeAt(0);
  }

  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
}

class _Storage implements SessionStorage {
  String? access;
  String? refresh;
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

class _State implements RestoreCredentialsState {
  String? synced;
  bool suppressed = false;
  @override
  Future<void> clearSyncedUserId() async {
    synced = null;
  }

  @override
  Future<bool> isAutomaticRestoreSuppressed() async => suppressed;
  @override
  Future<String?> readSyncedUserId() async => synced;
  @override
  Future<void> setAutomaticRestoreSuppressed(bool value) async {
    suppressed = value;
  }

  @override
  Future<void> setSyncedUserId(String userId) async {
    synced = userId;
  }
}

class _Platform implements RestoreCredentialsPlatform {
  RestoreCredentialPlatformResult createResult;
  RestoreCredentialPlatformResult getResult;
  bool clearCalled = false;
  _Platform(
      {this.createResult = const RestoreCredentialPlatformResult(
          RestoreCredentialPlatformStatus.failed),
      this.getResult = const RestoreCredentialPlatformResult(
          RestoreCredentialPlatformStatus.noCredential)});
  @override
  Future<RestoreCredentialPlatformResult> clearRestoreCredential() async {
    clearCalled = true;
    return const RestoreCredentialPlatformResult(
        RestoreCredentialPlatformStatus.failed);
  }

  @override
  Future<RestoreCredentialPlatformResult> createRestoreCredential(
          String requestJson, bool isCloudBackupEnabled) async =>
      createResult;
  @override
  Future<RestoreCredentialPlatformResult> getRestoreCredential(
          String requestJson) async =>
      getResult;
}

const _options = '{"ceremonyId":"c1","options":{"challenge":"x"}}';
const _auth =
    '{"accessToken":"new-access","refreshToken":"new-refresh","user":{"userId":"u1","email":"u@example.com","createdAt":"2026-01-01T00:00:00Z"}}';

RestoreCredentialsService _service(
        _Api api, _Storage storage, _Platform platform, _State state) =>
    RestoreCredentialsService(
        apiClient: api,
        sessionStorage: storage,
        platform: platform,
        state: state);

void main() {
  test(
      'successful registration verification records the authenticated user marker',
      () async {
    final state = _State();
    final service = _service(
        _Api([
          const ApiResponse(statusCode: 200, body: _options),
          const ApiResponse(statusCode: 204, body: '')
        ]),
        _Storage(),
        _Platform(
            createResult: const RestoreCredentialPlatformResult(
                RestoreCredentialPlatformStatus.success,
                responseJson: '{"id":"credential"}')),
        state);
    await service.syncForAuthenticatedUser(
        AuthUser(
            userId: 'u1',
            email: 'u@example.com',
            createdAt: DateTime.utc(2026)),
        'access');
    expect(state.synced, 'u1');
  });

  test('failed creation does not record a sync marker', () async {
    final state = _State();
    await _service(_Api([const ApiResponse(statusCode: 200, body: _options)]),
            _Storage(), _Platform(), state)
        .syncForAuthenticatedUser(
            AuthUser(
                userId: 'u2',
                email: 'u@example.com',
                createdAt: DateTime.utc(2026)),
            'access');
    expect(state.synced, isNull);
  });

  test('suppression prevents an assertion request', () async {
    final api = _Api([]);
    final state = _State()..suppressed = true;
    final outcome = await _service(api, _Storage(), _Platform(), state)
        .tryAutomaticRestore();
    expect(outcome, RestoreAuthenticationResult.noCredential);
    expect(api.calls, isEmpty);
  });

  test('successful assertion stores the ordinary token pair', () async {
    final storage = _Storage();
    final outcome = await _service(
            _Api([
              const ApiResponse(statusCode: 200, body: _options),
              const ApiResponse(statusCode: 200, body: _auth),
              const ApiResponse(statusCode: 200, body: _options),
              const ApiResponse(statusCode: 204, body: '')
            ]),
            storage,
            _Platform(
                getResult: const RestoreCredentialPlatformResult(
                    RestoreCredentialPlatformStatus.success,
                    responseJson: '{"id":"credential"}'),
                createResult: const RestoreCredentialPlatformResult(
                    RestoreCredentialPlatformStatus.success,
                    responseJson: '{"id":"credential"}')),
            _State())
        .tryAutomaticRestore();
    expect(outcome, RestoreAuthenticationResult.restored);
    expect(storage.access, 'new-access');
    expect(storage.refresh, 'new-refresh');
  });

  test(
      'explicit logout preparation suppresses restore, clears marker, and requests native clear',
      () async {
    final state = _State()..synced = 'u1';
    final platform = _Platform();
    await _service(_Api([]), _Storage(), platform, state)
        .prepareForExplicitLogout();
    expect(state.suppressed, isTrue);
    expect(state.synced, isNull);
    expect(platform.clearCalled, isTrue);
  });
}
