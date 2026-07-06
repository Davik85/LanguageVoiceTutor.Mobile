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
      'enforcementEnabled': true,
      'extraBackendField': 'ignored',
    });

    expect(status.displayLabel, 'Premium');
    expect(status.freeLessonRemainingToday, 0);
  });
}
