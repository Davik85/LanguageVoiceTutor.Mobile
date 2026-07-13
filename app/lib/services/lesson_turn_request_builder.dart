import '../models/language_options.dart';
import '../models/lesson_chat.dart';
import '../models/lesson_runtime.dart';
import '../models/user_settings.dart';
import 'lesson_context_selection_resolver.dart';

/// Builds every Mobile learner-turn request from the same published scenario.
class LessonTurnRequestBuilder {
  const LessonTurnRequestBuilder();

  LessonChatRequest build({
    required LessonRuntimeScenario scenario,
    required UserSettings settings,
    required String selectedLevel,
    required String userMessage,
    required String lastBotMessage,
    required int learnerTurnCount,
    required List<LessonRecentConversationMessage> recentMessages,
    required String backendSessionId,
    required LessonContextSelection context,
  }) {
    final languageId =
        LanguageOptions.studyLanguageIdFor(settings.studyLanguage);
    final languageName =
        LanguageOptions.backendStudyLanguageNameFor(settings.studyLanguage);
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
      targetLanguageId: languageId,
      targetLanguageName: languageName,
      targetLanguageNativeName: languageName,
      targetLanguageCode: languageId,
      userDisplayName: '',
      learnerTurnCount: learnerTurnCount,
      recentMessages: recentMessages,
      backendSessionId: backendSessionId,
      selectedContextTitle: context.selectedContextTitle ?? '',
      selectedContextVariant: context.selectedContextVariant,
      isContextSelectionTurn: context.isContextSelectionTurn,
      tutorAvatarId: tutorId,
      tutorDisplayName: tutor?.displayName.trim() ?? '',
    );
  }
}
