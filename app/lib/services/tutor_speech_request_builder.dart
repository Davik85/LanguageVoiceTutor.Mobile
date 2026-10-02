import '../models/audio_speech.dart';
import '../models/speech_voice_options.dart';
import '../models/study_language_definition.dart';
import '../models/user_settings.dart';

class TutorSpeechRequestBuilder {
  const TutorSpeechRequestBuilder();

  AudioSpeechRequest build({
    required String text,
    required UserSettings settings,
    required String backendSessionId,
    required AudioSpeechPurpose purpose,
  }) {
    final language = StudyLanguageDefinitions.resolve(settings.studyLanguage);
    return AudioSpeechRequest(
      text: text,
      speechVoice: SpeechVoiceOptions.resolve(settings.speechVoice,
          selectedTutorId: settings.selectedTutorId),
      speechSpeed: UserSettings.defaultSpeechSpeed,
      targetLanguageId: language.id,
      targetLanguageName: language.englishName,
      targetLanguageNativeName: language.nativeName,
      targetLanguageCode: language.transcriptionLanguageCode,
      backendSessionId: backendSessionId,
      purpose: purpose,
    );
  }
}
