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
    final controller = AppLocaleController()..setLanguageId('pl');
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
  });

  test('application supported locales contain only the approved eight locales',
      () {
    const portuguesePortugal = Locale.fromSubtags(
      languageCode: 'pt',
      countryCode: 'PT',
    );
    const genericPortuguese = Locale('pt');
    final expected = {
      const Locale('en'),
      const Locale('ru'),
      const Locale('es'),
      const Locale('fr'),
      const Locale('de'),
      const Locale('it'),
      portuguesePortugal,
      const Locale('bg'),
    };

    expect(AppLocaleController.supportedLocales.toSet(), expected);
    expect(AppLocaleController.supportedLocales, hasLength(8));
    expect(AppLocaleController.supportedLocales, contains(portuguesePortugal));
    expect(AppLocaleController.supportedLocales,
        isNot(contains(genericPortuguese)));
  });

  test('generated Portuguese fallback is not a selectable application locale',
      () {
    const portuguesePortugal = Locale.fromSubtags(
      languageCode: 'pt',
      countryCode: 'PT',
    );
    const genericPortuguese = Locale('pt');

    expect(AppLocalizations.supportedLocales, contains(genericPortuguese));
    expect(AppLocalizations.supportedLocales, contains(portuguesePortugal));
    expect(AppLocaleController.supportedLocales,
        isNot(contains(genericPortuguese)));
  });
}
