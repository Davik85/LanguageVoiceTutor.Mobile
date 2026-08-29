import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/screens/login_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _Storage implements SessionStorage {
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

class _Api implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
}

class _RecoveryAuth extends AuthService {
  _RecoveryAuth() : super(apiClient: _Api(), storage: _Storage());

  int requestCalls = 0;
  int confirmCalls = 0;
  String? requestedEmail;
  String? resetCode;
  String? newPassword;

  @override
  Future<String> requestPasswordReset(String email) async {
    requestCalls++;
    requestedEmail = email;
    return 'Instructions sent.';
  }

  @override
  Future<String> confirmPasswordReset(String token, String password) async {
    confirmCalls++;
    resetCode = token;
    newPassword = password;
    return 'Password updated.';
  }
}

Widget _screen(_RecoveryAuth auth, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginScreen(authService: auth),
    );

Future<void> _openRecovery(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('login-forgot-password')));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign-in shows Forgot password and registration hides it',
      (tester) async {
    await tester.pumpWidget(_screen(_RecoveryAuth()));
    await tester.pumpAndSettle();

    expect(find.text('Forgot password'), findsOneWidget);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password'), findsNothing);
  });

  testWidgets('opening recovery pre-fills the Login email', (tester) async {
    await tester.pumpWidget(_screen(_RecoveryAuth()));
    await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
    await _openRecovery(tester);

    expect(
        tester
            .widget<TextField>(find.byKey(const Key('password-recovery-email')))
            .controller!
            .text,
        'user@test.com');
  });

  testWidgets('request reset trims email and blank email stays local',
      (tester) async {
    final auth = _RecoveryAuth();
    await tester.pumpWidget(_screen(auth));
    await _openRecovery(tester);

    await tester.tap(find.byKey(const Key('password-recovery-request')));
    await tester.pumpAndSettle();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(auth.requestCalls, 0);

    await tester.enterText(
        find.byKey(const Key('password-recovery-email')), ' user@test.com ');
    await tester.tap(find.byKey(const Key('password-recovery-request')));
    await tester.pumpAndSettle();
    expect(auth.requestCalls, 1);
    expect(auth.requestedEmail, 'user@test.com');
  });

  testWidgets('signed-out recovery validates and confirms reset code',
      (tester) async {
    final auth = _RecoveryAuth();
    await tester.pumpWidget(_screen(auth));
    await _openRecovery(tester);

    await tester.enterText(
        find.byKey(const Key('password-recovery-code')), 'code-1');
    await tester.enterText(
        find.byKey(const Key('password-recovery-new-password')), 'first');
    await tester.enterText(
        find.byKey(const Key('password-recovery-confirm-password')), 'second');
    await _tapVisible(
        tester, find.byKey(const Key('password-recovery-confirm')));
    expect(
        find.text('New password and confirmation must match.'), findsOneWidget);
    expect(auth.confirmCalls, 0);

    await tester.enterText(
        find.byKey(const Key('password-recovery-confirm-password')), 'first');
    await _tapVisible(
        tester, find.byKey(const Key('password-recovery-confirm')));
    expect(auth.confirmCalls, 1);
    expect(auth.resetCode, 'code-1');
    expect(auth.newPassword, 'first');
    expect(find.text('Password updated.'), findsOneWidget);
  });

  testWidgets('switching to registration closes recovery', (tester) async {
    await tester.pumpWidget(_screen(_RecoveryAuth()));
    await _openRecovery(tester);
    expect(find.byKey(const Key('password-recovery-email')), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.byKey(const Key('login-mode-switch')));
    expect(find.byKey(const Key('password-recovery-email')), findsNothing);
  });

  testWidgets('Russian Login renders localized Forgot password',
      (tester) async {
    await tester
        .pumpWidget(_screen(_RecoveryAuth(), locale: const Locale('ru')));
    await tester.pumpAndSettle();
    expect(find.text('Забыли пароль?'), findsOneWidget);
  });
}
