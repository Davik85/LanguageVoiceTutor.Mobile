import 'dart:async';
import 'dart:convert';

import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/device_registration.dart';
import 'package:language_voice_tutor_mobile/services/analytics_service.dart';
import 'package:language_voice_tutor_mobile/services/device_metadata.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class MemoryAnalyticsStore implements AnalyticsStore {
  final values = <String, String>{};
  bool fail = false;
  @override
  Future<String?> read(String key) async {
    if (fail) throw StateError('storage unavailable');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (fail) throw StateError('storage unavailable');
    values[key] = value;
  }
}

class FakeAnalyticsSink implements AnalyticsSink {
  bool failInitialize = false;
  bool failLog = false;
  final consents = <bool>[];
  final events = <({String name, Map<String, Object> parameters})>[];
  @override
  Future<void> initialize() async {
    if (failInitialize) throw StateError('Firebase unavailable');
  }

  @override
  Future<void> setConsent(bool analyticsAllowed) async =>
      consents.add(analyticsAllowed);
  @override
  Future<void> log(String name, Map<String, Object> parameters) async {
    if (failLog) throw StateError('transport unavailable');
    events.add((name: name, parameters: parameters));
  }

  int count(String name) => events.where((event) => event.name == name).length;
}

class TrackingStorage implements SessionStorage {
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

class TrackingApi implements ApiClient {
  String user = 'user-1';
  String? authOverride;
  String history = '{"items":[]}';
  int historyStatus = 200;
  int loginStatus = 200;
  int startStatus = 201;
  int finishStatus = 200;
  int deviceStatus = 200;
  String finishedStatus = 'Finished';
  Future<ApiResponse>? delayedDevice;
  Future<ApiResponse>? delayedHistory;
  Future<ApiResponse>? delayedRefresh;
  final calls = <({
    String method,
    String path,
    String? token,
    Map<String, dynamic>? body
  })>[];
  static const session = 'abcdefab-1234-5678-abcd-abcdefabcdef';
  String get authBody =>
      authOverride ??
      jsonEncode({
        'accessToken': 'access-$user',
        'refreshToken': 'refresh-$user',
        'user': {
          'userId': user,
          'email': 'private@example.test',
          'displayName': 'Private Name'
        }
      });
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    calls.add((method: 'GET', path: path, token: accessToken, body: null));
    if (path == '/api/auth/me') {
      return ApiResponse(statusCode: 200, body: authBody);
    }
    if (path == '/api/me/lesson-history') {
      return delayedHistory ??
          ApiResponse(statusCode: historyStatus, body: history);
    }
    if (path.endsWith('/summary')) {
      return const ApiResponse(
          statusCode: 200, body: '{"status":"unavailable"}');
    }
    return const ApiResponse(statusCode: 500, body: '{}');
  }

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    calls.add((method: 'POST', path: path, token: accessToken, body: body));
    if (path == '/api/auth/login' || path == '/api/auth/register') {
      return ApiResponse(statusCode: loginStatus, body: authBody);
    }
    if (path == '/api/auth/refresh') {
      return delayedRefresh ?? ApiResponse(statusCode: 200, body: authBody);
    }
    if (path == '/api/me/lesson-sessions') {
      return ApiResponse(
          statusCode: startStatus,
          body: jsonEncode({
            'id': session,
            'lessonContentId': 'content',
            'studyLanguage': 'English',
            'status': 'Active'
          }));
    }
    if (path == '/api/me/devices') {
      return delayedDevice ??
          ApiResponse(
              statusCode: deviceStatus,
              body:
                  '{"registered":true,"lastSeenAt":"2026-10-18T10:00:00Z","trackingScope":"authenticated_device_record"}');
    }
    if (path.endsWith('/abandon') || path == '/api/auth/revoke') {
      return const ApiResponse(statusCode: 200, body: '{}');
    }
    return const ApiResponse(statusCode: 500, body: '{}');
  }

  @override
  Future<ApiResponse> put(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    calls.add((method: 'PUT', path: path, token: accessToken, body: body));
    return ApiResponse(
        statusCode: finishStatus,
        body: jsonEncode({'id': session, 'status': finishedStatus}));
  }

  int deviceCalls() => calls.where((c) => c.path == '/api/me/devices').length;
}

class FakeDeviceMetadata implements DeviceMetadata {
  FakeDeviceMetadata({this.name = 'Example Model [installation-1]'});
  final String name;
  bool fail = false;
  Completer<DeviceRegistrationRequest>? delayed;
  @override
  Future<DeviceRegistrationRequest> read() async {
    if (fail) throw StateError('metadata unavailable');
    return delayed?.future ??
        DeviceRegistrationRequest(deviceName: name, appVersion: '0.1.0+13');
  }
}

Future<void> flushTracking() => Future<void>.delayed(Duration.zero);
