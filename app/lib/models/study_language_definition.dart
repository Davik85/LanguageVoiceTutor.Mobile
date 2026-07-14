class StudyLanguageDefinition {
  const StudyLanguageDefinition({
    required this.id,
    required this.englishName,
    required this.nativeName,
    required this.bcp47Code,
    required this.transcriptionLanguageCode,
    required this.tutorInstructionName,
    required this.languageLockName,
    required this.isDefault,
  });

  final String id;
  final String englishName;
  final String nativeName;
  final String bcp47Code;
  final String transcriptionLanguageCode;
  final String tutorInstructionName;
  final String languageLockName;
  final bool isDefault;

  String get displayName =>
      englishName == nativeName ? englishName : '$englishName / $nativeName';
}

abstract final class StudyLanguageDefinitions {
  static const supported = <StudyLanguageDefinition>[
    StudyLanguageDefinition(
      id: 'en',
      englishName: 'English',
      nativeName: 'English',
      bcp47Code: 'en',
      transcriptionLanguageCode: 'en',
      tutorInstructionName: 'English',
      languageLockName: 'English',
      isDefault: true,
    ),
    StudyLanguageDefinition(
      id: 'fr',
      englishName: 'French',
      nativeName: 'Français',
      bcp47Code: 'fr',
      transcriptionLanguageCode: 'fr',
      tutorInstructionName: 'French',
      languageLockName: 'French',
      isDefault: false,
    ),
    StudyLanguageDefinition(
      id: 'de',
      englishName: 'German',
      nativeName: 'Deutsch',
      bcp47Code: 'de',
      transcriptionLanguageCode: 'de',
      tutorInstructionName: 'German',
      languageLockName: 'German',
      isDefault: false,
    ),
    StudyLanguageDefinition(
      id: 'pt',
      englishName: 'Portuguese',
      nativeName: 'Português',
      bcp47Code: 'pt',
      transcriptionLanguageCode: 'pt',
      tutorInstructionName: 'Portuguese',
      languageLockName: 'Portuguese',
      isDefault: false,
    ),
    StudyLanguageDefinition(
      id: 'es',
      englishName: 'Spanish',
      nativeName: 'Español',
      bcp47Code: 'es',
      transcriptionLanguageCode: 'es',
      tutorInstructionName: 'Spanish',
      languageLockName: 'Spanish',
      isDefault: false,
    ),
    StudyLanguageDefinition(
      id: 'it',
      englishName: 'Italian',
      nativeName: 'Italiano',
      bcp47Code: 'it',
      transcriptionLanguageCode: 'it',
      tutorInstructionName: 'Italian',
      languageLockName: 'Italian',
      isDefault: false,
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
