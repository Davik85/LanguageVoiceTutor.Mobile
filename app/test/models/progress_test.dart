import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/progress.dart';

Map<String, dynamic> completeProgressJson() => {
      'generatedAtUtc': '2026-07-19T12:00:00Z',
      'calendarTimezone': 'UTC',
      'completionRule': 'finished_session_with_finished_at',
      'completedLessons': {'allTime': 51, 'last7Days': 4, 'last30Days': 11},
      'streaks': {'currentDays': 3, 'longestDays': 7},
      'lastCompletedLesson': {
        'completedAtUtc': '2026-07-19T10:42:00Z',
        'studyLanguage': 'Spanish',
        'level': 'A1',
        'topicTitle': 'Daily Life',
        'subtopicTitle': 'Introductions',
      },
      'completedLessonsByStudyLanguage': [
        {'studyLanguage': 'Spanish', 'completedLessons': 30}
      ],
      'completedLessonsByLevel': [
        {'level': 'A1', 'completedLessons': 25}
      ],
      'dailyActivity': List.generate(
        35,
        (index) => {
          'activityDate': DateTime.utc(2026, 6, 15)
              .add(Duration(days: index))
              .toIso8601String()
              .substring(0, 10),
          'completedLessons': index == 34 ? 1 : 0,
        },
      ),
    };

void main() {
  test('parses complete backend-owned progress without recalculating values',
      () {
    final json = completeProgressJson()..['futureBackendField'] = true;
    final progress = ProgressResponse.fromJson(json);

    expect(progress.generatedAtUtc.isUtc, isTrue);
    expect(progress.completedLessons.allTime, 51);
    expect(progress.streaks.longestDays, 7);
    expect(progress.lastCompletedLesson?.studyLanguage, 'Spanish');
    expect(progress.dailyActivity, hasLength(35));
  });

  test('parses an empty account with null lesson and empty distributions', () {
    final json = completeProgressJson()
      ..['completedLessons'] = {}
      ..['streaks'] = {}
      ..['lastCompletedLesson'] = null
      ..['completedLessonsByStudyLanguage'] = []
      ..['completedLessonsByLevel'] = [];
    final progress = ProgressResponse.fromJson(json);

    expect(progress.completedLessons.allTime, 0);
    expect(progress.streaks.currentDays, 0);
    expect(progress.lastCompletedLesson, isNull);
    expect(progress.completedLessonsByStudyLanguage, isEmpty);
    expect(progress.completedLessonsByLevel, isEmpty);
  });

  test('allows nullable learner-facing last-lesson text and keeps dates UTC',
      () {
    final json = completeProgressJson();
    json['lastCompletedLesson'] = {
      ...(json['lastCompletedLesson'] as Map<String, dynamic>),
      'studyLanguage': null,
      'level': null,
      'topicTitle': null,
      'subtopicTitle': null,
    };
    final progress = ProgressResponse.fromJson(json);

    expect(progress.lastCompletedLesson?.studyLanguage, isNull);
    expect(progress.lastCompletedLesson?.completedAtUtc.isUtc, isTrue);
    expect(
        progress.dailyActivity.first.activityDate, DateTime.utc(2026, 6, 15));
  });

  test('malformed or missing count values default safely', () {
    final json = completeProgressJson()
      ..['completedLessons'] = {'allTime': -1, 'last7Days': 'four'}
      ..['streaks'] = {'currentDays': 1.5};
    final progress = ProgressResponse.fromJson(json);

    expect(progress.completedLessons.allTime, 0);
    expect(progress.completedLessons.last7Days, 0);
    expect(progress.completedLessons.last30Days, 0);
    expect(progress.streaks.currentDays, 0);
    expect(progress.streaks.longestDays, 0);
  });
}
