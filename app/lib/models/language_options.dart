import 'language_option.dart';

abstract final class LanguageOptions {
  static const defaultLanguageId = 'en';

  static const studyLanguages = [
    LanguageOption('en', 'English'),
    LanguageOption('fr', 'French'),
    LanguageOption('de', 'German'),
    LanguageOption('pt', 'Portuguese'),
    LanguageOption('es', 'Spanish'),
    LanguageOption('it', 'Italian'),
  ];

  static const nativeLanguages = [
    LanguageOption('en', 'English'),
    LanguageOption('es', 'Spanish'),
    LanguageOption('fr', 'French'),
    LanguageOption('de', 'German'),
    LanguageOption('it', 'Italian'),
    LanguageOption('pt', 'Portuguese'),
    LanguageOption('ru', 'Russian'),
    LanguageOption('uk', 'Ukrainian'),
    LanguageOption('pl', 'Polish'),
    LanguageOption('nl', 'Dutch'),
    LanguageOption('tr', 'Turkish'),
    LanguageOption('ar', 'Arabic'),
    LanguageOption('hi', 'Hindi'),
    LanguageOption('zh-Hans', 'Chinese Simplified'),
    LanguageOption('ja', 'Japanese'),
    LanguageOption('ko', 'Korean'),
    LanguageOption('vi', 'Vietnamese'),
    LanguageOption('id', 'Indonesian'),
    LanguageOption('fa', 'Persian'),
    LanguageOption('ur', 'Urdu'),
    LanguageOption('bn', 'Bengali'),
    LanguageOption('ta', 'Tamil'),
    LanguageOption('te', 'Telugu'),
    LanguageOption('mr', 'Marathi'),
    LanguageOption('gu', 'Gujarati'),
    LanguageOption('th', 'Thai'),
    LanguageOption('sv', 'Swedish'),
    LanguageOption('no', 'Norwegian'),
    LanguageOption('da', 'Danish'),
    LanguageOption('cs', 'Czech'),
    LanguageOption('ro', 'Romanian'),
    LanguageOption('el', 'Greek'),
    LanguageOption('he', 'Hebrew'),
    LanguageOption('sr', 'Serbian'),
    LanguageOption('hr', 'Croatian'),
    LanguageOption('bs', 'Bosnian'),
    LanguageOption('sl', 'Slovenian'),
    LanguageOption('sk', 'Slovak'),
    LanguageOption('bg', 'Bulgarian'),
    LanguageOption('hu', 'Hungarian'),
    LanguageOption('fi', 'Finnish'),
    LanguageOption('et', 'Estonian'),
    LanguageOption('lv', 'Latvian'),
    LanguageOption('lt', 'Lithuanian'),
    LanguageOption('sq', 'Albanian'),
    LanguageOption('mk', 'Macedonian'),
    LanguageOption('be', 'Belarusian'),
    LanguageOption('is', 'Icelandic'),
    LanguageOption('ga', 'Irish'),
    LanguageOption('cy', 'Welsh'),
    LanguageOption('ca', 'Catalan'),
    LanguageOption('eu', 'Basque'),
    LanguageOption('gl', 'Galician'),
    LanguageOption('mt', 'Maltese'),
    LanguageOption('lb', 'Luxembourgish'),
  ];

  static const interfaceLanguages = [
    LanguageOption('en', 'English'),
    LanguageOption('es', 'Spanish'),
    LanguageOption('fr', 'French'),
    LanguageOption('de', 'German'),
    LanguageOption('it', 'Italian'),
    LanguageOption('pt', 'Portuguese'),
    LanguageOption('ru', 'Russian'),
    LanguageOption('pl', 'Polish'),
    LanguageOption('ar', 'Arabic'),
    LanguageOption('ja', 'Japanese'),
    LanguageOption('ko', 'Korean'),
    LanguageOption('sr', 'Serbian'),
    LanguageOption('hr', 'Croatian'),
    LanguageOption('bg', 'Bulgarian'),
  ];

  static String studyLanguageIdFor(Object? value) => _idFor(
        value,
        studyLanguages,
        fallbackId: defaultLanguageId,
      );

  static String backendStudyLanguageNameFor(Object? value) => _labelFor(
        value,
        studyLanguages,
        fallbackLabel: 'English',
      );

  static String nativeLanguageIdFor(Object? value) => _idFor(
        value,
        nativeLanguages,
        fallbackId: defaultLanguageId,
      );

  static String backendNativeLanguageNameFor(Object? value) => _labelFor(
        value,
        nativeLanguages,
        fallbackLabel: 'English',
      );

  static String interfaceLanguageIdFor(Object? value) => _idFor(
        value,
        interfaceLanguages,
        fallbackId: defaultLanguageId,
      );

  static String _labelFor(
    Object? value,
    List<LanguageOption> options, {
    required String fallbackLabel,
  }) {
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) {
        for (final option in options) {
          if (option.id.toLowerCase() == normalized.toLowerCase() ||
              option.label.toLowerCase() == normalized.toLowerCase()) {
            return option.label;
          }
        }
      }
    }
    return fallbackLabel;
  }

  static String _idFor(
    Object? value,
    List<LanguageOption> options, {
    required String fallbackId,
  }) {
    if (value is! String) return fallbackId;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallbackId;

    for (final option in options) {
      if (option.matches(trimmed)) return option.id;
    }

    return fallbackId;
  }
}
