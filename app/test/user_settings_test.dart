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
    '{"nativeLanguage":"en","studyLanguage":"es","explanationLanguage":"en","speechVoice":"nova","speechSpeed":1.1,"conversationModeEnabled":true,"selectedTutorId":"nelli","currentLevel":"B2","extra":"ignored"}';
void main() {
  test('user settings response parsing tolerates extra fields', () {
    final settings = UserSettings.fromJson({
      'nativeLanguage': 'Russian',
      'studyLanguage': 'Spanish',
      'explanationLanguage': 'German',
      'speechVoice': 'nova',
      'speechSpeed': 1.2,
      'conversationModeEnabled': true,
      'selectedTutorId': 'david',
      'currentLevel': 'B1',
      'extra': 'ignored'
    });
    expect(settings.nativeLanguage, 'ru');
    expect(settings.studyLanguage, 'es');
    expect(settings.explanationLanguage, 'de');
    expect(settings.speechSpeed, 1.2);
    expect(settings.conversationModeEnabled, isTrue);
    expect(settings.selectedTutorId, 'david');
    expect(settings.currentLevel, 'B1');
  });
  test('user settings response tolerates missing selected tutor', () {
    final settings = UserSettings.fromJson({
      'nativeLanguage': 'en',
      'studyLanguage': 'es',
      'explanationLanguage': 'en',
      'speechVoice': 'nova',
      'speechSpeed': 1.2,
      'conversationModeEnabled': true,
    });
    expect(settings.selectedTutorId, UserSettings.defaultTutorId);
  });

  test('current level parses every supported canonical value', () {
    for (final level in ['A1', 'A2', 'B1', 'B2']) {
      expect(
          UserSettings.fromJson({'currentLevel': level}).currentLevel, level);
    }
  });

  test('current level parsing trims and normalizes case', () {
    expect(
        UserSettings.fromJson({'currentLevel': '  b2  '}).currentLevel, 'B2');
    expect(UserSettings.fromJson({'currentLevel': 'a2'}).currentLevel, 'A2');
  });

  test('invalid or absent current level safely falls back to A1', () {
    for (final value in <Object?>[null, '', '   ', 'C1']) {
      expect(UserSettings.fromJson({'currentLevel': value}).currentLevel, 'A1');
    }
    expect(UserSettings.fromJson({}).currentLevel, 'A1');
  });

  test('update settings request JSON includes backend supported fields', () {
    final json = const UserSettings(
            nativeLanguage: 'ru',
            studyLanguage: 'es',
            explanationLanguage: 'pl',
            speechVoice: 'nova',
            speechSpeed: 1.0,
            conversationModeEnabled: false,
            selectedTutorId: 'lana',
            currentLevel: 'B2')
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
          'selectedTutorId',
          'currentLevel'
        ]));
    expect(json['nativeLanguage'], 'ru');
    expect(json['studyLanguage'], 'Spanish');
    expect(json['currentLevel'], 'B2');

    const studyLanguageNames = {
      'en': 'English',
      'fr': 'French',
      'de': 'German',
      'pt': 'Portuguese',
      'es': 'Spanish',
      'it': 'Italian',
    };
    for (final entry in studyLanguageNames.entries) {
      final request = const UserSettings(
        nativeLanguage: 'tr',
        studyLanguage: 'en',
        explanationLanguage: 'ru',
        speechVoice: 'nova',
        speechSpeed: 1.0,
        conversationModeEnabled: true,
        selectedTutorId: 'lana',
        currentLevel: 'A1',
      ).copyWith(studyLanguage: entry.key);
      final requestJson = request.toJson();
      expect(request.studyLanguage, entry.key);
      expect(requestJson['studyLanguage'], entry.value);
      expect(requestJson['nativeLanguage'], 'tr');
      expect(requestJson['explanationLanguage'], 'ru');
    }
    expect(json['explanationLanguage'], 'pl');
    expect(json['selectedTutorId'], 'lana');
  });

  test('copyWith changes current level and preserves all other fields', () {
    const original = UserSettings(
      nativeLanguage: 'tr',
      studyLanguage: 'es',
      explanationLanguage: 'ru',
      speechVoice: 'coral',
      speechSpeed: 1.1,
      conversationModeEnabled: true,
      selectedTutorId: 'lana',
      currentLevel: 'A1',
    );

    final changed = original.copyWith(currentLevel: 'b2');

    expect(changed.currentLevel, 'B2');
    expect(changed.nativeLanguage, original.nativeLanguage);
    expect(changed.studyLanguage, original.studyLanguage);
    expect(changed.explanationLanguage, original.explanationLanguage);
    expect(changed.speechVoice, original.speechVoice);
    expect(changed.speechSpeed, original.speechSpeed);
    expect(changed.conversationModeEnabled, original.conversationModeEnabled);
    expect(changed.selectedTutorId, original.selectedTutorId);
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
        nativeLanguage: 'en',
        studyLanguage: 'es',
        explanationLanguage: 'en',
        speechVoice: 'nova',
        speechSpeed: 1.0,
        conversationModeEnabled: false,
        selectedTutorId: 'lana',
        currentLevel: 'B2'));
    expect(api.requests.map((r) => '${r.method} ${r.path} ${r.token}'),
        ['GET /api/me/settings token', 'PUT /api/me/settings token']);
    expect(api.requests.last.body?['selectedTutorId'], 'lana');
    expect(api.requests.last.body?['currentLevel'], 'B2');
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
