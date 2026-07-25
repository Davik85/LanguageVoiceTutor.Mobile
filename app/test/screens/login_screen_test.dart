import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/l10n/device_language_defaults.dart';
import 'package:language_voice_tutor_mobile/screens/login_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _LoginApi implements ApiClient {
  _LoginApi(this.responses);

  final Map<String, List<ApiResponse>> responses;
  final calls = <String>[];
  final putBodies = <Map<String, dynamic>>[];

  ApiResponse _take(String method, String path) {
    calls.add('$method $path');
    return responses[path]!.removeAt(0);
  }

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      _take('GET', path);

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      _take('POST', path);

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    if (body != null) putBodies.add(body);
    return _take('PUT', path);
  }
}

class _LoginStorage implements SessionStorage {
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
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }
}

const _authResponse = ApiResponse(
  statusCode: 200,
  body: '{"accessToken":"access","refreshToken":"refresh",'
      '"expiresAtUtc":"2026-08-01T00:00:00Z",'
      '"refreshTokenExpiresAtUtc":"2026-09-01T00:00:00Z",'
      '"user":{"userId":"u1","email":"learner@example.com",'
      '"createdAt":"2026-07-01T00:00:00Z"}}',
);

const _settingsResponse = ApiResponse(
  statusCode: 200,
  body: '{"nativeLanguage":"uk","studyLanguage":"French",'
      '"explanationLanguage":"ru","speechVoice":"nova",'
      '"speechSpeed":1.3,"conversationModeEnabled":true,'
      '"selectedTutorId":"nelli","currentLevel":"B2"}',
);

Widget _app(
  AuthService service, {
  DeviceLanguageDefaults defaults = const DeviceLanguageDefaults(
    interfaceLanguageId: 'en',
    nativeLanguageId: 'en',
  ),
  ValueChanged<String>? onLanguage,
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {'/home': (_) => const Scaffold(body: Text('home'))},
      home: LoginScreen(
        authService: service,
        deviceLanguageDefaults: defaults,
        onInterfaceLanguageLoaded: onLanguage,
      ),
    );

Future<void> _submit(WidgetTester tester, {required bool register}) async {
  await tester.enterText(
      find.byType(TextFormField).at(0), 'learner@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
  if (register) {
    await tester.tap(find.text('Create account'));
    await tester.pump();
  }
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'existing-account login loads the backend interface language only',
      (tester) async {
    final api = _LoginApi({
      '/api/auth/login': [_authResponse],
      '/api/me/settings': [_settingsResponse],
    });
    final languages = <String>[];
    await tester.pumpWidget(_app(
      AuthService(apiClient: api, storage: _LoginStorage()),
      onLanguage: languages.add,
    ));

    await _submit(tester, register: false);

    expect(find.text('home'), findsOneWidget);
    expect(languages, ['ru']);
    expect(api.calls, ['POST /api/auth/login', 'GET /api/me/settings']);
    expect(api.putBodies, isEmpty);
  });

  testWidgets('registration updates only the two device-derived languages',
      (tester) async {
    const defaults = DeviceLanguageDefaults(
      interfaceLanguageId: 'ru',
      nativeLanguageId: 'uk',
    );
    final api = _LoginApi({
      '/api/auth/register': [_authResponse],
      '/api/me/settings': [_settingsResponse, _settingsResponse],
    });
    final languages = <String>[];
    await tester.pumpWidget(_app(
      AuthService(apiClient: api, storage: _LoginStorage()),
      defaults: defaults,
      onLanguage: languages.add,
    ));

    await _submit(tester, register: true);

    expect(find.text('home'), findsOneWidget);
    expect(api.calls, [
      'POST /api/auth/register',
      'GET /api/me/settings',
      'PUT /api/me/settings',
    ]);
    expect(api.putBodies, hasLength(1));
    expect(api.putBodies.single, {
      'nativeLanguage': 'uk',
      'studyLanguage': 'French',
      'explanationLanguage': 'ru',
      'speechVoice': 'nova',
      'speechSpeed': 1.3,
      'conversationModeEnabled': true,
      'selectedTutorId': 'nelli',
      'currentLevel': 'B2',
    });
    expect(languages, ['ru']);
  });

  testWidgets('existing login survives a settings fetch failure without a PUT',
      (tester) async {
    final api = _LoginApi({
      '/api/auth/login': [_authResponse],
      '/api/me/settings': [const ApiResponse(statusCode: 503, body: '{}')],
    });
    final languages = ['ja'];
    await tester.pumpWidget(_app(
      AuthService(apiClient: api, storage: _LoginStorage()),
      onLanguage: languages.add,
    ));

    await _submit(tester, register: false);

    expect(find.text('home'), findsOneWidget);
    expect(api.calls, ['POST /api/auth/login', 'GET /api/me/settings']);
    expect(api.putBodies, isEmpty);
    expect(languages, ['ja']);
  });

  testWidgets(
      'registration stays successful when settings initialization fails',
      (tester) async {
    final api = _LoginApi({
      '/api/auth/register': [_authResponse],
      '/api/me/settings': [const ApiResponse(statusCode: 503, body: '{}')],
    });
    await tester.pumpWidget(_app(
      AuthService(apiClient: api, storage: _LoginStorage()),
    ));

    await _submit(tester, register: true);

    expect(find.text('home'), findsOneWidget);
    expect(api.calls, ['POST /api/auth/register', 'GET /api/me/settings']);
    expect(api.putBodies, isEmpty);
  });

  testWidgets(
      'registration survives a settings update failure without retrying',
      (tester) async {
    final api = _LoginApi({
      '/api/auth/register': [_authResponse],
      '/api/me/settings': [
        _settingsResponse,
        const ApiResponse(statusCode: 503, body: '{}'),
      ],
    });
    final languages = ['ru'];
    await tester.pumpWidget(_app(
      AuthService(apiClient: api, storage: _LoginStorage()),
      defaults: const DeviceLanguageDefaults(
        interfaceLanguageId: 'ru',
        nativeLanguageId: 'uk',
      ),
      onLanguage: languages.add,
    ));

    await _submit(tester, register: true);

    expect(find.text('home'), findsOneWidget);
    expect(api.calls, [
      'POST /api/auth/register',
      'GET /api/me/settings',
      'PUT /api/me/settings',
    ]);
    expect(api.putBodies, hasLength(1));
    expect(languages, ['ru']);
  });

  testWidgets('unsupported device defaults use English for new registration',
      (tester) async {
    final api = _LoginApi({
      '/api/auth/register': [_authResponse],
      '/api/me/settings': [_settingsResponse, _settingsResponse],
    });
    await tester.pumpWidget(_app(
      AuthService(apiClient: api, storage: _LoginStorage()),
    ));

    await _submit(tester, register: true);

    expect(api.putBodies.single['nativeLanguage'], 'en');
    expect(api.putBodies.single['explanationLanguage'], 'en');
  });
}
