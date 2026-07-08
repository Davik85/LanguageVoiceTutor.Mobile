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
      const ApiResponse(
        statusCode: 200,
        body:
            '{"status":"ok","environment":"test","checkedAtUtc":"2026-07-06T12:00:00Z"}',
      );
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
  String resetRequestMessage =
      'Password reset instructions were sent if this email is registered.';
  String resetConfirmMessage = 'Password updated.';
  String changePasswordMessage = 'Password updated.';
  bool signedIn = true;
  @override
  Future<AuthUser> loadCurrentUser() async {
    if (!signedIn) throw const ApiException('Please sign in again.');
    return AuthUser(
      userId: 'u1',
      email: 'user@example.com',
      displayName: 'User',
      createdAt: DateTime.parse('2026-07-01T12:00:00Z'));
  }
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
  Future<String> requestPasswordReset(String email) async => resetRequestMessage;

  @override
  Future<String> confirmPasswordReset(String token, String newPassword) async =>
      resetConfirmMessage;

  @override
  Future<String> changePassword(
          String currentPassword, String newPassword, String confirmNewPassword) async =>
      changePasswordMessage;

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
    scrollable: find.byType(ListView),
  );
}

Future<void> _scrollToAndTap(WidgetTester tester, String text) async {
  await _scrollToText(tester, text);
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _expandPasswordRecovery(WidgetTester tester) async {
  await _scrollToAndTap(tester, 'Password & recovery');
}

void main() {
  testWidgets('settings screen loaded state shows account, learning, audio',
      (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
    expect(find.text('Premium Monthly'), findsOneWidget);
    await _scrollToText(tester, 'Learning');
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
    await _scrollToText(tester, 'Connection status');
    expect(find.text('Connection status'), findsOneWidget);
    expect(find.text('Backend diagnostics'), findsNothing);
    expect(find.text('Save settings'), findsOneWidget);
    expect(find.textContaining('level', findRichText: true), findsNothing);
  });


  testWidgets('password recovery section is visible', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    expect(find.text('Password & recovery'), findsOneWidget);
    await tester.tap(find.text('Password & recovery'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password'), findsOneWidget);
    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
  });

  testWidgets('reset request validates empty email', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await tester.tap(find.text('Forgot password'));
    await tester.pumpAndSettle();
    expect(find.text('Email is required.'), findsOneWidget);
  });

  testWidgets('reset request success shows friendly accepted message', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.tap(find.text('Forgot password'));
    await tester.pumpAndSettle();
    expect(
        find.text('Password reset instructions were sent if this email is registered.'),
        findsOneWidget);
  });

  testWidgets('reset confirm validates missing code/password', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await _scrollToAndTap(tester, 'Reset password');
    expect(find.text('Reset code and new password are required.'), findsOneWidget);
  });

  testWidgets('reset confirm validates password mismatch', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await tester.enterText(find.byType(TextField).at(1), 'code');
    await tester.enterText(find.byType(TextField).at(2), 'one');
    await tester.enterText(find.byType(TextField).at(3), 'two');
    await _scrollToAndTap(tester, 'Reset password');
    expect(find.text('New password and confirmation must match.'), findsOneWidget);
  });

  testWidgets('reset confirm success shows Password updated.', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await tester.enterText(find.byType(TextField).at(1), 'code');
    await tester.enterText(find.byType(TextField).at(2), 'new');
    await tester.enterText(find.byType(TextField).at(3), 'new');
    await _scrollToAndTap(tester, 'Reset password');
    expect(find.text('Password updated.'), findsOneWidget);
  });

  testWidgets('change password requires signed-in user', (tester) async {
    final auth = FakeAuthService()..signedIn = false;
    await tester.pumpWidget(_screen(auth));
    await tester.pump();
    await tester.tap(find.text('Password & recovery'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Change password'),
      500,
      scrollable: find.byType(ListView),
    );
    await tester.tap(find.text('Change password'));
    await tester.pump();
    expect(find.text('Please sign in to change your password.'), findsOneWidget);
  });

  testWidgets('change password validates missing current password', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await _scrollToAndTap(tester, 'Change password');
    expect(find.text('Current password is required.'), findsOneWidget);
  });

  testWidgets('change password validates password mismatch', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await tester.enterText(find.byType(TextField).at(4), 'old');
    await tester.enterText(find.byType(TextField).at(5), 'one');
    await tester.enterText(find.byType(TextField).at(6), 'two');
    await _scrollToAndTap(tester, 'Change password');
    expect(find.text('New password and confirmation must match.'), findsOneWidget);
  });

  testWidgets('change password success shows Password updated.', (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();
    await _expandPasswordRecovery(tester);
    await tester.enterText(find.byType(TextField).at(4), 'old');
    await tester.enterText(find.byType(TextField).at(5), 'new');
    await tester.enterText(find.byType(TextField).at(6), 'new');
    await _scrollToAndTap(tester, 'Change password');
    expect(find.text('Password updated.'), findsOneWidget);
  });

  testWidgets('study language dropdown shows labels and saves backend IDs',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    await _scrollToText(tester, 'Study language');

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
    await _scrollToText(tester, 'Native language');

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
    await _scrollToText(tester, 'Interface / explanation language');

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
    await _scrollToText(tester, 'Selected tutor');
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

  testWidgets('connection status is non-intrusive and reveals check connection',
      (tester) async {
    await tester.pumpWidget(_screen(FakeAuthService()));
    await tester.pumpAndSettle();

    await _scrollToText(tester, 'Connection status');
    expect(find.text('Connection status'), findsOneWidget);
    expect(find.text('Check connection'), findsNothing);

    await tester.tap(find.text('Connection status'));
    await tester.pumpAndSettle();
    expect(find.text('Check connection'), findsOneWidget);
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
