import '../models/lesson_runtime.dart';

/// Mirrors Desktop's known-context opening construction from runtime content.
class LessonRoleplayOpeningBuilder {
  const LessonRoleplayOpeningBuilder();

  String buildKnownContextOpening({
    required LessonRuntimeContextVariant variant,
    required String tutorDisplayName,
  }) {
    final confirmation = _replaceTutorName(
      variant.contextConfirmationLine,
      tutorDisplayName,
    );
    final opening = _replaceTutorName(variant.openingLine, tutorDisplayName);
    return [confirmation, opening]
        .where((part) => part.trim().isNotEmpty)
        .join('\n\n');
  }

  String _replaceTutorName(String value, String tutorDisplayName) => value
      .replaceAll('{tutorName}', tutorDisplayName)
      .replaceAll('{TutorName}', tutorDisplayName)
      .trim();
}
