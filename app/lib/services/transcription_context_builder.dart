import '../models/lesson_runtime.dart';
import '../models/study_language_definition.dart';

abstract final class TranscriptionContextBuilder {
  static const initialCandidateLimit = 3;

  static String build({
    required LessonRuntimeScenario? scenario,
    required StudyLanguageDefinition studyLanguage,
    required String selectedContextTitle,
  }) {
    final selected = selectedContextTitle.trim();
    if (selected.isNotEmpty) return 'Selected context: $selected';
    if (scenario == null) return '';

    final candidateTitles = scenario.controlledVariation.contextVariants
        .take(initialCandidateLimit)
        .map((variant) => variant.title.trim())
        .where((title) => title.isNotEmpty)
        .toList(growable: false);
    if (candidateTitles.isEmpty) return '';

    return [
      'The learner is speaking in ${studyLanguage.englishName}.',
      'Transcribe exactly what the learner says. Do not translate or paraphrase.',
      'Current selectable context titles: ${candidateTitles.join(' | ')}',
    ].join(' ');
  }
}
