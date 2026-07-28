import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_chat.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/services/lesson_context_selection_resolver.dart';
import 'package:language_voice_tutor_mobile/services/lesson_turn_request_builder.dart';

void main() {
  final scenario = LessonRuntimeScenario.fromJson({
    'id': 'published-scenario',
    'metadata': {
      'topic': 'Travel',
      'subtopic': 'Hotel',
      'lessonType': 'roleplay'
    },
    'lessonSetup': {},
    'learningGoal': {'goal': 'Book a room'},
    'situation': {},
    'targetLanguage': {
      'keyPhrases': ['room'],
      'grammarFocus': ['would like']
    },
    'levelProfiles': {
      'A1': {'softWrapUpAfterUserTurn': 10, 'finalMessageAtUserTurn': 15}
    },
    'conversationFlow': {'opening': 'Opening', 'firstUserTask': 'Answer'},
    'roleplayBeats': [],
    'reciprocalQuestionHandling': {},
    'expectedScenarioProgression': [],
    'aiTutorPromptInstructions': ['runtime-rule'],
    'promptTemplates': {'response': 'runtime-template'},
    'controlledVariation': {
      'contextVariants': [
        {
          'id': 'hotel',
          'title': 'At a hotel',
          'openingLine': 'Welcome {tutorName}',
          'contextConfirmationLine': 'Great'
        }
      ]
    },
    'hintRules': {},
    'runtimeContent': {
      'contentPackSlug': 'pack',
      'versionNumber': 7,
      'snapshotHash': 'abc',
      'fallbackUsed': false,
      'scenarioKey': 'published-scenario'
    },
    'tutorProfiles': [
      {'tutorId': 'lana', 'displayName': 'Runtime Lana'}
    ],
  });
  const settings = UserSettings(
      nativeLanguage: 'hu',
      studyLanguage: 'en',
      explanationLanguage: 'en',
      speechVoice: '',
      speechSpeed: 1,
      conversationModeEnabled: false,
      selectedTutorId: 'lana',
      currentLevel: 'A1');

  test('preserves selected context and runtime tutor data on later turns', () {
    final context = LessonContextSelectionResolver.resolve(
        scenario: scenario, learnerInput: '1');
    final later = LessonContextSelectionResolver.resolve(
        scenario: scenario,
        currentSelectedContextId: context.selectedContextId,
        currentSelectedContextTitle: context.selectedContextTitle,
        learnerInput: 'I need a room');
    final request = const LessonTurnRequestBuilder().build(
      scenario: scenario,
      settings: settings,
      selectedLevel: 'A1',
      userMessage: 'I need a room',
      lastBotMessage: 'Opening',
      learnerTurnCount: 1,
      lessonPhase: LessonLivePhase.activeRoleplay,
      hasWrapUpStarted: false,
      shouldStartWrappingUp: false,
      shouldEndLessonNow: false,
      recentMessages: const [
        LessonRecentConversationMessage(sender: 'Tutor', text: 'Opening')
      ],
      backendSessionId: 'session',
      context: later,
    );
    expect(request.selectedContextVariantId, 'hotel');
    expect(request.isContextSelectionTurn, isFalse);
    expect(request.backendSessionId, 'session');
    expect(request.tutorAvatarId, 'lana');
    expect(request.tutorDisplayName, 'Runtime Lana');
    expect(request.aiTutorPromptInstructions, ['runtime-rule']);
    expect(request.runtimeContentVersionNumber, 7);
  });

  test('uses explicitly supplied live lesson state instead of runtime snapshot',
      () {
    final request = const LessonTurnRequestBuilder().build(
      scenario: scenario,
      settings: settings,
      selectedLevel: 'A1',
      userMessage: 'Hello',
      lastBotMessage: '',
      learnerTurnCount: 1,
      lessonPhase: LessonLivePhase.wrapUp,
      hasWrapUpStarted: true,
      shouldStartWrappingUp: false,
      shouldEndLessonNow: false,
      recentMessages: const [],
      backendSessionId: 'session',
      context: const LessonContextSelection(
          isContextSelectionTurn: false,
          isKnownCmsContext: false,
          isCustomContext: true,
          selectedContextTitle: 'Custom'),
    );
    expect(request.lessonPhase, 'wrap_up');
    expect(request.hasWrapUpStarted, isTrue);
  });

  test('resolves level-aware bounded history limits', () {
    const builder = LessonTurnRequestBuilder();
    expect(
      builder.resolveHistoryMessageLimit(
        scenario: scenario,
        selectedLevel: 'A1',
      ),
      33,
    );

    final b2Scenario = LessonRuntimeScenario(
      id: scenario.id,
      metadata: scenario.metadata,
      lessonSetup: scenario.lessonSetup,
      learningGoal: scenario.learningGoal,
      situation: scenario.situation,
      targetLanguage: scenario.targetLanguage,
      levelProfiles: const {
        'B2': LessonRuntimeLevelProfile(
          difficultyNotes: '',
          tutorLanguageStyle: '',
          expectedUserResponse: '',
          feedbackStrictness: '',
          hintStrategy: '',
          correctionPriority: '',
          conversationDepth: '',
          exampleGoodAnswer: '',
          exampleStretchAnswer: '',
          addedKeyPhrases: [],
          addedUsefulConstructions: [],
          addedGrammarFocus: [],
          softWrapUpAfterUserTurn: 0,
          finalMessageAtUserTurn: 32,
        ),
      },
      conversationFlow: scenario.conversationFlow,
      roleplayBeats: scenario.roleplayBeats,
      reciprocalQuestionHandling: scenario.reciprocalQuestionHandling,
      expectedScenarioProgression: scenario.expectedScenarioProgression,
      aiTutorPromptInstructions: scenario.aiTutorPromptInstructions,
      promptTemplates: scenario.promptTemplates,
      controlledVariation: scenario.controlledVariation,
      hintRules: scenario.hintRules,
      runtimeContent: scenario.runtimeContent,
      tutorProfiles: scenario.tutorProfiles,
    );
    expect(
      builder.resolveHistoryMessageLimit(
        scenario: b2Scenario,
        selectedLevel: 'B2',
      ),
      67,
    );
  });

  test('all six study languages send exact centralized request metadata', () {
    const expected = <String, List<String>>{
      'en': ['en', 'English', 'English', 'en'],
      'fr': ['fr', 'French', 'Français', 'fr'],
      'de': ['de', 'German', 'Deutsch', 'de'],
      'pt': ['pt', 'Portuguese', 'Português', 'pt'],
      'es': ['es', 'Spanish', 'Español', 'es'],
      'it': ['it', 'Italian', 'Italiano', 'it'],
    };
    for (final entry in expected.entries) {
      final request = const LessonTurnRequestBuilder().build(
        scenario: scenario,
        settings: UserSettings(
          nativeLanguage: 'hu',
          studyLanguage: entry.key,
          explanationLanguage: 'de',
          speechVoice: '',
          speechSpeed: 1,
          conversationModeEnabled: false,
          selectedTutorId: 'lana',
          currentLevel: 'A1',
        ),
        selectedLevel: 'A1',
        userMessage: 'Hello',
        lastBotMessage: '',
        learnerTurnCount: 1,
        lessonPhase: LessonLivePhase.activeRoleplay,
        hasWrapUpStarted: false,
        shouldStartWrappingUp: false,
        shouldEndLessonNow: false,
        recentMessages: const [],
        backendSessionId: 'session',
        context: const LessonContextSelection(
          isContextSelectionTurn: false,
          isKnownCmsContext: false,
          isCustomContext: true,
          selectedContextTitle: 'Custom',
        ),
      );
      expect(
        [
          request.targetLanguageId,
          request.targetLanguageName,
          request.targetLanguageNativeName,
          request.targetLanguageCode,
        ],
        entry.value,
      );
    }
  });
}
