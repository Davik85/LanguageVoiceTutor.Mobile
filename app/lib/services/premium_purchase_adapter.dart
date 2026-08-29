import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../models/premium_purchase.dart';
import 'google_play_billing_diagnostics.dart';

abstract class PremiumPurchaseAdapter {
  Future<void> initialize();
  Future<bool> get isAvailable;
  Stream<PremiumPurchaseEvent> get purchaseEvents;
  Future<PremiumProductLoadResult> loadSubscriptionProducts(
      Set<String> productIds);
  Future<bool> launchSubscriptionOffer(PremiumStoreProduct product,
      {String? obfuscatedAccountId});
  Future<void> restorePurchases({String? obfuscatedAccountId});
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
  Future<void> dispose() async {}
}

class GooglePlayPremiumPurchaseAdapter implements PremiumPurchaseAdapter {
  GooglePlayPremiumPurchaseAdapter({InAppPurchase? store}) : _store = store;
  InAppPurchase? _store;
  InAppPurchase get _purchaseStore => _store ??= InAppPurchase.instance;
  final _events = StreamController<PremiumPurchaseEvent>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _initialized = false;
  bool _available = false;
  final Map<
      ({
        String productId,
        String basePlanId,
        String? offerId,
        String offerToken
      }),
      GooglePlayProductDetails> _loadedOffers = {};

  @override
  Stream<PremiumPurchaseEvent> get purchaseEvents => _events.stream;
  @override
  Future<bool> get isAvailable async {
    try {
      _available = await _purchaseStore.isAvailable();
    } catch (error) {
      _available = false;
      GooglePlayBillingDiagnostics.log(
          'availability_exception exception_type=${error.runtimeType}');
    }
    return _available;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _subscription =
          _purchaseStore.purchaseStream.listen(_onPurchases, onError: (_, __) {
        _events.add(const PremiumPurchaseEvent(
            status: PremiumPurchaseEventStatus.failed,
            productId: '',
            requiresCompletion: false,
            failure: PremiumPurchaseFailure.storeError));
      });
    } catch (_) {
      _initialized = false;
      rethrow;
    }
  }

  @override
  Future<PremiumProductLoadResult> loadSubscriptionProducts(
      Set<String> productIds) async {
    _loadedOffers.clear();
    if (!_available) {
      return const PremiumProductLoadResult(
          failure: PremiumPurchaseFailure.unavailable);
    }
    try {
      final result = await _purchaseStore.queryProductDetails(productIds);
      final diagnostics =
          result.productDetails.map(_diagnosticProduct).toList(growable: false);
      if (result.error != null) {
        final loadResult = PremiumProductLoadResult(
          missingProductIds: result.notFoundIDs.toList(),
          diagnostics: PremiumCatalogDiagnostics(
            productDetails: diagnostics,
            errorCode: result.error!.code,
            errorMessagePresent: result.error!.message.trim().isNotEmpty,
          ),
          failure: PremiumPurchaseFailure.storeError,
        );
        GooglePlayBillingDiagnostics.logCatalogResponse(loadResult);
        return loadResult;
      }
      final products = <PremiumStoreProduct>[];
      for (final details in result.productDetails) {
        final product = _mapProduct(details);
        if (product == null) continue;
        products.add(product);
        _loadedOffers[(
          productId: product.productId,
          basePlanId: product.basePlanId!,
          offerId: product.offerId,
          offerToken: product.offerToken!,
        )] = details as GooglePlayProductDetails;
      }
      final loadResult = PremiumProductLoadResult(
        products: products,
        missingProductIds: result.notFoundIDs.toList(),
        diagnostics: PremiumCatalogDiagnostics(productDetails: diagnostics),
      );
      GooglePlayBillingDiagnostics.logCatalogResponse(loadResult);
      return loadResult;
    } catch (error) {
      const loadResult = PremiumProductLoadResult(
          failure: PremiumPurchaseFailure.disconnected);
      GooglePlayBillingDiagnostics.log(
          'query_exception exception_type=${error.runtimeType}');
      GooglePlayBillingDiagnostics.logCatalogResponse(loadResult);
      return loadResult;
    }
  }

  PremiumCatalogProductDiagnostic _diagnosticProduct(ProductDetails product) {
    if (product is! GooglePlayProductDetails) {
      return PremiumCatalogProductDiagnostic(
        productId: product.id,
        productType: 'non_android',
        offerTokenPresent: false,
      );
    }
    final index = product.subscriptionIndex;
    final offer = index != null
        ? (product.productDetails.subscriptionOfferDetails?[index])
        : null;
    return PremiumCatalogProductDiagnostic(
      productId: product.id,
      productType: product.productDetails.productType.name,
      basePlanId: offer?.basePlanId,
      offerId: offer?.offerId,
      offerTokenPresent: product.offerToken?.trim().isNotEmpty ?? false,
    );
  }

  PremiumStoreProduct? _mapProduct(ProductDetails product) {
    if (product is! GooglePlayProductDetails ||
        product.subscriptionIndex == null) {
      return null;
    }
    final offer = product
        .productDetails.subscriptionOfferDetails?[product.subscriptionIndex!];
    final basePlanId = offer?.basePlanId;
    final offerToken = product.offerToken;
    if (basePlanId == null ||
        basePlanId.trim().isEmpty ||
        offerToken == null ||
        offerToken.trim().isEmpty) {
      return null;
    }
    return PremiumStoreProduct(
        productId: product.id,
        title: product.title,
        description: product.description,
        localizedPrice: product.price,
        rawPrice: product.rawPrice,
        currencyCode: product.currencyCode,
        basePlanId: basePlanId,
        offerId: offer?.offerId,
        offerToken: offerToken);
  }

  @override
  Future<bool> launchSubscriptionOffer(PremiumStoreProduct product,
      {String? obfuscatedAccountId}) async {
    if (!_available) return false;
    final basePlanId = product.basePlanId;
    final offerToken = product.offerToken;
    if (basePlanId == null ||
        basePlanId.trim().isEmpty ||
        offerToken == null ||
        offerToken.trim().isEmpty) {
      return false;
    }
    final details = _loadedOffers[(
      productId: product.productId,
      basePlanId: basePlanId,
      offerId: product.offerId,
      offerToken: offerToken,
    )];
    if (details == null) return false;
    try {
      return _purchaseStore.buyNonConsumable(
          purchaseParam: GooglePlayPurchaseParam(
              productDetails: details,
              applicationUserName: obfuscatedAccountId,
              offerToken: offerToken));
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> restorePurchases({String? obfuscatedAccountId}) async {
    if (_available) {
      await _purchaseStore.restorePurchases(
          applicationUserName: obfuscatedAccountId);
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
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _events.close();
  }
}
