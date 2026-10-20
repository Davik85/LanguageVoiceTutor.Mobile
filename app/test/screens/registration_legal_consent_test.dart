import 'dart:async';

import 'package:language_voice_tutor_mobile/api/api_client.dart';

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
Future<void> _fill(WidgetTester tester) async {
  await tester.enterText(
      find.byType(TextFormField).at(0), 'learner@example.test');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
}

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
          TextSelection(baseOffset: start, extentOffset: start + 1))
      .first;
  await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
  await tester.pumpAndSettle();
}

class _UnavailableAnalytics extends NoopAnalyticsService {
  @override
  Future<void> initialize() async => throw StateError('Firebase unavailable');
  @override
  Future<bool> chooseConsent(bool allowed) async =>
      throw StateError('Consent storage unavailable');
}

class _PendingRegistrationApi extends TrackingApi {
  final pending = Completer<void>();
  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, String? accessToken}) async {
    if (path == '/api/auth/register') await pending.future;
    return super.post(path, body: body, accessToken: accessToken);
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

  testWidgets(
      'fields, Register and legal notice remain without analytics controls',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('registration-legal-sentence')), findsNothing);
    await _registerMode(tester);
    expect(find.byType(Checkbox), findsNothing);
    expect(
        find.byKey(const Key('registration-analytics-choice')), findsNothing);
    expect(find.byKey(const Key('registration-analytics-privacy-link')),
        findsNothing);
    expect(
        find.text(
            'I agree to share app usage statistics to help improve the app.'),
        findsNothing);
    expect(
        find.text(AppLocalizations.of(tester.element(find.byType(LoginScreen)))
            .analyticsSaveFailed),
        findsNothing);
    expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .map((f) => f.decoration!.labelText),
        ['Email', 'Password', 'Display name (optional)']);
    final form = find
        .descendant(of: find.byType(LoginScreen), matching: find.byType(Column))
        .first;
    final children = tester.widget<Column>(form).children;
    final buttonIndex = children.indexWhere((w) => w is FilledButton);
    final noticeIndex = children.indexWhere(
        (w) => w.runtimeType.toString() == 'RegistrationLegalNotice');
    expect(children.indexOf(children.whereType<TextFormField>().last),
        lessThan(buttonIndex));
    expect(buttonIndex, lessThan(noticeIndex));
    expect(
        children
            .sublist(buttonIndex + 1, noticeIndex)
            .every((w) => w is SizedBox),
        isTrue);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('registration-legal-sentence')))
            .textSpan!
            .toPlainText(),
        'By creating an account, you agree to our Terms of Service. Please review our Privacy Policy.');
    await _tap(tester, find.byType(FilledButton));
    expect(api.calls, isEmpty); // Existing form validation still applies.
  });

  for (final unavailable in [false, true]) {
    testWidgets(
        'registration succeeds without analytics interaction, unavailable: $unavailable',
        (tester) async {
      final analytics =
          unavailable ? _UnavailableAnalytics() : NoopAnalyticsService();
      addTearDown(analytics.dispose);
      auth = AuthService(
          apiClient: api, storage: TrackingStorage(), analytics: analytics);
      await tester.pumpWidget(_app(auth, launcher));
      await tester.pumpAndSettle();
      await _registerMode(tester);
      await _fill(tester);
      await _tap(tester, find.byType(FilledButton));
      expect(api.calls.first.path, '/api/auth/register');
      expect(api.calls.first.body,
          {'email': 'learner@example.test', 'password': 'password'});
      expect(find.text('Home ready'), findsOneWidget);
      expect(analytics.consent, isFalse);
    });
  }

  testWidgets(
      'registration ignores duplicate submit callbacks while authentication is pending',
      (tester) async {
    final pendingApi = _PendingRegistrationApi();
    auth = AuthService(apiClient: pendingApi, storage: TrackingStorage());
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _fill(tester);
    final callback = _submit(tester).onPressed!;
    callback();
    callback();
    await tester.pump();
    expect(_submit(tester).onPressed, isNull);
    pendingApi.pending.complete();
    await tester.pumpAndSettle();
    expect(
        pendingApi.calls
            .where((call) => call.path == '/api/auth/register')
            .length,
        1);
    expect(find.text('Home ready'), findsOneWidget);
  });

  testWidgets(
      'failed registration remains retryable without analytics controls',
      (tester) async {
    api.loginStatus = 400;
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _fill(tester);
    await _tap(tester, find.byType(FilledButton));
    expect(find.text('Home ready'), findsNothing);
    expect(_submit(tester).onPressed, isNotNull);
    expect(find.byType(Checkbox), findsNothing);
    api.loginStatus = 200;
    await _tap(tester, find.byType(FilledButton));
    expect(find.text('Home ready'), findsOneWidget);
  });

  testWidgets('switching modes leaves login independent of analytics',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _registerMode(tester);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byKey(const Key('registration-legal-sentence')), findsNothing);
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

  testWidgets('Terms and Privacy links below Register open without submitting',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _tapLink(tester, 'Terms of Service');
    await _tapLink(tester, 'Privacy Policy');
    expect(launcher.opened, [LegalDocuments.terms, LegalDocuments.privacy]);
    expect(_submit(tester).onPressed, isNotNull);
    expect(api.calls, isEmpty);
  });

  testWidgets('unavailable browser reports localized error', (tester) async {
    launcher.available = false;
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    await _tapLink(tester, 'Terms of Service');
    expect(find.text('Could not open the document. Please try again.'),
        findsOneWidget);
    expect(api.calls, isEmpty);
  });

  testWidgets(
      'application root has no analytics checkbox, global panel or modal',
      (tester) async {
    final analytics = NoopAnalyticsService();
    addTearDown(analytics.dispose);
    auth = _SignedOutAuth(api: api, analytics: analytics);
    await tester.pumpWidget(LanguageVoiceTutorApp(
        authService: auth,
        premiumPurchaseAdapter: const UnavailablePremiumPurchaseAdapter()));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await _registerMode(tester);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(Card), findsNothing);
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
    testWidgets(
        'localized legal notice renders with working inline links for $locale',
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
      expect(find.byKey(const Key('registration-analytics-privacy-link')),
          findsNothing);
      await _tapLink(tester, text.privacyPolicy);
      expect(launcher.opened, [LegalDocuments.privacy]);
      expect(find.byType(Checkbox), findsNothing);
      if (locale.languageCode == 'sr') {
        expect(RegExp(r'[Ѐ-ӿ]').hasMatch(text.privacyPolicy), isFalse);
      }
      expect(find.text(text.registrationAnalyticsConsent), findsNothing);
      await _tapLink(tester, text.termsOfService);
      expect(launcher.opened, [LegalDocuments.privacy, LegalDocuments.terms]);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Russian registration hides the retained analytics translation',
      (tester) async {
    await tester.pumpWidget(_app(auth, launcher, locale: const Locale('ru')));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    expect(
        find.text(
            'Я согласен на передачу статистических данных об использовании приложения для его улучшения.'),
        findsNothing);
    expect(find.byType(Checkbox), findsNothing);
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
      expect(find.byType(Checkbox), findsNothing);
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(_submit(tester).onPressed, isNotNull);
      expect(tester.getRect(find.byType(FilledButton)).bottom,
          lessThanOrEqualTo(568 - 260));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'document spans expose separate accessible links without a checkbox',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(auth, launcher));
    await tester.pumpAndSettle();
    await _registerMode(tester);
    expect(find.byType(Checkbox), findsNothing);
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
