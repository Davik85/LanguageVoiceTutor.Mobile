import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/screens/settings_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/backend_health_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class FakeApiClient implements ApiClient {
  FakeApiClient(this.response);

  final Future<ApiResponse> Function(String path) response;

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) => response(path);

  @override
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body, String? accessToken}) => throw UnimplementedError();
}

class FakeAuthService extends AuthService {
  FakeAuthService()
      : super(apiClient: FakeApiClient((_) async => const ApiResponse(statusCode: 200, body: '{}')), storage: _MemoryStorage());

  @override
  Future<AuthUser> loadCurrentUser() async => AuthUser(
        userId: 'u1',
        email: 'user@example.com',
        displayName: 'User',
        createdAt: DateTime.parse('2026-07-01T12:00:00Z'),
      );

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async => SubscriptionStatus(
        userId: 'u1',
        planName: 'Premium Monthly',
        premiumActive: true,
        trialActive: false,
        freeLessonUsedToday: 0,
        freeLessonRemainingToday: 3,
        checkedAtUtc: DateTime.parse('2026-07-06T12:00:00Z'),
        enforcementEnabled: true,
      );
}

class _MemoryStorage implements SessionStorage {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
}

void main() {
  testWidgets('settings screen shows connected after a successful health check',
      (tester) async {
    final service = BackendHealthService(
      apiClient: FakeApiClient(
        (_) async => const ApiResponse(
          statusCode: 200,
          body:
              '{"status":"ok","environment":"production","checkedAtUtc":"2026-07-06T12:00:00Z"}',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(healthService: service, authService: FakeAuthService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backend connection'), findsOneWidget);
    expect(find.text('Not checked'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);

    await tester.tap(find.text('Check connection'));
    await tester.pumpAndSettle();

    expect(find.text('Connected'), findsOneWidget);
  });
}
