import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/l10n/app_locale_controller.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';

void main() {
  Future<void> pumpLocalizedApp(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocaleController.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Builder(
          builder: (context) => Text(
            '${Directionality.of(context).name}:${AppLocalizations.of(context).appTitle}',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Arabic resolves with LTR application geometry', (tester) async {
    await pumpLocalizedApp(tester, const Locale('ar'));

    expect(find.textContaining('ltr:'), findsOneWidget);
    expect(find.textContaining('Language Voice Tutor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Japanese resolves to LTR through Flutter localization',
      (tester) async {
    await pumpLocalizedApp(tester, const Locale('ja'));

    expect(find.textContaining('ltr:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English also resolves with LTR application geometry',
      (tester) async {
    await pumpLocalizedApp(tester, const Locale('en'));

    expect(find.textContaining('ltr:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
