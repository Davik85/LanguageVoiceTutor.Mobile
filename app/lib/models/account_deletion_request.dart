class AccountDeletionRequest {
  const AccountDeletionRequest({
    required this.currentPassword,
    this.reason,
  });

  final String currentPassword;
  final String? reason;

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        if (reason != null && reason!.trim().isNotEmpty)
          'reason': reason!.trim(),
      };
}

class AccountDeletionRequestResponse {
  const AccountDeletionRequestResponse({
    required this.reportId,
    required this.status,
    required this.alreadyRequested,
  });

  final String reportId;
  final String status;
  final bool alreadyRequested;

  factory AccountDeletionRequestResponse.fromJson(Map<String, dynamic> json) {
    final reportId = json['reportId']?.toString().trim() ?? '';
    final status = json['status']?.toString().trim() ?? '';
    if (reportId.isEmpty ||
        status.isEmpty ||
        json['alreadyRequested'] is! bool) {
      throw const FormatException('Invalid account deletion response.');
    }
    return AccountDeletionRequestResponse(
      reportId: reportId,
      status: status,
      alreadyRequested: json['alreadyRequested'] as bool,
    );
  }
}

enum AccountDeletionRequestSubmitStatus {
  success,
  incorrectPassword,
  authenticationRequired,
  networkFailure,
  malformedResponse,
  failed,
}

class AccountDeletionRequestSubmitResult {
  const AccountDeletionRequestSubmitResult._(this.status, this.message,
      [this.response]);

  final AccountDeletionRequestSubmitStatus status;
  final String message;
  final AccountDeletionRequestResponse? response;

  factory AccountDeletionRequestSubmitResult.success(
          AccountDeletionRequestResponse response) =>
      AccountDeletionRequestSubmitResult._(
        AccountDeletionRequestSubmitStatus.success,
        response.alreadyRequested
            ? 'An active account deletion request already exists.'
            : 'Your account deletion request has been submitted for support processing.',
        response,
      );
  factory AccountDeletionRequestSubmitResult.incorrectPassword() =>
      const AccountDeletionRequestSubmitResult._(
          AccountDeletionRequestSubmitStatus.incorrectPassword,
          'Your current password is incorrect.');
  factory AccountDeletionRequestSubmitResult.authenticationRequired() =>
      const AccountDeletionRequestSubmitResult._(
          AccountDeletionRequestSubmitStatus.authenticationRequired,
          'Please sign in again.');
  factory AccountDeletionRequestSubmitResult.networkFailure() =>
      const AccountDeletionRequestSubmitResult._(
          AccountDeletionRequestSubmitStatus.networkFailure,
          'Unable to reach the service. Please try again.');
  factory AccountDeletionRequestSubmitResult.malformedResponse() =>
      const AccountDeletionRequestSubmitResult._(
          AccountDeletionRequestSubmitStatus.malformedResponse,
          'The service returned an unexpected response. Please try again.');
  factory AccountDeletionRequestSubmitResult.failed() =>
      const AccountDeletionRequestSubmitResult._(
          AccountDeletionRequestSubmitStatus.failed,
          'Unable to submit your request right now. Please try again.');
}
