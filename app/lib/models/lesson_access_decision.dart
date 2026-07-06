class LessonAccessDecision {
  const LessonAccessDecision({
    required this.userId,
    required this.canStartNewLesson,
    required this.premiumActive,
    required this.trialActive,
    required this.freeLessonUsedToday,
    required this.freeLessonRemainingToday,
    required this.enforcementEnabled,
    required this.decision,
    required this.reason,
    this.source,
    required this.checkedAtUtc,
  });

  final String userId;
  final bool canStartNewLesson;
  final bool premiumActive;
  final bool trialActive;
  final bool freeLessonUsedToday;
  final int freeLessonRemainingToday;
  final bool enforcementEnabled;
  final String decision;
  final String reason;
  final String? source;
  final DateTime checkedAtUtc;

  factory LessonAccessDecision.fromJson(Map<String, dynamic> json) =>
      LessonAccessDecision(
        userId: _string(json['userId']),
        canStartNewLesson: _bool(json['canStartNewLesson']),
        premiumActive: _bool(json['premiumActive']),
        trialActive: _bool(json['trialActive']),
        freeLessonUsedToday: _bool(json['freeLessonUsedToday']),
        freeLessonRemainingToday: _int(json['freeLessonRemainingToday']),
        enforcementEnabled: _bool(json['enforcementEnabled']),
        decision: _string(json['decision']),
        reason: _string(json['reason']),
        source: _stringOrNull(json['source']),
        checkedAtUtc:
            _dateOrNull(json['checkedAtUtc']) ?? DateTime.now().toUtc(),
      );

  String get displayReason {
    final trimmedReason = reason.trim();
    if (trimmedReason.isNotEmpty) return trimmedReason;

    final trimmedDecision = decision.trim();
    if (trimmedDecision.isNotEmpty) return trimmedDecision;

    return canStartNewLesson
        ? 'The backend says lesson access is available.'
        : 'The backend says lesson access is not available right now.';
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
