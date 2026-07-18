import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/lesson_history.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class HistoryFakeApiClient implements ApiClient {
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
    final queued = responses[path];
    return queued != null && queued.isNotEmpty
        ? queued.removeAt(0)
        : const ApiResponse(statusCode: 200, body: '{}');
  }

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    calls.add('POST $path');
    tokens.add(accessToken);
    bodies.add(body);
    final queued = responses[path];
    final queuedErrors = errors[path];
    if (queuedErrors != null && queuedErrors.isNotEmpty) {
      throw queuedErrors.removeAt(0);
    }
    return queued != null && queued.isNotEmpty
        ? queued.removeAt(0)
        : const ApiResponse(
            statusCode: 200,
            body:
                '{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-06T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-06T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}');
  }

  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
}

class HistoryStorage implements SessionStorage {
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

const refreshResponseBody =
    '{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-06T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-06T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}';

const historyListBody = '''{
  "items":[{
    "sessionId":"11111111-1111-1111-1111-111111111111",
    "lessonContentId":"daily_introductions","studyLanguage":"Spanish",
    "topicTitle":"Daily Life","subtopicTitle":"Introductions","level":"A1",
    "selectedContextTitle":null,"modeUsed":"text","status":"finished",
    "startedAt":"2026-07-10T10:00:00Z","finishedAt":null,
    "validTurnCount":3,"estimatedCost":0.12,"hasSummary":false,
    "summaryPreview":null,"messageCount":6,"updatedAt":"2026-07-10T10:05:00Z"
  }]
}''';

const historyDetailBody = '''{
  "sessionId":"11111111-1111-1111-1111-111111111111",
  "userId":"22222222-2222-2222-2222-222222222222",
  "lessonContentId":"daily_introductions","studyLanguage":"Spanish",
  "topicId":"daily-life","topicTitle":"Daily Life","subtopicId":"introductions",
  "subtopicTitle":"Introductions","level":"A1","selectedContextId":null,
  "selectedContextTitle":null,"modeUsed":"text","status":"finished",
  "startedAt":"2026-07-10T10:00:00Z","finishedAt":null,"validTurnCount":3,
  "estimatedCost":0.12,"createdAt":"2026-07-10T09:59:00Z","updatedAt":"2026-07-10T10:05:00Z",
  "summary":null,"messages":[],"feedbackResults":[]
}''';

void main() {
  AuthService service(HistoryFakeApiClient api, [HistoryStorage? storage]) =>
      AuthService(apiClient: api, storage: storage ?? HistoryStorage());

  test('history list uses the authenticated production endpoint', () async {
    final api = HistoryFakeApiClient()
      ..responses['/api/me/lesson-history'] = [
        const ApiResponse(statusCode: 200, body: historyListBody),
      ];

    final result = await service(api).fetchLessonHistory();

    expect(result.status, LessonHistoryStatus.success);
    expect(result.history?.items.single.sessionId,
        '11111111-1111-1111-1111-111111111111');
    expect(api.calls, ['GET /api/me/lesson-history']);
    expect(api.calls.join(' '), isNot(contains('/api/dev/lesson-history')));
  });

  test('history detail uses the exact encoded production endpoint', () async {
    final api = HistoryFakeApiClient()
      ..responses['/api/me/lesson-history/session%2Fone'] = [
        const ApiResponse(statusCode: 200, body: historyDetailBody),
      ];

    final result = await service(api).fetchLessonHistoryDetail('session/one');

    expect(result.status, LessonHistoryStatus.success);
    expect(result.detail?.sessionId, '11111111-1111-1111-1111-111111111111');
    expect(api.calls, ['GET /api/me/lesson-history/session%2Fone']);
    expect(api.calls.join(' '), isNot(contains('/api/dev/lesson-history')));
  });

  test('blank detail ID is rejected without an HTTP request', () async {
    final api = HistoryFakeApiClient();
    final result = await service(api).fetchLessonHistoryDetail('  ');
    expect(result.status, LessonHistoryStatus.validation);
    expect(api.calls, isEmpty);
  });

  test('detail 404 is a safe not-found result', () async {
    final api = HistoryFakeApiClient()
      ..responses['/api/me/lesson-history/session-1'] = [
        const ApiResponse(statusCode: 404, body: '{}'),
      ];
    final result = await service(api).fetchLessonHistoryDetail('session-1');
    expect(result.status, LessonHistoryStatus.notFound);
    expect(result.message, 'This lesson is no longer available.');
  });

  test('history retries once through shared refresh after an initial 401',
      () async {
    final storage = HistoryStorage();
    final api = HistoryFakeApiClient()
      ..responses['/api/me/lesson-history'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(statusCode: 200, body: historyListBody),
      ]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 200, body: refreshResponseBody),
      ];
    final result = await service(api, storage).fetchLessonHistory();
    expect(result.status, LessonHistoryStatus.success);
    expect(storage.access, 'new-access');
    expect(storage.refresh, 'new-refresh');
    expect(api.tokens, ['access', null, 'new-access']);
    expect(api.bodies[1], {'refreshToken': 'refresh'});
    expect(api.calls, [
      'GET /api/me/lesson-history',
      'POST /api/auth/refresh',
      'GET /api/me/lesson-history',
    ]);
  });

  test('invalid JSON, network, and non-success failures stay safe', () async {
    final invalidJsonApi = HistoryFakeApiClient()
      ..responses['/api/me/lesson-history'] = [
        const ApiResponse(statusCode: 200, body: 'not json'),
      ];
    expect((await service(invalidJsonApi).fetchLessonHistory()).status,
        LessonHistoryStatus.failed);

    final networkApi = HistoryFakeApiClient()
      ..errors['/api/me/lesson-history'] = [
        const ApiException(
          'Unable to reach the service.',
          category: ApiFailureCategory.network,
        ),
      ];
    final networkResult = await service(networkApi).fetchLessonHistory();
    expect(networkResult.status, LessonHistoryStatus.unavailable);
    expect(
        networkResult.message, isNot(contains('Unable to reach the service.')));

    final serverApi = HistoryFakeApiClient()
      ..responses['/api/me/lesson-history'] = [
        const ApiResponse(statusCode: 500, body: 'internal error'),
      ];
    expect((await service(serverApi).fetchLessonHistory()).message,
        isNot(contains('internal error')));
  });
}
