import '../models/lesson_runtime.dart';
import '../models/study_language_definition.dart';
import 'localized_lesson_text_service.dart';

/// Mirrors Desktop's known-context opening construction from runtime content.
class LessonRoleplayOpeningBuilder {
  const LessonRoleplayOpeningBuilder();

  static const _defaultCustomContextOpening =
      "Hi! Nice to meet you. What's your name?";

  String buildKnownContextOpening({
    required LessonRuntimeScenario scenario,
    required LessonRuntimeContextVariant variant,
    required StudyLanguageDefinition studyLanguage,
    required String tutorDisplayName,
    String? resolvedLocalizedTitle,
  }) {
    final englishConfirmation = _replaceTutorName(
      variant.contextConfirmationLine.trim().isEmpty
          ? "Great! Let's imagine this situation: ${variant.title}."
          : variant.contextConfirmationLine,
      tutorDisplayName,
    );
    final confirmation =
        LocalizedLessonTextService.buildContextConfirmationLine(
      variant: variant,
      resolvedLocalizedTitle: resolvedLocalizedTitle ?? '',
      studyLanguage: studyLanguage,
      englishFallback: englishConfirmation,
    );
    final englishOpening = _replaceTutorName(
      variant.openingLine.trim().isEmpty
          ? scenario.conversationFlow.defaultOpeningExample
          : variant.openingLine,
      tutorDisplayName,
    );
    final opening = LocalizedLessonTextService.buildContextOpeningLine(
      englishOpeningLine: englishOpening,
      scenario: scenario,
      studyLanguage: studyLanguage,
    );
    return [confirmation, opening]
        .where((part) => part.trim().isNotEmpty)
        .join('\n\n');
  }

  String buildCustomContextOpening({
    required LessonRuntimeScenario scenario,
    required String customContext,
    required StudyLanguageDefinition studyLanguage,
    required String tutorDisplayName,
  }) {
    final englishOpening = _replaceTutorName(
      scenario.conversationFlow.defaultOpeningExample.trim().isEmpty
          ? _defaultCustomContextOpening
          : scenario.conversationFlow.defaultOpeningExample.trim(),
      tutorDisplayName,
    );
    final opening = LocalizedLessonTextService.buildContextOpeningLine(
      englishOpeningLine: englishOpening,
      scenario: scenario,
      studyLanguage: studyLanguage,
    );
    return LocalizedLessonTextService.buildCustomContextStartMessage(
      customContext: customContext,
      openingLine: opening,
      studyLanguage: studyLanguage,
    );
  }

  String _replaceTutorName(String value, String tutorDisplayName) => value
      .replaceAll('{tutorName}', tutorDisplayName)
      .replaceAll('{TutorName}', tutorDisplayName)
      .trim();
}
