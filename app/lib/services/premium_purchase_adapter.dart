import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../models/premium_purchase.dart';

abstract class PremiumPurchaseAdapter {
  Future<void> initialize();
  Future<bool> get isAvailable;
  Stream<PremiumPurchaseEvent> get purchaseEvents;
  Future<PremiumProductLoadResult> loadSubscriptionProducts(
      Set<String> productIds);
  Future<bool> launchSubscriptionOffer(PremiumStoreProduct product,
      {String? obfuscatedAccountId});
  Future<void> restorePurchases({String? obfuscatedAccountId});
  Future<bool> completeVerifiedPurchase(String productId);
  Future<void> dispose();
}

class UnavailablePremiumPurchaseAdapter implements PremiumPurchaseAdapter {
  const UnavailablePremiumPurchaseAdapter();
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> get isAvailable async => false;
  @override
  Stream<PremiumPurchaseEvent> get purchaseEvents => const Stream.empty();
  @override
  Future<PremiumProductLoadResult> loadSubscriptionProducts(
          Set<String> productIds) async =>
      const PremiumProductLoadResult(
          failure: PremiumPurchaseFailure.unavailable);
  @override
  Future<bool> launchSubscriptionOffer(PremiumStoreProduct product,
          {String? obfuscatedAccountId}) async =>
      false;
  @override
  Future<void> restorePurchases({String? obfuscatedAccountId}) async {}
  @override
  Future<bool> completeVerifiedPurchase(String productId) async => false;
  @override
  Future<void> dispose() async {}
}

/// Real adapter. It is intentionally not created by production composition yet.
class GooglePlayPremiumPurchaseAdapter implements PremiumPurchaseAdapter {
  GooglePlayPremiumPurchaseAdapter({InAppPurchase? store})
      : _store = store ?? InAppPurchase.instance;
  final InAppPurchase _store;
  final _events = StreamController<PremiumPurchaseEvent>.broadcast();
  final Map<String, PurchaseDetails> _uncompleted = {};
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _initialized = false;
  bool _available = false;

  @override
  Stream<PremiumPurchaseEvent> get purchaseEvents => _events.stream;
  @override
  Future<bool> get isAvailable async => _available;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _available = await _store.isAvailable();
    if (!_available) return;
    _subscription =
        _store.purchaseStream.listen(_onPurchases, onError: (_, __) {
      _events.add(const PremiumPurchaseEvent(
          status: PremiumPurchaseEventStatus.failed,
          productId: '',
          requiresCompletion: false,
          failure: PremiumPurchaseFailure.storeError));
    });
  }

  @override
  Future<PremiumProductLoadResult> loadSubscriptionProducts(
      Set<String> productIds) async {
    if (!_available) {
      return const PremiumProductLoadResult(
          failure: PremiumPurchaseFailure.unavailable);
    }
    try {
      final result = await _store.queryProductDetails(productIds);
      if (result.error != null) {
        return const PremiumProductLoadResult(
            failure: PremiumPurchaseFailure.storeError);
      }
      return PremiumProductLoadResult(
          products: result.productDetails.map(_mapProduct).toList(),
          missingProductIds: result.notFoundIDs.toList());
    } catch (_) {
      return const PremiumProductLoadResult(
          failure: PremiumPurchaseFailure.disconnected);
    }
  }

  PremiumStoreProduct _mapProduct(ProductDetails product) {
    String? basePlanId;
    String? offerId;
    String? offerToken;
    if (product is GooglePlayProductDetails &&
        product.subscriptionIndex != null) {
      final offer = product
          .productDetails.subscriptionOfferDetails?[product.subscriptionIndex!];
      basePlanId = offer?.basePlanId;
      offerId = offer?.offerId;
      offerToken = product.offerToken;
    }
    return PremiumStoreProduct(
        productId: product.id,
        title: product.title,
        description: product.description,
        localizedPrice: product.price,
        rawPrice: product.rawPrice,
        currencyCode: product.currencyCode,
        basePlanId: basePlanId,
        offerId: offerId,
        offerToken: offerToken);
  }

  @override
  Future<bool> launchSubscriptionOffer(PremiumStoreProduct product,
      {String? obfuscatedAccountId}) async {
    if (!_available) return false;
    try {
      final response = await _store.queryProductDetails({product.productId});
      ProductDetails? details;
      for (final item in response.productDetails) {
        if (item.id == product.productId) {
          details = item;
          break;
        }
      }
      if (details == null) return false;
      return _store.buyNonConsumable(
          purchaseParam: GooglePlayPurchaseParam(
              productDetails: details,
              applicationUserName: obfuscatedAccountId,
              offerToken: product.offerToken));
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> restorePurchases({String? obfuscatedAccountId}) async {
    if (_available) {
      await _store.restorePurchases(applicationUserName: obfuscatedAccountId);
    }
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      final status = switch (purchase.status) {
        PurchaseStatus.purchased => PremiumPurchaseEventStatus.purchased,
        PurchaseStatus.pending => PremiumPurchaseEventStatus.pending,
        PurchaseStatus.restored => PremiumPurchaseEventStatus.restored,
        PurchaseStatus.canceled => PremiumPurchaseEventStatus.cancelled,
        PurchaseStatus.error => PremiumPurchaseEventStatus.failed,
      };
      if (purchase.pendingCompletePurchase &&
          status != PremiumPurchaseEventStatus.pending) {
        _uncompleted[purchase.productID] = purchase;
      }
      _events.add(PremiumPurchaseEvent(
          status: status,
          productId: purchase.productID,
          purchaseToken:
              purchase.verificationData.serverVerificationData.isEmpty
                  ? null
                  : purchase.verificationData.serverVerificationData,
          requiresCompletion: purchase.pendingCompletePurchase,
          failure: status == PremiumPurchaseEventStatus.failed
              ? PremiumPurchaseFailure.storeError
              : null));
    }
  }

  @override
  Future<bool> completeVerifiedPurchase(String productId) async {
    final purchase = _uncompleted.remove(productId);
    if (purchase == null || !purchase.pendingCompletePurchase) return false;
    // Backend verification and entitlement activation must succeed first; only then may Google Play completion occur.
    await _store.completePurchase(purchase);
    return true;
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _events.close();
  }
}
