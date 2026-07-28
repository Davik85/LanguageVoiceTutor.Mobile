import '../models/language_options.dart';
import '../models/lesson_chat.dart';
import '../models/lesson_runtime.dart';
import '../models/study_language_definition.dart';
import '../models/user_settings.dart';
import 'lesson_context_selection_resolver.dart';

/// Builds every Mobile learner-turn request from the same published scenario.
class LessonTurnRequestBuilder {
  const LessonTurnRequestBuilder();

  static const fallbackHistoryMessageLimit = 10;
  static const maximumHistoryMessageLimit = 70;
  static const setupContextHistoryOverhead = 3;

  LessonTurnLimits resolveTurnLimits({
    required LessonRuntimeScenario scenario,
    required String selectedLevel,
  }) {
    final levelProfile = scenario.levelProfileFor(selectedLevel);
    return LessonTurnLimits(
      softWrapUpAfterUserTurn: levelProfile.softWrapUpAfterUserTurn > 0
          ? levelProfile.softWrapUpAfterUserTurn
          : scenario.runtimeContent.softWrapUpAfterUserTurn,
      finalMessageAtUserTurn: levelProfile.finalMessageAtUserTurn > 0
          ? levelProfile.finalMessageAtUserTurn
          : scenario.runtimeContent.finalMessageAtUserTurn,
    );
  }

  int resolveHistoryMessageLimit({
    required LessonRuntimeScenario scenario,
    required String selectedLevel,
  }) {
    final finalTurn = resolveTurnLimits(
      scenario: scenario,
      selectedLevel: selectedLevel,
    ).finalMessageAtUserTurn;
    if (finalTurn <= 0) return fallbackHistoryMessageLimit;

    return (finalTurn * 2 + setupContextHistoryOverhead)
        .clamp(0, maximumHistoryMessageLimit)
        .toInt();
  }

  LessonChatRequest build({
    required LessonRuntimeScenario scenario,
    required UserSettings settings,
    required String selectedLevel,
    required String userMessage,
    required String lastBotMessage,
    required int learnerTurnCount,
    required LessonLivePhase lessonPhase,
    required bool hasWrapUpStarted,
    required bool shouldStartWrappingUp,
    required bool shouldEndLessonNow,
    required List<LessonRecentConversationMessage> recentMessages,
    required String backendSessionId,
    required LessonContextSelection context,
    bool? isContextSelectionTurn,
    int? sourceMessageId,
    String? sourcePersistedMessageId,
    String sourceMessageKind = '',
    String userDisplayName = '',
  }) {
    final studyLanguage =
        StudyLanguageDefinitions.resolve(settings.studyLanguage);
    final tutorId = settings.selectedTutorId.trim();
    final tutor = scenario.tutorProfiles
        .cast<LessonRuntimeTutorProfile?>()
        .firstWhere(
          (profile) =>
              profile?.tutorId.trim().toLowerCase() == tutorId.toLowerCase(),
          orElse: () => null,
        );
    return LessonChatRequest.fromScenario(
      scenario: scenario,
      levelProfile: scenario.levelProfileFor(selectedLevel),
      selectedLevel: selectedLevel,
      topicTitle: scenario.metadata.topic,
      subtopicTitle: scenario.metadata.subtopic,
      userMessage: userMessage,
      lastBotMessage: lastBotMessage,
      nativeLanguageName:
          LanguageOptions.backendNativeLanguageNameFor(settings.nativeLanguage),
      targetLanguageId: studyLanguage.id,
      targetLanguageName: studyLanguage.englishName,
      targetLanguageNativeName: studyLanguage.nativeName,
      targetLanguageCode: studyLanguage.transcriptionLanguageCode,
      userDisplayName: userDisplayName,
      learnerTurnCount: learnerTurnCount,
      lessonPhase: lessonPhase.contractValue,
      hasWrapUpStarted: hasWrapUpStarted,
      shouldStartWrappingUp: shouldStartWrappingUp,
      shouldEndLessonNow: shouldEndLessonNow,
      recentMessages: recentMessages,
      backendSessionId: backendSessionId,
      selectedContextTitle: context.selectedContextTitle ?? '',
      selectedContextLocalizedTitle:
          context.selectedContextLocalizedTitle ?? '',
      selectedContextVariant: context.selectedContextVariant,
      isContextSelectionTurn:
          isContextSelectionTurn ?? context.isContextSelectionTurn,
      sourceMessageId: sourceMessageId,
      sourcePersistedMessageId: sourcePersistedMessageId,
      sourceMessageKind: sourceMessageKind,
      tutorAvatarId: tutorId,
      tutorDisplayName: tutor?.displayName.trim() ?? '',
    );
  }
}

class LessonTurnLimits {
  const LessonTurnLimits({
    required this.softWrapUpAfterUserTurn,
    required this.finalMessageAtUserTurn,
  });

  final int softWrapUpAfterUserTurn;
  final int finalMessageAtUserTurn;
}
