import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/study_language_definition.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/services/lesson_context_selection_resolver.dart';
import 'package:language_voice_tutor_mobile/services/mobile_transcription_request_builder.dart';

void main() {
  const builder = MobileTranscriptionRequestBuilder();

  UserSettings settings(
    String studyLanguage, {
    String nativeLanguage = 'hu',
    String explanationLanguage = 'de',
  }) =>
      UserSettings(
        nativeLanguage: nativeLanguage,
        studyLanguage: studyLanguage,
        explanationLanguage: explanationLanguage,
        speechVoice: '',
        speechSpeed: 1,
        conversationModeEnabled: true,
        selectedTutorId: 'lana',
      );

  LessonRuntimeScenario scenario({
    List<String> titles = const [
      'Runtime choice alpha',
      'Runtime choice beta',
      'Runtime choice gamma',
      'Runtime choice outside the visible limit',
    ],
    String lessonPhase = 'scenario_selection',
  }) =>
      LessonRuntimeScenario.fromJson({
        'id': 'runtime-scenario',
        'metadata': {},
        'lessonSetup': {},
        'learningGoal': {},
        'situation': {},
        'targetLanguage': {},
        'levelProfiles': {},
        'conversationFlow': {},
        'roleplayBeats': [],
        'reciprocalQuestionHandling': {},
        'expectedScenarioProgression': [],
        'aiTutorPromptInstructions': [],
        'promptTemplates': {},
        'controlledVariation': {
          'contextVariants': titles.indexed
              .map((entry) => {
                    'id': 'runtime-${entry.$1}',
                    'title': entry.$2,
                  })
              .toList(),
        },
        'hintRules': {},
        'runtimeContent': {'lessonPhase': lessonPhase},
      });

  test('supported study languages resolve explicit transcription metadata', () {
    const expected = {
      'en': ('English', 'English', 'en'),
      'fr': ('French', 'Français', 'fr'),
      'de': ('German', 'Deutsch', 'de'),
      'pt': ('Portuguese', 'Português', 'pt'),
      'es': ('Spanish', 'Español', 'es'),
      'it': ('Italian', 'Italiano', 'it'),
    };

    for (final entry in expected.entries) {
      final definition = StudyLanguageDefinitions.resolve(entry.key);
      expect(definition.id, entry.key, reason: entry.key);
      expect(definition.englishName, entry.value.$1, reason: entry.key);
      expect(definition.nativeName, entry.value.$2, reason: entry.key);
      expect(definition.transcriptionLanguageCode, entry.value.$3,
          reason: entry.key);
    }
  });

  test('native and explanation languages do not alter transcription language',
      () {
    final first = builder.build(
      audioFilePath: 'first.wav',
      backendSessionId: 'session',
      settings: settings('fr', nativeLanguage: 'hu', explanationLanguage: 'de'),
      scenario: null,
      selectedContextTitle: '',
    );
    final second = builder.build(
      audioFilePath: 'second.wav',
      backendSessionId: 'session',
      settings: settings('fr', nativeLanguage: 'ja', explanationLanguage: 'es'),
      scenario: null,
      selectedContextTitle: '',
    );

    expect(first.targetLanguageId, 'fr');
    expect(first.targetLanguageName, 'French');
    expect(first.targetLanguageNativeName, 'Français');
    expect(first.targetLanguageCode, 'fr');
    expect(second.targetLanguageId, first.targetLanguageId);
    expect(second.targetLanguageName, first.targetLanguageName);
    expect(second.targetLanguageNativeName, first.targetLanguageNativeName);
    expect(second.targetLanguageCode, first.targetLanguageCode);
  });

  test('initial selection context uses only current visible runtime candidates',
      () {
    final request = builder.build(
      audioFilePath: 'lesson.wav',
      backendSessionId: 'session',
      settings: settings('en'),
      scenario: scenario(),
      selectedContextTitle: '',
    );

    expect(request.lessonPhase, 'scenario_selection');
    expect(request.transcriptionContext, contains('speaking in English'));
    expect(request.transcriptionContext, contains('Transcribe exactly'));
    expect(request.transcriptionContext, contains('Do not translate'));
    expect(request.transcriptionContext, contains('or paraphrase'));
    expect(request.transcriptionContext, contains('Runtime choice alpha'));
    expect(request.transcriptionContext, contains('Runtime choice beta'));
    expect(request.transcriptionContext, contains('Runtime choice gamma'));
    expect(request.transcriptionContext,
        isNot(contains('Runtime choice outside the visible limit')));
  });

  test('active roleplay context is the selected runtime context', () {
    final request = builder.build(
      audioFilePath: 'lesson.wav',
      backendSessionId: 'session',
      settings: settings('es'),
      scenario: scenario(lessonPhase: 'active_roleplay'),
      selectedContextTitle: 'Runtime selected context',
    );

    expect(request.lessonPhase, 'active_roleplay');
    expect(request.transcriptionContext,
        'Selected context: Runtime selected context');
  });

  test('Conversation mode and Lesson Chat share language and lesson context',
      () {
    final runtime = scenario(titles: const ['CMS-only candidate']);
    final lessonChat = builder.build(
      audioFilePath: 'lesson.wav',
      backendSessionId: 'session',
      settings: settings('pt'),
      scenario: runtime,
      selectedContextTitle: '',
    );
    final conversationMode = builder.build(
      audioFilePath: 'conversation.wav',
      backendSessionId: 'session',
      settings: settings('pt'),
      scenario: runtime,
      selectedContextTitle: '',
    );

    expect(conversationMode.targetLanguageId, lessonChat.targetLanguageId);
    expect(conversationMode.targetLanguageName, lessonChat.targetLanguageName);
    expect(conversationMode.targetLanguageNativeName,
        lessonChat.targetLanguageNativeName);
    expect(conversationMode.targetLanguageCode, lessonChat.targetLanguageCode);
    expect(conversationMode.lessonPhase, lessonChat.lessonPhase);
    expect(
        conversationMode.transcriptionContext, lessonChat.transcriptionContext);
    expect(
        conversationMode.transcriptionContext, contains('CMS-only candidate'));
  });

  test('missing runtime context is safely omitted', () {
    final request = builder.build(
      audioFilePath: 'lesson.wav',
      backendSessionId: 'session',
      settings: settings('it'),
      scenario: null,
      selectedContextTitle: '',
    );

    expect(request.lessonPhase, isEmpty);
    expect(request.transcriptionContext, isEmpty);
  });

  test('existing deterministic voice scenario resolution remains unchanged',
      () {
    final runtime = scenario(titles: const ['Runtime exact match']);
    final resolved = LessonContextSelectionResolver.resolve(
      scenario: runtime,
      learnerInput: 'Runtime exact match',
    );

    expect(resolved.isKnownCmsContext, isTrue);
    expect(resolved.selectedContextTitle, 'Runtime exact match');
  });
}
