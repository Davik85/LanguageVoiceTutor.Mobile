class ProgressResponse {
  const ProgressResponse({
    required this.generatedAtUtc,
    required this.calendarTimezone,
    required this.completedLessons,
    required this.streaks,
    required this.lastCompletedLesson,
    required this.completedLessonsByStudyLanguage,
    required this.completedLessonsByLevel,
    required this.dailyActivity,
  });

  final DateTime generatedAtUtc;
  final String calendarTimezone;
  final ProgressCompletedLessons completedLessons;
  final ProgressStreaks streaks;
  final ProgressLastCompletedLesson? lastCompletedLesson;
  final List<ProgressStudyLanguageDistributionItem>
      completedLessonsByStudyLanguage;
  final List<ProgressLevelDistributionItem> completedLessonsByLevel;
  final List<ProgressDailyActivityItem> dailyActivity;

  factory ProgressResponse.fromJson(Map<String, dynamic> json) =>
      ProgressResponse(
        generatedAtUtc: _requiredUtcDateTime(json['generatedAtUtc']),
        calendarTimezone: _stringOrEmpty(json['calendarTimezone']),
        completedLessons: ProgressCompletedLessons.fromJson(
          _mapOrEmpty(json['completedLessons']),
        ),
        streaks: ProgressStreaks.fromJson(_mapOrEmpty(json['streaks'])),
        lastCompletedLesson: json['lastCompletedLesson'] is Map<String, dynamic>
            ? ProgressLastCompletedLesson.fromJson(
                json['lastCompletedLesson'] as Map<String, dynamic>,
              )
            : null,
        completedLessonsByStudyLanguage:
            _maps(json['completedLessonsByStudyLanguage'])
                .map(ProgressStudyLanguageDistributionItem.fromJson)
                .toList(growable: false),
        completedLessonsByLevel: _maps(json['completedLessonsByLevel'])
            .map(ProgressLevelDistributionItem.fromJson)
            .toList(growable: false),
        dailyActivity: _maps(json['dailyActivity'])
            .map(ProgressDailyActivityItem.fromJson)
            .toList(growable: false),
      );
}

class ProgressCompletedLessons {
  const ProgressCompletedLessons({
    required this.allTime,
    required this.last7Days,
    required this.last30Days,
  });

  final int allTime;
  final int last7Days;
  final int last30Days;

  factory ProgressCompletedLessons.fromJson(Map<String, dynamic> json) =>
      ProgressCompletedLessons(
        allTime: _nonNegativeInt(json['allTime']),
        last7Days: _nonNegativeInt(json['last7Days']),
        last30Days: _nonNegativeInt(json['last30Days']),
      );
}

class ProgressStreaks {
  const ProgressStreaks({required this.currentDays, required this.longestDays});

  final int currentDays;
  final int longestDays;

  factory ProgressStreaks.fromJson(Map<String, dynamic> json) =>
      ProgressStreaks(
        currentDays: _nonNegativeInt(json['currentDays']),
        longestDays: _nonNegativeInt(json['longestDays']),
      );
}

class ProgressLastCompletedLesson {
  const ProgressLastCompletedLesson({
    required this.completedAtUtc,
    required this.studyLanguage,
    required this.level,
    required this.topicTitle,
    required this.subtopicTitle,
  });

  final DateTime completedAtUtc;
  final String? studyLanguage;
  final String? level;
  final String? topicTitle;
  final String? subtopicTitle;

  factory ProgressLastCompletedLesson.fromJson(Map<String, dynamic> json) =>
      ProgressLastCompletedLesson(
        completedAtUtc: _requiredUtcDateTime(json['completedAtUtc']),
        studyLanguage: _nullableString(json['studyLanguage']),
        level: _nullableString(json['level']),
        topicTitle: _nullableString(json['topicTitle']),
        subtopicTitle: _nullableString(json['subtopicTitle']),
      );
}

class ProgressStudyLanguageDistributionItem {
  const ProgressStudyLanguageDistributionItem({
    required this.studyLanguage,
    required this.completedLessons,
  });

  final String studyLanguage;
  final int completedLessons;

  factory ProgressStudyLanguageDistributionItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      ProgressStudyLanguageDistributionItem(
        studyLanguage: _stringOrEmpty(json['studyLanguage']),
        completedLessons: _nonNegativeInt(json['completedLessons']),
      );
}

class ProgressLevelDistributionItem {
  const ProgressLevelDistributionItem({
    required this.level,
    required this.completedLessons,
  });

  final String level;
  final int completedLessons;

  factory ProgressLevelDistributionItem.fromJson(Map<String, dynamic> json) =>
      ProgressLevelDistributionItem(
        level: _stringOrEmpty(json['level']),
        completedLessons: _nonNegativeInt(json['completedLessons']),
      );
}

class ProgressDailyActivityItem {
  const ProgressDailyActivityItem({
    required this.activityDate,
    required this.completedLessons,
  });

  /// UTC midnight of the backend-provided UTC calendar date.
  final DateTime activityDate;
  final int completedLessons;

  factory ProgressDailyActivityItem.fromJson(Map<String, dynamic> json) =>
      ProgressDailyActivityItem(
        activityDate: _requiredUtcCalendarDate(json['activityDate']),
        completedLessons: _nonNegativeInt(json['completedLessons']),
      );
}

enum ProgressStatus { success, authRequired, unavailable, failed }

class ProgressResult {
  const ProgressResult._(
      {required this.status, required this.message, this.progress});

  final ProgressStatus status;
  final String message;
  final ProgressResponse? progress;
  bool get isSuccess => status == ProgressStatus.success;

  factory ProgressResult.success(ProgressResponse progress) => ProgressResult._(
        status: ProgressStatus.success,
        message: '',
        progress: progress,
      );
  factory ProgressResult.authRequired() => const ProgressResult._(
        status: ProgressStatus.authRequired,
        message: 'Please sign in again to view progress.',
      );
  factory ProgressResult.unavailable() => const ProgressResult._(
        status: ProgressStatus.unavailable,
        message: 'Progress is temporarily unavailable. Please try again.',
      );
  factory ProgressResult.failed() => const ProgressResult._(
        status: ProgressStatus.failed,
        message: 'Could not load progress. Please try again.',
      );
}

Map<String, dynamic> _mapOrEmpty(Object? value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<Map<String, dynamic>> _maps(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList(growable: false)
    : const <Map<String, dynamic>>[];

String _stringOrEmpty(Object? value) => value is String ? value : '';

String? _nullableString(Object? value) => value is String ? value : null;

int _nonNegativeInt(Object? value) =>
    value is num && value == value.roundToDouble() && value >= 0
        ? value.toInt()
        : 0;

DateTime _requiredUtcDateTime(Object? value) {
  if (value is! String) throw const FormatException('Invalid UTC timestamp.');
  return DateTime.parse(value).toUtc();
}

DateTime _requiredUtcCalendarDate(Object? value) {
  if (value is! String) throw const FormatException('Invalid activity date.');
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) throw const FormatException('Invalid activity date.');
  return DateTime.utc(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}
