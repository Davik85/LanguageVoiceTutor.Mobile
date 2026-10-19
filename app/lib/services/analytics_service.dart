import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AnalyticsEvent {
  signUp('sign_up'),
  login('login'),
  lessonStart('lesson_start'),
  firstLessonStarted('first_lesson_started'),
  lessonComplete('lesson_complete'),
  premiumView('premium_view');

  const AnalyticsEvent(this.name);
  final String name;
}

abstract class AnalyticsStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SecureAnalyticsStore implements AnalyticsStore {
  const SecureAnalyticsStore();
  static const _storage = FlutterSecureStorage();
  @override
  Future<String?> read(String key) => _storage.read(key: 'lvt_analytics_$key');
  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: 'lvt_analytics_$key', value: value);
}

abstract class AnalyticsSink {
  Future<void> initialize();
  Future<void> setConsent(bool analyticsAllowed);
  Future<void> log(String name, Map<String, Object> parameters);
}

abstract class AnalyticsService extends ChangeNotifier {
  bool get loaded;
  bool? get consent;
  Future<void> initialize();
  Future<bool> chooseConsent(bool allowed);
  Future<bool> firstLessonCandidate(
      String userId, Future<bool?> Function() hasNoServerHistory);
  Future<void> log(AnalyticsEvent event,
      {String? localDeduplicationKey,
      Map<String, Object> parameters = const {}});
}

class NoopAnalyticsService extends AnalyticsService {
  @override
  bool get loaded => false;
  @override
  bool? get consent => false;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> chooseConsent(bool allowed) async => false;
  @override
  Future<bool> firstLessonCandidate(
          String userId, Future<bool?> Function() hasNoServerHistory) async =>
      false;
  @override
  Future<void> log(AnalyticsEvent event,
      {String? localDeduplicationKey,
      Map<String, Object> parameters = const {}}) async {}
}

/// Identifiers are used only to hash local deduplication keys. They never enter
/// the sink. Events dropped while consent is absent are never replayed.
class ConsentAnalyticsService extends AnalyticsService {
  ConsentAnalyticsService(
      {required AnalyticsStore store, required AnalyticsSink sink})
      : _store = store,
        _sink = sink;

  final AnalyticsStore _store;
  final AnalyticsSink _sink;
  bool _loaded = false;
  bool? _consent;
  bool _ready = false;
  bool _disposed = false;
  Future<void>? _initialization;
  Future<void> _queue = Future.value();
  static const _deadline = Duration(seconds: 3);
  @override
  bool get loaded => _loaded;
  @override
  bool? get consent => _consent;

  @override
  Future<void> initialize() => _initialization ??= _serialize(() async {
        try {
          final saved = await _store.read('consent_v1').timeout(_deadline);
          _consent = saved == 'yes' ? true : (saved == 'no' ? false : null);
          await _sink.initialize().timeout(_deadline);
          await _sink.setConsent(_consent == true).timeout(_deadline);
          _ready = true;
        } catch (_) {
          // Configuration, platform and storage failures are isolated.
          _ready = false;
        }
        _loaded = true;
        _notify();
      });

  @override
  Future<bool> chooseConsent(bool allowed) async {
    // Withdrawal takes effect before queued events or platform work.
    if (!allowed) {
      _consent = false;
      _notify();
    }
    var saved = false;
    await initialize();
    await _serialize(() async {
      try {
        await _store
            .write('consent_v1', allowed ? 'yes' : 'no')
            .timeout(_deadline);
        _consent = allowed;
        saved = true;
      } catch (_) {
        _consent = false;
      }
      try {
        // Always attempt a disable after initialization/platform failure too.
        // A stored grant must never enable an unavailable/unvalidated sink.
        await _sink.setConsent(_ready && _consent == true).timeout(_deadline);
      } catch (_) {
        _ready = false;
      }
      _notify();
    });
    return saved;
  }

  @override
  Future<bool> firstLessonCandidate(
      String userId, Future<bool?> Function() hasNoServerHistory) async {
    if (!_ready || _consent != true || userId.isEmpty) return false;
    try {
      if (await _store.read(_key('first:$userId')).timeout(_deadline) != null) {
        return false;
      }
      // A timeout means unknown. It must never become an empty-history proof.
      return await hasNoServerHistory().timeout(const Duration(seconds: 2)) ==
          true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> log(AnalyticsEvent event,
      {String? localDeduplicationKey,
      Map<String, Object> parameters = const {}}) {
    // Do not queue denied events for later consent.
    if (!_ready || _consent != true) return Future.value();
    return _serialize(() async {
      if (!_ready || _consent != true) return;
      try {
        if (localDeduplicationKey != null) {
          final key = _key(localDeduplicationKey);
          if (await _store.read(key).timeout(_deadline) != null) return;
          // Persist before sending: prefer a missed event to a false duplicate
          // after a crash or transport failure. No retries or purchase events.
          await _store.write(key, 'claimed').timeout(_deadline);
        }
        if (_consent != true) return;
        await _sink
            .log(event.name, _safeParameters(parameters))
            .timeout(_deadline);
      } catch (_) {}
    });
  }

  static String _key(String value) =>
      sha256.convert(utf8.encode(value)).toString();

  static Map<String, Object> _safeParameters(Map<String, Object> input) {
    final result = <String, Object>{};
    // Fixed vocabularies only, even if a caller accidentally passes free text.
    final rawLanguage = input['study_language'];
    final language = const {
          'English': 'en',
          'German': 'de',
          'French': 'fr',
          'Spanish': 'es',
          'Italian': 'it',
          'Portuguese': 'pt',
        }[rawLanguage] ??
        rawLanguage;
    if (language is String &&
        const {
          'en',
          'de',
          'fr',
          'es',
          'it',
          'pt',
          'ru',
          'uk',
          'pl',
          'bg',
          'hr',
          'sr',
          'sr-Latn',
          'tr',
          'ar',
          'ja',
          'ko',
          'zh',
          'hu',
          'cs',
          'nl',
          'sv',
          'el',
          'ro',
          'he',
          'hi',
        }.contains(language)) {
      result['study_language'] = language;
    }
    final level = input['level'];
    if (const {'A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}.contains(level)) {
      result['level'] = level!;
    }
    if (input['method'] == 'password') result['method'] = 'password';
    return result;
  }

  Future<void> _serialize(Future<void> Function() action) {
    final next = _queue.then((_) => action()).catchError((Object _) {});
    _queue = next;
    return next;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
