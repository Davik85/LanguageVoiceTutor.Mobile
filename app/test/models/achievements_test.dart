import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/achievements.dart';

Map<String, dynamic> item({
  String id = 'streak-7-v1',
  String category = 'streak',
  String scope = 'account',
  String? studyLanguage,
  String? topicId,
  String? lessonContentId,
  bool unlocked = false,
  String? unlockedAtUtc,
  int currentProgress = 0,
  int targetProgress = 7,
}) =>
    {
      'id': id,
      'category': category,
      'scope': scope,
      'studyLanguage': studyLanguage,
      'topicId': topicId,
      'lessonContentId': lessonContentId,
      'title': 'Seven days',
      'description': 'Practice for seven days.',
      'iconKey': 'streak',
      'unlocked': unlocked,
      'unlockedAtUtc': unlockedAtUtc,
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
    };

Map<String, dynamic> response({
  String? activeStudyLanguage = 'English',
  List<Map<String, dynamic>>? achievements,
  List<Map<String, dynamic>>? homeItems,
}) =>
    {
      'generatedAtUtc': '2026-07-19T12:00:00Z',
      'calendarTimezone': 'UTC',
      'activeStudyLanguage': activeStudyLanguage,
      'summary': {'unlocked': 1, 'total': achievements?.length ?? 1},
      'achievements': achievements ?? [item()],
      'homeItems': homeItems ?? [item()],
    };

void main() {
  test('parses the complete backend response with nullable account fields', () {
    final parsed = AchievementsResponse.fromJson(response()..['future'] = true);

    expect(parsed.generatedAtUtc.isUtc, isTrue);
    expect(parsed.activeStudyLanguage, 'English');
    expect(parsed.achievements.single.topicId, isNull);
    expect(parsed.achievements.single.lessonContentId, isNull);
    expect(parsed.achievements.single.unlockedAtUtc, isNull);
  });

  test('preserves backend achievement and Home order without recalculation',
      () {
    final achievements = [
      item(id: 'second', currentProgress: 7, targetProgress: 7),
      item(id: 'first', currentProgress: 1, targetProgress: 100),
    ];
    final homes = [item(id: 'home-b'), item(id: 'home-a')];
    final parsed = AchievementsResponse.fromJson(
      response(achievements: achievements, homeItems: homes),
    );

    expect(parsed.achievements.map((value) => value.id), ['second', 'first']);
    expect(parsed.homeItems.map((value) => value.id), ['home-b', 'home-a']);
    expect(parsed.achievements.first.currentProgress, 7);
  });

  test('parses study-language unlock dates as UTC and accepts 11 or 41 items',
      () {
    final studyItem = item(
      id: 'subtopic-travel-travel_airport_check_in-v1',
      category: 'subtopic',
      scope: 'studyLanguage',
      studyLanguage: 'English',
      topicId: 'travel',
      lessonContentId: 'travel_airport_check_in',
      unlocked: true,
      unlockedAtUtc: '2026-07-18T14:30:00Z',
      currentProgress: 1,
      targetProgress: 1,
    );
    final eleven = List.generate(11, (_) => item());
    final fortyOne = List.generate(41, (_) => studyItem);

    expect(
        AchievementsResponse.fromJson(
                response(activeStudyLanguage: null, achievements: eleven))
            .achievements,
        hasLength(11));
    final parsed =
        AchievementsResponse.fromJson(response(achievements: fortyOne));
    expect(parsed.achievements, hasLength(41));
    expect(parsed.achievements.first.unlockedAtUtc?.isUtc, isTrue);
  });

  test('rejects malformed top-level and required item fields', () {
    expect(() => AchievementsResponse.fromJson({}), throwsFormatException);
    final malformed = response()..['achievements'] = [item()..['id'] = 7];
    expect(
        () => AchievementsResponse.fromJson(malformed), throwsFormatException);
  });
}
