import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class RecordingApiClient implements ApiClient {
  RecordingApiClient({required this.getResponse, required this.putResponse});
  final ApiResponse Function(String path, String? token) getResponse;
  final ApiResponse Function(
      String path, Map<String, dynamic>? body, String? token) putResponse;
  final requests = <({
    String method,
    String path,
    Map<String, dynamic>? body,
    String? token
  })>[];
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    requests.add((method: 'GET', path: path, body: null, token: accessToken));
    return getResponse(path, accessToken);
  }

  @override
  Future<ApiResponse> put(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    requests.add((method: 'PUT', path: path, body: body, token: accessToken));
    return putResponse(path, body, accessToken);
  }

  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
}

class MemoryStorage implements SessionStorage {
  MemoryStorage({this.accessToken});
  String? accessToken;
  @override
  Future<void> clear() async {
    accessToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
  }
}

const settingsJson =
    '{"nativeLanguage":"English","studyLanguage":"Spanish","explanationLanguage":"English","speechVoice":"nova","speechSpeed":1.1,"conversationModeEnabled":true,"selectedTutorId":"nelli","extra":"ignored"}';
void main() {
  test('user settings response parsing tolerates extra fields', () {
    final settings = UserSettings.fromJson({
      'nativeLanguage': 'English',
      'studyLanguage': 'Spanish',
      'explanationLanguage': 'English',
      'speechVoice': 'nova',
      'speechSpeed': 1.2,
      'conversationModeEnabled': true,
      'selectedTutorId': 'david',
      'extra': 'ignored'
    });
    expect(settings.studyLanguage, 'Spanish');
    expect(settings.speechSpeed, 1.2);
    expect(settings.conversationModeEnabled, isTrue);
    expect(settings.selectedTutorId, 'david');
  });
  test('user settings response tolerates missing selected tutor', () {
    final settings = UserSettings.fromJson({
      'nativeLanguage': 'English',
      'studyLanguage': 'Spanish',
      'explanationLanguage': 'English',
      'speechVoice': 'nova',
      'speechSpeed': 1.2,
      'conversationModeEnabled': true,
    });
    expect(settings.selectedTutorId, UserSettings.defaultTutorId);
  });

  test('update settings request JSON includes backend supported fields', () {
    final json = const UserSettings(
            nativeLanguage: 'English',
            studyLanguage: 'Spanish',
            explanationLanguage: 'English',
            speechVoice: 'nova',
            speechSpeed: 1.0,
            conversationModeEnabled: false,
            selectedTutorId: 'lana')
        .toJson();
    expect(
        json.keys,
        unorderedEquals([
          'nativeLanguage',
          'studyLanguage',
          'explanationLanguage',
          'speechVoice',
          'speechSpeed',
          'conversationModeEnabled',
          'selectedTutorId'
        ]));
    expect(json['selectedTutorId'], 'lana');
  });
  test('settings service GET and PUT success with fakes', () async {
    final api = RecordingApiClient(
        getResponse: (_, __) =>
            const ApiResponse(statusCode: 200, body: settingsJson),
        putResponse: (_, __, ___) =>
            const ApiResponse(statusCode: 200, body: settingsJson));
    final service = AuthService(
        apiClient: api, storage: MemoryStorage(accessToken: 'token'));
    await service.fetchUserSettings();
    await service.updateUserSettings(const UserSettings(
        nativeLanguage: 'English',
        studyLanguage: 'Spanish',
        explanationLanguage: 'English',
        speechVoice: 'nova',
        speechSpeed: 1.0,
        conversationModeEnabled: false,
        selectedTutorId: 'lana'));
    expect(api.requests.map((r) => '${r.method} ${r.path} ${r.token}'),
        ['GET /api/me/settings token', 'PUT /api/me/settings token']);
    expect(api.requests.last.body?['selectedTutorId'], 'lana');
  });
  test('settings service failure is sanitized', () async {
    final api = RecordingApiClient(
        getResponse: (_, __) =>
            const ApiResponse(statusCode: 500, body: '{"secret":"no"}'),
        putResponse: (_, __, ___) =>
            const ApiResponse(statusCode: 500, body: '{}'));
    await expectLater(
        AuthService(
                apiClient: api, storage: MemoryStorage(accessToken: 'token'))
            .fetchUserSettings(),
        throwsA(isA<ApiException>().having((e) => e.message, 'message',
            'Unable to load account details right now.')));
  });
}
