import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

class FirebaseAnalyticsSink implements AnalyticsSink {
  FirebaseAnalytics? _analytics;

  @override
  Future<void> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('Android analytics only.');
    }
    // Android uses the native resources generated from google-services.json.
    // Missing operator configuration fails closed; never substitute identifiers.
    final app = await Firebase.initializeApp();
    _analytics = FirebaseAnalytics.instanceFor(app: app);
    // Also closes collection if initialization finishes after the caller's
    // timeout. Only the consent service may subsequently enable it.
    await _analytics!.setAnalyticsCollectionEnabled(false);
    if (app.options.projectId != 'orralen-lvt-production') {
      throw StateError('Unexpected Firebase project.');
    }
  }

  @override
  Future<void> setConsent(bool analyticsAllowed) async {
    final analytics = _analytics!;
    await analytics.setAnalyticsCollectionEnabled(false);
    await analytics.setConsent(
      analyticsStorageConsentGranted: analyticsAllowed,
      adStorageConsentGranted: false,
      adUserDataConsentGranted: false,
      adPersonalizationSignalsConsentGranted: false,
    );
    if (!analyticsAllowed) await analytics.resetAnalyticsData();
    if (analyticsAllowed) await analytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> log(String name, Map<String, Object> parameters) =>
      _analytics!.logEvent(name: name, parameters: parameters);
}
