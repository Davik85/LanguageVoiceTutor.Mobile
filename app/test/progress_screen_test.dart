import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/progress.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/screens/progress_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _Api implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) =>
      throw UnimplementedError();
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
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

class _ProgressAuthService extends AuthService {
  _ProgressAuthService(this.responses)
      : super(apiClient: _Api(), storage: _Storage());

  final List<Future<ProgressResult> Function()> responses;
  int progressCalls = 0;

  @override
  Future<ProgressResult> fetchProgress() {
    progressCalls += 1;
    return responses.removeAt(0)();
  }

  @override
  Future<AuthUser> loadCurrentUser() async => AuthUser(
        userId: 'user',
        email: 'learner@example.com',
        displayName: 'Learner',
        createdAt: DateTime.utc(2026, 7, 19),
      );
}

ProgressResponse _progress({
  int allTime = 51,
  ProgressLastCompletedLesson? lastLesson,
  List<ProgressStudyLanguageDistributionItem>? languages,
  List<ProgressLevelDistributionItem>? levels,
  List<ProgressDailyActivityItem>? activity,
}) =>
    ProgressResponse(
      generatedAtUtc: DateTime.utc(2026, 7, 19, 12),
      calendarTimezone: 'UTC',
      completedLessons: ProgressCompletedLessons(
          allTime: allTime, last7Days: 4, last30Days: 11),
      streaks: const ProgressStreaks(currentDays: 3, longestDays: 7),
      lastCompletedLesson: lastLesson,
      completedLessonsByStudyLanguage: languages ??
          const [
            ProgressStudyLanguageDistributionItem(
                studyLanguage: 'Spanish', completedLessons: 30)
          ],
      completedLessonsByLevel: levels ??
          const [
            ProgressLevelDistributionItem(level: 'A1', completedLessons: 25)
          ],
      dailyActivity: activity ??
          List.generate(
            35,
            (index) => ProgressDailyActivityItem(
              activityDate:
                  DateTime.utc(2026, 6, 15).add(Duration(days: index)),
              completedLessons: index == 0
                  ? 0
                  : index == 34
                      ? 2
                      : 1,
            ),
          ),
    );

Widget _screen(_ProgressAuthService auth, {bool home = false}) => MaterialApp(
      home: home
          ? HomeScreen(authService: auth)
          : ProgressScreen(authService: auth),
      routes: {'/login': (_) => const Scaffold(body: Text('Login route'))},
    );

void main() {
  testWidgets('Home opens Progress once after repeated rapid taps',
      (tester) async {
    final auth = _ProgressAuthService([
      () async => ProgressResult.success(_progress()),
    ]);
    await tester.pumpWidget(_screen(auth, home: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-progress')), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-progress')));
    await tester.tap(find.byKey(const Key('home-progress')),
        warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('progress-screen')), findsOneWidget);
    expect(auth.progressCalls, 1);
    expect(find.byKey(const Key('lesson-history-screen')), findsNothing);
  });

  testWidgets(
      'shows loading once then displays exact backend values and content',
      (tester) async {
    final pending = Completer<ProgressResult>();
    final lesson = ProgressLastCompletedLesson(
      completedAtUtc: DateTime.utc(2026, 7, 19),
      studyLanguage: 'Spanish',
      level: 'A1',
      topicTitle: 'Daily Life',
      subtopicTitle: 'Introductions',
    );
    final auth = _ProgressAuthService([
      () => pending.future,
    ]);
    await tester.pumpWidget(_screen(auth));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(auth.progressCalls, 1);

    pending.complete(ProgressResult.success(_progress(lastLesson: lesson)));
    await tester.pumpAndSettle();

    expect(find.text('51'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('Jul 19, 2026'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    await tester.dragUntilVisible(
      find.byKey(const Key('progress-activity-2026-06-15')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(
        find.byKey(const Key('progress-activity-2026-06-15')), findsOneWidget);
    expect(
        find.byKey(const Key('progress-activity-2026-07-19')), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Lessons by language'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Lessons by language'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Lessons by level'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Lessons by level'), findsOneWidget);
    expect(find.textContaining('finished_session'), findsNothing);
    expect(find.text('UTC'), findsNothing);
  });

  testWidgets(
      'empty successful Progress is learner-friendly and omits empty sections',
      (tester) async {
    final auth = _ProgressAuthService([
      () async => ProgressResult.success(_progress(
            allTime: 0,
            languages: const [],
            levels: const [],
            activity: List.generate(
              35,
              (index) => ProgressDailyActivityItem(
                activityDate:
                    DateTime.utc(2026, 6, 15).add(Duration(days: index)),
                completedLessons: 0,
              ),
            ),
          )),
    ]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('progress-empty')), findsOneWidget);
    expect(find.text('Your progress will appear here'), findsOneWidget);
    expect(find.text('Lessons by language'), findsNothing);
    expect(find.text('Lessons by level'), findsNothing);
  });

  testWidgets('omits null lesson fields and retries unavailable requests once',
      (tester) async {
    final pending = Completer<ProgressResult>();
    final auth = _ProgressAuthService([
      () async => ProgressResult.unavailable(),
      () => pending.future,
    ]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    expect(find.text('Progress is temporarily unavailable. Please try again.'),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('progress-retry')));
    await tester.tap(find.byKey(const Key('progress-retry')));
    await tester.pump();
    expect(auth.progressCalls, 2);

    pending.complete(ProgressResult.success(_progress(
      lastLesson: ProgressLastCompletedLesson(
        completedAtUtc: DateTime.utc(2026, 7, 19),
        studyLanguage: null,
        level: null,
        topicTitle: null,
        subtopicTitle: null,
      ),
      languages: const [],
      levels: const [],
    )));
    await tester.pumpAndSettle();
    expect(find.text('Last completed lesson'), findsOneWidget);
    expect(find.text('null'), findsNothing);
    expect(find.text('Lessons by language'), findsNothing);
    expect(find.text('Lessons by level'), findsNothing);
  });

  testWidgets('authentication-required Progress safely routes to Login',
      (tester) async {
    final auth = _ProgressAuthService([
      () async => ProgressResult.authRequired(),
    ]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();

    expect(find.text('Login route'), findsOneWidget);
    expect(find.textContaining('401'), findsNothing);
  });

  testWidgets('scrolls long learner-facing content on a small surface',
      (tester) async {
    final auth = _ProgressAuthService([
      () async => ProgressResult.success(_progress(
            lastLesson: ProgressLastCompletedLesson(
              completedAtUtc: DateTime.utc(2026, 7, 19),
              studyLanguage: 'Spanish',
              level: 'A1',
              topicTitle: 'A long practical conversation topic for travel',
              subtopicTitle: 'A detailed situation with useful learner context',
            ),
            languages: const [
              ProgressStudyLanguageDistributionItem(
                  studyLanguage: 'Spanish', completedLessons: 30),
              ProgressStudyLanguageDistributionItem(
                  studyLanguage: 'French', completedLessons: 21),
            ],
            levels: const [
              ProgressLevelDistributionItem(level: 'A1', completedLessons: 25),
              ProgressLevelDistributionItem(level: 'B1', completedLessons: 26),
            ],
          )),
    ]);
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Lessons by level'),
      find.byType(ListView),
      const Offset(0, -200),
    );

    expect(find.text('Lessons by level'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
