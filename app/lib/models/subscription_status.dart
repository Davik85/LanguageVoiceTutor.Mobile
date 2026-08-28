class SubscriptionStatus {
  const SubscriptionStatus({
    required this.userId,
    this.planId,
    this.planName,
    required this.premiumActive,
    required this.trialActive,
    this.trialEndsAtUtc,
    this.subscriptionStatus,
    this.billingProvider,
    required this.freeLessonUsedToday,
    required this.freeLessonRemainingToday,
    this.freeLessonConsumptionRule,
    required this.checkedAtUtc,
    this.currentAccessTier,
    this.currentAccessSource,
    this.currentTariffName,
    this.premiumDisplayStatusCode,
    this.premiumStartsAtUtc,
    this.premiumEndsAtUtc,
    this.googlePlayPurchaseAllowed,
    this.googlePlayPurchaseBlockReasonCode,
    this.googlePlayPurchaseBlockingProvider,
    this.hasValidCheckedAtUtc = true,
    required this.enforcementEnabled,
  });

  final String userId;
  final String? planId;
  final String? planName;
  final bool premiumActive;
  final bool trialActive;
  final DateTime? trialEndsAtUtc;
  final String? subscriptionStatus;
  final String? billingProvider;
  final int freeLessonUsedToday;
  final int freeLessonRemainingToday;
  final String? freeLessonConsumptionRule;
  final DateTime checkedAtUtc;
  final String? currentAccessTier;
  final String? currentAccessSource;
  final String? currentTariffName;
  final String? premiumDisplayStatusCode;
  final DateTime? premiumStartsAtUtc;
  final DateTime? premiumEndsAtUtc;
  final bool? googlePlayPurchaseAllowed;
  final String? googlePlayPurchaseBlockReasonCode;
  final String? googlePlayPurchaseBlockingProvider;
  final bool hasValidCheckedAtUtc;
  final bool enforcementEnabled;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      SubscriptionStatus(
        userId: _string(json['userId']),
        planId: _stringOrNull(json['planId']),
        planName: _stringOrNull(json['planName']),
        premiumActive: _bool(json['premiumActive']),
        trialActive: _bool(json['trialActive']),
        trialEndsAtUtc: _dateOrNull(json['trialEndsAtUtc']),
        subscriptionStatus: _stringOrNull(json['subscriptionStatus']),
        billingProvider: _stringOrNull(json['billingProvider']),
        freeLessonUsedToday: _int(json['freeLessonUsedToday']),
        freeLessonRemainingToday: _int(json['freeLessonRemainingToday']),
        freeLessonConsumptionRule:
            _stringOrNull(json['freeLessonConsumptionRule']),
        checkedAtUtc:
            _dateOrNull(json['checkedAtUtc']) ?? DateTime.now().toUtc(),
        currentAccessTier: _stringOrNull(json['currentAccessTier']),
        currentAccessSource: _stringOrNull(json['currentAccessSource']),
        currentTariffName: _stringOrNull(json['currentTariffName']),
        premiumDisplayStatusCode:
            _stringOrNull(json['premiumDisplayStatusCode']),
        premiumStartsAtUtc: _dateOrNull(json['premiumStartsAtUtc']),
        premiumEndsAtUtc: _dateOrNull(json['premiumEndsAtUtc']),
        googlePlayPurchaseAllowed:
            _boolOrNull(json['googlePlayPurchaseAllowed']),
        googlePlayPurchaseBlockReasonCode:
            _stringOrNull(json['googlePlayPurchaseBlockReasonCode']),
        googlePlayPurchaseBlockingProvider:
            _stringOrNull(json['googlePlayPurchaseBlockingProvider']),
        hasValidCheckedAtUtc: _dateOrNull(json['checkedAtUtc']) != null,
        enforcementEnabled: _bool(json['enforcementEnabled']),
      );

  static const googlePlayPurchaseAllowedReasonCode = 'none';

  bool get explicitlyAllowsNewGooglePlayPurchase =>
      googlePlayPurchaseAllowed == true &&
      googlePlayPurchaseBlockReasonCode ==
          googlePlayPurchaseAllowedReasonCode &&
      (googlePlayPurchaseBlockingProvider == null ||
          googlePlayPurchaseBlockingProvider!.trim().isEmpty);

  bool hasFreshGooglePlayPurchaseGate({DateTime? nowUtc}) {
    if (!hasValidCheckedAtUtc || !explicitlyAllowsNewGooglePlayPurchase) {
      return false;
    }
    final now = (nowUtc ?? DateTime.now()).toUtc();
    final checkedAt = checkedAtUtc.toUtc();
    return checkedAt.isAfter(now.subtract(const Duration(minutes: 5))) &&
        checkedAt.isBefore(now.add(const Duration(minutes: 5)));
  }

  String get displayLabel {
    if (premiumActive) return 'Premium';
    if (trialActive) return 'Trial';
    return 'Free';
  }

  static DateTime? _dateOrNull(Object? value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;

  static String _string(Object? value) => value is String ? value : '';
  static String? _stringOrNull(Object? value) => value is String ? value : null;
  static bool _bool(Object? value) => value is bool ? value : false;
  static bool? _boolOrNull(Object? value) => value is bool ? value : null;
  static int _int(Object? value) => value is int
      ? value
      : value is num
          ? value.toInt()
          : 0;
}
