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
  final bool enforcementEnabled;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      SubscriptionStatus(
        userId: json['userId'] as String? ?? '',
        planId: json['planId'] as String?,
        planName: json['planName'] as String?,
        premiumActive: json['premiumActive'] as bool? ?? false,
        trialActive: json['trialActive'] as bool? ?? false,
        trialEndsAtUtc: _dateOrNull(json['trialEndsAtUtc']),
        subscriptionStatus: json['subscriptionStatus'] as String?,
        billingProvider: json['billingProvider'] as String?,
        freeLessonUsedToday: json['freeLessonUsedToday'] as int? ?? 0,
        freeLessonRemainingToday: json['freeLessonRemainingToday'] as int? ?? 0,
        freeLessonConsumptionRule: json['freeLessonConsumptionRule'] as String?,
        checkedAtUtc: DateTime.parse(json['checkedAtUtc'] as String),
        currentAccessTier: json['currentAccessTier'] as String?,
        currentAccessSource: json['currentAccessSource'] as String?,
        currentTariffName: json['currentTariffName'] as String?,
        premiumDisplayStatusCode: json['premiumDisplayStatusCode'] as String?,
        premiumStartsAtUtc: _dateOrNull(json['premiumStartsAtUtc']),
        premiumEndsAtUtc: _dateOrNull(json['premiumEndsAtUtc']),
        enforcementEnabled: json['enforcementEnabled'] as bool? ?? false,
      );

  String get displayLabel {
    if (premiumActive) return 'Premium';
    if (trialActive) return 'Trial';
    return 'Free';
  }

  static DateTime? _dateOrNull(Object? value) =>
      value is String && value.isNotEmpty ? DateTime.parse(value) : null;
}
