import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/study_language_definition.dart';
import 'package:language_voice_tutor_mobile/services/lesson_roleplay_opening_builder.dart';

void main() {
  final scenario = LessonRuntimeScenario.fromJson({
    'id': 'everyday_english_introductions',
    'metadata': {'subtopic': 'Introductions'},
    'conversationFlow': {
      'opening': 'Hello.',
      'defaultOpeningExample': 'Welcome! What is your name?',
    },
  });
  const variant = LessonRuntimeContextVariant(
      id: 'c',
      title: 'Context',
      localizedTitle: '',
      openingLine: 'Welcome, {tutorName}.',
      contextConfirmationLine: 'Great choice.',
      openingIntent: 'start');
  test('builds from runtime fields and supplied tutor identity', () {
    final text = const LessonRoleplayOpeningBuilder().buildKnownContextOpening(
        scenario: scenario,
        variant: variant,
        studyLanguage: StudyLanguageDefinitions.supported.first,
        tutorDisplayName: 'Runtime Tutor');
    expect(text, 'Great choice.\n\nWelcome, Runtime Tutor.');
    expect(text, isNot(contains('Lana')));
  });
  test('French known-context opening is localized', () {
    final text = const LessonRoleplayOpeningBuilder().buildKnownContextOpening(
      scenario: scenario,
      variant: variant,
      studyLanguage: StudyLanguageDefinitions.resolve('fr'),
      tutorDisplayName: 'Runtime Tutor',
    );
    expect(text, contains('Très bien'));
    expect(text, contains('Comment tu t’appelles ?'));
    expect(text, isNot(contains('Great choice')));
  });
  test('custom context uses runtime default opening with Desktop fallback', () {
    const builder = LessonRoleplayOpeningBuilder();
    expect(
      builder.buildCustomContextOpening(
        scenario: scenario,
        customContext: 'Meeting a colleague',
        studyLanguage: StudyLanguageDefinitions.resolve('en'),
        tutorDisplayName: 'Runtime Tutor',
      ),
      'Good idea. Let\'s keep it simple: Meeting a colleague.\n\n'
      'Welcome! What is your name?',
    );
    final fallback = LessonRuntimeScenario.fromJson({
      'metadata': {'subtopic': 'Other'},
      'conversationFlow': {},
    });
    expect(
      builder.buildCustomContextOpening(
        scenario: fallback,
        customContext: 'At a park',
        studyLanguage: StudyLanguageDefinitions.resolve('en'),
        tutorDisplayName: 'Runtime Tutor',
      ),
      'Good idea. Let\'s keep it simple: At a park.\n\n'
      'Hi! Nice to meet you. What\'s your name?',
    );
  });

  test('custom context resolves both CMS tutor placeholders', () {
    const builder = LessonRoleplayOpeningBuilder();
    for (final placeholder in const ['{tutorName}', '{TutorName}']) {
      final placeholderScenario = LessonRuntimeScenario.fromJson({
        'metadata': {'subtopic': 'Other'},
        'conversationFlow': {
          'defaultOpeningExample':
              'Hello! I\'m $placeholder. What\'s your name?',
        },
      });

      final text = builder.buildCustomContextOpening(
        scenario: placeholderScenario,
        customContext: 'Meeting a colleague',
        studyLanguage: StudyLanguageDefinitions.resolve('en'),
        tutorDisplayName: 'Runtime Tutor',
      );

      expect(
        text,
        'Good idea. Let\'s keep it simple: Meeting a colleague.\n\n'
        'Hello! I\'m Runtime Tutor. What\'s your name?',
      );
      expect(text, isNot(contains(placeholder)));
    }
  });

  test('known context falls back to the CMS default opening example', () {
    const builder = LessonRoleplayOpeningBuilder();
    const blankVariant = LessonRuntimeContextVariant(
      id: 'fallback',
      title: 'Context',
      localizedTitle: '',
      openingLine: '   ',
      contextConfirmationLine: 'Great choice.',
      openingIntent: 'start',
    );
    final fallbackScenario = LessonRuntimeScenario.fromJson({
      'metadata': {'subtopic': 'Other'},
      'conversationFlow': {
        'opening': 'This opening must not be used.',
        'defaultOpeningExample': 'Hello! I\'m {TutorName}. What\'s your name?',
      },
    });

    expect(
      builder.buildKnownContextOpening(
        scenario: fallbackScenario,
        variant: blankVariant,
        studyLanguage: StudyLanguageDefinitions.resolve('en'),
        tutorDisplayName: 'Runtime Tutor',
      ),
      'Great choice.\n\nHello! I\'m Runtime Tutor. What\'s your name?',
    );
  });
}
