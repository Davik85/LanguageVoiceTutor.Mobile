class AchievementsResponse {
  const AchievementsResponse({
    required this.generatedAtUtc,
    required this.calendarTimezone,
    required this.activeStudyLanguage,
    required this.summary,
    required this.achievements,
    required this.homeItems,
  });

  final DateTime generatedAtUtc;
  final String calendarTimezone;
  final String? activeStudyLanguage;
  final AchievementSummary summary;
  final List<AchievementItem> achievements;
  final List<AchievementItem> homeItems;

  factory AchievementsResponse.fromJson(Map<String, dynamic> json) =>
      AchievementsResponse(
        generatedAtUtc: _requiredUtcDateTime(json['generatedAtUtc']),
        calendarTimezone: _requiredString(json['calendarTimezone']),
        activeStudyLanguage: _nullableString(json['activeStudyLanguage']),
        summary: AchievementSummary.fromJson(_requiredMap(json['summary'])),
        achievements: _requiredMaps(json['achievements'])
            .map(AchievementItem.fromJson)
            .toList(growable: false),
        homeItems: _requiredMaps(json['homeItems'])
            .map(AchievementItem.fromJson)
            .toList(growable: false),
      );
}

class AchievementSummary {
  const AchievementSummary({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  factory AchievementSummary.fromJson(Map<String, dynamic> json) =>
      AchievementSummary(
        unlocked: _requiredNonNegativeInt(json['unlocked']),
        total: _requiredNonNegativeInt(json['total']),
      );
}

class AchievementItem {
  const AchievementItem({
    required this.id,
    required this.category,
    required this.scope,
    required this.studyLanguage,
    required this.topicId,
    required this.lessonContentId,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.unlocked,
    required this.unlockedAtUtc,
    required this.currentProgress,
    required this.targetProgress,
  });

  final String id;
  final String category;
  final String scope;
  final String? studyLanguage;
  final String? topicId;
  final String? lessonContentId;
  final String title;
  final String description;
  final String iconKey;
  final bool unlocked;
  final DateTime? unlockedAtUtc;
  final int currentProgress;
  final int targetProgress;

  factory AchievementItem.fromJson(Map<String, dynamic> json) =>
      AchievementItem(
        id: _requiredString(json['id']),
        category: _requiredString(json['category']),
        scope: _requiredString(json['scope']),
        studyLanguage: _nullableString(json['studyLanguage']),
        topicId: _nullableString(json['topicId']),
        lessonContentId: _nullableString(json['lessonContentId']),
        title: _requiredString(json['title']),
        description: _requiredString(json['description']),
        iconKey: _requiredString(json['iconKey']),
        unlocked: _requiredBool(json['unlocked']),
        unlockedAtUtc: _nullableUtcDateTime(json['unlockedAtUtc']),
        currentProgress: _requiredNonNegativeInt(json['currentProgress']),
        targetProgress: _requiredNonNegativeInt(json['targetProgress']),
      );
}

enum AchievementsStatus { success, authRequired, unavailable, failed }

class AchievementsResult {
  const AchievementsResult._({
    required this.status,
    required this.message,
    this.achievements,
  });

  final AchievementsStatus status;
  final String message;
  final AchievementsResponse? achievements;
  bool get isSuccess => status == AchievementsStatus.success;

  factory AchievementsResult.success(AchievementsResponse achievements) =>
      AchievementsResult._(
        status: AchievementsStatus.success,
        message: '',
        achievements: achievements,
      );
  factory AchievementsResult.authRequired() => const AchievementsResult._(
        status: AchievementsStatus.authRequired,
        message: 'Please sign in again to view achievements.',
      );
  factory AchievementsResult.unavailable() => const AchievementsResult._(
        status: AchievementsStatus.unavailable,
        message: 'Achievements are temporarily unavailable. Please try again.',
      );
  factory AchievementsResult.failed() => const AchievementsResult._(
        status: AchievementsStatus.failed,
        message: 'Could not load achievements. Please try again.',
      );
}

Map<String, dynamic> _requiredMap(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Invalid object.');
  }
  return value;
}

List<Map<String, dynamic>> _requiredMaps(Object? value) {
  if (value is! List || value.any((item) => item is! Map<String, dynamic>)) {
    throw const FormatException('Invalid list.');
  }
  return value.cast<Map<String, dynamic>>();
}

String _requiredString(Object? value) {
  if (value is! String) throw const FormatException('Invalid string.');
  return value;
}

String? _nullableString(Object? value) {
  if (value == null) {
    return null;
  }
  return _requiredString(value);
}

bool _requiredBool(Object? value) {
  if (value is! bool) throw const FormatException('Invalid boolean.');
  return value;
}

int _requiredNonNegativeInt(Object? value) {
  if (value is! num || value != value.roundToDouble() || value < 0) {
    throw const FormatException('Invalid non-negative integer.');
  }
  return value.toInt();
}

DateTime _requiredUtcDateTime(Object? value) {
  if (value is! String) throw const FormatException('Invalid UTC timestamp.');
  return DateTime.parse(value).toUtc();
}

DateTime? _nullableUtcDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  return _requiredUtcDateTime(value);
}
