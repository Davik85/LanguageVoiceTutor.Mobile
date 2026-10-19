import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';
import 'package:language_voice_tutor_mobile/services/analytics_service.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/restore_credentials_service.dart';
import 'package:language_voice_tutor_mobile/services/restore_credentials_platform.dart';
import 'package:language_voice_tutor_mobile/services/restore_credentials_state.dart';
import 'package:language_voice_tutor_mobile/screens/splash_screen.dart';
import 'package:language_voice_tutor_mobile/services/device_activity_tracker.dart';
import 'package:language_voice_tutor_mobile/services/premium_purchase_adapter.dart';
import 'package:language_voice_tutor_mobile/screens/premium_screen.dart';
import 'package:language_voice_tutor_mobile/widgets/analytics_consent_control.dart';
import '../support/tracking_fakes.dart';

const request = StartLessonSessionRequest(
    lessonContentId: 'content',
    studyLanguage: 'English',
    topicId: 'topic',
    topicTitle: 'private',
    subtopicId: 'subtopic',
    subtopicTitle: 'private',
    level: 'A1');

class _RestorePlatform implements RestoreCredentialsPlatform {
  @override
  Future<RestoreCredentialPlatformResult> getRestoreCredential(
          String requestJson) async =>
      const RestoreCredentialPlatformResult(
          RestoreCredentialPlatformStatus.success,
          responseJson: '{"id":"test-credential"}');
  @override
  Future<RestoreCredentialPlatformResult> createRestoreCredential(
          String requestJson, bool isCloudBackupEnabled) async =>
      const RestoreCredentialPlatformResult(
          RestoreCredentialPlatformStatus.unavailable);
  @override
  Future<RestoreCredentialPlatformResult> clearRestoreCredential() async =>
      const RestoreCredentialPlatformResult(
          RestoreCredentialPlatformStatus.success);
}

class _RestoreState implements RestoreCredentialsState {
  @override
  Future<bool> isAutomaticRestoreSuppressed() async => false;
  @override
  Future<void> setAutomaticRestoreSuppressed(bool value) async {}
  @override
  Future<String?> readSyncedUserId() async => null;
  @override
  Future<void> setSyncedUserId(String userId) async {}
  @override
  Future<void> clearSyncedUserId() async {}
}

class _RestoreApi extends TrackingApi {
  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    if (path.endsWith('/assertion/options')) {
      return const ApiResponse(
          statusCode: 200,
          body: '{"ceremonyId":"test","options":{"challenge":"test"}}');
    }
    if (path.endsWith('/assertion/verify')) {
      return ApiResponse(statusCode: 200, body: authBody);
    }
    return super.post(path, body: body, accessToken: accessToken);
  }
}

void main() {
  late TrackingApi api;
  late TrackingStorage storage;
  late FakeAnalyticsSink sink;
  late ConsentAnalyticsService analytics;
  late AuthService auth;
  setUp(() async {
    api = TrackingApi();
    storage = TrackingStorage();
    sink = FakeAnalyticsSink();
    analytics =
        ConsentAnalyticsService(store: MemoryAnalyticsStore(), sink: sink);
    await analytics.initialize();
    await analytics.chooseConsent(true);
    auth = AuthService(apiClient: api, storage: storage, analytics: analytics);
  });
  tearDown(() => analytics.dispose());
  Future<void> widgetAnalytics() async {
    // The serialized queue belongs to the widget test's FakeAsync zone.
    analytics.dispose();
    analytics =
        ConsentAnalyticsService(store: MemoryAnalyticsStore(), sink: sink);
    await analytics.initialize();
    await analytics.chooseConsent(true);
    auth = AuthService(apiClient: api, storage: storage, analytics: analytics);
  }

  for (final register in [false, true]) {
    test(
        'successful ${register ? 'signup' : 'login'} emits once and registers device',
        () async {
      final tracker = DeviceActivityTracker(
          authenticatedUser: auth.authenticatedUser,
          metadata: FakeDeviceMetadata(),
          register: (user, request) async {
            await auth.registerDevice(user, request);
          });
      tracker.setForeground(true);
      if (register) {
        await auth.register('private@example.test', 'password', 'Private');
      } else {
        await auth.login('private@example.test', 'password');
      }
      await flushTracking();
      expect(sink.count(register ? 'sign_up' : 'login'), 1);
      expect(api.deviceCalls(), 1);
      final call = api.calls.singleWhere((c) => c.path == '/api/me/devices');
      expect(call.method, 'POST');
      expect(call.token, 'access-user-1');
      expect(call.body, {
        'platform': 'Android',
        'deviceName': 'Example Model [installation-1]',
        'appVersion': '0.1.0+13'
      });
      tracker.dispose();
    });
    test('failed ${register ? 'signup' : 'login'} emits nothing', () async {
      api.loginStatus = 400;
      if (register) {
        await expectLater(
            auth.register('e', 'p', 'n'), throwsA(isA<ApiException>()));
      } else {
        await expectLater(auth.login('e', 'p'), throwsA(isA<ApiException>()));
      }
      await flushTracking();
      expect(sink.events, isEmpty);
      expect(auth.authenticatedUser.value, isNull);
    });
  }
  test(
      'session restoration registers without generating login and temporary failure retains session',
      () async {
    final tracker = DeviceActivityTracker(
        authenticatedUser: auth.authenticatedUser,
        metadata: FakeDeviceMetadata(),
        register: (user, request) async {
          await auth.registerDevice(user, request);
        })
      ..setForeground(true);
    expect(await auth.checkSession(), SessionCheckResult.authenticated);
    await flushTracking();
    expect(api.deviceCalls(), 1);
    expect(sink.events, isEmpty);
    api.deviceStatus = 503;
    await auth.registerDevice('user-1', await FakeDeviceMetadata().read());
    expect(auth.authenticatedUser.value, 'user-1');
    expect(storage.access, 'access');
    tracker.dispose();
  });
  test(
      'backend confirmed start and first lesson emit once despite repeated callbacks',
      () async {
    await auth.loadCurrentUser();
    expect((await auth.startLessonSession(request: request)).isReady, isTrue);
    await auth.startLessonSession(request: request);
    await flushTracking();
    expect(sink.count('lesson_start'), 1);
    expect(sink.count('first_lesson_started'), 1);
    expect(
        api.calls.indexWhere((c) => c.path == '/api/me/lesson-history'),
        lessThan(api.calls.indexWhere(
            (c) => c.method == 'POST' && c.path == '/api/me/lesson-sessions')));
  });
  test(
      'cross-device credential restoration registers the backend-confirmed user without login',
      () async {
    final restoreApi = _RestoreApi();
    final restore = RestoreCredentialsService(
        apiClient: restoreApi,
        sessionStorage: storage,
        platform: _RestorePlatform(),
        state: _RestoreState());
    final restoredAuth = AuthService(
        apiClient: restoreApi,
        storage: storage,
        restoreCredentialsService: restore,
        analytics: analytics);
    final tracker = DeviceActivityTracker(
        authenticatedUser: restoredAuth.authenticatedUser,
        metadata: FakeDeviceMetadata(),
        register: (user, request) async {
          await restoredAuth.registerDevice(user, request);
        })
      ..setForeground(true);
    expect(await restoredAuth.tryAutomaticRestore(),
        RestoreAuthenticationResult.restored);
    await flushTracking();
    expect(restoredAuth.authenticatedUser.value, 'user-1');
    expect(restoreApi.deviceCalls(), 1);
    expect(sink.count('login'), 0);
    tracker.dispose();
  });
  testWidgets(
      'Firebase initialization failure permits normal splash-to-login startup',
      (tester) async {
    analytics.dispose();
    sink.failInitialize = true;
    storage.access = null;
    analytics =
        ConsentAnalyticsService(store: MemoryAnalyticsStore(), sink: sink);
    await analytics.initialize();
    final startupAuth =
        AuthService(apiClient: api, storage: storage, analytics: analytics);
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(authService: startupAuth),
        routes: {'/login': (_) => const Text('Login ready')}));
    await tester.pumpAndSettle();
    expect(find.text('Login ready'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test('backgrounding during a device request prevents refresh retries',
      () async {
    await auth.loadCurrentUser();
    var foreground = true;
    final delayed = Completer<ApiResponse>();
    api.delayedDevice = delayed.future;
    final request = auth.registerDevice(
        'user-1', await FakeDeviceMetadata().read(),
        canSend: () => foreground);
    await flushTracking();
    foreground = false;
    delayed.complete(const ApiResponse(statusCode: 401, body: '{}'));
    await request;
    expect(api.calls.where((c) => c.path == '/api/auth/refresh'), isEmpty);
    expect(auth.authenticatedUser.value, 'user-1');
  });
  test(
      'malformed successful auth payloads never manufacture login or signup events',
      () async {
    api.authOverride = '{}';
    await auth.login('e', 'p');
    await auth.register('e', 'p', 'n');
    await flushTracking();
    expect(sink.events, isEmpty);
    expect(auth.authenticatedUser.value, isNull);
  });
  test(
      'completion deduplicates upper and lower case representations of a session ID',
      () async {
    await auth.loadCurrentUser();
    // Use a GUID with alphabetic hex digits to exercise actual case changes.
    const source = TrackingApi.session;
    await auth.finishLessonSession(
        sessionId: source.toUpperCase(), validTurnCount: 1);
    await auth.finishLessonSession(
        sessionId: source.toLowerCase(), validTurnCount: 1);
    await flushTracking();
    expect(sink.count('lesson_complete'), 1);
  });
  test('failed start emits nothing', () async {
    await auth.loadCurrentUser();
    api.startStatus = 500;
    await auth.startLessonSession(request: request);
    await flushTracking();
    expect(sink.events, isEmpty);
  });
  for (final history in [
    '{"items":[{"status":"Abandoned"}]}',
    '{}',
    '{"items":null}',
    'invalid'
  ]) {
    test('nonempty or malformed history $history never emits first conversion',
        () async {
      await auth.loadCurrentUser();
      api.history = history;
      await auth.startLessonSession(request: request);
      await flushTracking();
      expect(sink.count('lesson_start'), 1);
      expect(sink.count('first_lesson_started'), 0);
    });
  }
  test('unauthorized analytics evidence read cannot refresh or clear session',
      () async {
    await auth.loadCurrentUser();
    api.historyStatus = 401;
    await auth.startLessonSession(request: request);
    await flushTracking();
    expect(sink.count('first_lesson_started'), 0);
    expect(sink.count('lesson_start'), 1);
    expect(storage.access, 'access');
    expect(api.calls.where((c) => c.path == '/api/auth/refresh'), isEmpty);
  });
  testWidgets(
      'timed out first history check is unknown and lesson still starts',
      (tester) async {
    await auth.loadCurrentUser();
    api.delayedHistory = Completer<ApiResponse>().future;
    final result = auth.startLessonSession(request: request);
    await tester.pump(const Duration(seconds: 3));
    expect((await result).isReady, isTrue);
    await tester.pump();
    expect(sink.count('first_lesson_started'), 0);
  });
  test(
      'finish confirmed Finished response emits completion once, independent of summary',
      () async {
    await auth.loadCurrentUser();
    await auth.finishLessonSession(
        sessionId: TrackingApi.session, validTurnCount: 2);
    await auth.finishLessonSession(
        sessionId: TrackingApi.session, validTurnCount: 2);
    await flushTracking();
    expect(sink.count('lesson_complete'), 1);
  });
  test('failed, abandoned, and nonfinished lessons emit no completion',
      () async {
    await auth.loadCurrentUser();
    api.finishStatus = 500;
    await auth.finishLessonSession(
        sessionId: TrackingApi.session, validTurnCount: 1);
    await auth.abandonLessonSession(sessionId: TrackingApi.session);
    api.finishStatus = 200;
    api.finishedStatus = 'Abandoned';
    await auth.finishLessonSession(
        sessionId: TrackingApi.session, validTurnCount: 1);
    await flushTracking();
    expect(sink.count('lesson_complete'), 0);
  });
  test('device refresh uses existing recovery and no unauthenticated requests',
      () async {
    final metadata = await FakeDeviceMetadata().read();
    await auth.registerDevice('user-1', metadata);
    expect(api.deviceCalls(), 0);
    await auth.loadCurrentUser();
    api.deviceStatus = 401;
    await auth.registerDevice('user-1', metadata);
    expect(api.calls.where((c) => c.path == '/api/auth/refresh').length, 1);
    expect(api.deviceCalls(), 2);
  });
  test(
      'stale device unauthorized response after account switch cannot refresh or clear new account',
      () async {
    await auth.login('e', 'p');
    final delayed = Completer<ApiResponse>();
    api.delayedDevice = delayed.future;
    final tracking =
        auth.registerDevice('user-1', await FakeDeviceMetadata().read());
    await flushTracking();
    api.user = 'user-2';
    await auth.login('e2', 'p2');
    delayed.complete(const ApiResponse(statusCode: 401, body: '{}'));
    await tracking;
    expect(auth.authenticatedUser.value, 'user-2');
    expect(storage.access, 'access-user-2');
    expect(api.calls.where((c) => c.path == '/api/auth/refresh'), isEmpty);
  });
  testWidgets(
      'Premium view logs once per opening and never on rebuild or restoration',
      (tester) async {
    await widgetAnalytics();
    Widget page() => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PremiumScreen(
            authService: auth,
            purchaseAdapter: const UnavailablePremiumPurchaseAdapter()));
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    expect(sink.count('premium_view'), 1);
    expect(sink.events.any((e) => e.name == 'in_app_purchase'), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets(
      'localized consent can be declined and granted later in Settings control',
      (tester) async {
    await widgetAnalytics();
    await analytics.chooseConsent(false);
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AnalyticsConsentControl(analytics: analytics))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('analytics-toggle')));
    await tester.pumpAndSettle();
    expect(analytics.consent, isTrue);
    await tester.tap(find.byKey(const Key('analytics-toggle')));
    await tester.pumpAndSettle();
    expect(analytics.consent, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
