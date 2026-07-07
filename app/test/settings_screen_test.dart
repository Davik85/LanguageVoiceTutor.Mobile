import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/models/tutor_options.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/screens/settings_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/backend_health_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';
import 'package:language_voice_tutor_mobile/services/tutor_options_service.dart';

class FakeApiClient implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
}

class FakeAuthService extends AuthService {
  FakeAuthService({this.settingsFailure, this.saveFailure})
      : super(apiClient: FakeApiClient(), storage: _MemoryStorage());
  final ApiException? settingsFailure;
  final ApiException? saveFailure;
  bool saved = false;
  UserSettings? savedSettings;
  @override
  Future<AuthUser> loadCurrentUser() async => AuthUser(
      userId: 'u1',
      email: 'user@example.com',
      displayName: 'User',
      createdAt: DateTime.parse('2026-07-01T12:00:00Z'));
  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async =>
      SubscriptionStatus(
          userId: 'u1',
          planName: 'Premium Monthly',
          premiumActive: true,
          trialActive: false,
          freeLessonUsedToday: 0,
          freeLessonRemainingToday: 3,
          checkedAtUtc: DateTime.parse('2026-07-06T12:00:00Z'),
          enforcementEnabled: true);
  @override
  Future<UserSettings> fetchUserSettings() async {
    if (settingsFailure != null) throw settingsFailure!;
    return const UserSettings(
        nativeLanguage: 'en',
        studyLanguage: 'es',
        explanationLanguage: 'en',
        speechVoice: 'nova',
        speechSpeed: 1.0,
        conversationModeEnabled: true,
        selectedTutorId: 'nelli');
  }

  @override
  Future<UserSettings> updateUserSettings(UserSettings settings) async {
    if (saveFailure != null) throw saveFailure!;
    saved = true;
    savedSettings = settings;
    return settings;
  }
}

class FakeTutorOptionsService extends TutorOptionsService {
  FakeTutorOptionsService() : super(apiClient: FakeApiClient());
  @override
  Future<TutorOptions> fetchTutorOptions() async => const TutorOptions(tutors: [
        TutorOption(tutorId: 'lana', displayName: 'Lana', isActive: true),
        TutorOption(tutorId: 'nelli', displayName: 'Nelli', isActive: true)
      ]);
}

class _MemoryStorage implements SessionStorage {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {}
}

Widget _screen(FakeAuthService auth) => MaterialApp(
    home: SettingsScreen(
        healthService: BackendHealthService(apiClient: FakeApiClient()),
        authService: auth,
        tutorOptionsService: FakeTutorOptionsService()));

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    500,
    scrollable: find.byType(Scrollable),
  );
}

void main() {
  testWidgets('settings screen loaded state shows account, learning, audio',
      (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
    expect(find.text('Premium Monthly'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Study language'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('es'), findsNothing);
    expect(find.text('Selected tutor'), findsOneWidget);
    expect(find.text('Nelli'), findsOneWidget);
    expect(find.text('Tutor voice'), findsOneWidget);
    expect(
        find.text(
            'Selected tutor persistence is not available in the current settings API yet.'),
        findsNothing);
    await _scrollToText(tester, 'Audio');
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('Conversation mode enabled'), findsOneWidget);
    await _scrollToText(tester, 'Backend diagnostics');
    expect(find.text('Backend diagnostics'), findsOneWidget);
    expect(find.text('Save settings'), findsOneWidget);
    expect(find.textContaining('level', findRichText: true), findsNothing);
  });

  testWidgets('study language dropdown shows labels and saves backend IDs',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();

    expect(find.text('French'), findsWidgets);
    expect(find.text('Russian'), findsNothing);

    await tester.tap(find.text('French').last);
    await tester.pumpAndSettle();
    await _scrollToText(tester, 'Save settings');
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();

    expect(auth.savedSettings?.studyLanguage, 'fr');
    expect(auth.savedSettings?.nativeLanguage, 'en');
    expect(auth.savedSettings?.explanationLanguage, 'en');
  });

  testWidgets('native language dropdown shows labels and saves backend IDs',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();

    expect(find.text('Russian'), findsOneWidget);

    await tester.tap(find.text('Russian').last);
    await tester.pumpAndSettle();
    await _scrollToText(tester, 'Save settings');
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();

    expect(auth.savedSettings?.nativeLanguage, 'ru');
    expect(auth.savedSettings?.studyLanguage, 'es');
    expect(auth.savedSettings?.explanationLanguage, 'en');
  });

  testWidgets('interface language dropdown shows labels and saves backend IDs',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();

    expect(find.text('Polish'), findsOneWidget);

    await tester.tap(find.text('Polish').last);
    await tester.pumpAndSettle();
    await _scrollToText(tester, 'Save settings');
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();

    expect(auth.savedSettings?.explanationLanguage, 'pl');
    expect(auth.savedSettings?.nativeLanguage, 'en');
    expect(auth.savedSettings?.studyLanguage, 'es');
  });

  testWidgets('selecting tutor and saving sends selectedTutorId',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lana').last);
    await tester.pumpAndSettle();
    await _scrollToText(tester, 'Save settings');
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();
    expect(auth.savedSettings?.selectedTutorId, 'lana');
    expect(auth.savedSettings?.speechVoice, 'nova');
  });

  testWidgets('settings screen save success shows friendly message',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    await _scrollToText(tester, 'Save settings');
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();
    expect(auth.saved, isTrue);
    expect(find.text('Settings saved.'), findsOneWidget);
  });
  testWidgets('settings screen friendly failure hides raw backend details',
      (tester) async {
    final auth = FakeAuthService(
        saveFailure: const ApiException('raw stack trace secret token'));
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    await _scrollToText(tester, 'Save settings');
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to save settings right now.'), findsOneWidget);
    expect(find.textContaining('secret token'), findsNothing);
  });
}
