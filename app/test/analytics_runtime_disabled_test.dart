import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/analytics_service.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/device_activity_tracker.dart';

import 'support/tracking_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'production startup injects no-op without initializing Firebase or consent storage',
      () {
    final main = File('lib/main.dart').readAsStringSync();
    final startup = main.substring(main.indexOf('Future<void> main()'),
        main.indexOf('class LanguageVoiceTutorApp'));
    expect(startup, contains('final analytics = NoopAnalyticsService();'));
    expect(startup, contains('createAuthService(analytics: analytics)'));
    expect(startup, isNot(contains('ConsentAnalyticsService(')));
    expect(startup, isNot(contains('FirebaseAnalyticsSink(')));
    expect(startup, isNot(contains('analytics.initialize()')));
  });

  test(
      'Android application deactivates collection and retains every denied default',
      () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final application = manifest.substring(
        manifest.indexOf('<application'), manifest.indexOf('</application>'));
    expect(
        RegExp(r'<meta-data\s+android:name="firebase_analytics_collection_deactivated"\s+android:value="true"\s*/>')
            .allMatches(application),
        hasLength(1));
    for (final name in [
      'firebase_analytics_collection_enabled',
      'google_analytics_default_allow_analytics_storage',
      'google_analytics_default_allow_ad_storage',
      'google_analytics_default_allow_ad_user_data',
      'google_analytics_default_allow_ad_personalization_signals',
      'google_analytics_adid_collection_enabled',
      'google_analytics_automatic_screen_reporting_enabled',
    ]) {
      expect(
          application, contains('android:name="$name" android:value="false"'));
    }
  });

  test(
      'no-op ignores a persisted grant and never reads, clears or rewrites consent',
      () async {
    const storage =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    final stored = <String, String>{'lvt_analytics_consent_v1': 'yes'};
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storage, (call) async {
      calls.add(call);
      if (call.method == 'read') return stored[(call.arguments as Map)['key']];
      throw StateError('Consent records must remain untouched');
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storage, null));
    // Establish that the existing persistence adapter can see the old grant.
    expect(await const SecureAnalyticsStore().read('consent_v1'), 'yes');
    calls.clear();
    final analytics = NoopAnalyticsService();
    addTearDown(analytics.dispose);
    await analytics.initialize();
    expect(analytics.consent, isFalse);
    expect(await analytics.chooseConsent(true), isFalse);
    for (final event in AnalyticsEvent.values) {
      await analytics.log(event, localDeduplicationKey: 'test');
    }
    var historyRequested = false;
    expect(
        await analytics.firstLessonCandidate('user', () async {
          historyRequested = true;
          return true;
        }),
        isFalse);
    expect(historyRequested, isFalse);
    expect(calls, isEmpty);
    expect(stored, {'lvt_analytics_consent_v1': 'yes'});
    expect(analytics.consent, isFalse);
  });

  for (final register in [false, true]) {
    test(
        'no-op leaves device registration after ${register ? 'registration' : 'login'} intact',
        () async {
      final api = TrackingApi();
      final auth = AuthService(
          apiClient: api,
          storage: TrackingStorage(),
          analytics: NoopAnalyticsService());
      addTearDown(auth.analytics.dispose);
      final tracker = DeviceActivityTracker(
        authenticatedUser: auth.authenticatedUser,
        metadata: FakeDeviceMetadata(),
        register: (user, request) async {
          await auth.registerDevice(user, request);
        },
      );
      addTearDown(tracker.dispose);
      tracker.setForeground(true);
      if (register) {
        await auth.register('learner@example.test', 'password', 'Learner');
      } else {
        await auth.login('learner@example.test', 'password');
      }
      await flushTracking();
      expect(api.deviceCalls(), 1);
      final device =
          api.calls.singleWhere((call) => call.path == '/api/me/devices');
      expect(device.token, 'access-user-1');
      expect(device.body, {
        'platform': 'Android',
        'deviceName': 'Example Model [installation-1]',
        'appVersion': '0.1.0+13'
      });
      expect(auth.analytics.consent, isFalse);
    });
  }
}
