import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/audio_speech.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/services/tutor_speech_request_builder.dart';

void main() {
  test(
      'speech requests normalize stale direct settings without changing speed or purpose',
      () {
    const settings = UserSettings(
        nativeLanguage: 'en',
        studyLanguage: 'es',
        explanationLanguage: 'en',
        speechVoice: 'onyx',
        speechSpeed: 0.9,
        conversationModeEnabled: true,
        selectedTutorId: 'david',
        currentLevel: 'B2');
    for (final purpose in [
      AudioSpeechPurpose.lessonChatTts,
      AudioSpeechPurpose.conversationModeTts
    ]) {
      final request = const TutorSpeechRequestBuilder().build(
          text: 'Reply',
          settings: settings,
          backendSessionId: 'session',
          purpose: purpose);
      expect(request.speechVoice, 'cedar');
      expect(request.speechSpeed, 0.9);
      expect(request.purpose, purpose);
    }
  });

  const builder = TutorSpeechRequestBuilder();

  AudioSpeechRequest build(String language, AudioSpeechPurpose purpose) =>
      builder.build(
        text: 'Tutor reply',
        settings: UserSettings(
          nativeLanguage: 'hu',
          studyLanguage: language,
          explanationLanguage: 'de',
          speechVoice: 'coral',
          speechSpeed: 0.9,
          conversationModeEnabled: true,
          selectedTutorId: 'lana',
          currentLevel: 'A1',
        ),
        backendSessionId: 'session',
        purpose: purpose,
      );

  test('Lesson Chat TTS uses exact English, French, Spanish, and German fields',
      () {
    const cases = {
      'en': ['en', 'English', 'English', 'en'],
      'fr': ['fr', 'French', 'Français', 'fr'],
      'es': ['es', 'Spanish', 'Español', 'es'],
      'de': ['de', 'German', 'Deutsch', 'de'],
    };
    for (final entry in cases.entries) {
      final request = build(entry.key, AudioSpeechPurpose.lessonChatTts);
      expect([
        request.targetLanguageId,
        request.targetLanguageName,
        request.targetLanguageNativeName,
        request.targetLanguageCode,
      ], entry.value);
      expect(request.purpose, AudioSpeechPurpose.lessonChatTts);
    }
  });

  test('Conversation TTS uses exact Portuguese and Italian fields', () {
    const cases = {
      'pt': ['pt', 'Portuguese', 'Português', 'pt'],
      'it': ['it', 'Italian', 'Italiano', 'it'],
    };
    for (final entry in cases.entries) {
      final request = build(entry.key, AudioSpeechPurpose.conversationModeTts);
      expect([
        request.targetLanguageId,
        request.targetLanguageName,
        request.targetLanguageNativeName,
        request.targetLanguageCode,
      ], entry.value);
      expect(request.purpose, AudioSpeechPurpose.conversationModeTts);
    }
  });
}
