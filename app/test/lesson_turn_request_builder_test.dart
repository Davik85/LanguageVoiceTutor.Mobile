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
      'A1': {'softWrapUpAfterUserTurn': 3, 'finalMessageAtUserTurn': 4}
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

  test('does not fabricate a missing backend lesson phase', () {
    final request = const LessonTurnRequestBuilder().build(
      scenario: scenario,
      settings: settings,
      selectedLevel: 'A1',
      userMessage: 'Hello',
      lastBotMessage: '',
      learnerTurnCount: 1,
      recentMessages: const [],
      backendSessionId: 'session',
      context: const LessonContextSelection(
          isContextSelectionTurn: false,
          isKnownCmsContext: false,
          isCustomContext: true,
          selectedContextTitle: 'Custom'),
    );
    expect(request.lessonPhase, isEmpty);
  });
}
