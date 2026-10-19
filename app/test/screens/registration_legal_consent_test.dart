import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/screens/login_screen.dart';
import 'package:language_voice_tutor_mobile/services/analytics_service.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/legal_document_launcher.dart';
import 'package:language_voice_tutor_mobile/main.dart';
import 'package:language_voice_tutor_mobile/services/premium_purchase_adapter.dart';

import '../support/tracking_fakes.dart';

class _Launcher implements LegalDocumentLauncher {
  final opened = <Uri>[];
  bool available = true;
  @override
  Future<bool> open(Uri document) async {
    opened.add(document);
    return available;
  }
}

Widget _app(AuthService auth, _Launcher launcher,
        {Locale locale = const Locale('en'), double scale = 1}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      routes: {'/home': (_) => const Scaffold(body: Text('Home ready'))},
      home: LoginScreen(authService: auth, legalDocumentLauncher: launcher),
    );

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200,
        scrollable: find
            .descendant(
                of: find.byType(LoginScreen), matching: find.byType(Scrollable))
            .first);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _registerMode(WidgetTester tester) =>
    _tap(tester, find.byKey(const Key('login-mode-switch')));
Future<void> _accept(WidgetTester tester) =>
    _tap(tester, find.byKey(const Key('registration-analytics-checkbox')));
Future<void> _fill(WidgetTester tester) async {
  await tester.enterText(
      find.byType(TextFormField).at(0), 'learner@example.test');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
}

bool _accepted(WidgetTester tester) => tester
    .widget<Checkbox>(find.byKey(const Key('registration-analytics-checkbox')))
    .value!;
FilledButton _submit(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

Future<void> _tapLink(WidgetTester tester, String label) async {
  final sentence = find.byKey(const Key('registration-legal-sentence'));
  await tester.ensureVisible(sentence);
  await tester.pumpAndSettle();
  final rich = find.descendant(of: sentence, matching: find.byType(RichText));
  final paragraph = tester.renderObject<RenderParagraph>(rich);
  final text = tester.widget<Text>(sentence).textSpan!.toPlainText();
  final start = text.indexOf(label);
  expect(start, greaterThanOrEqualTo(0));
  final box = paragraph
      .getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: start + label.length))
      .first;
  await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
  await tester.pumpAndSettle();
}

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

class _SignedOutAuth extends AuthService {
  _SignedOutAuth({required TrackingApi api, required super.analytics})
      : super(apiClient: api, storage: TrackingStorage());
  @override
  Future<SessionCheckResult> checkSession() async =>
      SessionCheckResult.authenticationRequired;
}

void main() {
  late TrackingApi api;
  late AuthService auth;
  late _Launcher launcher;
  setUp(() {
    api = TrackingApi();
    auth = AuthService(apiClient: api, storage: TrackingStorage());
    launcher = _Launcher();
  });

  testWidgets('exact field, optional checkbox, button, then legal notice order',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byKey(const Key('registration-legal-sentence')), findsNothing);
    await _registerMode(tester);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(_accepted(tester), isFalse);
    expect(_submit(tester).onPressed, isNotNull);
    final form = find
        .descendant(of: find.byType(LoginScreen), matching: find.byType(Column))
        .first;
    final children = tester.widget<Column>(form).children;
    final fields = children.whereType<TextFormField>().toList();
    expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .map((f) => f.decoration!.labelText),
        ['Email', 'Password', 'Display name (optional)']);
    final consentIndex = children
        .indexWhere((w) => w.key == const Key('registration-analytics-choice'));
    final buttonIndex = children.indexWhere((w) => w is FilledButton);
    final noticeIndex = children.indexWhere(
        (w) => w.runtimeType.toString() == 'RegistrationLegalNotice');
    expect(children.indexOf(fields.last), lessThan(consentIndex));
    expect(consentIndex, lessThan(buttonIndex));
    expect(buttonIndex, lessThan(noticeIndex));
    expect(
        children
            .sublist(consentIndex + 1, buttonIndex)
            .every((w) => w is SizedBox),
        isTrue);
    expect(
        children
            .sublist(buttonIndex + 1, noticeIndex)
            .every((w) => w is SizedBox),
        isTrue);
    final consent = find.byKey(const Key('registration-analytics-choice'));
    expect(
        find.descendant(of: consent, matching: find.text('Privacy Policy')),
        findsOneWidget);
    expect(
        find
            .descendant(of: consent, matching: find.byType(RichText))
            .evaluate()
            .map((e) => (e.widget as RichText).text.toPlainText()),
        contains(
            'I agree to share app usage statistics to help improve the app.'));
    expect(
        tester
            .widget<Text>(find.byKey(const Key('registration-legal-sentence')))
            .textSpan!
            .toPlainText(),
        'By creating an account, you agree to our Terms of Service. Please review our Privacy Policy.');
    await _tap(tester, find.byType(FilledButton));
    expect(api.calls, isEmpty); // Input validation still runs without opt-in.
  });

  for (final optedIn in [false, true]) {
    testWidgets(
        'registration succeeds with analytics consent $optedIn, applied before conversion',
        (tester) async {
      final store = MemoryAnalyticsStore();
      final sink = _OrderedSink(store);
      final analytics = ConsentAnalyticsService(store: store, sink: sink);
      await analytics.initialize();
      addTearDown(analytics.dispose);
      auth = AuthService(
          apiClient: api, storage: TrackingStorage(), analytics: analytics);
      await tester.pumpWidget(_app(auth, launcher));
      await tester.pumpAndSettle();
      await _registerMode(tester);
      await _fill(tester);
      if (optedIn) await _accept(tester);
      expect(analytics.consent,
          isNull); // Draft checkbox does not enable collection.
      await _tap(tester, find.byType(FilledButton));
      final call = api.calls.first;
      expect(call.path, '/api/auth/register');
      expect(
          call.body, {'email': 'learner@example.test', 'password': 'password'});
      expect(find.text('Home ready'), findsOneWidget);
      expect(store.values['consent_v1'], optedIn ? 'yes' : 'no');
      expect(sink.consents.last, optedIn);
      expect(sink.count('sign_up'), optedIn ? 1 : 0);
      if (optedIn) {
        expect(sink.trace,
            containsAllInOrder(['consent:true', 'sign_up:yes:true']));
        expect(sink.events.single.parameters, {'method': 'password'});
      }
      final restarted =
          ConsentAnalyticsService(store: store, sink: FakeAnalyticsSink());
      await restarted.initialize();
      expect(restarted.consent, optedIn);
      restarted.dispose();
    });
  }

  testWidgets(
      'registration waits for consent persistence and ignores duplicate submit callbacks',
      (tester) async {
    final store = _PendingStore();
    final sink = FakeAnalyticsSink();
    final analytics = ConsentAnalyticsService(store: store, sink: sink);
    await analytics.initialize();
    addTearDown(analytics.dispose);
    auth = AuthService(
        apiClient: api, storage: TrackingStorage(), analytics: analytics);
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _fill(tester);
    await _accept(tester);
    final callback = _submit(tester).onPressed!;
    callback();
    callback();
    await tester.pump();
    expect(api.calls, isEmpty);
    expect(sink.events, isEmpty);
    expect(_submit(tester).onPressed, isNull);
    store.pending.complete();
    await tester.pumpAndSettle();
    expect(
        api.calls.where((call) => call.path == '/api/auth/register').length, 1);
    expect(sink.count('sign_up'), 1);
  });

  testWidgets('failed consent storage cannot block registration or send events',
      (tester) async {
    final store = MemoryAnalyticsStore();
    final sink = FakeAnalyticsSink();
    final analytics = ConsentAnalyticsService(store: store, sink: sink);
    await analytics.initialize();
    await analytics.chooseConsent(true);
    store.fail = true;
    addTearDown(analytics.dispose);
    auth = AuthService(
        apiClient: api, storage: TrackingStorage(), analytics: analytics);
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _fill(tester);
    await _accept(tester);
    await _tap(tester, find.byType(FilledButton));
    expect(find.text('Home ready'), findsOneWidget);
    expect(analytics.consent, isFalse);
    expect(sink.consents.last, isFalse);
    expect(sink.events, isEmpty);
  });

  testWidgets('unchecked registration overrides a previous installation grant',
      (tester) async {
    final store = MemoryAnalyticsStore();
    final sink = FakeAnalyticsSink();
    final analytics = ConsentAnalyticsService(store: store, sink: sink);
    await analytics.initialize();
    await analytics.chooseConsent(true);
    addTearDown(analytics.dispose);
    auth = AuthService(
        apiClient: api, storage: TrackingStorage(), analytics: analytics);
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    expect(_accepted(tester), isFalse);
    await _fill(tester);
    await _tap(tester, find.byType(FilledButton));
    expect(find.text('Home ready'), findsOneWidget);
    expect(store.values['consent_v1'], 'no');
    expect(sink.events, isEmpty);
  });

  testWidgets(
      'failed registration emits no conversion and keeps the optional choice editable',
      (tester) async {
    final sink = FakeAnalyticsSink();
    final real =
        ConsentAnalyticsService(store: MemoryAnalyticsStore(), sink: sink);
    await real.initialize();
    addTearDown(real.dispose);
    api.loginStatus = 400;
    auth = AuthService(
        apiClient: api, storage: TrackingStorage(), analytics: real);
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _fill(tester);
    await _accept(tester);
    await _tap(tester, find.byType(FilledButton));
    expect(sink.events, isEmpty);
    expect(_submit(tester).onPressed, isNotNull);
    expect(_accepted(tester), isTrue);
    await _accept(tester);
    expect(_accepted(tester), isFalse);
  });

  testWidgets(
      'returning to Login needs no consent and registration draft resets',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _accept(tester);
    await _registerMode(tester);
    expect(find.byType(Checkbox), findsNothing);
    expect(_submit(tester).onPressed, isNotNull);
    await _registerMode(tester);
    expect(_accepted(tester), isFalse);
    await _registerMode(tester);
    await _fill(tester);
    await _tap(tester, find.byType(FilledButton));
    expect(api.calls.first.path, '/api/auth/login');
    expect(find.text('Home ready'), findsOneWidget);
  });

  testWidgets('Forgot password remains reachable without analytics consent',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('login-forgot-password')));
    expect(find.byKey(const Key('password-recovery-email')), findsOneWidget);
    expect(find.byKey(const Key('password-recovery-request')), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('Terms and Privacy links below Register do not toggle or submit',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _tapLink(tester, 'Terms of Service');
    expect(launcher.opened, [LegalDocuments.terms]);
    await _tapLink(tester, 'Privacy Policy');
    expect(launcher.opened, [LegalDocuments.terms, LegalDocuments.privacy]);
    expect(_accepted(tester), isFalse);
    expect(_submit(tester).onPressed, isNotNull);
    expect(api.calls, isEmpty);
  });

  for (final optedIn in [false, true]) {
    testWidgets('analytics privacy link preserves consent $optedIn',
        (tester) async {
      final store = MemoryAnalyticsStore();
      final sink = FakeAnalyticsSink();
      final analytics = ConsentAnalyticsService(store: store, sink: sink);
      await analytics.initialize();
      addTearDown(analytics.dispose);
      auth = AuthService(
          apiClient: api, storage: TrackingStorage(), analytics: analytics);
      await tester.pumpWidget(_app(auth, launcher));
      await tester.pumpAndSettle();
      await _registerMode(tester);
      if (optedIn) await _accept(tester);
      final storedConsent = store.values['consent_v1'];
      final consentCalls = List<bool>.of(sink.consents);
      await _tap(tester,
          find.byKey(const Key('registration-analytics-privacy-link')));
      expect(launcher.opened,
          [Uri.parse('https://languagevoicetutor.com/privacy.html')]);
      expect(_accepted(tester), optedIn);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(analytics.consent, isNull);
      expect(store.values['consent_v1'], storedConsent);
      expect(sink.consents, consentCalls);
      expect(sink.events, isEmpty);
      expect(api.calls, isEmpty);
      expect(find.byKey(const Key('registration-legal-sentence')), findsOneWidget);
      expect(_submit(tester).onPressed, isNotNull);
    });
  }

  testWidgets('unavailable browser reports localized error', (tester) async {
    launcher.available = false;
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _tapLink(tester, 'Terms of Service');
    expect(find.text('Could not open the document. Please try again.'),
        findsOneWidget);
    expect(_accepted(tester), isFalse);
    expect(api.calls, isEmpty);
  });

  testWidgets(
      'real application root shows exactly one checkbox and no global panel or modal',
      (tester) async {
    final analytics = ConsentAnalyticsService(
        store: MemoryAnalyticsStore(), sink: FakeAnalyticsSink());
    await analytics.initialize();
    addTearDown(analytics.dispose);
    auth = _SignedOutAuth(api: api, analytics: analytics);
    await tester.pumpWidget(LanguageVoiceTutorApp(
        authService: auth,
        premiumPurchaseAdapter: const UnavailablePremiumPurchaseAdapter()));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Optional analytics'), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    await _registerMode(tester);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(Card), findsNothing);
    expect(analytics.consent, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('all 16 existing locale resources translate sentence, links and errors',
      () async {
    expect(AppLocalizations.supportedLocales.length, 16);
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    for (final locale in AppLocalizations.supportedLocales) {
      final text = await AppLocalizations.delegate.load(locale);
      final sentence =
          text.registrationLegalNotice('TERMS_LINK', 'PRIVACY_LINK');
      expect('TERMS_LINK'.allMatches(sentence).length, 1, reason: '$locale');
      expect('PRIVACY_LINK'.allMatches(sentence).length, 1, reason: '$locale');
      for (final value in [
        text.termsOfService,
        text.privacyPolicy,
        text.analyticsExplanation,
        text.analyticsTitle,
        text.registrationAnalyticsConsent,
        text.legalDocumentOpenFailed
      ]) {
        expect(value.trim(), isNotEmpty, reason: '$locale');
      }
      if (locale.languageCode != 'en') {
        expect(
            sentence,
            isNot(
                english.registrationLegalNotice('TERMS_LINK', 'PRIVACY_LINK')),
            reason: '$locale');
        expect(text.termsOfService, isNot(english.termsOfService),
            reason: '$locale');
        expect(text.privacyPolicy, isNot(english.privacyPolicy),
            reason: '$locale');
        expect(text.analyticsExplanation, isNot(english.analyticsExplanation),
            reason: '$locale');
        expect(text.analyticsTitle, isNot(english.analyticsTitle),
            reason: '$locale');
        expect(text.registrationAnalyticsConsent,
            isNot(english.registrationAnalyticsConsent),
            reason: '$locale');
        expect(text.legalDocumentOpenFailed,
            isNot(english.legalDocumentOpenFailed),
            reason: '$locale');
      }
    }
  });
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('localized consent renders with inline links for $locale',
        (tester) async {
      await tester.pumpWidget(_app(auth, launcher, locale: locale));
      await tester.pumpAndSettle();
      await _registerMode(tester);
      final text =
          AppLocalizations.of(tester.element(find.byType(LoginScreen)));
      final sentence = tester
          .widget<Text>(find.byKey(const Key('registration-legal-sentence')))
          .textSpan!
          .toPlainText();
      expect(
          sentence,
          text.registrationLegalNotice(
              text.termsOfService, text.privacyPolicy));
      final privacyLink = find.byKey(const Key('registration-analytics-privacy-link'));
      expect(find.descendant(of: privacyLink, matching: find.text(text.privacyPolicy)),
          findsOneWidget);
      await _tap(tester, privacyLink);
      expect(launcher.opened, [LegalDocuments.privacy]);
      expect(_accepted(tester), isFalse);
      if (locale.languageCode == 'sr') {
        expect(RegExp(r'[Ѐ-ӿ]').hasMatch(text.privacyPolicy), isFalse);
      }
      expect(find.text(text.registrationAnalyticsConsent), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).semanticLabel,
          text.registrationAnalyticsConsent);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Russian registration uses the approved short checkbox copy',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher, locale: const Locale('ru')));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    expect(
        find.text(
            'Я согласен на передачу статистических данных об использовании приложения для его улучшения.'),
        findsOneWidget);
    expect(_accepted(tester), isFalse);
    expect(_submit(tester).onPressed, isNotNull);
  });
  for (final locale in [
    const Locale('en'),
    const Locale('de'),
    const Locale('ru'),
    const Locale('ja'),
    const Locale('ar')
  ]) {
    testWidgets(
        'small keyboard viewport and large accessibility fonts remain usable for $locale',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(_app(auth, launcher, locale: locale, scale: 2.5));
      await tester.pumpAndSettle();
      await _registerMode(tester);
      await tester.ensureVisible(
          find.byKey(const Key('registration-analytics-checkbox')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Checkbox)).width,
          greaterThanOrEqualTo(48));
      await _accept(tester);
      expect(_accepted(tester), isTrue);
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(_submit(tester).onPressed, isNotNull);
      expect(tester.getRect(find.byType(FilledButton)).bottom,
          lessThanOrEqualTo(568 - 260));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'checkbox has an accessible name and document spans expose separate links',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    expect(
        tester.getSemantics(find.byType(Checkbox)),
        matchesSemantics(
            label:
                'I agree to share app usage statistics to help improve the app.',
            hasCheckedState: true,
            isChecked: false,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true));
    final links = <SemanticsNode>[];
    void collectLinks(SemanticsNode node) {
      if (node.getSemanticsData().flagsCollection.isLink) links.add(node);
      node.visitChildren((child) {
        collectLinks(child);
        return true;
      });
    }

    collectLinks(tester
        .getSemantics(find.byKey(const Key('registration-legal-sentence'))));
    expect(links.map((node) => node.label),
        ['Terms of Service', 'Privacy Policy']);
    handle.dispose();
  });

  const channel =
      MethodChannel('com.languagevoicetutor.mobile/legal_documents');
  test(
      'Android external-link channel allows only the exact two HTTPS documents',
      () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    const platform = AndroidLegalDocumentLauncher();
    expect(await platform.open(LegalDocuments.terms), isTrue);
    expect(await platform.open(LegalDocuments.privacy), isTrue);
    expect(await platform.open(Uri.parse('https://example.test/')), isFalse);
    expect(calls.map((call) => call.method), ['openExternal', 'openExternal']);
    expect(calls.map((call) => call.arguments), [
      {'url': 'https://languagevoicetutor.com/terms.html'},
      {'url': 'https://languagevoicetutor.com/privacy.html'},
    ]);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test('missing browser/platform handler fails safely', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel, (_) async => throw PlatformException(code: 'unavailable'));
    expect(
        await const AndroidLegalDocumentLauncher().open(LegalDocuments.terms),
        isFalse);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
