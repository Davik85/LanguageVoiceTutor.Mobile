class TranslationRequest {
  const TranslationRequest({
    required this.text,
    required this.targetLanguage,
    required this.sourceLanguageId,
    required this.sourceLanguageName,
    required this.sourceLanguageNativeName,
    required this.sourceLanguageCode,
    required this.backendSessionId,
  });

  final String text;
  final String targetLanguage;
  final String sourceLanguageId;
  final String sourceLanguageName;
  final String sourceLanguageNativeName;
  final String sourceLanguageCode;
  final String backendSessionId;

  Map<String, dynamic> toJson() => {
        'text': text,
        'targetLanguage': targetLanguage,
        'sourceLanguageId': sourceLanguageId,
        'sourceLanguageName': sourceLanguageName,
        'sourceLanguageNativeName': sourceLanguageNativeName,
        'sourceLanguageCode': sourceLanguageCode,
        'backendSessionId': backendSessionId,
      };
}

class TranslationResponse {
  const TranslationResponse({required this.translatedText});

  final String translatedText;

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    final value = json['translatedText'];
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid translation response.');
    }
    return TranslationResponse(translatedText: value.trim());
  }
}

enum TranslationStatus {
  success,
  validation,
  authRequired,
  sessionEnded,
  temporarilyUnavailable,
  unavailable,
  failed,
}

class TranslationResult {
  const TranslationResult._({
    required this.status,
    required this.message,
    this.translation,
  });

  final TranslationStatus status;
  final String message;
  final TranslationResponse? translation;

  bool get isSuccess => status == TranslationStatus.success;

  factory TranslationResult.success(TranslationResponse translation) =>
      TranslationResult._(
        status: TranslationStatus.success,
        message: 'Translation ready.',
        translation: translation,
      );

  factory TranslationResult.validation() => const TranslationResult._(
        status: TranslationStatus.validation,
        message: 'This message cannot be translated.',
      );

  factory TranslationResult.authRequired() => const TranslationResult._(
        status: TranslationStatus.authRequired,
        message: 'Please sign in again to continue the lesson.',
      );

  factory TranslationResult.sessionEnded() => const TranslationResult._(
        status: TranslationStatus.sessionEnded,
        message: 'This lesson has already ended.',
      );

  factory TranslationResult.temporarilyUnavailable() =>
      const TranslationResult._(
        status: TranslationStatus.temporarilyUnavailable,
        message:
            'Translation is temporarily unavailable. Please try again shortly.',
      );

  factory TranslationResult.unavailable() => const TranslationResult._(
        status: TranslationStatus.unavailable,
        message: 'Translation is unavailable right now. Please try again.',
      );

  factory TranslationResult.failed() => const TranslationResult._(
        status: TranslationStatus.failed,
        message: 'Could not translate this message. Please try again.',
      );
}
