import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/services/voice_scenario_intent_resolver.dart';

void main() {
  final variants = <LessonRuntimeContextVariant>[
    const LessonRuntimeContextVariant(
      id: 'candidate-a',
      title: 'Meeting a new neighbor',
      localizedTitle: '',
      openingLine: '',
      contextConfirmationLine: '',
      openingIntent: '',
    ),
    const LessonRuntimeContextVariant(
      id: 'candidate-b',
      title: 'First day at a language school',
      localizedTitle: '',
      openingLine: '',
      contextConfirmationLine: '',
      openingIntent: '',
    ),
  ];

  VoiceScenarioDeterministicResult resolve(String text) =>
      VoiceScenarioIntentResolver.resolve(
        transcript: text,
        variants: variants,
      );

  test('displayed numbers and ordinals resolve without semantic matching', () {
    for (final text in ['1', '1.', 'first', 'first option', '2nd']) {
      final result = resolve(text);
      expect(result.decision,
          VoiceScenarioDeterministicDecision.publishedScenario);
      expect(result.matchedVariant, isNotNull);
    }
  });

  test('exact CMS title ignores case whitespace and punctuation', () {
    for (final text in [
      'Meeting a new neighbor',
      '  MEETING   A NEW NEIGHBOR!!! ',
    ]) {
      final result = resolve(text);
      expect(result.decision,
          VoiceScenarioDeterministicDecision.publishedScenario);
      expect(result.matchedVariant?.id, 'candidate-a');
    }
  });

  test('a unique tiny character recognition error resolves locally', () {
    final result = resolve('Meeting a new neighbur');
    expect(
        result.decision, VoiceScenarioDeterministicDecision.publishedScenario);
    expect(result.matchedVariant?.id, 'candidate-a');
    expect(result.matchingSignals, contains('unique_small_title_edit'));
  });

  test('partial, paraphrased, generic, and novel text require backend', () {
    for (final text in [
      'meeting neighbor',
      'language school',
      'meeting',
      'meeting a friend in a park',
    ]) {
      expect(resolve(text).decision,
          VoiceScenarioDeterministicDecision.backendSemantic);
    }
  });

  test('unsafe transcript wins before deterministic selection', () {
    final result = VoiceScenarioIntentResolver.resolve(
      transcript: '1',
      variants: variants,
      unsafeTranscript: true,
    );
    expect(
        result.decision, VoiceScenarioDeterministicDecision.unsafeTranscript);
  });
}
