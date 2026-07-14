import 'lesson_runtime.dart';

class LessonChatRequest {
  const LessonChatRequest({
    required this.selectedLevel,
    required this.topicTitle,
    required this.subtopicTitle,
    required this.userMessage,
    required this.lastBotMessage,
    required this.nativeLanguageName,
    required this.targetLanguageId,
    required this.targetLanguageName,
    required this.targetLanguageNativeName,
    required this.targetLanguageCode,
    required this.tutorAvatarId,
    required this.tutorDisplayName,
    required this.userDisplayName,
    required this.learningGoal,
    required this.learnerTurnCount,
    required this.softLearnerTurnLimit,
    required this.hardLearnerTurnLimit,
    required this.remainingLearnerTurns,
    required this.shouldStartWrappingUp,
    required this.shouldEndLessonNow,
    required this.recentMessages,
    required this.lessonPhase,
    required this.hasWrapUpStarted,
    required this.lessonScenarioId,
    required this.level,
    required this.topic,
    required this.subtopic,
    required this.lessonGoal,
    required this.lessonType,
    required this.aiTutorPromptInstructions,
    required this.promptTemplates,
    required this.selectedContextVariantId,
    required this.selectedContextTitle,
    required this.selectedContextLocalizedTitle,
    required this.selectedContextOpeningLine,
    required this.selectedContextConfirmationLine,
    required this.selectedContextOpeningIntent,
    required this.isContextSelectionTurn,
    required this.userTurnNumber,
    required this.softWrapUpAfterUserTurn,
    required this.finalMessageAtUserTurn,
    required this.effectiveRuntimeSource,
    required this.contentPackSlug,
    required this.runtimeContentVersionNumber,
    required this.runtimeContentSnapshotHash,
    required this.runtimeContentFallbackUsed,
    required this.runtimeContentScenarioKey,
    required this.resolvedLevelId,
    required this.levelBotLanguageComplexityGuidance,
    required this.levelCorrectionGuidance,
    required this.levelAnswerLengthGuidance,
    required this.targetLanguageKeyPhrases,
    required this.grammarFocus,
    required this.conversationOpening,
    required this.conversationFirstUserTask,
    required this.conversationGuidedPracticeFollowUpQuestions,
    required this.conversationVariationOrComplication,
    required this.conversationCorrectionMoment,
    required this.conversationWrapUpMessage,
    required this.conversationFinalMessage,
    required this.conversationWrapUpIntent,
    required this.conversationFinalMessageIntent,
    required this.roleplayBeats,
    required this.reciprocalQuestionIfUserAsksTutorName,
    required this.reciprocalQuestionIfUserAsksSimplePersonalQuestion,
    required this.reciprocalQuestionMustNotIgnoreUserQuestion,
    required this.reciprocalQuestionMustNotRefuseScenarioCompatibleQuestions,
    required this.expectedScenarioProgression,
    required this.feedbackRulesSummary,
    required this.backendSessionId,
    required this.tutorProfileId,
    required this.activeLevelProfileDifficultyNotes,
    required this.activeLevelProfileTutorLanguageStyle,
    required this.activeLevelProfileExpectedUserResponse,
    required this.activeLevelProfileFeedbackStrictness,
    required this.activeLevelProfileHintStrategy,
    required this.activeLevelProfileCorrectionPriority,
    required this.activeLevelProfileConversationDepth,
    required this.activeLevelProfileExampleGoodAnswer,
    required this.activeLevelProfileExampleStretchAnswer,
    required this.activeLevelProfileAddedKeyPhrases,
    required this.activeLevelProfileAddedUsefulConstructions,
    required this.activeLevelProfileAddedGrammarFocus,
    this.sourceMessageId,
    this.sourcePersistedMessageId,
    this.sourceMessageKind = '',
  });

  final String selectedLevel;
  final String topicTitle;
  final String subtopicTitle;
  final String userMessage;
  final String lastBotMessage;
  final String nativeLanguageName;
  final String targetLanguageId;
  final String targetLanguageName;
  final String targetLanguageNativeName;
  final String targetLanguageCode;
  final String tutorAvatarId;
  final String tutorDisplayName;
  final String userDisplayName;
  final String learningGoal;
  final int learnerTurnCount;
  final int softLearnerTurnLimit;
  final int hardLearnerTurnLimit;
  final int remainingLearnerTurns;
  final bool shouldStartWrappingUp;
  final bool shouldEndLessonNow;
  final List<LessonRecentConversationMessage> recentMessages;
  final String lessonPhase;
  final bool hasWrapUpStarted;
  final String lessonScenarioId;
  final String level;
  final String topic;
  final String subtopic;
  final String lessonGoal;
  final String lessonType;
  final List<String> aiTutorPromptInstructions;
  final Map<String, String> promptTemplates;
  final String selectedContextVariantId;
  final String selectedContextTitle;
  final String selectedContextLocalizedTitle;
  final String selectedContextOpeningLine;
  final String selectedContextConfirmationLine;
  final String selectedContextOpeningIntent;
  final bool isContextSelectionTurn;
  final int userTurnNumber;
  final int softWrapUpAfterUserTurn;
  final int finalMessageAtUserTurn;
  final String effectiveRuntimeSource;
  final String contentPackSlug;
  final int? runtimeContentVersionNumber;
  final String runtimeContentSnapshotHash;
  final bool runtimeContentFallbackUsed;
  final String runtimeContentScenarioKey;
  final String resolvedLevelId;
  final String levelBotLanguageComplexityGuidance;
  final String levelCorrectionGuidance;
  final String levelAnswerLengthGuidance;
  final List<String> targetLanguageKeyPhrases;
  final List<String> grammarFocus;
  final String conversationOpening;
  final String conversationFirstUserTask;
  final List<String> conversationGuidedPracticeFollowUpQuestions;
  final String conversationVariationOrComplication;
  final String conversationCorrectionMoment;
  final String conversationWrapUpMessage;
  final String conversationFinalMessage;
  final String conversationWrapUpIntent;
  final String conversationFinalMessageIntent;
  final List<LessonScenarioRoleplayBeat> roleplayBeats;
  final String reciprocalQuestionIfUserAsksTutorName;
  final String reciprocalQuestionIfUserAsksSimplePersonalQuestion;
  final bool reciprocalQuestionMustNotIgnoreUserQuestion;
  final bool reciprocalQuestionMustNotRefuseScenarioCompatibleQuestions;
  final List<String> expectedScenarioProgression;
  final String feedbackRulesSummary;
  final String backendSessionId;
  final String tutorProfileId;
  final String activeLevelProfileDifficultyNotes;
  final String activeLevelProfileTutorLanguageStyle;
  final String activeLevelProfileExpectedUserResponse;
  final String activeLevelProfileFeedbackStrictness;
  final String activeLevelProfileHintStrategy;
  final String activeLevelProfileCorrectionPriority;
  final String activeLevelProfileConversationDepth;
  final String activeLevelProfileExampleGoodAnswer;
  final String activeLevelProfileExampleStretchAnswer;
  final List<String> activeLevelProfileAddedKeyPhrases;
  final List<String> activeLevelProfileAddedUsefulConstructions;
  final List<String> activeLevelProfileAddedGrammarFocus;
  final int? sourceMessageId;
  final String? sourcePersistedMessageId;
  final String sourceMessageKind;

  Map<String, dynamic> toJson() => {
        'selectedLevel': selectedLevel,
        'topicTitle': topicTitle,
        'subtopicTitle': subtopicTitle,
        'userMessage': userMessage,
        'lastBotMessage': lastBotMessage,
        'nativeLanguageName': nativeLanguageName,
        'targetLanguageId': targetLanguageId,
        'targetLanguageName': targetLanguageName,
        'targetLanguageNativeName': targetLanguageNativeName,
        'targetLanguageCode': targetLanguageCode,
        'tutorAvatarId': tutorAvatarId,
        'tutorDisplayName': tutorDisplayName,
        'userDisplayName': userDisplayName,
        'learningGoal': learningGoal,
        'learnerTurnCount': learnerTurnCount,
        'softLearnerTurnLimit': softLearnerTurnLimit,
        'hardLearnerTurnLimit': hardLearnerTurnLimit,
        'remainingLearnerTurns': remainingLearnerTurns,
        'shouldStartWrappingUp': shouldStartWrappingUp,
        'shouldEndLessonNow': shouldEndLessonNow,
        'recentMessages':
            recentMessages.map((message) => message.toJson()).toList(),
        'lessonPhase': lessonPhase,
        'hasWrapUpStarted': hasWrapUpStarted,
        'lessonScenarioId': lessonScenarioId,
        'level': level,
        'topic': topic,
        'subtopic': subtopic,
        'lessonGoal': lessonGoal,
        'lessonType': lessonType,
        'aiTutorPromptInstructions': aiTutorPromptInstructions,
        'promptTemplates': promptTemplates,
        'selectedContextVariantId': selectedContextVariantId,
        'selectedContextTitle': selectedContextTitle,
        'selectedContextLocalizedTitle': selectedContextLocalizedTitle,
        'selectedContextOpeningLine': selectedContextOpeningLine,
        'selectedContextConfirmationLine': selectedContextConfirmationLine,
        'selectedContextOpeningIntent': selectedContextOpeningIntent,
        'isContextSelectionTurn': isContextSelectionTurn,
        'userTurnNumber': userTurnNumber,
        'softWrapUpAfterUserTurn': softWrapUpAfterUserTurn,
        'finalMessageAtUserTurn': finalMessageAtUserTurn,
        'effectiveRuntimeSource': effectiveRuntimeSource,
        'contentPackSlug': contentPackSlug,
        'runtimeContentVersionNumber': runtimeContentVersionNumber,
        'runtimeContentSnapshotHash': runtimeContentSnapshotHash,
        'runtimeContentFallbackUsed': runtimeContentFallbackUsed,
        'runtimeContentScenarioKey': runtimeContentScenarioKey,
        'resolvedLevelId': resolvedLevelId,
        'levelBotLanguageComplexityGuidance':
            levelBotLanguageComplexityGuidance,
        'levelCorrectionGuidance': levelCorrectionGuidance,
        'levelAnswerLengthGuidance': levelAnswerLengthGuidance,
        'targetLanguageKeyPhrases': targetLanguageKeyPhrases,
        'grammarFocus': grammarFocus,
        'conversationOpening': conversationOpening,
        'conversationFirstUserTask': conversationFirstUserTask,
        'conversationGuidedPracticeFollowUpQuestions':
            conversationGuidedPracticeFollowUpQuestions,
        'conversationVariationOrComplication':
            conversationVariationOrComplication,
        'conversationCorrectionMoment': conversationCorrectionMoment,
        'conversationWrapUpMessage': conversationWrapUpMessage,
        'conversationFinalMessage': conversationFinalMessage,
        'conversationWrapUpIntent': conversationWrapUpIntent,
        'conversationFinalMessageIntent': conversationFinalMessageIntent,
        'roleplayBeats': roleplayBeats.map((beat) => beat.toJson()).toList(),
        'reciprocalQuestionIfUserAsksTutorName':
            reciprocalQuestionIfUserAsksTutorName,
        'reciprocalQuestionIfUserAsksSimplePersonalQuestion':
            reciprocalQuestionIfUserAsksSimplePersonalQuestion,
        'reciprocalQuestionMustNotIgnoreUserQuestion':
            reciprocalQuestionMustNotIgnoreUserQuestion,
        'reciprocalQuestionMustNotRefuseScenarioCompatibleQuestions':
            reciprocalQuestionMustNotRefuseScenarioCompatibleQuestions,
        'expectedScenarioProgression': expectedScenarioProgression,
        'feedbackRulesSummary': feedbackRulesSummary,
        'backendSessionId': backendSessionId,
        'tutorProfileId': tutorProfileId,
        'activeLevelProfileDifficultyNotes': activeLevelProfileDifficultyNotes,
        'activeLevelProfileTutorLanguageStyle':
            activeLevelProfileTutorLanguageStyle,
        'activeLevelProfileExpectedUserResponse':
            activeLevelProfileExpectedUserResponse,
        'activeLevelProfileFeedbackStrictness':
            activeLevelProfileFeedbackStrictness,
        'activeLevelProfileHintStrategy': activeLevelProfileHintStrategy,
        'activeLevelProfileCorrectionPriority':
            activeLevelProfileCorrectionPriority,
        'activeLevelProfileConversationDepth':
            activeLevelProfileConversationDepth,
        'activeLevelProfileExampleGoodAnswer':
            activeLevelProfileExampleGoodAnswer,
        'activeLevelProfileExampleStretchAnswer':
            activeLevelProfileExampleStretchAnswer,
        'activeLevelProfileAddedKeyPhrases': activeLevelProfileAddedKeyPhrases,
        'activeLevelProfileAddedUsefulConstructions':
            activeLevelProfileAddedUsefulConstructions,
        'activeLevelProfileAddedGrammarFocus':
            activeLevelProfileAddedGrammarFocus,
        if (sourceMessageId != null) 'sourceMessageId': sourceMessageId,
        if (sourcePersistedMessageId != null)
          'sourcePersistedMessageId': sourcePersistedMessageId,
        if (sourceMessageKind.isNotEmpty)
          'sourceMessageKind': sourceMessageKind,
      };

  factory LessonChatRequest.fromScenario({
    required LessonRuntimeScenario scenario,
    required LessonRuntimeLevelProfile levelProfile,
    required String selectedLevel,
    required String topicTitle,
    required String subtopicTitle,
    required String userMessage,
    required String lastBotMessage,
    required String nativeLanguageName,
    required String targetLanguageId,
    required String targetLanguageName,
    required String targetLanguageNativeName,
    required String targetLanguageCode,
    required String userDisplayName,
    required int learnerTurnCount,
    required List<LessonRecentConversationMessage> recentMessages,
    required String backendSessionId,
    int? sourceMessageId,
    String? sourcePersistedMessageId,
    String sourceMessageKind = '',
    String selectedContextTitle = '',
    String selectedContextLocalizedTitle = '',
    LessonRuntimeContextVariant? selectedContextVariant,
    bool isContextSelectionTurn = false,
    String tutorAvatarId = '',
    String tutorDisplayName = '',
  }) {
    final softTurn = levelProfile.softWrapUpAfterUserTurn > 0
        ? levelProfile.softWrapUpAfterUserTurn
        : scenario.runtimeContent.softWrapUpAfterUserTurn;
    final finalTurn = levelProfile.finalMessageAtUserTurn > 0
        ? levelProfile.finalMessageAtUserTurn
        : scenario.runtimeContent.finalMessageAtUserTurn;

    return LessonChatRequest(
      selectedLevel: selectedLevel,
      topicTitle: topicTitle,
      subtopicTitle: subtopicTitle,
      userMessage: userMessage,
      lastBotMessage: lastBotMessage,
      nativeLanguageName: nativeLanguageName,
      targetLanguageId: targetLanguageId,
      targetLanguageName: targetLanguageName,
      targetLanguageNativeName: targetLanguageNativeName,
      targetLanguageCode: targetLanguageCode,
      tutorAvatarId: tutorAvatarId,
      tutorDisplayName: tutorDisplayName,
      userDisplayName: userDisplayName,
      learningGoal: scenario.learningGoal.goal,
      learnerTurnCount: learnerTurnCount,
      softLearnerTurnLimit: softTurn,
      hardLearnerTurnLimit: finalTurn,
      remainingLearnerTurns: finalTurn > 0
          ? (finalTurn - learnerTurnCount).clamp(0, finalTurn)
          : 0,
      shouldStartWrappingUp: softTurn > 0 && learnerTurnCount >= softTurn,
      shouldEndLessonNow: finalTurn > 0 && learnerTurnCount >= finalTurn,
      recentMessages: recentMessages,
      lessonPhase: scenario.runtimeContent.lessonPhase,
      hasWrapUpStarted: scenario.runtimeContent.hasWrapUpStarted,
      lessonScenarioId: scenario.id,
      level: selectedLevel,
      topic: scenario.metadata.topic,
      subtopic: scenario.metadata.subtopic,
      lessonGoal: scenario.learningGoal.goal,
      lessonType: scenario.metadata.lessonType,
      aiTutorPromptInstructions: scenario.aiTutorPromptInstructions,
      promptTemplates: scenario.promptTemplates,
      selectedContextVariantId: selectedContextVariant?.id ?? '',
      selectedContextTitle: selectedContextTitle,
      selectedContextLocalizedTitle: selectedContextLocalizedTitle.isNotEmpty
          ? selectedContextLocalizedTitle
          : selectedContextVariant?.localizedTitle ?? '',
      selectedContextOpeningLine: selectedContextVariant?.openingLine ?? '',
      selectedContextConfirmationLine:
          selectedContextVariant?.contextConfirmationLine ?? '',
      selectedContextOpeningIntent: selectedContextVariant?.openingIntent ?? '',
      isContextSelectionTurn: isContextSelectionTurn,
      userTurnNumber: learnerTurnCount,
      softWrapUpAfterUserTurn: softTurn,
      finalMessageAtUserTurn: finalTurn,
      effectiveRuntimeSource: scenario.runtimeContent.effectiveRuntimeSource,
      contentPackSlug: scenario.runtimeContent.contentPackSlug,
      runtimeContentVersionNumber: scenario.runtimeContent.versionNumber,
      runtimeContentSnapshotHash: scenario.runtimeContent.snapshotHash,
      runtimeContentFallbackUsed: scenario.runtimeContent.fallbackUsed,
      runtimeContentScenarioKey: scenario.runtimeContent.scenarioKey,
      resolvedLevelId: scenario.runtimeContent.resolvedLevelId.isNotEmpty
          ? scenario.runtimeContent.resolvedLevelId
          : selectedLevel,
      levelBotLanguageComplexityGuidance: levelProfile.tutorLanguageStyle,
      levelCorrectionGuidance: levelProfile.feedbackStrictness,
      levelAnswerLengthGuidance: levelProfile.conversationDepth,
      targetLanguageKeyPhrases: scenario.targetLanguage.keyPhrases,
      grammarFocus: [
        ...scenario.targetLanguage.grammarFocus,
        ...levelProfile.addedGrammarFocus,
      ],
      conversationOpening: scenario.conversationFlow.opening,
      conversationFirstUserTask: scenario.conversationFlow.firstUserTask,
      conversationGuidedPracticeFollowUpQuestions:
          scenario.conversationFlow.guidedPracticeFollowUpQuestions,
      conversationVariationOrComplication:
          scenario.conversationFlow.variationOrComplication,
      conversationCorrectionMoment: scenario.conversationFlow.correctionMoment,
      conversationWrapUpMessage: scenario.conversationFlow.wrapUpMessage,
      conversationFinalMessage: scenario.conversationFlow.finalMessage,
      conversationWrapUpIntent: scenario.conversationFlow.wrapUpIntent,
      conversationFinalMessageIntent:
          scenario.conversationFlow.finalMessageIntent,
      roleplayBeats: scenario.roleplayBeats
          .map(
            (beat) =>
                LessonScenarioRoleplayBeat(id: beat.id, intent: beat.intent),
          )
          .toList(growable: false),
      reciprocalQuestionIfUserAsksTutorName:
          scenario.reciprocalQuestionHandling.ifUserAsksTutorName,
      reciprocalQuestionIfUserAsksSimplePersonalQuestion:
          scenario.reciprocalQuestionHandling.ifUserAsksSimplePersonalQuestion,
      reciprocalQuestionMustNotIgnoreUserQuestion:
          scenario.reciprocalQuestionHandling.mustNotIgnoreUserQuestion,
      reciprocalQuestionMustNotRefuseScenarioCompatibleQuestions: scenario
          .reciprocalQuestionHandling.mustNotRefuseScenarioCompatibleQuestions,
      expectedScenarioProgression: scenario.expectedScenarioProgression,
      feedbackRulesSummary: '',
      backendSessionId: backendSessionId,
      tutorProfileId: '',
      activeLevelProfileDifficultyNotes: levelProfile.difficultyNotes,
      activeLevelProfileTutorLanguageStyle: levelProfile.tutorLanguageStyle,
      activeLevelProfileExpectedUserResponse: levelProfile.expectedUserResponse,
      activeLevelProfileFeedbackStrictness: levelProfile.feedbackStrictness,
      activeLevelProfileHintStrategy: levelProfile.hintStrategy,
      activeLevelProfileCorrectionPriority: levelProfile.correctionPriority,
      activeLevelProfileConversationDepth: levelProfile.conversationDepth,
      activeLevelProfileExampleGoodAnswer: levelProfile.exampleGoodAnswer,
      activeLevelProfileExampleStretchAnswer: levelProfile.exampleStretchAnswer,
      activeLevelProfileAddedKeyPhrases: levelProfile.addedKeyPhrases,
      activeLevelProfileAddedUsefulConstructions:
          levelProfile.addedUsefulConstructions,
      activeLevelProfileAddedGrammarFocus: levelProfile.addedGrammarFocus,
      sourceMessageId: sourceMessageId,
      sourcePersistedMessageId: sourcePersistedMessageId,
      sourceMessageKind: sourceMessageKind,
    );
  }
}

class LessonRecentConversationMessage {
  const LessonRecentConversationMessage({
    required this.sender,
    required this.text,
  });

  final String sender;
  final String text;

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
      };
}

class LessonScenarioRoleplayBeat {
  const LessonScenarioRoleplayBeat({
    required this.id,
    required this.intent,
  });

  final String id;
  final String intent;

  Map<String, dynamic> toJson() => {
        'id': id,
        'intent': intent,
      };
}

class LessonChatReplyResponse {
  const LessonChatReplyResponse({
    required this.botReply,
    required this.isLessonComplete,
  });

  final String botReply;
  final bool isLessonComplete;

  factory LessonChatReplyResponse.fromJson(Map<String, dynamic> json) =>
      LessonChatReplyResponse(
        botReply: _string(json, 'botReply'),
        isLessonComplete: _bool(json, 'isLessonComplete'),
      );
}

enum LessonChatReplyStatus {
  success,
  validation,
  authRequired,
  notFound,
  conflict,
  limited,
  unavailable,
  failed,
}

class LessonChatReplyResult {
  const LessonChatReplyResult._({
    required this.status,
    required this.message,
    this.reply,
  });

  final LessonChatReplyStatus status;
  final String message;
  final LessonChatReplyResponse? reply;

  bool get isSuccess => status == LessonChatReplyStatus.success;

  factory LessonChatReplyResult.success(LessonChatReplyResponse reply) =>
      LessonChatReplyResult._(
        status: LessonChatReplyStatus.success,
        message: 'Message sent.',
        reply: reply,
      );

  factory LessonChatReplyResult.validation() => const LessonChatReplyResult._(
        status: LessonChatReplyStatus.validation,
        message: 'Please enter a message.',
      );

  factory LessonChatReplyResult.authRequired() => const LessonChatReplyResult._(
        status: LessonChatReplyStatus.authRequired,
        message: 'Please sign in again to continue the lesson.',
      );

  factory LessonChatReplyResult.notFound() => const LessonChatReplyResult._(
        status: LessonChatReplyStatus.notFound,
        message: 'This lesson session is no longer available.',
      );

  factory LessonChatReplyResult.conflict() => const LessonChatReplyResult._(
        status: LessonChatReplyStatus.conflict,
        message: 'This lesson has already ended.',
      );

  factory LessonChatReplyResult.limited() => const LessonChatReplyResult._(
        status: LessonChatReplyStatus.limited,
        message:
            'You have used today\'s free lesson. Please try again tomorrow or upgrade.',
      );

  factory LessonChatReplyResult.unavailable() => const LessonChatReplyResult._(
        status: LessonChatReplyStatus.unavailable,
        message:
            'Could not send the message. Please check your connection and try again.',
      );

  factory LessonChatReplyResult.failed() => const LessonChatReplyResult._(
        status: LessonChatReplyStatus.failed,
        message: 'Could not send the message. Please try again.',
      );
}

class LessonChatHintResponse {
  const LessonChatHintResponse({required this.hintText});

  final String hintText;

  factory LessonChatHintResponse.fromJson(Map<String, dynamic> json) {
    final hintText = _string(json, 'hintText').trim();
    if (hintText.isEmpty) {
      throw const FormatException('Invalid hint response.');
    }
    return LessonChatHintResponse(hintText: hintText);
  }
}

enum LessonChatHintStatus {
  success,
  authRequired,
  notFound,
  conflict,
  limited,
  unavailable,
  failed,
}

class LessonChatHintResult {
  const LessonChatHintResult._({
    required this.status,
    required this.message,
    this.hint,
  });

  final LessonChatHintStatus status;
  final String message;
  final LessonChatHintResponse? hint;

  bool get isSuccess => status == LessonChatHintStatus.success;

  factory LessonChatHintResult.success(LessonChatHintResponse hint) =>
      LessonChatHintResult._(
        status: LessonChatHintStatus.success,
        message: 'Hint ready.',
        hint: hint,
      );

  factory LessonChatHintResult.authRequired() => const LessonChatHintResult._(
        status: LessonChatHintStatus.authRequired,
        message: 'Please sign in again to continue the lesson.',
      );

  factory LessonChatHintResult.notFound() => const LessonChatHintResult._(
        status: LessonChatHintStatus.notFound,
        message: 'This lesson session is no longer available.',
      );

  factory LessonChatHintResult.conflict() => const LessonChatHintResult._(
        status: LessonChatHintStatus.conflict,
        message: 'This lesson has already ended.',
      );

  factory LessonChatHintResult.limited() => const LessonChatHintResult._(
        status: LessonChatHintStatus.limited,
        message: 'Hint is temporarily unavailable. Please try again shortly.',
      );

  factory LessonChatHintResult.unavailable() => const LessonChatHintResult._(
        status: LessonChatHintStatus.unavailable,
        message:
            'Could not get a hint. Please check your connection and try again.',
      );

  factory LessonChatHintResult.failed() => const LessonChatHintResult._(
        status: LessonChatHintStatus.failed,
        message: 'Could not get a hint. Please try again.',
      );
}

class CreateLessonSessionMessageRequest {
  const CreateLessonSessionMessageRequest({
    required this.role,
    required this.text,
    required this.source,
    required this.turnNumber,
    required this.isValidLessonTurn,
    required this.studyLanguage,
  });

  final String role;
  final String text;
  final String source;
  final int turnNumber;
  final bool isValidLessonTurn;
  final String studyLanguage;

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        'source': source,
        'turnNumber': turnNumber,
        'isValidLessonTurn': isValidLessonTurn,
        'studyLanguage': studyLanguage,
        'transcriptConfidence': null,
        'audioDurationMs': null,
      };
}

class LessonFeedbackResponse {
  const LessonFeedbackResponse({
    required this.shortText,
    required this.correctedVersion,
    required this.grammarTip,
    required this.vocabularyTip,
    required this.cultureTip,
    required this.naturalVersion,
  });

  final String shortText;
  final String correctedVersion;
  final String grammarTip;
  final String vocabularyTip;
  final String cultureTip;
  final String naturalVersion;

  factory LessonFeedbackResponse.fromJson(Map<String, dynamic> json) {
    final shortText = _string(json, 'shortText').trim();
    if (shortText.isEmpty) {
      throw const FormatException('Invalid feedback response.');
    }
    return LessonFeedbackResponse(
      shortText: shortText,
      correctedVersion: _string(json, 'correctedVersion').trim(),
      grammarTip: _string(json, 'grammarTip').trim(),
      vocabularyTip: _string(json, 'vocabularyTip').trim(),
      cultureTip: _string(json, 'cultureTip').trim(),
      naturalVersion: _string(json, 'naturalVersion').trim(),
    );
  }
}

enum LessonFeedbackStatus {
  success,
  authRequired,
  sessionEnded,
  validation,
  temporarilyUnavailable,
  unavailable,
  failed
}

class LessonFeedbackResult {
  const LessonFeedbackResult._(this.status, this.message, [this.feedback]);
  final LessonFeedbackStatus status;
  final String message;
  final LessonFeedbackResponse? feedback;
  bool get isSuccess => status == LessonFeedbackStatus.success;
  factory LessonFeedbackResult.success(LessonFeedbackResponse value) =>
      LessonFeedbackResult._(
          LessonFeedbackStatus.success, 'Feedback ready.', value);
  factory LessonFeedbackResult.authRequired() => const LessonFeedbackResult._(
      LessonFeedbackStatus.authRequired,
      'Please sign in again to continue the lesson.');
  factory LessonFeedbackResult.sessionEnded() => const LessonFeedbackResult._(
      LessonFeedbackStatus.sessionEnded, 'This lesson has already ended.');
  factory LessonFeedbackResult.validation() => const LessonFeedbackResult._(
      LessonFeedbackStatus.validation,
      'Feedback is not available for this message.');
  factory LessonFeedbackResult.temporarilyUnavailable() =>
      const LessonFeedbackResult._(LessonFeedbackStatus.temporarilyUnavailable,
          'Feedback is temporarily unavailable. Please try again shortly.');
  factory LessonFeedbackResult.unavailable() => const LessonFeedbackResult._(
      LessonFeedbackStatus.unavailable,
      'Feedback is unavailable right now. Please try again.');
  factory LessonFeedbackResult.failed() => const LessonFeedbackResult._(
      LessonFeedbackStatus.failed, 'Could not get feedback. Please try again.');
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is String ? value : '';
}

bool _bool(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is bool ? value : false;
}
