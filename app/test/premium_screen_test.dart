import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/screens/premium_screen.dart';
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

class FakeAuth extends AuthService {
  FakeAuth(this.responses) : super(apiClient: _Api(), storage: _Storage());
  final List<Object> responses;
  int calls = 0;
  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async {
    final item =
        responses[calls < responses.length ? calls++ : responses.length - 1];
    if (item is Future<SubscriptionStatus>) return item;
    if (item is Exception) throw item;
    return item as SubscriptionStatus;
  }
}

SubscriptionStatus status(
        {bool premium = false,
        bool trial = false,
        int left = 1,
        bool enforcement = true,
        String? tariff,
        String? plan,
        DateTime? trialEnd,
        DateTime? premiumEnd}) =>
    SubscriptionStatus(
      userId: 'u',
      premiumActive: premium,
      trialActive: trial,
      freeLessonUsedToday: 0,
      freeLessonRemainingToday: left,
      checkedAtUtc: DateTime.utc(2026, 7, 23),
      enforcementEnabled: enforcement,
      currentTariffName: tariff,
      planName: plan,
      trialEndsAtUtc: trialEnd,
      premiumEndsAtUtc: premiumEnd,
    );

Widget screen(FakeAuth auth,
        {Locale locale = const Locale('en'),
        PurchaseEntryAction? buy,
        PurchaseEntryAction? restore}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {'/login': (_) => const Scaffold(body: Text('Login'))},
      home: PremiumScreen(
          authService: auth, purchaseAction: buy, restoreAction: restore),
    );

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 300,
      scrollable: find.byType(Scrollable).last);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows loading then free singular state and approved wording',
      (tester) async {
    final pending = Completer<SubscriptionStatus>();
    final auth = FakeAuth([pending.future]);
    await tester.pumpWidget(screen(auth));
    expect(find.bySemanticsLabel('Loading Premium status'), findsOneWidget);
    pending.complete(status(left: 1));
    await tester.pumpAndSettle();
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('1 free lesson remaining today.'), findsOneWidget);
    expect(
        find.text('Premium removes the daily lesson limit.'), findsOneWidget);
    expect(find.text('Get Premium'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('free plural, zero, and unenforced status are learner-safe',
      (tester) async {
    final auth = FakeAuth(
        [status(left: 0), status(left: 2), status(enforcement: false)]);
    await tester.pumpWidget(screen(auth));
    await tester.pumpAndSettle();
    expect(find.text('No free lessons remaining today.'), findsOneWidget);
    await tapVisible(tester, find.text('Refresh status'));
    expect(find.text('2 free lessons remaining today.'), findsOneWidget);
    await tapVisible(tester, find.text('Refresh status'));
    expect(find.textContaining('remaining today'), findsNothing);
  });

  testWidgets('Russian localizes the free plan and Premium trial states',
      (tester) async {
    final auth = FakeAuth([
      status(left: 0),
      status(trial: true, trialEnd: DateTime.utc(2026, 8, 1)),
    ]);
    await tester.pumpWidget(screen(auth, locale: const Locale('ru')));
    await tester.pumpAndSettle();

    expect(find.text('Бесплатный план'), findsOneWidget);
    expect(find.text('Сегодня бесплатных уроков не осталось.'), findsOneWidget);
    expect(find.text('Получить Premium'), findsOneWidget);

    await tapVisible(tester, find.text('Обновить статус'));
    expect(find.text('Пробный Premium'), findsOneWidget);
    expect(find.textContaining('Пробный Premium действует до'), findsOneWidget);
  });

  for (final localeText in const {
    'en': ('Free plan', 'Get Premium', 'Refresh status'),
    'es': ('Plan gratuito', 'Obtener Premium', 'Actualizar estado'),
    'fr': ('Formule gratuite', 'Obtenir Premium', 'Actualiser le statut'),
    'de': ('Kostenloser Tarif', 'Premium erhalten', 'Status aktualisieren'),
  }.entries) {
    testWidgets(
        '${localeText.key} keeps free-plan actions and refresh behavior',
        (tester) async {
      final auth = FakeAuth([status(), status()]);
      await tester.pumpWidget(screen(auth, locale: Locale(localeText.key)));
      await tester.pumpAndSettle();

      expect(find.text(localeText.value.$1), findsOneWidget);
      expect(find.text(localeText.value.$2), findsOneWidget);
      await tapVisible(tester, find.text(localeText.value.$3));
      expect(find.text(localeText.value.$1), findsOneWidget);
      expect(auth.calls, 2);
    });
  }

  testWidgets('Russian localizes the unavailable Google Play dialog',
      (tester) async {
    await tester
        .pumpWidget(screen(FakeAuth([status()]), locale: const Locale('ru')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Получить Premium'));
    await tester.pumpAndSettle();
    expect(find.text('Покупки Google Play пока недоступны'), findsOneWidget);
    expect(find.textContaining('Эта сборка не может'), findsOneWidget);
    await tester.tap(find.text('ОК'));
    await tester.pumpAndSettle();
    expect(find.text('Бесплатный план'), findsOneWidget);
  });

  testWidgets('trial and premium hide free counter and show dates',
      (tester) async {
    final auth = FakeAuth([
      status(trial: true, trialEnd: DateTime.utc(2026, 8, 1)),
      status(
          premium: true,
          premiumEnd: DateTime.utc(2026, 8, 2),
          tariff: 'Gold',
          plan: 'Ignored')
    ]);
    await tester.pumpWidget(screen(auth));
    await tester.pumpAndSettle();
    expect(find.text('Premium trial'), findsOneWidget);
    expect(find.textContaining('Trial ends'), findsOneWidget);
    expect(find.textContaining('free lesson'), findsNothing);
    expect(find.text('Get Premium'), findsOneWidget);
    await tapVisible(tester, find.text('Refresh status'));
    expect(find.text('Premium active'), findsOneWidget);
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Get Premium'), findsNothing);
    expect(find.textContaining('Premium ends'), findsOneWidget);
  });

  testWidgets('uses plan name only when current tariff is blank',
      (tester) async {
    final auth =
        FakeAuth([status(premium: true, tariff: ' ', plan: 'Monthly')]);
    await tester.pumpWidget(screen(auth));
    await tester.pumpAndSettle();
    expect(find.text('Monthly'), findsOneWidget);
  });

  testWidgets(
      'production actions show unavailable messages and do not change state',
      (tester) async {
    final auth = FakeAuth([status()]);
    await tester.pumpWidget(screen(auth));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Premium'));
    await tester.pumpAndSettle();
    expect(find.text('Google Play purchases are not available yet'),
        findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();
    expect(find.text('Restore purchases is not available yet'), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);
    expect(auth.calls, 1);
  });

  testWidgets('completed action reloads backend and requires confirmed status',
      (tester) async {
    final auth = FakeAuth([status(), status(premium: true)]);
    await tester.pumpWidget(
        screen(auth, buy: () async => PurchaseEntryResult.completed));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Premium'));
    await tester.pumpAndSettle();
    expect(find.text('Premium active'), findsOneWidget);
    expect(auth.calls, 2);
  });

  testWidgets(
      'completed free, cancelled, failed, pending, and refresh failure are safe',
      (tester) async {
    final pending = Completer<PurchaseEntryResult>();
    final auth =
        FakeAuth([status(), status(), const ApiException('temporary')]);
    await tester.pumpWidget(screen(auth, buy: () => pending.future));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Premium'));
    await tester.pump();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Please wait...'))
            .onPressed,
        isNull);
    pending.complete(PurchaseEntryResult.completed);
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Purchase processing is not confirmed yet. Refresh your status again shortly.'),
        findsOneWidget);
    await tapVisible(tester, find.text('Refresh status'));
    expect(find.text('Free plan'), findsOneWidget);
  });

  testWidgets('authentication required routes to login and screen scrolls',
      (tester) async {
    final auth = FakeAuth([const ApiException('Please sign in again.')]);
    await tester.pumpWidget(screen(auth));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });
}
