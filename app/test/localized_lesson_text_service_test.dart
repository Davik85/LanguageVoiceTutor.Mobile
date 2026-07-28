import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/study_language_definition.dart';
import 'package:language_voice_tutor_mobile/services/lesson_context_selection_resolver.dart';
import 'package:language_voice_tutor_mobile/services/localized_lesson_text_service.dart';

void main() {
  final scenario = LessonRuntimeScenario.fromJson({
    'id': 'everyday_english_introductions',
    'metadata': {
      'topic': 'Daily Life',
      'subtopic': 'Introductions',
      'lessonType': 'guided_roleplay',
    },
    'lessonSetup': {
      'setupMessage': 'Hi, {{userDisplayName}}!\n\n'
          'Meeting a new neighbor,,,\n\n'
          '1. Say hello\n2. Ask a question',
    },
    'learningGoal': {'goal': 'English goal'},
    'conversationFlow': {'opening': 'Today we practice introductions.'},
    'controlledVariation': {
      'contextVariants': [
        {
          'id': 'neighbor',
          'title': 'Meeting a new neighbor',
          'openingLine': 'Hello from {tutorName}.',
          'contextConfirmationLine': 'Great choice.',
          'aliases': ['new neighbor'],
        },
        {
          'id': 'school',
          'title': 'First day at a language school',
        },
        {
          'id': 'club',
          'title': 'Meeting someone at a hobby club',
        },
      ],
    },
    'hintRules': {'exampleHint': 'Try: My name is Ana.'},
    'runtimeContent': {'lessonPhase': 'active_roleplay'},
  });

  test('English preserves the CMS setup template formatting', () {
    final text = LocalizedLessonTextService.buildSetupMessage(
      scenario: scenario,
      studyLanguage: StudyLanguageDefinitions.resolve('en'),
      userDisplayName: 'David',
    );
    expect(
      text,
      'Hi, David!\n\nMeeting a new neighbor,,,\n\n'
      '1. Say hello\n2. Ask a question',
    );
    expect(text, isNot(contains('Today we practice introductions.')));
    expect(text, isNot(contains('{{userDisplayName}}')));
  });

  test('English setup uses the exact Desktop fallback when CMS is blank', () {
    final blankSetupScenario = LessonRuntimeScenario.fromJson({
      'metadata': {'subtopic': 'Other'},
      'lessonSetup': {'setupMessage': '   '},
      'conversationFlow': {'opening': 'This must not be shown.'},
    });
    expect(
      LocalizedLessonTextService.buildSetupMessage(
        scenario: blankSetupScenario,
        studyLanguage: StudyLanguageDefinitions.resolve('en'),
      ),
      "Hi! Let's practice this situation. Are you ready?",
    );
  });

  test('blank display name keeps the safe setup greeting fallback', () {
    expect(
      LocalizedLessonTextService.buildSetupMessage(
        scenario: scenario,
        studyLanguage: StudyLanguageDefinitions.resolve('en'),
      ),
      'Hi!\n\nMeeting a new neighbor,,,\n\n'
      '1. Say hello\n2. Ask a question',
    );
  });

  final setupExpectations = <String, List<String>>{
    'fr': ['Aujourd’hui', 'Objectif', 'Rencontrer un nouveau voisin'],
    'de': ['Heute üben wir', 'Ziel', 'Einen neuen Nachbarn treffen'],
    'pt': ['Hoje vamos praticar', 'Objetivo', 'Conhecer um novo vizinho'],
    'es': ['Hoy vamos a practicar', 'Objetivo', 'Conocer a un nuevo vecino'],
    'it': ['Oggi pratichiamo', 'Obiettivo', 'Conoscere un nuovo vicino'],
  };
  for (final entry in setupExpectations.entries) {
    test('${entry.key} setup localizes structure and scenario choices', () {
      final text = LocalizedLessonTextService.buildSetupMessage(
        scenario: scenario,
        studyLanguage: StudyLanguageDefinitions.resolve(entry.key),
      );
      for (final expected in entry.value) {
        expect(text, contains(expected));
      }
      expect(text, isNot(contains('Meeting a new neighbor,,,')));
    });
  }

  test('known-context confirmation and introductions opening localize', () {
    final variant = scenario.controlledVariation.contextVariants.first;
    final language = StudyLanguageDefinitions.resolve('fr');
    expect(
      LocalizedLessonTextService.buildContextConfirmationLine(
        variant: variant,
        studyLanguage: language,
        englishFallback: 'Great choice.',
      ),
      contains('Rencontrer un nouveau voisin'),
    );
    expect(
      LocalizedLessonTextService.buildContextOpeningLine(
        englishOpeningLine: variant.openingLine,
        scenario: scenario,
        studyLanguage: language,
      ),
      'Bonjour ! Ravi de te rencontrer. Comment tu t’appelles ?',
    );
  });

  test('generic opening, pre-context Hint, and example Hint localize', () {
    final generic = LessonRuntimeScenario.fromJson({
      'id': 'other',
      'metadata': {'subtopic': 'Other'},
    });
    final spanish = StudyLanguageDefinitions.resolve('es');
    expect(
      LocalizedLessonTextService.buildContextOpeningLine(
        englishOpeningLine: 'Start.',
        scenario: generic,
        studyLanguage: spanish,
      ),
      contains('Empecemos'),
    );
    expect(
      LocalizedLessonTextService.buildSetupContextHint(
        scenario: scenario,
        studyLanguage: spanish,
      ),
      contains('Conocer a un nuevo vecino'),
    );
    expect(
      LocalizedLessonTextService.buildExampleHint(
        scenario.hintRules.exampleHint,
        spanish,
      ),
      contains('Me llamo'),
    );
  });

  test('custom context opening matches Desktop wording and preserves input',
      () {
    expect(
      LocalizedLessonTextService.buildCustomContextStartMessage(
        customContext: ' Meeting a colleague ',
        openingLine: 'Welcome! What is your name?',
        studyLanguage: StudyLanguageDefinitions.resolve('en'),
      ),
      'Good idea. Let\'s keep it simple: Meeting a colleague.\n\n'
      'Welcome! What is your name?',
    );
    expect(
      LocalizedLessonTextService.buildCustomContextStartMessage(
        customContext: 'Une réunion',
        openingLine: 'Bonjour !',
        studyLanguage: StudyLanguageDefinitions.resolve('fr'),
      ),
      'Bonne idée. Restons simples : Une réunion.\n\nBonjour !',
    );
  });

  test('localized French and Spanish titles resolve the canonical variant', () {
    for (final entry in {
      'fr': 'RENCONTRER UN NOUVEAU VOISIN !',
      'es': 'Conocer a un nuevo vecino.',
    }.entries) {
      final result = LessonContextSelectionResolver.resolve(
        scenario: scenario,
        learnerInput: entry.value,
        studyLanguage: StudyLanguageDefinitions.resolve(entry.key),
      );
      expect(result.selectedContextId, 'neighbor');
      expect(result.selectedContextTitle, 'Meeting a new neighbor');
      expect(result.isKnownCmsContext, isTrue);
    }
  });

  test('unsupported language safely resolves to English behavior', () {
    final language = StudyLanguageDefinitions.resolve('unsupported');
    expect(language.id, 'en');
    expect(
      LocalizedLessonTextService.buildExampleHint('English hint', language),
      'English hint',
    );
  });
}
