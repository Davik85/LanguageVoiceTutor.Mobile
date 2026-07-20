import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/lesson_session_lifecycle_coordinator.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _Api implements ApiClient {
  final calls = <String>[];
  final responses = <String, List<ApiResponse>>{};
  Future<ApiResponse>? delayedHeartbeatResponse;

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) =>
      Future.value(const ApiResponse(statusCode: 200, body: '{}'));

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    calls.add('POST $path');
    if (path.endsWith('/heartbeat') && delayedHeartbeatResponse != null) {
      return delayedHeartbeatResponse!;
    }
    final queued = responses[path];
    if (queued != null && queued.isNotEmpty) return queued.removeAt(0);
    if (path.endsWith('/heartbeat')) {
      return const ApiResponse(statusCode: 200, body: _active);
    }
    return const ApiResponse(statusCode: 200, body: '{}');
  }

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) =>
      Future.value(const ApiResponse(statusCode: 200, body: '{}'));
}

class _Storage implements SessionStorage {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> readAccessToken() async => 'access';
  @override
  Future<String?> readRefreshToken() async => 'refresh';
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

const _sessionId = '11111111-1111-1111-1111-111111111111';
const _active = '{"id":"$_sessionId","status":"Active"}';

void main() {
  test('starts immediately, uses the shared interval, and stops after abandon',
      () async {
    final api = _Api()
      ..responses['/api/lesson-sessions/$_sessionId/heartbeat'] = [
        const ApiResponse(statusCode: 200, body: _active),
      ]
      ..responses['/api/lesson-sessions/$_sessionId/abandon'] = [
        const ApiResponse(statusCode: 200, body: '{}'),
      ];
    final coordinator = LessonSessionLifecycleCoordinator(
      authService: AuthService(apiClient: api, storage: _Storage()),
      heartbeatInterval: const Duration(milliseconds: 5),
    );

    coordinator.start(_sessionId);
    await Future<void>.delayed(const Duration(milliseconds: 12));
    expect(api.calls.where((call) => call.contains('/heartbeat')).length,
        greaterThanOrEqualTo(1));

    final abandon = await coordinator.abandon();
    expect(abandon.status, LessonSessionAbandonStatus.abandoned);
    final heartbeatsAfterAbandon =
        api.calls.where((call) => call.contains('/heartbeat')).length;
    await Future<void>.delayed(const Duration(milliseconds: 12));
    expect(api.calls.where((call) => call.contains('/heartbeat')).length,
        heartbeatsAfterAbandon);
    expect(api.calls.where((call) => call.contains('/abandon')), hasLength(1));
  });

  test(
      'does not heartbeat without a valid session id and stop cancels the timer',
      () async {
    final api = _Api();
    final coordinator = LessonSessionLifecycleCoordinator(
      authService: AuthService(apiClient: api, storage: _Storage()),
      heartbeatInterval: const Duration(milliseconds: 5),
    );
    coordinator.start('invalid');
    await Future<void>.delayed(const Duration(milliseconds: 8));
    expect(api.calls, isEmpty);

    coordinator.start(_sessionId);
    await Future<void>.delayed(const Duration(milliseconds: 8));
    await coordinator.stop();
    final callsAfterStop = api.calls.length;
    await Future<void>.delayed(const Duration(milliseconds: 12));
    expect(api.calls.length, callsAfterStop);
  });

  test('does not overlap heartbeat requests while an earlier request is open',
      () async {
    final pendingHeartbeat = Completer<ApiResponse>();
    final api = _Api()..delayedHeartbeatResponse = pendingHeartbeat.future;
    final coordinator = LessonSessionLifecycleCoordinator(
      authService: AuthService(apiClient: api, storage: _Storage()),
      heartbeatInterval: const Duration(milliseconds: 1),
    );

    coordinator.start(_sessionId);
    await Future<void>.delayed(const Duration(milliseconds: 8));
    expect(
        api.calls.where((call) => call.contains('/heartbeat')), hasLength(1));

    pendingHeartbeat
        .complete(const ApiResponse(statusCode: 200, body: _active));
    await coordinator.stop();
  });
}
