import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/l10n/app_locale_controller.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';

void main() {
  test('only explanation language changes the interface locale', () {
    final controller = AppLocaleController()..setLanguageId('ru');
    expect(controller.locale.languageCode, 'ru');

    const settings = UserSettings(
      nativeLanguage: 'en',
      studyLanguage: 'es',
      explanationLanguage: 'ru',
      speechVoice: 'nova',
      speechSpeed: 1,
      conversationModeEnabled: true,
      selectedTutorId: 'nelli',
      currentLevel: 'A1',
    );
    settings.copyWith(studyLanguage: 'de');
    settings.copyWith(nativeLanguage: 'fr');

    expect(controller.locale.languageCode, 'ru');
    controller.setLanguageId(settings.explanationLanguage);
    expect(controller.locale.languageCode, 'ru');
  });

  test('unsupported explanation language safely displays English', () {
    final controller = AppLocaleController()..setLanguageId('unsupported');
    expect(controller.locale.languageCode, 'en');
  });

  test('new backend explanation-language IDs resolve to approved locales', () {
    final controller = AppLocaleController();

    controller.setLanguageId('it');
    expect(controller.locale, const Locale('it'));

    controller.setLanguageId('pt');
    expect(
      controller.locale,
      const Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
    );

    controller.setLanguageId('bg');
    expect(controller.locale, const Locale('bg'));

    controller.setLanguageId('hr');
    expect(controller.locale, const Locale('hr'));

    controller.setLanguageId('sr');
    expect(
      controller.locale,
      const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
    );

    controller.setLanguageId('pl');
    expect(controller.locale, const Locale('pl'));

    controller.setLanguageId('ja');
    expect(controller.locale, const Locale('ja'));

    controller.setLanguageId('ko');
    expect(controller.locale, const Locale('ko'));

    controller.setLanguageId('ar');
    expect(controller.locale, const Locale('ar'));
  });

  test(
      'application supported locales contain only the approved fourteen locales',
      () {
    const portuguesePortugal = Locale.fromSubtags(
      languageCode: 'pt',
      countryCode: 'PT',
    );
    const genericPortuguese = Locale('pt');
    const serbianLatin = Locale.fromSubtags(
      languageCode: 'sr',
      scriptCode: 'Latn',
    );
    const genericSerbian = Locale('sr');
    final expected = {
      const Locale('en'),
      const Locale('ru'),
      const Locale('es'),
      const Locale('fr'),
      const Locale('de'),
      const Locale('it'),
      portuguesePortugal,
      const Locale('bg'),
      const Locale('hr'),
      serbianLatin,
      const Locale('pl'),
      const Locale('ja'),
      const Locale('ko'),
      const Locale('ar'),
    };

    expect(AppLocaleController.supportedLocales.toSet(), expected);
    expect(AppLocaleController.supportedLocales, hasLength(14));
    expect(AppLocaleController.supportedLocales, contains(portuguesePortugal));
    expect(AppLocaleController.supportedLocales,
        isNot(contains(genericPortuguese)));
    expect(AppLocaleController.supportedLocales, contains(serbianLatin));
    expect(
        AppLocaleController.supportedLocales, isNot(contains(genericSerbian)));
    expect(AppLocaleController.supportedLocales, contains(const Locale('ja')));
    expect(AppLocaleController.supportedLocales, contains(const Locale('ko')));
    expect(AppLocaleController.supportedLocales, contains(const Locale('ar')));
  });

  test('generated fallback locales are not selectable application locales', () {
    const portuguesePortugal = Locale.fromSubtags(
      languageCode: 'pt',
      countryCode: 'PT',
    );
    const genericPortuguese = Locale('pt');
    const serbianLatin = Locale.fromSubtags(
      languageCode: 'sr',
      scriptCode: 'Latn',
    );
    const genericSerbian = Locale('sr');

    expect(AppLocalizations.supportedLocales, contains(genericPortuguese));
    expect(AppLocalizations.supportedLocales, contains(portuguesePortugal));
    expect(AppLocalizations.supportedLocales, contains(genericSerbian));
    expect(AppLocalizations.supportedLocales, contains(serbianLatin));
    expect(AppLocalizations.supportedLocales, contains(const Locale('ja')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('ko')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('ar')));
    expect(AppLocalizations.supportedLocales, hasLength(16));
    expect(AppLocaleController.supportedLocales,
        isNot(contains(genericPortuguese)));
    expect(
        AppLocaleController.supportedLocales, isNot(contains(genericSerbian)));
  });
}
