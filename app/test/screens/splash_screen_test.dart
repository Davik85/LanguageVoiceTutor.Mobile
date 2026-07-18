import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/config/app_config.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/screens/splash_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _SplashApi implements ApiClient {
  _SplashApi(this.responses);
  final Map<String, List<ApiResponse>> responses;
  final calls = <String>[];
  ApiResponse _take(String method, String path) {
    calls.add('$method $path');
    return responses[path]!.removeAt(0);
  }

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      _take('GET', path);
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      _take('POST', path);
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      _take('PUT', path);
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

final _testAssetManifest = const StandardMessageCodec().encodeMessage(
  <String, List<Map<String, Object?>>>{
    AppConfig.logoAsset: [
      {'asset': AppConfig.logoAsset},
    ],
  },
)!;

class _SplashAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return _testAssetManifest;
    }
    if (key == AppConfig.logoAsset) {
      final bytes = await File(AppConfig.logoAsset).readAsBytes();
      return ByteData.sublistView(bytes);
    }
    throw FlutterError('Unexpected asset request: $key');
  }
}

class _HomeAuthService extends AuthService {
  _HomeAuthService()
      : super(apiClient: _SplashApi({}), storage: _SplashStorage());

  @override
  Future<AuthUser> loadCurrentUser() async => AuthUser(
        userId: 'u1',
        email: 'user@example.com',
        displayName: 'User',
        createdAt: DateTime.utc(2026, 7, 1),
      );
}

Widget _app(
  AuthService service, {
  AuthService? homeService,
  AssetBundle? assetBundle,
}) =>
    MaterialApp(
      builder: (context, child) => assetBundle == null
          ? child!
          : DefaultAssetBundle(bundle: assetBundle, child: child!),
      routes: {
        '/home': (_) => HomeScreen(authService: homeService ?? service),
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
    final assetBundle = _SplashAssetBundle();
    final logo = (await tester.runAsync(createTestImage))!;
    addTearDown(logo.dispose);
    tester.binding.imageCache.putIfAbsent(
      AssetBundleImageKey(
        bundle: assetBundle,
        name: AppConfig.logoAsset,
        scale: 1.0,
      ),
      () => OneFrameImageStreamCompleter(
        SynchronousFuture<ImageInfo>(ImageInfo(image: logo)),
      ),
    );
    final api = _SplashApi({
      '/api/auth/me': [
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(
            statusCode: 200,
            body:
                '{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}'),
      ],
      '/api/auth/refresh': [const ApiResponse(statusCode: 503, body: '{}')],
    });
    final service = AuthService(
      apiClient: api,
      storage: _SplashStorage(),
    );
    await tester.pumpWidget(_app(
      service,
      homeService: _HomeAuthService(),
      assetBundle: assetBundle,
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('splash-retry-button')), findsOneWidget);
    expect(find.text('login'), findsNothing);
    expect(api.calls, ['GET /api/auth/me', 'POST /api/auth/refresh']);
    await tester.tap(find.byKey(const Key('splash-retry-button')));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(api.calls, [
      'GET /api/auth/me',
      'POST /api/auth/refresh',
      'GET /api/auth/me',
    ]);
    expect(find.byKey(const Key('home-branded-title')), findsOneWidget);
  });
}
