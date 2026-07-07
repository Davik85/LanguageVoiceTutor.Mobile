import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/lesson_access_decision.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/screens/settings_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class FakeApiClient implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 200, body: '{}');

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 200, body: '{}');
}

class FakeAuthService extends AuthService {
  FakeAuthService({
    AuthUser? user,
    this.loadFailure,
  })  : user = user ??
            AuthUser(
              userId: 'user-1',
              email: 'david@example.com',
              displayName: 'David',
              createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            ),
        super(apiClient: FakeApiClient(), storage: MemoryStorage());

  final AuthUser? user;
  final ApiException? loadFailure;

  @override
  Future<AuthUser> loadCurrentUser() async {
    if (loadFailure != null) throw loadFailure!;
    return user!;
  }

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async =>
      SubscriptionStatus(
        userId: 'user-1',
        premiumActive: false,
        trialActive: false,
        freeLessonUsedToday: 0,
        freeLessonRemainingToday: 1,
        checkedAtUtc: DateTime.parse('2026-07-06T12:00:00Z'),
        enforcementEnabled: true,
      );

  @override
  Future<LessonAccessDecision> fetchLessonAccessDecision() async =>
      LessonAccessDecision.fromJson({
        'canStartNewLesson': true,
        'premiumActive': false,
        'trialActive': false,
        'freeLessonRemainingToday': 1,
        'reason': 'A free lesson is available.',
      });
}

class MemoryStorage implements SessionStorage {
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

Widget _home({FakeAuthService? authService}) => MaterialApp(
      home: HomeScreen(authService: authService ?? FakeAuthService()),
      routes: {
        SettingsScreen.routeName: (_) =>
            const Scaffold(body: Center(child: Text('Settings route'))),
      },
    );

void main() {
  testWidgets('home hides tutor diagnostics', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('Available tutors'), findsNothing);
    expect(find.text('Available tutors: Lana, Nelli, David'), findsNothing);
  });

  testWidgets('home shows logo and title', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-branded-title')), findsOneWidget);
    expect(
      find.text('Language Voice Tutor', findRichText: true),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Language Voice Tutor'), findsOneWidget);
    expect(find.byKey(const Key('app-logo')), findsOneWidget);
    expect(find.bySemanticsLabel('Language Voice Tutor logo'), findsOneWidget);
  });

  testWidgets('home shows friendly signed-in account status', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('Signed in as David'), findsOneWidget);
    expect(find.text('david@example.com'), findsOneWidget);
    expect(find.textContaining('user-1'), findsNothing);
  });

  testWidgets('home shows sign-in sync prompt when account is unavailable',
      (tester) async {
    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        user: null,
        loadFailure: const ApiException('Please sign in again.'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(
      find.text('Sign in to keep your settings and progress synced.'),
      findsOneWidget,
    );
    expect(find.text('Please sign in again.'), findsNothing);
  });

  testWidgets('home uses learner-friendly account and plan wording',
      (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('Your account'), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Refresh status'), findsOneWidget);
    expect(find.text('Account / access'), findsNothing);
    expect(find.text('Refresh access'), findsNothing);
  });

  testWidgets('home does not show backend or debug wording', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.textContaining('Backend'), findsNothing);
    expect(find.textContaining('diagnostics'), findsNothing);
    expect(find.textContaining('debug'), findsNothing);
  });

  testWidgets('start lesson opens choose level', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Level'), findsOneWidget);
  });

  testWidgets('open settings opens settings route', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Open Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings route'), findsOneWidget);
  });
}
