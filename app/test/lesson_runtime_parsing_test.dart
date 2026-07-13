import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';

void main() {
  test('parses the production runtime DTO without inventing a lesson phase',
      () {
    final runtime = LessonRuntimeScenario.fromJson({
      'id': 'scenario-7',
      'metadata': {'topic': 'T', 'subtopic': 'S'},
      'lessonSetup': {},
      'learningGoal': {'goal': 'Goal'},
      'situation': {},
      'targetLanguage': {},
      'levelProfiles': {},
      'conversationFlow': {'opening': 'Opening', 'firstUserTask': 'Reply'},
      'roleplayBeats': [],
      'reciprocalQuestionHandling': {},
      'expectedScenarioProgression': [],
      'aiTutorPromptInstructions': ['runtime instruction'],
      'promptTemplates': {},
      'controlledVariation': {
        'contextVariants': [
          {
            'id': 'context',
            'title': 'Context',
            'openingLine': 'Hi {tutorName}',
            'contextConfirmationLine': 'Great'
          }
        ]
      },
      'hintRules': {},
      'runtimeContent': {
        'versionNumber': 7,
        'effectiveRuntimeSource': 'CmsPublishedSnapshot',
        'scenarioKey': 'scenario-7'
      },
      'tutorProfiles': [
        {'tutorId': 'tutor', 'displayName': 'Runtime Tutor'}
      ],
      'unknownBackendField': {'ignored': true},
    });
    expect(runtime.id, 'scenario-7');
    expect(runtime.runtimeContent.versionNumber, 7);
    expect(
        runtime.runtimeContent.effectiveRuntimeSource, 'CmsPublishedSnapshot');
    expect(runtime.tutorProfiles.single.displayName, 'Runtime Tutor');
    expect(runtime.aiTutorPromptInstructions, ['runtime instruction']);
    expect(runtime.conversationFlow.opening, 'Opening');
    expect(runtime.learningGoal.goal, 'Goal');
    expect(runtime.controlledVariation.contextVariants.single.openingLine,
        'Hi {tutorName}');
    expect(runtime.runtimeContent.lessonPhase, isEmpty);
  });
}
