import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/language_options.dart';
import 'package:language_voice_tutor_mobile/models/study_language_definition.dart';

void main() {
  test('contains the six exact Desktop-compatible definitions', () {
    const expected = <List<Object>>[
      ['en', 'English', 'English', 'en', 'en', 'English', 'English', true],
      ['fr', 'French', 'Français', 'fr', 'fr', 'French', 'French', false],
      ['de', 'German', 'Deutsch', 'de', 'de', 'German', 'German', false],
      [
        'pt',
        'Portuguese',
        'Português',
        'pt',
        'pt',
        'Portuguese',
        'Portuguese',
        false
      ],
      ['es', 'Spanish', 'Español', 'es', 'es', 'Spanish', 'Spanish', false],
      ['it', 'Italian', 'Italiano', 'it', 'it', 'Italian', 'Italian', false],
    ];
    expect(
      StudyLanguageDefinitions.supported
          .map((value) => [
                value.id,
                value.englishName,
                value.nativeName,
                value.bcp47Code,
                value.transcriptionLanguageCode,
                value.tutorInstructionName,
                value.languageLockName,
                value.isDefault,
              ])
          .toList(),
      expected,
    );
  });

  test('resolves id, English name, and native name case-insensitively', () {
    expect(StudyLanguageDefinitions.resolve(' FR ').id, 'fr');
    expect(StudyLanguageDefinitions.resolve('gErMaN').id, 'de');
    expect(StudyLanguageDefinitions.resolve('españOL').id, 'es');
    expect(StudyLanguageDefinitions.resolve('PORTUGUÊS').id, 'pt');
  });

  test('blank, missing, and unsupported values fall back to English', () {
    for (final value in [null, '', '  ', 'Klingon']) {
      expect(StudyLanguageDefinitions.resolve(value).id, 'en');
    }
  });

  test('displayName and LanguageOptions derive from the authoritative list',
      () {
    expect(StudyLanguageDefinitions.resolve('en').displayName, 'English');
    expect(StudyLanguageDefinitions.resolve('fr').displayName,
        'French / Français');
    expect(
      LanguageOptions.studyLanguages.map((option) => [option.id, option.label]),
      StudyLanguageDefinitions.supported
          .map((definition) => [definition.id, definition.displayName]),
    );
  });
}
