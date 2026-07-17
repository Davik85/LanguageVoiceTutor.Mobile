enum FeedbackReportCategory { suggestion, appIssue, aiResponse }

extension FeedbackReportCategoryWire on FeedbackReportCategory {
  String get value => switch (this) {
        FeedbackReportCategory.suggestion => 'suggestion',
        FeedbackReportCategory.appIssue => 'app_issue',
        FeedbackReportCategory.aiResponse => 'ai_response',
      };

  String get label => switch (this) {
        FeedbackReportCategory.suggestion => 'Suggestion',
        FeedbackReportCategory.appIssue => 'App problem',
        FeedbackReportCategory.aiResponse => 'AI response',
      };
}

class FeedbackReportRequest {
  const FeedbackReportRequest(
      {required this.category,
      required this.message,
      this.reportedAiText,
      required this.clientPlatform,
      required this.clientVersion});
  final FeedbackReportCategory category;
  final String message;
  final String? reportedAiText;
  final String clientPlatform;
  final String clientVersion;
  Map<String, dynamic> toJson() => {
        'category': category.value,
        'message': message.trim(),
        'reportedAiText': reportedAiText?.trim(),
        'clientPlatform': clientPlatform,
        'clientVersion': clientVersion,
      };
}

enum FeedbackReportSubmitStatus {
  success,
  authenticationRequired,
  temporaryFailure,
  validationFailure
}

class FeedbackReportSubmitResult {
  const FeedbackReportSubmitResult._(this.status, this.message);
  final FeedbackReportSubmitStatus status;
  final String message;
  factory FeedbackReportSubmitResult.success() =>
      const FeedbackReportSubmitResult._(FeedbackReportSubmitStatus.success,
          'Thank you. Your message has been received.');
  factory FeedbackReportSubmitResult.authenticationRequired() =>
      const FeedbackReportSubmitResult._(
          FeedbackReportSubmitStatus.authenticationRequired,
          'Please sign in again.');
  factory FeedbackReportSubmitResult.temporaryFailure() =>
      const FeedbackReportSubmitResult._(
          FeedbackReportSubmitStatus.temporaryFailure,
          'Feedback is temporarily unavailable. Please try again.');
  factory FeedbackReportSubmitResult.validationFailure() =>
      const FeedbackReportSubmitResult._(
          FeedbackReportSubmitStatus.validationFailure,
          'Please check your message and try again.');
}
