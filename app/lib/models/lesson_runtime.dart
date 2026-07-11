class LessonRuntimeScenario {
  const LessonRuntimeScenario({
    required this.id,
    required this.metadata,
    required this.lessonSetup,
    required this.learningGoal,
    required this.situation,
    required this.targetLanguage,
    required this.levelProfiles,
    required this.conversationFlow,
    required this.roleplayBeats,
    required this.reciprocalQuestionHandling,
    required this.expectedScenarioProgression,
    required this.aiTutorPromptInstructions,
    required this.promptTemplates,
    required this.controlledVariation,
    required this.hintRules,
    required this.runtimeContent,
  });

  final String id;
  final LessonRuntimeMetadata metadata;
  final LessonRuntimeSetup lessonSetup;
  final LessonRuntimeLearningGoal learningGoal;
  final LessonRuntimeSituation situation;
  final LessonRuntimeTargetLanguage targetLanguage;
  final Map<String, LessonRuntimeLevelProfile> levelProfiles;
  final LessonRuntimeConversationFlow conversationFlow;
  final List<LessonRuntimeRoleplayBeat> roleplayBeats;
  final LessonRuntimeReciprocalQuestionHandling reciprocalQuestionHandling;
  final List<String> expectedScenarioProgression;
  final List<String> aiTutorPromptInstructions;
  final Map<String, String> promptTemplates;
  final LessonRuntimeControlledVariation controlledVariation;
  final LessonRuntimeHintRules hintRules;
  final LessonRuntimeContent runtimeContent;

  factory LessonRuntimeScenario.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeScenario(
        id: _string(json, 'id'),
        metadata: LessonRuntimeMetadata.fromJson(_object(json, 'metadata')),
        lessonSetup: LessonRuntimeSetup.fromJson(_object(json, 'lessonSetup')),
        learningGoal:
            LessonRuntimeLearningGoal.fromJson(_object(json, 'learningGoal')),
        situation: LessonRuntimeSituation.fromJson(_object(json, 'situation')),
        targetLanguage: LessonRuntimeTargetLanguage.fromJson(
            _object(json, 'targetLanguage')),
        levelProfiles: _levelProfiles(_object(json, 'levelProfiles')),
        conversationFlow: LessonRuntimeConversationFlow.fromJson(
          _object(json, 'conversationFlow'),
        ),
        roleplayBeats: _list(_value(json, 'roleplayBeats'))
            .map((value) => LessonRuntimeRoleplayBeat.fromJson(_map(value)))
            .toList(growable: false),
        reciprocalQuestionHandling:
            LessonRuntimeReciprocalQuestionHandling.fromJson(
          _object(json, 'reciprocalQuestionHandling'),
        ),
        expectedScenarioProgression:
            _stringList(_value(json, 'expectedScenarioProgression')),
        aiTutorPromptInstructions:
            _stringList(_value(json, 'aiTutorPromptInstructions')),
        promptTemplates: _stringMap(_value(json, 'promptTemplates')),
        controlledVariation: LessonRuntimeControlledVariation.fromJson(
          _object(json, 'controlledVariation'),
        ),
        hintRules: LessonRuntimeHintRules.fromJson(_object(json, 'hintRules')),
        runtimeContent:
            LessonRuntimeContent.fromJson(_object(json, 'runtimeContent')),
      );

  LessonRuntimeLevelProfile levelProfileFor(String level) =>
      levelProfiles[level] ?? const LessonRuntimeLevelProfile.empty();
}

class LessonRuntimeMetadata {
  const LessonRuntimeMetadata({
    required this.topic,
    required this.subtopic,
    required this.lessonType,
  });

  final String topic;
  final String subtopic;
  final String lessonType;

  factory LessonRuntimeMetadata.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeMetadata(
        topic: _string(json, 'topic'),
        subtopic: _string(json, 'subtopic'),
        lessonType: _string(json, 'lessonType'),
      );
}

class LessonRuntimeSetup {
  const LessonRuntimeSetup({required this.setupMessage});

  final String setupMessage;

  factory LessonRuntimeSetup.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeSetup(setupMessage: _string(json, 'setupMessage'));
}

class LessonRuntimeLearningGoal {
  const LessonRuntimeLearningGoal({required this.goal});

  final String goal;

  factory LessonRuntimeLearningGoal.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeLearningGoal(goal: _string(json, 'goal'));
}

class LessonRuntimeSituation {
  const LessonRuntimeSituation({required this.description});

  final String description;

  factory LessonRuntimeSituation.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeSituation(description: _string(json, 'description'));
}

class LessonRuntimeTargetLanguage {
  const LessonRuntimeTargetLanguage({
    required this.keyPhrases,
    required this.grammarFocus,
  });

  final List<String> keyPhrases;
  final List<String> grammarFocus;

  factory LessonRuntimeTargetLanguage.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeTargetLanguage(
        keyPhrases: _stringList(_value(json, 'keyPhrases')),
        grammarFocus: _stringList(_value(json, 'grammarFocus')),
      );
}

class LessonRuntimeLevelProfile {
  const LessonRuntimeLevelProfile({
    required this.difficultyNotes,
    required this.tutorLanguageStyle,
    required this.expectedUserResponse,
    required this.feedbackStrictness,
    required this.hintStrategy,
    required this.correctionPriority,
    required this.conversationDepth,
    required this.exampleGoodAnswer,
    required this.exampleStretchAnswer,
    required this.addedKeyPhrases,
    required this.addedUsefulConstructions,
    required this.addedGrammarFocus,
    required this.softWrapUpAfterUserTurn,
    required this.finalMessageAtUserTurn,
  });

  const LessonRuntimeLevelProfile.empty()
      : difficultyNotes = '',
        tutorLanguageStyle = '',
        expectedUserResponse = '',
        feedbackStrictness = '',
        hintStrategy = '',
        correctionPriority = '',
        conversationDepth = '',
        exampleGoodAnswer = '',
        exampleStretchAnswer = '',
        addedKeyPhrases = const [],
        addedUsefulConstructions = const [],
        addedGrammarFocus = const [],
        softWrapUpAfterUserTurn = 0,
        finalMessageAtUserTurn = 0;

  final String difficultyNotes;
  final String tutorLanguageStyle;
  final String expectedUserResponse;
  final String feedbackStrictness;
  final String hintStrategy;
  final String correctionPriority;
  final String conversationDepth;
  final String exampleGoodAnswer;
  final String exampleStretchAnswer;
  final List<String> addedKeyPhrases;
  final List<String> addedUsefulConstructions;
  final List<String> addedGrammarFocus;
  final int softWrapUpAfterUserTurn;
  final int finalMessageAtUserTurn;

  factory LessonRuntimeLevelProfile.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeLevelProfile(
        difficultyNotes: _string(json, 'difficultyNotes'),
        tutorLanguageStyle: _string(json, 'tutorLanguageStyle'),
        expectedUserResponse: _string(json, 'expectedUserResponse'),
        feedbackStrictness: _string(json, 'feedbackStrictness'),
        hintStrategy: _string(json, 'hintStrategy'),
        correctionPriority: _string(json, 'correctionPriority'),
        conversationDepth: _string(json, 'conversationDepth'),
        exampleGoodAnswer: _string(json, 'exampleGoodAnswer'),
        exampleStretchAnswer: _string(json, 'exampleStretchAnswer'),
        addedKeyPhrases: _stringList(_value(json, 'addedKeyPhrases')),
        addedUsefulConstructions:
            _stringList(_value(json, 'addedUsefulConstructions')),
        addedGrammarFocus: _stringList(_value(json, 'addedGrammarFocus')),
        softWrapUpAfterUserTurn: _int(json, 'softWrapUpAfterUserTurn'),
        finalMessageAtUserTurn: _int(json, 'finalMessageAtUserTurn'),
      );
}

class LessonRuntimeConversationFlow {
  const LessonRuntimeConversationFlow({
    required this.opening,
    required this.firstUserTask,
    required this.guidedPracticeFollowUpQuestions,
    required this.variationOrComplication,
    required this.correctionMoment,
    required this.wrapUpMessage,
    required this.finalMessage,
    required this.wrapUpIntent,
    required this.finalMessageIntent,
  });

  final String opening;
  final String firstUserTask;
  final List<String> guidedPracticeFollowUpQuestions;
  final String variationOrComplication;
  final String correctionMoment;
  final String wrapUpMessage;
  final String finalMessage;
  final String wrapUpIntent;
  final String finalMessageIntent;

  factory LessonRuntimeConversationFlow.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeConversationFlow(
        opening: _string(json, 'opening'),
        firstUserTask: _string(json, 'firstUserTask'),
        guidedPracticeFollowUpQuestions:
            _stringList(_value(json, 'guidedPracticeFollowUpQuestions')),
        variationOrComplication: _string(json, 'variationOrComplication'),
        correctionMoment: _string(json, 'correctionMoment'),
        wrapUpMessage: _string(json, 'wrapUpMessage'),
        finalMessage: _string(json, 'finalMessage'),
        wrapUpIntent: _string(json, 'wrapUpIntent'),
        finalMessageIntent: _string(json, 'finalMessageIntent'),
      );
}

class LessonRuntimeRoleplayBeat {
  const LessonRuntimeRoleplayBeat({
    required this.id,
    required this.intent,
  });

  final String id;
  final String intent;

  factory LessonRuntimeRoleplayBeat.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeRoleplayBeat(
        id: _string(json, 'id'),
        intent: _string(json, 'intent'),
      );
}

class LessonRuntimeReciprocalQuestionHandling {
  const LessonRuntimeReciprocalQuestionHandling({
    required this.ifUserAsksTutorName,
    required this.ifUserAsksSimplePersonalQuestion,
    required this.mustNotIgnoreUserQuestion,
    required this.mustNotRefuseScenarioCompatibleQuestions,
  });

  final String ifUserAsksTutorName;
  final String ifUserAsksSimplePersonalQuestion;
  final bool mustNotIgnoreUserQuestion;
  final bool mustNotRefuseScenarioCompatibleQuestions;

  factory LessonRuntimeReciprocalQuestionHandling.fromJson(
    Map<String, dynamic> json,
  ) =>
      LessonRuntimeReciprocalQuestionHandling(
        ifUserAsksTutorName: _string(json, 'ifUserAsksTutorName'),
        ifUserAsksSimplePersonalQuestion:
            _string(json, 'ifUserAsksSimplePersonalQuestion'),
        mustNotIgnoreUserQuestion: _bool(json, 'mustNotIgnoreUserQuestion'),
        mustNotRefuseScenarioCompatibleQuestions:
            _bool(json, 'mustNotRefuseScenarioCompatibleQuestions'),
      );
}

class LessonRuntimeContent {
  const LessonRuntimeContent({
    required this.contentPackSlug,
    required this.versionNumber,
    required this.snapshotHash,
    required this.fallbackUsed,
    required this.scenarioKey,
    required this.resolvedLevelId,
    required this.softWrapUpAfterUserTurn,
    required this.finalMessageAtUserTurn,
    required this.lessonPhase,
    required this.hasWrapUpStarted,
    required this.effectiveRuntimeSource,
  });

  final String contentPackSlug;
  final int? versionNumber;
  final String snapshotHash;
  final bool fallbackUsed;
  final String scenarioKey;
  final String resolvedLevelId;
  final int softWrapUpAfterUserTurn;
  final int finalMessageAtUserTurn;
  final String lessonPhase;
  final bool hasWrapUpStarted;
  final String effectiveRuntimeSource;

  factory LessonRuntimeContent.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeContent(
        contentPackSlug: _string(json, 'contentPackSlug'),
        versionNumber: _nullableInt(json, 'versionNumber') ??
            _nullableInt(json, 'publishedVersionNumber'),
        snapshotHash: _string(json, 'snapshotHash'),
        fallbackUsed: _bool(json, 'fallbackUsed'),
        scenarioKey: _string(json, 'scenarioKey'),
        resolvedLevelId: _string(json, 'resolvedLevelId'),
        softWrapUpAfterUserTurn: _int(json, 'softWrapUpAfterUserTurn'),
        finalMessageAtUserTurn: _int(json, 'finalMessageAtUserTurn'),
        lessonPhase: _string(json, 'lessonPhase'),
        hasWrapUpStarted: _bool(json, 'hasWrapUpStarted'),
        effectiveRuntimeSource: _string(json, 'effectiveRuntimeSource'),
      );
}

class LessonRuntimeControlledVariation {
  const LessonRuntimeControlledVariation({
    required this.contextVariants,
  });

  final List<LessonRuntimeContextVariant> contextVariants;

  factory LessonRuntimeControlledVariation.fromJson(
          Map<String, dynamic> json) =>
      LessonRuntimeControlledVariation(
        contextVariants: _list(_value(json, 'contextVariants'))
            .map((value) => LessonRuntimeContextVariant.fromJson(_map(value)))
            .where((value) => value.title.isNotEmpty)
            .toList(growable: false),
      );
}

class LessonRuntimeHintRules {
  const LessonRuntimeHintRules({required this.exampleHint});

  final String exampleHint;

  factory LessonRuntimeHintRules.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeHintRules(exampleHint: _string(json, 'exampleHint'));
}

class LessonRuntimeContextVariant {
  const LessonRuntimeContextVariant({
    required this.id,
    required this.title,
    required this.localizedTitle,
    required this.openingLine,
    required this.contextConfirmationLine,
    required this.openingIntent,
  });

  final String id;
  final String title;
  final String localizedTitle;
  final String openingLine;
  final String contextConfirmationLine;
  final String openingIntent;

  factory LessonRuntimeContextVariant.fromJson(Map<String, dynamic> json) =>
      LessonRuntimeContextVariant(
        id: _string(json, 'id'),
        title: _string(json, 'title'),
        localizedTitle: _string(json, 'localizedTitle'),
        openingLine: _string(json, 'openingLine'),
        contextConfirmationLine: _string(json, 'contextConfirmationLine'),
        openingIntent: _string(json, 'openingIntent'),
      );
}

Map<String, LessonRuntimeLevelProfile> _levelProfiles(
    Map<String, dynamic> json) {
  return json.map(
    (key, value) => MapEntry(
      key,
      LessonRuntimeLevelProfile.fromJson(_map(value)),
    ),
  );
}

Object? _value(Map<String, dynamic> json, String key) => json[key];

Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is Map<String, dynamic> ? value : const {};
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : const {};

List<Object?> _list(Object? value) => value is List ? value : const [];

List<String> _stringList(Object? value) => _list(value)
    .whereType<String>()
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toList(growable: false);

Map<String, String> _stringMap(Object? value) {
  if (value is! Map<String, dynamic>) return const {};
  final result = <String, String>{};
  value.forEach((key, entry) {
    if (entry is String) {
      result[key] = entry;
    }
  });
  return result;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is String ? value : '';
}

int _int(Map<String, dynamic> json, String key) => _nullableInt(json, key) ?? 0;

int? _nullableInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is double) return value.toInt();
  return null;
}

bool _bool(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is bool ? value : false;
}
