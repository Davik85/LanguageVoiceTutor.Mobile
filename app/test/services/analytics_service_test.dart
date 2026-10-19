import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/analytics_service.dart';

import '../support/tracking_fakes.dart';

void main() {
  late MemoryAnalyticsStore store;
  late FakeAnalyticsSink sink;
  late ConsentAnalyticsService service;
  setUp(() {
    store = MemoryAnalyticsStore();
    sink = FakeAnalyticsSink();
    service = ConsentAnalyticsService(store: store, sink: sink);
  });
  tearDown(() => service.dispose());

  test('Firebase initialization failure is isolated and does not log',
      () async {
    sink.failInitialize = true;
    await service.initialize();
    expect(service.loaded, isTrue);
    expect(await service.chooseConsent(true), isTrue);
    await service.log(AnalyticsEvent.login);
    expect(sink.events, isEmpty);
    expect(sink.consents.last, isFalse);
    await service.chooseConsent(false);
    expect(sink.consents.last, isFalse);
  });
  test('unknown and denied consent prevent optional collection', () async {
    await service.initialize();
    expect(service.consent, isNull);
    await service.log(AnalyticsEvent.login);
    await service.chooseConsent(false);
    await service.log(AnalyticsEvent.signUp);
    expect(sink.events, isEmpty);
    expect(sink.consents, everyElement(false));
  });
  test('grant enables collection, withdrawal stops it, choice survives restart',
      () async {
    await service.initialize();
    await service.chooseConsent(true);
    await service.log(AnalyticsEvent.login);
    expect(sink.count('login'), 1);
    await service.chooseConsent(false);
    await service.log(AnalyticsEvent.signUp);
    expect(sink.count('sign_up'), 0);
    final restarted = ConsentAnalyticsService(store: store, sink: sink);
    await restarted.initialize();
    expect(restarted.consent, isFalse);
    expect(sink.consents.last, isFalse);
    restarted.dispose();
  });
  test('denied events are never replayed after consent', () async {
    await service.initialize();
    await service.log(AnalyticsEvent.login);
    await service.chooseConsent(true);
    expect(sink.events, isEmpty);
  });
  test(
      'persistent atomic claims deduplicate concurrent and restarted callbacks',
      () async {
    await service.initialize();
    await service.chooseConsent(true);
    await Future.wait(List.generate(
        5,
        (_) => service.log(AnalyticsEvent.lessonStart,
            localDeduplicationKey: 'start:user:session')));
    final restarted = ConsentAnalyticsService(store: store, sink: sink);
    await restarted.initialize();
    await restarted.log(AnalyticsEvent.lessonStart,
        localDeduplicationKey: 'start:user:session');
    expect(sink.count('lesson_start'), 1);
    expect(store.values.keys.any((key) => key.contains('user')), isFalse);
    restarted.dispose();
  });
  test('failed storage or transport cannot generate retries or duplicates',
      () async {
    await service.initialize();
    await service.chooseConsent(true);
    sink.failLog = true;
    await service.log(AnalyticsEvent.firstLessonStarted,
        localDeduplicationKey: 'first:user');
    sink.failLog = false;
    await service.log(AnalyticsEvent.firstLessonStarted,
        localDeduplicationKey: 'first:user');
    expect(sink.events, isEmpty);
    store.fail = true;
    await service.log(AnalyticsEvent.lessonComplete,
        localDeduplicationKey: 'complete:user:session');
    expect(sink.events, isEmpty);
  });
  test('first conversion needs authoritative empty history and no prior claim',
      () async {
    await service.initialize();
    await service.chooseConsent(true);
    expect(
        await service.firstLessonCandidate('user', () async => true), isTrue);
    expect(
        await service.firstLessonCandidate('user', () async => false), isFalse);
    expect(
        await service.firstLessonCandidate('user', () async => null), isFalse);
    expect(
        await service.firstLessonCandidate(
            'user', () async => throw StateError('offline')),
        isFalse);
    await service.log(AnalyticsEvent.firstLessonStarted,
        localDeduplicationKey: 'first:user');
    var fetched = false;
    expect(
        await service.firstLessonCandidate('user', () async {
          fetched = true;
          return true;
        }),
        isFalse);
    expect(fetched, isFalse);
  });
  test(
      'parameters are fixed vocabulary and never forward identifiers or free text',
      () async {
    await service.initialize();
    await service.chooseConsent(true);
    await service.log(AnalyticsEvent.lessonStart, parameters: {
      'study_language': 'English',
      'level': 'A1',
      'email': 'secret@example.test',
      'account_id': '123',
      'transcript': 'private text',
      'category': 'user supplied prompt'
    });
    expect(
        sink.events.single.parameters, {'study_language': 'en', 'level': 'A1'});
    await service.log(AnalyticsEvent.lessonStart, parameters: {
      'study_language': 'private text',
      'level': 'private text'
    });
    expect(sink.events.last.parameters, isEmpty);
  });
  test('local account scopes do not deduplicate another user', () async {
    await service.initialize();
    await service.chooseConsent(true);
    await service.log(AnalyticsEvent.firstLessonStarted,
        localDeduplicationKey: 'first:a');
    await service.log(AnalyticsEvent.firstLessonStarted,
        localDeduplicationKey: 'first:b');
    expect(sink.count('first_lesson_started'), 2);
  });
  test('event contract has no manually emitted first_open or purchase', () {
    expect(
        AnalyticsEvent.values.map((e) => e.name),
        unorderedEquals([
          'sign_up',
          'login',
          'lesson_start',
          'first_lesson_started',
          'lesson_complete',
          'premium_view'
        ]));
  });
}
