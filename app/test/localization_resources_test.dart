import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const languages = [
    'en',
    'ru',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'pt_PT',
    'bg',
    'hr',
    'sr',
    'sr_Latn',
    'pl',
  ];
  const sharedEnglishExceptions = {
    'appTitle',
    'premium',
    'autoSendMessage',
    'autoPlayTutorVoice',
    'topicCardSemantics',
    'situationCardSemantics',
    'languageNameEnglish',
    'languageNameRussian',
    'languageNameSpanish',
    'languageNameFrench',
    'languageNameGerman',
  };
  const localeEnglishExceptions = {
    // Existing accepted locale-specific cognates and international labels.
    'es': {'audio', 'historyTutor'},
    'fr': {'audio', 'conversation', 'situations', 'feedbackSuggestion'},
    'de': {'app', 'audio', 'statusValue', 'historyTutor'},
    // Audio and Feedback are standard Italian mobile-interface loanwords.
    'it': {'audio', 'premiumOk', 'lessonFeedback'},
    // Feedback is a standard Portuguese mobile-interface loanword.
    'pt': {'premiumOk', 'lessonFeedback'},
    'pt_PT': {'premiumOk', 'lessonFeedback'},
    'bg': {'premiumOk'},
  };
  final temporaryMarker = RegExp(
    r'^\s*(?:\[(?:it|pt|bg|hr|sr|sr_Latn|pl)\]\s*|(?:FIXME|TRANSLATE)\b)',
    caseSensitive: false,
  );
  // Keep TODO uppercase-only so Spanish “Todo” (All time) remains valid.
  final todoMarker = RegExp(r'^\s*TODO\b');
  final placeholder = RegExp(r'\{([A-Za-z_][A-Za-z0-9_]*)(?=,|\})');

  Map<String, dynamic> arb(String language) => jsonDecode(
        File('lib/l10n/app_$language.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

  Set<String> messageKeys(Map<String, dynamic> resource) =>
      resource.keys.where((key) => !key.startsWith('@')).toSet();

  Map<String, dynamic> metadata(Map<String, dynamic> resource) =>
      Map.fromEntries(
        resource.entries.where((entry) => entry.key.startsWith('@')),
      )..remove('@@locale');

  Set<String> placeholders(String value) =>
      placeholder.allMatches(value).map((match) => match.group(1)!).toSet();

  test('all ARBs match English messages and metadata structurally', () {
    final english = arb('en');
    final englishKeys = messageKeys(english);
    final englishMetadata = metadata(english);

    for (final language in languages.skip(1)) {
      final translated = arb(language);
      expect(messageKeys(translated), englishKeys,
          reason: '$language must match the English message keys');
      expect(metadata(translated), englishMetadata,
          reason: '$language must preserve English ARB metadata');

      for (final key in englishKeys) {
        final value = translated[key];
        expect(value, isA<String>(), reason: '$language.$key must be text');
        expect((value as String).trim(), isNotEmpty,
            reason: '$language.$key must not be blank');
        expect(temporaryMarker.hasMatch(value) || todoMarker.hasMatch(value),
            isFalse,
            reason: '$language.$key contains a temporary marker');
        expect(placeholders(value), placeholders(english[key] as String),
            reason: '$language.$key must preserve placeholder names');
      }
    }
  });

  test('translations only retain documented intentional English values', () {
    final english = arb('en');
    final englishKeys = messageKeys(english);

    for (final language in languages.skip(1)) {
      final translated = arb(language);
      final allowed = {
        ...sharedEnglishExceptions,
        ...?localeEnglishExceptions[language],
      };
      final unexpected = <String>[];
      for (final key in englishKeys) {
        if (english[key] == translated[key] && !allowed.contains(key)) {
          unexpected.add(key);
        }
      }
      expect(unexpected, isEmpty,
          reason: '$language contains unexpected English fallback values');
    }
  });

  test('Portuguese fallback and Portugal ARBs only differ by locale', () {
    final portuguese = arb('pt')..remove('@@locale');
    final portuguesePortugal = arb('pt_PT')..remove('@@locale');

    expect(portuguese, portuguesePortugal);
  });

  test('Serbian fallback and Latin Serbian ARBs only differ by locale', () {
    final serbian = arb('sr')..remove('@@locale');
    final serbianLatin = arb('sr_Latn')..remove('@@locale');

    expect(serbian, serbianLatin);
  });

  test('Serbian ARBs contain only Latin-script text', () {
    final cyrillic = RegExp(r'[\u0400-\u04FF]');

    for (final language in ['sr', 'sr_Latn']) {
      final resource = arb(language);
      for (final key in messageKeys(resource)) {
        expect(cyrillic.hasMatch(resource[key] as String), isFalse,
            reason: '$language.$key must not contain Cyrillic text');
      }
    }
  });
}
