import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/services/analytics_service.dart';
import 'package:language_voice_tutor_mobile/widgets/analytics_consent_control.dart';
import 'support/tracking_fakes.dart';

// The reusable control remains tested for a separately approved future use.
Widget _control(AnalyticsService analytics,
        {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: ListView(
              children: [AnalyticsConsentControl(analytics: analytics)])),
    );

class _OrderedSink extends FakeAnalyticsSink {
  _OrderedSink(this.store);
  final MemoryAnalyticsStore store;
  final trace = <String>[];
  @override
  Future<void> setConsent(bool allowed) async {
    trace.add('consent:$allowed');
    await super.setConsent(allowed);
  }

  @override
  Future<void> log(String name, Map<String, Object> parameters) async {
    trace.add('$name:${store.values['consent_v1']}:${consents.last}');
    await super.log(name, parameters);
  }
}

class _PendingStore extends MemoryAnalyticsStore {
  final pending = Completer<void>();
  @override
  Future<void> write(String key, String value) async {
    if (key == 'consent_v1') await pending.future;
    await super.write(key, value);
  }
}

void main() {
  test(
      'consent persistence precedes event delivery and stored grants survive service restart',
      () async {
    final store = MemoryAnalyticsStore();
    final sink = _OrderedSink(store);
    final analytics = ConsentAnalyticsService(store: store, sink: sink);
    addTearDown(analytics.dispose);
    await analytics.initialize();
    await analytics.chooseConsent(true);
    await analytics
        .log(AnalyticsEvent.signUp, parameters: {'method': 'password'});
    expect(
        sink.trace, containsAllInOrder(['consent:true', 'sign_up:yes:true']));
    expect(sink.events.single.parameters, {'method': 'password'});
    final restarted =
        ConsentAnalyticsService(store: store, sink: FakeAnalyticsSink());
    addTearDown(restarted.dispose);
    await restarted.initialize();
    expect(restarted.consent, isTrue);
    store.fail = true;
    expect(await analytics.chooseConsent(true), isFalse);
    await analytics.log(AnalyticsEvent.signUp);
    expect(sink.count('sign_up'), 1);
    expect(sink.consents.last, isFalse);
  });
  test('pending consent storage cannot enable events before persistence',
      () async {
    final store = _PendingStore();
    final sink = FakeAnalyticsSink();
    final analytics = ConsentAnalyticsService(store: store, sink: sink);
    addTearDown(analytics.dispose);
    await analytics.initialize();
    final saving = analytics.chooseConsent(true);
    await Future<void>.delayed(Duration.zero);
    await analytics.log(AnalyticsEvent.signUp);
    expect(sink.events, isEmpty);
    expect(sink.consents.last, isFalse);
    store.pending.complete();
    expect(await saving, isTrue);
    await analytics.log(AnalyticsEvent.signUp);
    expect(sink.count('sign_up'), 1);
  });

  testWidgets(
      'retained consent control supports compact layout, withdrawal and persistence',
      (tester) async {
    final store = MemoryAnalyticsStore();
    final sink = FakeAnalyticsSink();
    final analytics = ConsentAnalyticsService(store: store, sink: sink);
    await analytics.initialize();
    addTearDown(analytics.dispose);
    await tester.pumpWidget(_control(analytics));
    await tester.pumpAndSettle();
    final toggle = find.byKey(const Key('analytics-toggle'));
    await tester.ensureVisible(toggle);
    expect(find.text('Usage statistics'), findsOneWidget);
    expect(find.text('Share app usage statistics to help improve the app.'),
        findsOneWidget);
    final card = find.byKey(const Key('analytics-settings-card'));
    expect(card, findsOneWidget);
    expect(find.descendant(of: card, matching: toggle), findsOneWidget);
    expect(tester.widget<Card>(card).color, isNull); // Shared Settings theme.
    expect(tester.widget<Card>(card).shape, isNull);
    expect((tester.widget<Card>(card).child! as Padding).padding,
        const EdgeInsets.all(16));
    final tile = tester.widget<SwitchListTile>(toggle);
    expect(tile.controlAffinity, ListTileControlAffinity.trailing);
    expect(ListTileTheme.of(tester.element(toggle)).titleAlignment,
        ListTileTitleAlignment.center);
    expect(find.text('Optional analytics'), findsNothing);
    expect(find.byKey(const Key('analytics-allow')), findsNothing);
    expect(find.byKey(const Key('analytics-decline')), findsNothing);
    expect(
        find.byKey(const Key('registration-analytics-checkbox')), findsNothing);
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(analytics.consent, isTrue);
    expect(store.values['consent_v1'], 'yes');
    await analytics.log(AnalyticsEvent.login);
    expect(sink.count('login'), 1);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(analytics.consent, isFalse);
    expect(store.values['consent_v1'], 'no');
    expect(sink.consents.last, isFalse);
    await analytics.log(AnalyticsEvent.login);
    expect(sink.count('login'), 1);
    final restarted =
        ConsentAnalyticsService(store: store, sink: FakeAnalyticsSink());
    await restarted.initialize();
    expect(restarted.consent, isFalse);
    restarted.dispose();
  });

  for (final locale in [const Locale('en'), const Locale('ru')]) {
    testWidgets(
        'usage statistics card stays usable and centers its switch on a narrow screen: $locale',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final analytics = ConsentAnalyticsService(
          store: MemoryAnalyticsStore(), sink: FakeAnalyticsSink());
      await analytics.initialize();
      addTearDown(analytics.dispose);
      await tester.pumpWidget(_control(analytics, locale: locale));
      await tester.pumpAndSettle();
      final card = find.byKey(const Key('analytics-settings-card'));
      await tester.ensureVisible(card);
      final title = locale.languageCode == 'ru'
          ? 'Статистика использования'
          : 'Usage statistics';
      final description = locale.languageCode == 'ru'
          ? 'Передавать статистику использования приложения для его улучшения.'
          : 'Share app usage statistics to help improve the app.';
      expect(find.descendant(of: card, matching: find.text(title)),
          findsOneWidget);
      expect(find.descendant(of: card, matching: find.text(description)),
          findsOneWidget);
      final toggle = find.byKey(const Key('analytics-toggle'));
      final switchFinder =
          find.descendant(of: toggle, matching: find.byType(Switch));
      expect(tester.getCenter(switchFinder).dx,
          greaterThan(tester.getCenter(find.text(title)).dx));
      expect(tester.getCenter(switchFinder).dy,
          closeTo(tester.getCenter(toggle).dy, 1));
      expect(tester.getRect(switchFinder).right,
          lessThanOrEqualTo(tester.getRect(card).right - 16));
      expect(tester.getRect(card).right, lessThanOrEqualTo(320));
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(analytics.consent, isTrue);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(analytics.consent, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
