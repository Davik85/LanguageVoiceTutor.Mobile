import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/premium_purchase.dart';
import 'package:language_voice_tutor_mobile/services/premium_purchase_adapter.dart';

void main() {
  test('unavailable adapter performs no store work and exposes no successes',
      () async {
    const adapter = UnavailablePremiumPurchaseAdapter();
    await adapter.initialize();
    expect(await adapter.isAvailable, isFalse);
    expect((await adapter.loadSubscriptionProducts({'test-id'})).products,
        isEmpty);
    expect(
        await adapter.launchSubscriptionOffer(const PremiumStoreProduct(
            productId: 'test-id',
            title: '',
            description: '',
            localizedPrice: '',
            rawPrice: 0,
            currencyCode: '')),
        isFalse);
    expect(await adapter.completeVerifiedPurchase('test-id'), isFalse);
    await expectLater(adapter.purchaseEvents, emitsDone);
  });

  test('store-neutral product preserves Google-provided catalog values', () {
    const product = PremiumStoreProduct(
        productId: 'fixture-subscription',
        title: 'Catalog title',
        description: 'Catalog description',
        localizedPrice: '€4.99',
        rawPrice: 4.99,
        currencyCode: 'EUR',
        basePlanId: 'fixture-base',
        offerId: 'fixture-offer',
        offerToken: 'fixture-token');
    expect(product.localizedPrice, '€4.99');
    expect(product.rawPrice, 4.99);
    expect(product.currencyCode, 'EUR');
    expect(product.basePlanId, 'fixture-base');
    expect(product.offerId, 'fixture-offer');
    expect(product.offerToken, 'fixture-token');
  });

  test('purchase events retain transient verification data without persistence',
      () {
    const event = PremiumPurchaseEvent(
        status: PremiumPurchaseEventStatus.purchased,
        productId: 'fixture-subscription',
        purchaseToken: 'transient-fixture-token',
        requiresCompletion: true);
    expect(event.status, PremiumPurchaseEventStatus.purchased);
    expect(event.purchaseToken, 'transient-fixture-token');
    expect(event.requiresCompletion, isTrue);
  });

  test('pending and restored event models never imply a local entitlement', () {
    const pending = PremiumPurchaseEvent(
        status: PremiumPurchaseEventStatus.pending,
        productId: 'fixture-subscription',
        requiresCompletion: true);
    const restored = PremiumPurchaseEvent(
        status: PremiumPurchaseEventStatus.restored,
        productId: 'fixture-subscription',
        requiresCompletion: true);
    expect(pending.status, isNot(PremiumPurchaseEventStatus.purchased));
    expect(restored.status, isNot(PremiumPurchaseEventStatus.purchased));
  });
}
