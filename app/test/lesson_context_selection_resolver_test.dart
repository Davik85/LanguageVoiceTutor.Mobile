import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/services/lesson_context_selection_resolver.dart';

void main() {
  final scenario = LessonRuntimeScenario.fromJson({
    'id': 'scenario',
    'metadata': {
      'topic': 'topic',
      'subtopic': 'subtopic',
      'lessonType': 'roleplay'
    },
    'lessonSetup': {},
    'learningGoal': {},
    'situation': {},
    'targetLanguage': {},
    'levelProfiles': {},
    'conversationFlow': {},
    'roleplayBeats': [],
    'reciprocalQuestionHandling': {},
    'expectedScenarioProgression': [],
    'aiTutorPromptInstructions': [],
    'promptTemplates': {},
    'controlledVariation': {
      'contextVariants': [
        {'id': 'new_neighbor', 'title': 'Meeting a New Neighbor'},
      ]
    },
    'hintRules': {},
    'runtimeContent': {'lessonPhase': 'active_roleplay'},
  });

  test('resolves case, punctuation, and numeric choices to the CMS variant',
      () {
    for (final input in [
      'meeting a new neighbor',
      'MEETING A NEW NEIGHBOR.',
      '1.'
    ]) {
      final result = LessonContextSelectionResolver.resolve(
        scenario: scenario,
        learnerInput: input,
      );
      expect(result.selectedContextId, 'new_neighbor');
      expect(result.selectedContextVariant?.id, 'new_neighbor');
      expect(result.isKnownCmsContext, isTrue);
      expect(result.isCustomContext, isFalse);
    }
  });

  test('keeps unmatched input as custom without inventing an ID', () {
    final result = LessonContextSelectionResolver.resolve(
      scenario: scenario,
      learnerInput: 'a different situation',
    );
    expect(result.selectedContextId, isNull);
    expect(result.isCustomContext, isTrue);
  });

  test(
      'keeps the selected CMS context without marking later turns as selection',
      () {
    final first = LessonContextSelectionResolver.resolve(
      scenario: scenario,
      learnerInput: 'Meeting a New Neighbor',
    );
    final second = LessonContextSelectionResolver.resolve(
      scenario: scenario,
      currentSelectedContextId: first.selectedContextId,
      currentSelectedContextTitle: first.selectedContextTitle,
      learnerInput: 'Nice to meet you!',
    );

    expect(first.isContextSelectionTurn, isTrue);
    expect(second.isContextSelectionTurn, isFalse);
    expect(second.selectedContextId, 'new_neighbor');
    expect(second.selectedContextVariant?.id, 'new_neighbor');
  });
}
