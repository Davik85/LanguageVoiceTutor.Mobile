import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/progress.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class ProgressFakeApiClient implements ApiClient {
  final calls = <String>[];
  final tokens = <String?>[];
  final bodies = <Map<String, dynamic>?>[];
  final responses = <String, List<ApiResponse>>{};
  final errors = <String, List<Object>>{};

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    calls.add('GET $path');
    tokens.add(accessToken);
    bodies.add(null);
    final queuedErrors = errors[path];
    if (queuedErrors != null && queuedErrors.isNotEmpty) {
      throw queuedErrors.removeAt(0);
    }
    return responses[path]?.removeAt(0) ??
        const ApiResponse(statusCode: 500, body: '{}');
  }

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    calls.add('POST $path');
    tokens.add(accessToken);
    bodies.add(body);
    return responses[path]?.removeAt(0) ??
        const ApiResponse(statusCode: 500, body: '{}');
  }

  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
}

class ProgressStorage implements SessionStorage {
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

const progressBody = '''{
  "generatedAtUtc":"2026-07-19T12:00:00Z", "calendarTimezone":"UTC",
  "completedLessons":{"allTime":51,"last7Days":4,"last30Days":11},
  "streaks":{"currentDays":3,"longestDays":7}, "lastCompletedLesson":null,
  "completedLessonsByStudyLanguage":[], "completedLessonsByLevel":[],
  "dailyActivity":[]
}''';
const refreshBody =
    '''{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-20T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-20T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}''';

void main() {
  AuthService service(ProgressFakeApiClient api, [ProgressStorage? storage]) =>
      AuthService(apiClient: api, storage: storage ?? ProgressStorage());

  test(
      'uses only the authenticated Progress route and preserves backend all-time totals',
      () async {
    final api = ProgressFakeApiClient()
      ..responses['/api/me/progress'] = [
        const ApiResponse(statusCode: 200, body: progressBody)
      ];

    final result = await service(api).fetchProgress();

    expect(result.status, ProgressStatus.success);
    expect(result.progress?.completedLessons.allTime, 51);
    expect(api.calls, ['GET /api/me/progress']);
    expect(api.tokens, ['access']);
    expect(api.bodies.single, isNull);
    expect(api.calls.join(' '), isNot(contains('/api/dev')));
    expect(api.calls.join(' '), isNot(contains('lesson-history')));
  });

  test(
      'reuses refresh-on-401 and maps auth, network, and malformed responses safely',
      () async {
    final storage = ProgressStorage();
    final refreshApi = ProgressFakeApiClient()
      ..responses['/api/me/progress'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(statusCode: 200, body: progressBody),
      ]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 200, body: refreshBody)
      ];
    final refreshed = await service(refreshApi, storage).fetchProgress();
    expect(refreshed.status, ProgressStatus.success);
    expect(refreshApi.tokens, ['access', null, 'new-access']);

    final authApi = ProgressFakeApiClient()
      ..responses['/api/me/progress'] = [
        const ApiResponse(statusCode: 401, body: '{}')
      ]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 401, body: '{}')
      ];
    expect((await service(authApi).fetchProgress()).status,
        ProgressStatus.authRequired);

    final networkApi = ProgressFakeApiClient()
      ..errors['/api/me/progress'] = [
        const ApiException('network', category: ApiFailureCategory.network)
      ];
    expect((await service(networkApi).fetchProgress()).status,
        ProgressStatus.unavailable);

    final malformedApi = ProgressFakeApiClient()
      ..responses['/api/me/progress'] = [
        const ApiResponse(statusCode: 200, body: 'not json')
      ];
    expect((await service(malformedApi).fetchProgress()).status,
        ProgressStatus.failed);
  });
}
