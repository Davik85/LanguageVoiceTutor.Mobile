import 'package:flutter/foundation.dart';

import '../models/premium_purchase.dart';

class GooglePlayBillingDiagnostics {
  static const String prefix = 'LVT_BILLING_DIAG';

  static void log(String message) => debugPrint('$prefix $message');

  static PremiumCatalogSelectionDiagnostic classifySelection({
    required Set<String> productIds,
    required String basePlanId,
    required PremiumProductLoadResult catalog,
    required bool selectedCandidate,
  }) {
    final products = catalog.diagnostics.productDetails.isNotEmpty
        ? catalog.diagnostics.productDetails
        : catalog.products
            .map((product) => PremiumCatalogProductDiagnostic(
                  productId: product.productId,
                  productType: 'mapped_catalog_product',
                  basePlanId: product.basePlanId,
                  offerId: product.offerId,
                  offerTokenPresent:
                      product.offerToken?.trim().isNotEmpty ?? false,
                ))
            .toList(growable: false);
    final configuredProducts = products
        .where((product) => productIds.contains(product.productId))
        .toList();
    final basePlanMatches = configuredProducts
        .where((product) => product.basePlanId == basePlanId)
        .toList();
    final noOfferMatches =
        basePlanMatches.where((product) => product.offerId == null).toList();
    final tokenMatches =
        noOfferMatches.where((product) => product.offerTokenPresent).toList();

    final stage = switch (catalog.failure) {
      PremiumPurchaseFailure.unavailable => 'store_unavailable',
      PremiumPurchaseFailure.storeError ||
      PremiumPurchaseFailure.disconnected =>
        'query_error',
      _
          when catalog.missingProductIds
              .any((productId) => productIds.contains(productId)) =>
        'product_not_found',
      _ when products.isEmpty => 'no_product_details',
      _ when configuredProducts.isEmpty => 'product_not_found',
      _ when basePlanMatches.isEmpty => 'base_plan_not_found',
      _ when noOfferMatches.isEmpty => 'no_offer_candidate_not_found',
      _ when tokenMatches.isEmpty => 'offer_token_missing',
      _ when !selectedCandidate => 'ambiguous_candidate',
      _ => 'candidate_selected',
    };

    return PremiumCatalogSelectionDiagnostic(
      configuredProductMatched: configuredProducts.isNotEmpty,
      exactMonthlyBasePlanMatched: basePlanMatches.isNotEmpty,
      exactNoOfferMatched: noOfferMatches.isNotEmpty,
      usableOfferTokenPresent: tokenMatches.isNotEmpty,
      selectedCandidate: selectedCandidate,
      exitStage: stage,
    );
  }

  static void logCatalogResponse(PremiumProductLoadResult catalog) {
    final diagnostics = catalog.diagnostics;
    if (diagnostics.errorCode != null) {
      log('query_response error_code=${diagnostics.errorCode} '
          'error_message_present=${diagnostics.errorMessagePresent}');
    }
    log('query_response not_found_ids=${catalog.missingProductIds.join(',')} '
        'returned_product_details=${diagnostics.productDetails.length}');
    for (final product in diagnostics.productDetails) {
      log('product product_id=${product.productId} '
          'product_type=${product.productType} '
          'base_plan_id=${product.basePlanId ?? 'null'} '
          'offer_id=${product.offerId ?? 'null'} '
          'offer_token_present=${product.offerTokenPresent}');
    }
  }

  static void logSelection(PremiumCatalogSelectionDiagnostic selection) {
    log('candidate_selection configured_product_matched='
        '${selection.configuredProductMatched} '
        'exact_monthly_base_plan_matched=${selection.exactMonthlyBasePlanMatched} '
        'exact_no_offer_matched=${selection.exactNoOfferMatched} '
        'usable_offer_token_present=${selection.usableOfferTokenPresent} '
        'selected_candidate=${selection.selectedCandidate} '
        'exit_stage=${selection.exitStage}');
  }
}

class PremiumCatalogSelectionDiagnostic {
  const PremiumCatalogSelectionDiagnostic({
    required this.configuredProductMatched,
    required this.exactMonthlyBasePlanMatched,
    required this.exactNoOfferMatched,
    required this.usableOfferTokenPresent,
    required this.selectedCandidate,
    required this.exitStage,
  });

  final bool configuredProductMatched;
  final bool exactMonthlyBasePlanMatched;
  final bool exactNoOfferMatched;
  final bool usableOfferTokenPresent;
  final bool selectedCandidate;
  final String exitStage;
}
