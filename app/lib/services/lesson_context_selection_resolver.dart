import '../models/lesson_runtime.dart';
import '../models/study_language_definition.dart';
import 'localized_lesson_text_service.dart';

class LessonContextSelection {
  const LessonContextSelection({
    this.selectedContextId,
    this.selectedContextTitle,
    this.selectedContextVariant,
    this.selectedContextLocalizedTitle,
    required this.isContextSelectionTurn,
    required this.isKnownCmsContext,
    required this.isCustomContext,
  });

  final String? selectedContextId;
  final String? selectedContextTitle;
  final LessonRuntimeContextVariant? selectedContextVariant;
  final String? selectedContextLocalizedTitle;
  final bool isContextSelectionTurn;
  final bool isKnownCmsContext;
  final bool isCustomContext;
}

class LessonContextSelectionResolver {
  static LessonContextSelection resolve({
    required LessonRuntimeScenario scenario,
    String? currentSelectedContextId,
    String? currentSelectedContextTitle,
    required String learnerInput,
    StudyLanguageDefinition? studyLanguage,
  }) {
    final variants = scenario.controlledVariation.contextVariants;
    final currentId = currentSelectedContextId?.trim();
    final currentTitle = currentSelectedContextTitle?.trim();
    LessonRuntimeContextVariant? match;
    if (currentId != null && currentId.isNotEmpty) {
      for (final variant in variants) {
        if (variant.id == currentId) match = variant;
      }
    }

    final input = _normalize(learnerInput);
    if (match == null && input.isNotEmpty) {
      final choice = int.tryParse(input);
      if (choice != null && choice >= 1 && choice <= variants.length) {
        match = variants[choice - 1];
      } else {
        for (final variant in variants) {
          final localizedTitle = studyLanguage == null
              ? variant.localizedTitle
              : LocalizedLessonTextService.localizedScenarioTitle(
                  variant,
                  studyLanguage,
                );
          final candidates = <String>[
            variant.title,
            localizedTitle,
            variant.localizedTitle,
            ...variant.aliases,
          ];
          if (candidates
              .any((candidate) => _matches(input, _normalize(candidate)))) {
            match = variant;
            break;
          }
        }
      }
    }

    final hasCurrentSelection =
        (currentId?.isNotEmpty ?? false) || (currentTitle?.isNotEmpty ?? false);
    if (match != null) {
      return LessonContextSelection(
        selectedContextId: match.id,
        selectedContextTitle: match.title.trim(),
        selectedContextVariant: match,
        selectedContextLocalizedTitle: studyLanguage == null
            ? (match.localizedTitle.trim().isEmpty
                ? match.title.trim()
                : match.localizedTitle.trim())
            : LocalizedLessonTextService.localizedScenarioTitle(
                match,
                studyLanguage,
              ),
        // A selected context remains part of every later request, but it only
        // represents a selection on the learner turn which chose it.
        isContextSelectionTurn: !hasCurrentSelection,
        isKnownCmsContext: true,
        isCustomContext: false,
      );
    }
    final custom = (currentTitle != null && currentTitle.isNotEmpty)
        ? currentTitle
        : learnerInput.trim();
    return LessonContextSelection(
      selectedContextTitle: custom.isEmpty ? null : custom,
      isContextSelectionTurn: !hasCurrentSelection && custom.isNotEmpty,
      isKnownCmsContext: false,
      isCustomContext: custom.isNotEmpty,
    );
  }

  static String normalize(String value) => _normalize(value);

  static String _normalize(String value) => value
      .trim()
      .replaceAll('_', ' ')
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static bool _matches(String input, String candidate) =>
      candidate.isNotEmpty &&
      (input == candidate ||
          input.contains(candidate) ||
          candidate.contains(input));
}
