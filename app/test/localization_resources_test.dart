import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const languages = ['en', 'ru', 'es', 'fr', 'de'];
  const universallyDisplayedKeys = {
    'appTitle',
    'audio',
    'app',
    // Premium is a product name in every supported interface locale.
    'premium',
    'languageNameEnglish',
    'languageNameRussian',
    'languageNameSpanish',
    'languageNameFrench',
    'languageNameGerman',
    // French uses these exact, correctly localized cognates.
    'conversation',
    'situations',
    // This word is spelled identically in English and French.
    'feedbackSuggestion',
    // German uses the same international status label.
    'statusValue',
    // These placeholder-only accessibility templates are language-neutral.
    'topicCardSemantics',
    'situationCardSemantics',
  };

  Map<String, dynamic> arb(String language) =>
      jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
          as Map<String, dynamic>;

  test('stage-1 ARBs have the complete English message set', () {
    final english = arb('en');
    final englishKeys =
        english.keys.where((key) => !key.startsWith('@')).toSet();

    for (final language in languages.skip(1)) {
      final translatedKeys =
          arb(language).keys.where((key) => !key.startsWith('@')).toSet();
      expect(translatedKeys, englishKeys,
          reason: '$language must match app_en.arb');
    }
  });

  test('stage-1 translations do not silently retain English values', () {
    final english = arb('en');
    for (final language in languages.skip(1)) {
      final translated = arb(language);
      final untranslated = <String>[];
      for (final entry in english.entries) {
        if (entry.key.startsWith('@') ||
            universallyDisplayedKeys.contains(entry.key)) {
          continue;
        }
        if (entry.value is String && entry.value == translated[entry.key]) {
          untranslated.add(entry.key);
        }
      }
      expect(untranslated, isEmpty,
          reason: '$language contains unexpected English fallback values');
    }
  });
}
