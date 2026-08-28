import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';

void main() {
  test('parses subscription status while tolerating extra fields', () {
    final status = SubscriptionStatus.fromJson({
      'userId': 'u1',
      'planId': 'premium',
      'planName': 'Premium Monthly',
      'premiumActive': true,
      'trialActive': false,
      'trialEndsAtUtc': null,
      'subscriptionStatus': 'active',
      'billingProvider': 'paddle',
      'freeLessonUsedToday': 1,
      'freeLessonRemainingToday': 0,
      'freeLessonConsumptionRule': 'daily',
      'checkedAtUtc': '2026-07-06T12:00:00Z',
      'currentAccessTier': 'premium',
      'currentAccessSource': 'subscription',
      'currentTariffName': 'Premium',
      'premiumDisplayStatusCode': 'active',
      'premiumStartsAtUtc': '2026-07-01T12:00:00Z',
      'premiumEndsAtUtc': null,
      'googlePlayPurchaseAllowed': false,
      'googlePlayPurchaseBlockReasonCode': 'external_auto_renew_active',
      'googlePlayPurchaseBlockingProvider': 'paddle',
      'enforcementEnabled': true,
      'extraBackendField': 'ignored',
    });

    expect(status.displayLabel, 'Premium');
    expect(status.freeLessonRemainingToday, 0);
    expect(status.googlePlayPurchaseAllowed, isFalse);
    expect(
        status.googlePlayPurchaseBlockReasonCode, 'external_auto_renew_active');
    expect(status.googlePlayPurchaseBlockingProvider, 'paddle');
    expect(status.explicitlyAllowsNewGooglePlayPurchase, isFalse);
  });

  test('missing Google Play eligibility fails closed for a new purchase', () {
    final status = SubscriptionStatus.fromJson({
      'userId': 'u1',
      'premiumActive': false,
      'trialActive': true,
      'freeLessonUsedToday': 0,
      'freeLessonRemainingToday': 1,
      'checkedAtUtc': '2026-08-27T12:00:00Z',
      'enforcementEnabled': true,
    });

    expect(status.googlePlayPurchaseAllowed, isNull);
    expect(status.explicitlyAllowsNewGooglePlayPurchase, isFalse);
  });

  test('explicit complete allow gate permits a fresh new purchase', () {
    final checkedAt = DateTime.utc(2026, 8, 27, 12);
    final status = SubscriptionStatus.fromJson({
      'userId': 'u1',
      'premiumActive': true,
      'trialActive': false,
      'freeLessonUsedToday': 0,
      'freeLessonRemainingToday': 0,
      'checkedAtUtc': checkedAt.toIso8601String(),
      'googlePlayPurchaseAllowed': true,
      'googlePlayPurchaseBlockReasonCode': 'none',
      'googlePlayPurchaseBlockingProvider': null,
      'enforcementEnabled': true,
    });

    expect(status.explicitlyAllowsNewGooglePlayPurchase, isTrue);
    expect(status.hasFreshGooglePlayPurchaseGate(nowUtc: checkedAt), isTrue);
  });
}
