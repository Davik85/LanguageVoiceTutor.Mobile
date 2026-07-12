class AudioTranscriptionRequest {
  const AudioTranscriptionRequest({
    required this.audioFilePath,
    required this.targetLanguageId,
    required this.targetLanguageName,
    required this.targetLanguageNativeName,
    required this.targetLanguageCode,
    required this.lessonPhase,
    required this.transcriptionContext,
    required this.backendSessionId,
  });

  final String audioFilePath;
  final String targetLanguageId;
  final String targetLanguageName;
  final String targetLanguageNativeName;
  final String targetLanguageCode;
  final String lessonPhase;
  final String transcriptionContext;
  final String backendSessionId;

  Map<String, String> get fields => {
        'targetLanguageId': targetLanguageId,
        'targetLanguageName': targetLanguageName,
        'targetLanguageNativeName': targetLanguageNativeName,
        'targetLanguageCode': targetLanguageCode,
        'lessonPhase': lessonPhase,
        'transcriptionContext': transcriptionContext,
        'backendSessionId': backendSessionId,
      };
}

class AudioTranscriptionResponse {
  const AudioTranscriptionResponse(this.text);

  final String text;

  factory AudioTranscriptionResponse.fromJson(Map<String, dynamic> json) {
    final text = json['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const FormatException('Missing transcription text.');
    }
    return AudioTranscriptionResponse(text.trim());
  }
}

enum AudioTranscriptionStatus {
  success,
  authenticationRequired,
  sessionEnded,
  rateLimited,
  serviceUnavailable,
  timeout,
  networkFailure,
  malformedResponse,
  invalidRecording,
  ordinaryFailure,
}

class AudioTranscriptionResult {
  const AudioTranscriptionResult._(this.status, this.message,
      [this.text, this.retryAfterSeconds]);

  final AudioTranscriptionStatus status;
  final String message;
  final String? text;
  final int? retryAfterSeconds;
  bool get isSuccess => status == AudioTranscriptionStatus.success;

  factory AudioTranscriptionResult.success(String text) =>
      AudioTranscriptionResult._(AudioTranscriptionStatus.success, '', text);
  factory AudioTranscriptionResult.authenticationRequired() =>
      const AudioTranscriptionResult._(
        AudioTranscriptionStatus.authenticationRequired,
        'Please sign in again to use recording.',
      );
  factory AudioTranscriptionResult.sessionEnded() =>
      const AudioTranscriptionResult._(
        AudioTranscriptionStatus.sessionEnded,
        'This lesson has already ended.',
      );
  factory AudioTranscriptionResult.rateLimited([int? retryAfterSeconds]) =>
      AudioTranscriptionResult._(
        AudioTranscriptionStatus.rateLimited,
        'Transcription is temporarily unavailable. Please try again shortly.',
        null,
        retryAfterSeconds,
      );
  factory AudioTranscriptionResult.serviceUnavailable() =>
      const AudioTranscriptionResult._(
        AudioTranscriptionStatus.serviceUnavailable,
        'Transcription is temporarily unavailable. Please try again shortly.',
      );
  factory AudioTranscriptionResult.timeout() =>
      const AudioTranscriptionResult._(
        AudioTranscriptionStatus.timeout,
        'The recording request timed out. Please try again.',
      );
  factory AudioTranscriptionResult.networkFailure() =>
      const AudioTranscriptionResult._(
        AudioTranscriptionStatus.networkFailure,
        'Connection failed while transcribing. Please try again.',
      );
  factory AudioTranscriptionResult.malformedResponse() =>
      const AudioTranscriptionResult._(
        AudioTranscriptionStatus.malformedResponse,
        'The transcription response was invalid. Please try again.',
      );
  factory AudioTranscriptionResult.invalidRecording(String message) =>
      AudioTranscriptionResult._(
          AudioTranscriptionStatus.invalidRecording, message);
  factory AudioTranscriptionResult.failed() => const AudioTranscriptionResult._(
        AudioTranscriptionStatus.ordinaryFailure,
        'Could not transcribe that recording. Please try again.',
      );
}
