import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/achievements.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class AchievementsFakeApiClient implements ApiClient {
  final calls = <String>[];
  final tokens = <String?>[];
  final responses = <String, List<ApiResponse>>{};
  final errors = <String, List<Object>>{};

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    calls.add('GET $path');
    tokens.add(accessToken);
    final queued = errors[path];
    if (queued != null && queued.isNotEmpty) throw queued.removeAt(0);
    return responses[path]?.removeAt(0) ??
        const ApiResponse(statusCode: 500, body: '{}');
  }

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    calls.add('POST $path');
    tokens.add(accessToken);
    return responses[path]?.removeAt(0) ??
        const ApiResponse(statusCode: 500, body: '{}');
  }

  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
}

class AchievementsStorage implements SessionStorage {
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

const achievementsBody =
    '''{"generatedAtUtc":"2026-07-19T12:00:00Z","calendarTimezone":"UTC","activeStudyLanguage":"English","summary":{"unlocked":0,"total":41},"achievements":[],"homeItems":[{"id":"streak-7-v1","category":"streak","scope":"account","studyLanguage":null,"topicId":null,"lessonContentId":null,"title":"7-Day Streak","description":"Practice.","iconKey":"streak","unlocked":false,"unlockedAtUtc":null,"currentProgress":0,"targetProgress":7}]}''';
const refreshBody =
    '''{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-20T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-20T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}''';

void main() {
  AuthService service(AchievementsFakeApiClient api,
          [AchievementsStorage? storage]) =>
      AuthService(apiClient: api, storage: storage ?? AchievementsStorage());

  test(
      'uses exactly the authenticated achievements route and returns backend Home unchanged',
      () async {
    final api = AchievementsFakeApiClient()
      ..responses['/api/me/achievements'] = [
        const ApiResponse(statusCode: 200, body: achievementsBody)
      ];
    final result = await service(api).fetchAchievements();
    expect(result.status, AchievementsStatus.success);
    expect(result.achievements?.homeItems.single.id, 'streak-7-v1');
    expect(api.calls, ['GET /api/me/achievements']);
    expect(api.tokens, ['access']);
    expect(api.calls.join(' '), isNot(contains('/api/dev')));
    expect(api.calls.join(' '), isNot(contains('lesson-history')));
    expect(api.calls.join(' '), isNot(contains('/api/me/progress')));
  });

  test('reuses one refresh retry and maps safe errors without raw bodies',
      () async {
    final refreshedApi = AchievementsFakeApiClient()
      ..responses['/api/me/achievements'] = [
        const ApiResponse(statusCode: 401, body: 'secret'),
        const ApiResponse(statusCode: 200, body: achievementsBody)
      ]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 200, body: refreshBody)
      ];
    final refreshed = await service(refreshedApi).fetchAchievements();
    expect(refreshed.status, AchievementsStatus.success);
    expect(refreshedApi.tokens, ['access', null, 'new-access']);

    final authApi = AchievementsFakeApiClient()
      ..responses['/api/me/achievements'] = [
        const ApiResponse(statusCode: 401, body: 'secret')
      ]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 401, body: 'secret')
      ];
    expect((await service(authApi).fetchAchievements()).status,
        AchievementsStatus.authRequired);

    final networkApi = AchievementsFakeApiClient()
      ..errors['/api/me/achievements'] = [
        const ApiException('network', category: ApiFailureCategory.network)
      ];
    expect((await service(networkApi).fetchAchievements()).status,
        AchievementsStatus.unavailable);

    final malformedApi = AchievementsFakeApiClient()
      ..responses['/api/me/achievements'] = [
        const ApiResponse(statusCode: 200, body: 'not json')
      ];
    final malformed = await service(malformedApi).fetchAchievements();
    expect(malformed.status, AchievementsStatus.failed);
    expect(malformed.message, isNot(contains('not json')));
  });
}
