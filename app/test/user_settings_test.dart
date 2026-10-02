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
    '{"nativeLanguage":"en","studyLanguage":"es","explanationLanguage":"en","speechVoice":"coral","speechSpeed":1.1,"conversationModeEnabled":true,"selectedTutorId":"nelli","currentLevel":"B2","extra":"ignored"}';
void main() {
  for (final value in [true, false, null, 'false', 0, 1, <String, dynamic>{}]) {
    test('backend Conversation Mode value $value always normalizes to true',
        () {
      final settings = UserSettings.fromJson({
        'conversationModeEnabled': value,
        'speechSpeed': 0.5,
        'speechVoice': 'cedar',
        'selectedTutorId': 'david',
        'currentLevel': 'B2'
      });
      expect(settings.conversationModeEnabled, isTrue);
      expect(settings.speechSpeed, 1.0);
      expect(settings.speechVoice, 'cedar');
      expect(settings.currentLevel, 'B2');
    });
  }
  test('missing Conversation Mode flag defaults to true', () {
    expect(UserSettings.fromJson({}).conversationModeEnabled, isTrue);
  });
  for (final value in [true, false]) {
    test('direct Conversation Mode value $value always serializes true', () {
      final settings = UserSettings(
          nativeLanguage: 'en',
          studyLanguage: 'es',
          explanationLanguage: 'en',
          speechVoice: 'cedar',
          speechSpeed: 2.0,
          conversationModeEnabled: value,
          selectedTutorId: 'david',
          currentLevel: 'B2');
      expect(settings.toJson()['conversationModeEnabled'], isTrue);
      expect(settings.toJson()['speechSpeed'], 1.0);
      expect(
          settings.withNormalizedSpeechVoice().conversationModeEnabled, isTrue);
      expect(
          settings
              .copyWith(conversationModeEnabled: false)
              .conversationModeEnabled,
          isTrue);
      expect(settings.toJson().keys,
          containsAll(['conversationModeEnabled', 'speechSpeed']));
    });
  }

  for (final speed in [
    0.5,
    0.9,
    1.0,
    1.3,
    2.0,
    null,
    '1.3',
    'malformed',
    true,
    <String, dynamic>{}
  ]) {
    test('backend speech speed $speed normalizes to fixed 1.0', () {
      final settings = UserSettings.fromJson({
        'speechSpeed': speed,
        'speechVoice': 'cedar',
        'selectedTutorId': 'david',
        'currentLevel': 'B2',
        'studyLanguage': 'Spanish'
      });
      expect(settings.speechSpeed, 1.0);
      expect(settings.speechVoice, 'cedar');
      expect(settings.currentLevel, 'B2');
      expect(settings.studyLanguage, 'es');
    });
  }
  test('missing backend speech speed normalizes to fixed 1.0', () {
    expect(UserSettings.fromJson({}).speechSpeed, 1.0);
  });
  for (final speed in [0.5, 0.9, 1.0, 1.3, 2.0, double.nan, double.infinity]) {
    test('direct stale speech speed $speed serializes as 1.0', () {
      final settings = UserSettings(
          nativeLanguage: 'en',
          studyLanguage: 'es',
          explanationLanguage: 'en',
          speechVoice: 'cedar',
          speechSpeed: speed,
          conversationModeEnabled: true,
          selectedTutorId: 'david',
          currentLevel: 'B2',
          displayName: 'User');
      expect(settings.toJson(), {
        'nativeLanguage': 'en',
        'studyLanguage': 'Spanish',
        'explanationLanguage': 'en',
        'speechVoice': 'cedar',
        'speechSpeed': 1.0,
        'conversationModeEnabled': true,
        'selectedTutorId': 'david',
        'currentLevel': 'B2',
        'displayName': 'User'
      });
      expect(settings.withNormalizedSpeechVoice().speechSpeed, 1.0);
    });
  }

  for (final voice in ['nova', 'onyx', 'fable', 'unknown', '', ' ', null, 42]) {
    for (final tutor in ['david', 'nelli', 'lana', null]) {
      test('settings parsing normalizes $voice for $tutor', () {
        final settings = UserSettings.fromJson(
            {'speechVoice': voice, 'selectedTutorId': tutor});
        expect(settings.speechVoice, tutor == 'david' ? 'cedar' : 'coral');
        expect(settings.toJson()['speechVoice'], settings.speechVoice);
      });
    }
  }
  for (final voice in [
    'alloy',
    'ash',
    'ballad',
    'coral',
    'echo',
    'sage',
    'shimmer',
    'verse',
    'marin',
    'cedar'
  ]) {
    test('settings parsing canonicalizes supported $voice', () {
      expect(
          UserSettings.fromJson({
            'speechVoice': ' ${voice.toUpperCase()} ',
            'selectedTutorId': 'david'
          }).speechVoice,
          voice);
    });
  }
  test('direct stale settings serialize only a supported tutor-aware voice',
      () {
    const settings = UserSettings(
        nativeLanguage: 'en',
        studyLanguage: 'es',
        explanationLanguage: 'en',
        speechVoice: 'onyx',
        speechSpeed: 1,
        conversationModeEnabled: true,
        selectedTutorId: 'david',
        currentLevel: 'B2');
    expect(settings.toJson()['speechVoice'], 'cedar');
    expect(settings.withNormalizedSpeechVoice().speechVoice, 'cedar');
    expect(settings.withNormalizedSpeechVoice().speechSpeed, 1);
  });

  test('user settings response parsing tolerates extra fields', () {
    final settings = UserSettings.fromJson({
      'nativeLanguage': 'Russian',
      'studyLanguage': 'Spanish',
      'explanationLanguage': 'German',
      'speechVoice': 'coral',
      'speechSpeed': 1.2,
      'conversationModeEnabled': true,
      'selectedTutorId': 'david',
      'currentLevel': 'B1',
      'displayName': 'José',
      'extra': 'ignored'
    });
    expect(settings.nativeLanguage, 'ru');
    expect(settings.studyLanguage, 'es');
    expect(settings.explanationLanguage, 'de');
    expect(settings.speechSpeed, 1.0);
    expect(settings.conversationModeEnabled, isTrue);
    expect(settings.selectedTutorId, 'david');
    expect(settings.currentLevel, 'B1');
    expect(settings.displayName, 'José');
  });
  test('missing or non-string display name safely becomes empty', () {
    expect(UserSettings.fromJson({}).displayName, '');
    expect(UserSettings.fromJson({'displayName': null}).displayName, '');
    expect(UserSettings.fromJson({'displayName': 123}).displayName, '');
  });
  test('user settings response tolerates missing selected tutor', () {
    final settings = UserSettings.fromJson({
      'nativeLanguage': 'en',
      'studyLanguage': 'es',
      'explanationLanguage': 'en',
      'speechVoice': 'coral',
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
            speechVoice: 'coral',
            speechSpeed: 1.0,
            conversationModeEnabled: false,
            selectedTutorId: 'lana',
            currentLevel: 'B2',
            displayName: 'Давид')
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
          'currentLevel',
          'displayName'
        ]));
    expect(json['conversationModeEnabled'], isTrue);
    expect(json['nativeLanguage'], 'ru');
    expect(json['studyLanguage'], 'Spanish');
    expect(json['currentLevel'], 'B2');
    expect(json['displayName'], 'Давид');

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
        speechVoice: 'coral',
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

  test('copyWith changes level, fixes speed, and preserves other fields', () {
    const original = UserSettings(
      nativeLanguage: 'tr',
      studyLanguage: 'es',
      explanationLanguage: 'ru',
      speechVoice: 'coral',
      speechSpeed: 1.1,
      conversationModeEnabled: true,
      selectedTutorId: 'lana',
      currentLevel: 'A1',
      displayName: 'محمد',
    );

    final changed = original.copyWith(currentLevel: 'b2');

    expect(changed.currentLevel, 'B2');
    expect(changed.nativeLanguage, original.nativeLanguage);
    expect(changed.studyLanguage, original.studyLanguage);
    expect(changed.explanationLanguage, original.explanationLanguage);
    expect(changed.speechVoice, original.speechVoice);
    expect(changed.speechSpeed, 1.0);
    expect(original.copyWith(speechSpeed: 2.0).speechSpeed, 1.0);
    expect(changed.conversationModeEnabled, original.conversationModeEnabled);
    expect(changed.selectedTutorId, original.selectedTutorId);
    expect(changed.displayName, 'محمد');
    expect(original.copyWith(displayName: '山田').displayName, '山田');
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
        speechVoice: 'coral',
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
