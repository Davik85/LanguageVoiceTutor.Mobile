import '../models/audio_transcription.dart';
import '../models/lesson_runtime.dart';
import '../models/study_language_definition.dart';
import '../models/user_settings.dart';
import 'transcription_context_builder.dart';

class MobileTranscriptionRequestBuilder {
  const MobileTranscriptionRequestBuilder();

  AudioTranscriptionRequest build({
    required String audioFilePath,
    required String backendSessionId,
    required UserSettings settings,
    required LessonRuntimeScenario? scenario,
    required String selectedContextTitle,
  }) {
    final studyLanguage =
        StudyLanguageDefinitions.resolve(settings.studyLanguage);
    return AudioTranscriptionRequest(
      audioFilePath: audioFilePath,
      targetLanguageId: studyLanguage.id,
      targetLanguageName: studyLanguage.englishName,
      targetLanguageNativeName: studyLanguage.nativeName,
      targetLanguageCode: studyLanguage.transcriptionLanguageCode,
      lessonPhase: scenario?.runtimeContent.lessonPhase.trim() ?? '',
      transcriptionContext: TranscriptionContextBuilder.build(
        scenario: scenario,
        studyLanguage: studyLanguage,
        selectedContextTitle: selectedContextTitle,
      ),
      backendSessionId: backendSessionId,
    );
  }
}
