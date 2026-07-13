class StudyLanguageDefinition {
  const StudyLanguageDefinition({
    required this.id,
    required this.englishName,
    required this.nativeName,
    required this.transcriptionLanguageCode,
  });

  final String id;
  final String englishName;
  final String nativeName;
  final String transcriptionLanguageCode;
}

abstract final class StudyLanguageDefinitions {
  static const supported = <StudyLanguageDefinition>[
    StudyLanguageDefinition(
      id: 'en',
      englishName: 'English',
      nativeName: 'English',
      transcriptionLanguageCode: 'en',
    ),
    StudyLanguageDefinition(
      id: 'fr',
      englishName: 'French',
      nativeName: 'Français',
      transcriptionLanguageCode: 'fr',
    ),
    StudyLanguageDefinition(
      id: 'de',
      englishName: 'German',
      nativeName: 'Deutsch',
      transcriptionLanguageCode: 'de',
    ),
    StudyLanguageDefinition(
      id: 'pt',
      englishName: 'Portuguese',
      nativeName: 'Português',
      transcriptionLanguageCode: 'pt',
    ),
    StudyLanguageDefinition(
      id: 'es',
      englishName: 'Spanish',
      nativeName: 'Español',
      transcriptionLanguageCode: 'es',
    ),
    StudyLanguageDefinition(
      id: 'it',
      englishName: 'Italian',
      nativeName: 'Italiano',
      transcriptionLanguageCode: 'it',
    ),
  ];

  static StudyLanguageDefinition resolve(Object? studyLanguage) {
    if (studyLanguage is String) {
      final normalized = studyLanguage.trim().toLowerCase();
      for (final definition in supported) {
        if (definition.id.toLowerCase() == normalized ||
            definition.englishName.toLowerCase() == normalized ||
            definition.nativeName.toLowerCase() == normalized) {
          return definition;
        }
      }
    }
    return supported.first;
  }
}
