import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/premium_purchase.dart';
import 'package:language_voice_tutor_mobile/services/google_play_billing_diagnostics.dart';

void main() {
  const productIds = {'premium'};
  const basePlanId = 'monthly';

  PremiumCatalogSelectionDiagnostic classify(PremiumProductLoadResult catalog) {
    return GooglePlayBillingDiagnostics.classifySelection(
      productIds: productIds,
      basePlanId: basePlanId,
      catalog: catalog,
      selectedCandidate: false,
    );
  }

  test('not-found IDs are classified without token values', () {
    final result = classify(const PremiumProductLoadResult(
      missingProductIds: ['premium'],
    ));

    expect(result.exitStage, 'product_not_found');
  });

  test('zero returned products is distinguishable', () {
    final result = classify(const PremiumProductLoadResult());

    expect(result.exitStage, 'no_product_details');
  });

  test('wrong base plan is distinguishable', () {
    final result = classify(const PremiumProductLoadResult(
      diagnostics: PremiumCatalogDiagnostics(productDetails: [
        PremiumCatalogProductDiagnostic(
          productId: 'premium',
          productType: 'subs',
          basePlanId: 'annual',
          offerTokenPresent: true,
        ),
      ]),
    ));

    expect(result.exitStage, 'base_plan_not_found');
  });

  test('an offer ID is distinguishable from the no-offer candidate', () {
    final result = classify(const PremiumProductLoadResult(
      diagnostics: PremiumCatalogDiagnostics(productDetails: [
        PremiumCatalogProductDiagnostic(
          productId: 'premium',
          productType: 'subs',
          basePlanId: 'monthly',
          offerId: 'introductory',
          offerTokenPresent: true,
        ),
      ]),
    ));

    expect(result.exitStage, 'no_offer_candidate_not_found');
  });

  test('a missing offer token is distinguishable', () {
    final result = classify(const PremiumProductLoadResult(
      diagnostics: PremiumCatalogDiagnostics(productDetails: [
        PremiumCatalogProductDiagnostic(
          productId: 'premium',
          productType: 'subs',
          basePlanId: 'monthly',
          offerTokenPresent: false,
        ),
      ]),
    ));

    expect(result.exitStage, 'offer_token_missing');
  });

  test('the exact no-offer monthly candidate is recognized without a token',
      () {
    const catalog = PremiumProductLoadResult(
      diagnostics: PremiumCatalogDiagnostics(productDetails: [
        PremiumCatalogProductDiagnostic(
          productId: 'premium',
          productType: 'subs',
          basePlanId: 'monthly',
          offerTokenPresent: true,
        ),
      ]),
    );

    final result = GooglePlayBillingDiagnostics.classifySelection(
      productIds: productIds,
      basePlanId: basePlanId,
      catalog: catalog,
      selectedCandidate: true,
    );

    expect(result.exitStage, 'candidate_selected');
    expect(result.usableOfferTokenPresent, isTrue);
  });
}
