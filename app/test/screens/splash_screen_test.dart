import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/screens/splash_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _SplashApi implements ApiClient {
  _SplashApi(this.responses);
  final Map<String, List<ApiResponse>> responses;
  ApiResponse _take(String path) => responses[path]!.removeAt(0);
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      _take(path);
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      _take(path);
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      _take(path);
}

class _SplashStorage implements SessionStorage {
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

Widget _app(AuthService service) => MaterialApp(
      routes: {
        '/home': (_) => const Scaffold(body: Text('home')),
        '/login': (_) => const Scaffold(body: Text('login')),
      },
      home: SplashScreen(authService: service),
    );

void main() {
  testWidgets('invalid session navigates to Login', (tester) async {
    final service = AuthService(
      apiClient: _SplashApi({
        '/api/auth/me': [const ApiResponse(statusCode: 401, body: '{}')],
        '/api/auth/refresh': [const ApiResponse(statusCode: 401, body: '{}')],
      }),
      storage: _SplashStorage(),
    );
    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();
    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('temporary failure stays on Splash and Retry reaches Home',
      (tester) async {
    final service = AuthService(
      apiClient: _SplashApi({
        '/api/auth/me': [
          const ApiResponse(statusCode: 401, body: '{}'),
          const ApiResponse(
              statusCode: 200,
              body:
                  '{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}'),
        ],
        '/api/auth/refresh': [const ApiResponse(statusCode: 503, body: '{}')],
      }),
      storage: _SplashStorage(),
    );
    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('splash-retry-button')), findsOneWidget);
    expect(find.text('login'), findsNothing);
    await tester.tap(find.byKey(const Key('splash-retry-button')));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
