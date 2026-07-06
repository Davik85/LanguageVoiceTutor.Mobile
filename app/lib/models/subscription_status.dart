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
        enforcementEnabled: _bool(json['enforcementEnabled']),
      );

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
  static int _int(Object? value) => value is int
      ? value
      : value is num
          ? value.toInt()
          : 0;
}
