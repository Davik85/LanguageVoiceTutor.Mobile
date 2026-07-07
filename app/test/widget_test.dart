import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/main.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class FakeAuthService extends AuthService {
  FakeAuthService()
      : super(apiClient: _FakeApiClient(), storage: _MemoryStorage());

  @override
  Future<AuthUser> loadCurrentUser() async {
    throw const ApiException('Please sign in to continue.');
  }

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async {
    throw const ApiException('Please sign in to continue.');
  }
}

class _FakeApiClient implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 500, body: '{}');

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 500, body: '{}');
}

class _MemoryStorage implements SessionStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

void main() {
  testWidgets('renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      LanguageVoiceTutorApp(authService: FakeAuthService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Language Voice Tutor'), findsOneWidget);
    expect(find.text('Please sign in to continue.'), findsOneWidget);
    expect(find.text('Continue to sign in'), findsOneWidget);
  });
}
