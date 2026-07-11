import 'dart:typed_data';

class AudioSpeechRequest {
  const AudioSpeechRequest({
    required this.text,
    required this.speechVoice,
    required this.speechSpeed,
    required this.targetLanguageId,
    required this.targetLanguageName,
    required this.targetLanguageNativeName,
    required this.targetLanguageCode,
    required this.backendSessionId,
  });

  static const purpose = 'lesson_chat_tts';

  final String text;
  final String speechVoice;
  final double speechSpeed;
  final String targetLanguageId;
  final String targetLanguageName;
  final String targetLanguageNativeName;
  final String targetLanguageCode;
  final String backendSessionId;

  Map<String, dynamic> toJson() => {
        'text': text,
        'purpose': purpose,
        'speechVoice': speechVoice,
        'speechSpeed': speechSpeed,
        'targetLanguageId': targetLanguageId,
        'targetLanguageName': targetLanguageName,
        'targetLanguageNativeName': targetLanguageNativeName,
        'targetLanguageCode': targetLanguageCode,
        'backendSessionId': backendSessionId,
      };
}

enum AudioSpeechStatus {
  success,
  authenticationRequired,
  sessionEnded,
  temporarilyUnavailable,
  ordinaryFailure,
}

class AudioSpeechResult {
  const AudioSpeechResult._(this.status, this.message, [this.audioBytes]);

  final AudioSpeechStatus status;
  final String message;
  final Uint8List? audioBytes;
  bool get isSuccess => status == AudioSpeechStatus.success;

  factory AudioSpeechResult.success(Uint8List bytes) =>
      AudioSpeechResult._(AudioSpeechStatus.success, '', bytes);
  factory AudioSpeechResult.authenticationRequired() =>
      const AudioSpeechResult._(AudioSpeechStatus.authenticationRequired,
          'Please sign in again to play voice.');
  factory AudioSpeechResult.sessionEnded() => const AudioSpeechResult._(
      AudioSpeechStatus.sessionEnded, 'This lesson has already ended.');
  factory AudioSpeechResult.temporarilyUnavailable() =>
      const AudioSpeechResult._(AudioSpeechStatus.temporarilyUnavailable,
          'Voice is temporarily unavailable. Please try again shortly.');
  factory AudioSpeechResult.failed() => const AudioSpeechResult._(
      AudioSpeechStatus.ordinaryFailure,
      'Could not play voice. Please try again.');
}
