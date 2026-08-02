enum GooglePlayPurchaseVerificationResult {
  verified,
  acknowledgementPending,
  pending,
  ownershipConflict,
  invalidPurchase,
  unsupportedProduct,
  notConfigured,
  temporarilyUnavailable,
  authenticationRequired,
  malformed,
}

class GooglePlayPurchaseVerificationRequest {
  const GooglePlayPurchaseVerificationRequest(this.purchaseToken);

  final String purchaseToken;

  Map<String, dynamic> toJson() => {'purchaseToken': purchaseToken};
}

class GooglePlayPurchaseVerificationResponse {
  const GooglePlayPurchaseVerificationResponse({
    required this.result,
    required this.subscriptionStatusRefreshRecommended,
  });

  final GooglePlayPurchaseVerificationResult result;
  final bool subscriptionStatusRefreshRecommended;

  static GooglePlayPurchaseVerificationResponse? tryParse(
      Map<String, dynamic> json) {
    final raw = json['result'];
    final refresh = json['subscriptionStatusRefreshRecommended'];
    if (raw is! String || refresh is! bool) return null;
    final result = switch (raw) {
      'verified' => GooglePlayPurchaseVerificationResult.verified,
      'acknowledgement_pending' =>
        GooglePlayPurchaseVerificationResult.acknowledgementPending,
      'pending' => GooglePlayPurchaseVerificationResult.pending,
      'ownership_conflict' =>
        GooglePlayPurchaseVerificationResult.ownershipConflict,
      'invalid_purchase' =>
        GooglePlayPurchaseVerificationResult.invalidPurchase,
      'unsupported_product' =>
        GooglePlayPurchaseVerificationResult.unsupportedProduct,
      'not_configured' => GooglePlayPurchaseVerificationResult.notConfigured,
      'temporarily_unavailable' =>
        GooglePlayPurchaseVerificationResult.temporarilyUnavailable,
      _ => GooglePlayPurchaseVerificationResult.malformed,
    };
    if (result == GooglePlayPurchaseVerificationResult.malformed) return null;
    return GooglePlayPurchaseVerificationResponse(
      result: result,
      subscriptionStatusRefreshRecommended: refresh,
    );
  }
}
