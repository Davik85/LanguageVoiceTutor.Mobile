import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/achievements.dart';
import 'package:language_voice_tutor_mobile/screens/achievements_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _Api implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
}

class _Storage implements SessionStorage {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {}
}

class _Service extends AuthService {
  _Service(this.result) : super(apiClient: _Api(), storage: _Storage());
  final AchievementsResult result;
  @override
  Future<AchievementsResult> fetchAchievements() async => result;
}

AchievementItem _item(String id, String category,
        {bool unlocked = false, String? language}) =>
    AchievementItem(
        id: id,
        category: category,
        scope: language == null ? 'account' : 'studyLanguage',
        studyLanguage: language,
        topicId: null,
        lessonContentId: null,
        title: id,
        description: 'Short description',
        iconKey: id == 'unknown' ? 'unrecognized' : 'streak',
        unlocked: unlocked,
        unlockedAtUtc: unlocked ? DateTime.utc(2026, 7, 18) : null,
        currentProgress: unlocked ? 7 : 3,
        targetProgress: 7);

void main() {
  testWidgets(
      'full screen shows backend counts, groups, order, progress and fallback icon safely',
      (tester) async {
    final response = AchievementsResponse(
        generatedAtUtc: DateTime.utc(2026, 7, 19),
        calendarTimezone: 'UTC',
        activeStudyLanguage: 'English',
        summary: const AchievementSummary(unlocked: 2, total: 4),
        achievements: [
          _item('streak-30-v1', 'streak'),
          _item('streak-7-v1', 'streak', unlocked: true),
          _item('topic-travel-complete-v1', 'topic', language: 'English'),
          _item('unknown', 'new-category')
        ],
        homeItems: const []);
    await tester.pumpWidget(MaterialApp(
        home: AchievementsScreen(
            authService: _Service(AchievementsResult.success(response)))));
    await tester.pumpAndSettle();
    expect(find.text('2 of 4 unlocked'), findsOneWidget);
    expect(find.text('Streaks'), findsOneWidget);
    expect(find.text('3 of 7'), findsNWidgets(2));
    expect(find.text('Completed'), findsOneWidget);
    expect(tester.getTopLeft(find.text('streak-30-v1')).dx,
        lessThan(tester.getTopLeft(find.text('streak-7-v1')).dx));
    expect(find.byType(GridView), findsNWidgets(2));
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage)
                .assetName
                .startsWith('assets/achievements/')),
        findsNWidgets(3));
    await tester.tap(find.byKey(const Key('all-achievement-streak-7-v1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievement-preview')), findsOneWidget);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievement-preview')), findsNothing);

    await tester.tap(find.byKey(const Key('all-achievement-streak-30-v1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievement-preview')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
