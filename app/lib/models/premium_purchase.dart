enum PremiumPurchaseEventStatus {
  purchased,
  pending,
  restored,
  cancelled,
  failed
}

enum PremiumPurchaseFailure {
  unavailable,
  productNotFound,
  disconnected,
  storeError,
  unknown
}

class PremiumStoreProduct {
  const PremiumStoreProduct(
      {required this.productId,
      required this.title,
      required this.description,
      required this.localizedPrice,
      required this.rawPrice,
      required this.currencyCode,
      this.basePlanId,
      this.offerId,
      this.offerToken});
  final String productId;
  final String title;
  final String description;
  final String localizedPrice;
  final double rawPrice;
  final String currencyCode;
  final String? basePlanId;
  final String? offerId;
  final String? offerToken;
}

class PremiumPurchaseEvent {
  const PremiumPurchaseEvent(
      {required this.status,
      required this.productId,
      this.purchaseToken,
      required this.requiresCompletion,
      this.failure});
  final PremiumPurchaseEventStatus status;
  final String productId;

  /// Transient only: a future backend verifier may consume this value. Never persist or log it.
  final String? purchaseToken;
  final bool requiresCompletion;
  final PremiumPurchaseFailure? failure;
}

class PremiumProductLoadResult {
  const PremiumProductLoadResult(
      {this.products = const [],
      this.missingProductIds = const [],
      this.failure});
  final List<PremiumStoreProduct> products;
  final List<String> missingProductIds;
  final PremiumPurchaseFailure? failure;
}
