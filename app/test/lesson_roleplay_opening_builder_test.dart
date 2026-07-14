import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/study_language_definition.dart';
import 'package:language_voice_tutor_mobile/services/lesson_roleplay_opening_builder.dart';

void main() {
  final scenario = LessonRuntimeScenario.fromJson({
    'id': 'everyday_english_introductions',
    'metadata': {'subtopic': 'Introductions'},
    'conversationFlow': {'opening': 'Hello.'},
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
}
