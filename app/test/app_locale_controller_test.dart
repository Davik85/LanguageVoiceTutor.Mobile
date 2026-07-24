import 'package:flutter_test/flutter_test.dart';
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
}
