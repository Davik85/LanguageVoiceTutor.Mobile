import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/achievements.dart';
import 'package:language_voice_tutor_mobile/models/lesson_access_decision.dart';
import 'package:language_voice_tutor_mobile/models/progress.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/screens/choose_topic_screen.dart';
import 'package:language_voice_tutor_mobile/screens/settings_screen.dart';
import 'package:language_voice_tutor_mobile/services/achievement_presentation_store.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class FakeApiClient implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 200, body: '{}');

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 200, body: '{}');
}

class FakeAuthService extends AuthService {
  FakeAuthService({
    AuthUser? user,
    this.loadFailure,
    this.currentLevel = 'A1',
    this.settingsFailure,
    this.settingsCompleter,
    this.progressResult,
    this.achievementsResult,
  })  : user = user ??
            AuthUser(
              userId: 'user-1',
              email: 'david@example.com',
              displayName: 'David',
              createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            ),
        super(apiClient: FakeApiClient(), storage: MemoryStorage());

  final AuthUser? user;
  final ApiException? loadFailure;
  final String currentLevel;
  final ApiException? settingsFailure;
  final Completer<UserSettings>? settingsCompleter;
  final ProgressResult? progressResult;
  final AchievementsResult? achievementsResult;
  int fetchUserSettingsCallCount = 0;
  int fetchProgressCallCount = 0;
  int fetchAchievementsCallCount = 0;

  @override
  Future<AuthUser> loadCurrentUser() async {
    if (loadFailure != null) throw loadFailure!;
    return user!;
  }

  @override
  @override
  Future<LessonAccessDecision> fetchLessonAccessDecision() async =>
      LessonAccessDecision.fromJson({
        'canStartNewLesson': true,
        'premiumActive': false,
        'trialActive': false,
        'freeLessonRemainingToday': 1,
        'reason': 'A free lesson is available.',
      });

  @override
  Future<UserSettings> fetchUserSettings() async {
    fetchUserSettingsCallCount += 1;
    if (settingsFailure != null) throw settingsFailure!;
    if (settingsCompleter != null) return settingsCompleter!.future;
    return _settings(currentLevel);
  }

  @override
  Future<ProgressResult> fetchProgress() async {
    fetchProgressCallCount++;
    return progressResult ?? ProgressResult.success(_progress());
  }

  @override
  Future<AchievementsResult> fetchAchievements() async {
    fetchAchievementsCallCount++;
    return achievementsResult ?? AchievementsResult.success(_achievements());
  }
}

AchievementsResponse _achievements() => AchievementsResponse(
      generatedAtUtc: DateTime.utc(2026, 7, 19),
      calendarTimezone: 'UTC',
      activeStudyLanguage: 'English',
      summary: const AchievementSummary(unlocked: 1, total: 41),
      achievements: [_achievement('streak-7-v1'), _achievement('lessons-1-v1')],
      homeItems: [_achievement('lessons-1-v1'), _achievement('streak-7-v1')],
    );

AchievementItem _achievement(String id, {bool? unlocked}) => AchievementItem(
      id: id,
      category: 'streak',
      scope: 'account',
      studyLanguage: null,
      topicId: null,
      lessonContentId: null,
      title: id,
      description: 'Practice.',
      iconKey: id.startsWith('lessons') ? 'lesson-milestone' : 'streak',
      unlocked: unlocked ?? id == 'streak-7-v1',
      unlockedAtUtc: null,
      currentProgress: 2,
      targetProgress: 7,
    );

ProgressResponse _progress({int currentDays = 6, int last7Days = 4}) =>
    ProgressResponse(
      generatedAtUtc: DateTime.utc(2026, 7, 19),
      calendarTimezone: 'UTC',
      completedLessons: ProgressCompletedLessons(
        allTime: 12,
        last7Days: last7Days,
        last30Days: 8,
      ),
      streaks: ProgressStreaks(currentDays: currentDays, longestDays: 99),
      lastCompletedLesson: null,
      completedLessonsByStudyLanguage: const [],
      completedLessonsByLevel: const [],
      dailyActivity: List.generate(
        8,
        (index) => ProgressDailyActivityItem(
          activityDate: DateTime.utc(2026, 7, 11 + index),
          completedLessons: index == 0
              ? 9
              : index.isEven
                  ? 0
                  : 1,
        ),
      ),
    );

UserSettings _settings(String currentLevel) => UserSettings(
      nativeLanguage: 'en',
      studyLanguage: 'es',
      explanationLanguage: 'en',
      speechVoice: 'nova',
      speechSpeed: 1.0,
      conversationModeEnabled: true,
      selectedTutorId: UserSettings.defaultTutorId,
      currentLevel: currentLevel,
    );

class MemoryStorage implements SessionStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class MemoryAchievementPresentationStore
    implements AchievementPresentationStore {
  MemoryAchievementPresentationStore([Set<String>? presented])
      : presented = {...?presented};

  final Set<String> presented;

  @override
  Future<void> markPresented(String userId, String achievementId) async {
    presented.add(achievementId);
  }

  @override
  Future<Set<String>> readPresentedIds(String userId) async => {...presented};
}

Widget _home({
  FakeAuthService? authService,
  AchievementPresentationStore? presentationStore,
  Locale locale = const Locale('en'),
}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(
        authService: authService ?? FakeAuthService(),
        achievementPresentationStore: presentationStore ??
            MemoryAchievementPresentationStore({'streak-7-v1'}),
      ),
      routes: {
        '/login': (_) => const Scaffold(body: Text('Login route')),
        SettingsScreen.routeName: (_) =>
            const Scaffold(body: Center(child: Text('Settings route'))),
      },
    );

void main() {
  testWidgets('Russian Home localizes primary learner-facing sections',
      (tester) async {
    await tester.pumpWidget(_home(locale: const Locale('ru')));
    await tester.pumpAndSettle();

    expect(find.text('Начать урок'), findsOneWidget);
    expect(find.text('Вы вошли как David'), findsOneWidget);
    expect(find.text('Бесплатный план'), findsOneWidget);
    expect(find.text('Достижения'), findsOneWidget);
    expect(find.text('Все'), findsOneWidget);
    expect(find.text('Ваша неделя'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Открыть настройки'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Открыть настройки'), findsOneWidget);
  });

  for (final localeAndAction in const {
    'es': 'Empezar lección',
    'fr': 'Commencer la leçon',
    'de': 'Lektion starten',
  }.entries) {
    testWidgets('${localeAndAction.key} Home localizes the main action',
        (tester) async {
      await tester.pumpWidget(_home(locale: Locale(localeAndAction.key)));
      await tester.pumpAndSettle();
      expect(find.text(localeAndAction.value), findsOneWidget);
      expect(find.text('Start lesson'), findsNothing);
    });
  }

  testWidgets('home hides tutor diagnostics', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('Available tutors'), findsNothing);
    expect(find.text('Available tutors: Lana, Nelli, David'), findsNothing);
  });

  testWidgets('home shows logo and title', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-branded-title')), findsOneWidget);
    expect(
      find.text('Language Voice Tutor', findRichText: true),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Language Voice Tutor'), findsOneWidget);
    expect(find.byKey(const Key('app-logo')), findsOneWidget);
    expect(find.bySemanticsLabel('Language Voice Tutor logo'), findsOneWidget);

    final wordmark = tester.widget<Text>(
      find.byKey(const Key('home-branded-title')),
    );
    final spans = (wordmark.textSpan! as TextSpan).children!;
    expect((spans[0] as TextSpan).style?.foreground?.shader, isNotNull);
    expect((spans[1] as TextSpan).style?.foreground?.shader, isNotNull);
    expect((spans[2] as TextSpan).style?.foreground?.shader, isNotNull);
  });

  testWidgets('home uses the compact approved layout', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsNothing);
    expect(find.text('Practice real conversations by text and voice.'),
        findsNothing);
    expect(
        find.text('Choose a topic and situation, then start a guided lesson.'),
        findsNothing);
    expect(find.text('Start lesson'), findsOneWidget);
    expect(find.text('Signed in as David'), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Your account'), findsNothing);
    expect(find.text('david@example.com'), findsNothing);
    expect(find.textContaining('user-1'), findsNothing);
    expect(find.text('1 free lesson available today'), findsOneWidget);
    expect(find.text('Refresh status'), findsNothing);
    expect(find.byKey(const Key('home-lesson-history')), findsNothing);
    expect(find.byKey(const Key('home-progress')), findsNothing);
    await tester.dragUntilVisible(
      find.text('Open Settings'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Open Settings'), findsOneWidget);
  });

  testWidgets('home loads plan and progress once and uses backend fields',
      (tester) async {
    final auth = FakeAuthService();
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    expect(auth.fetchProgressCallCount, 1);
    expect(auth.fetchAchievementsCallCount, 1);
    expect(find.bySemanticsLabel('6 day learning streak'), findsOneWidget);
    expect(find.text('4 lessons in the last 7 days'), findsOneWidget);
    expect(find.byKey(const Key('home-activity-2026-07-11')), findsNothing);
    expect(find.byKey(const Key('home-activity-2026-07-12')), findsOneWidget);
    expect(find.byKey(const Key('home-activity-2026-07-18')), findsOneWidget);
  });

  testWidgets('tapping a daily activity bar shows its completed lesson count',
      (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    final bar = find.byKey(const Key('home-activity-2026-07-18'));
    await tester.tap(bar);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-activity-detail')), findsOneWidget);
    expect(find.text('Sat: 1 lesson completed'), findsOneWidget);
  });

  testWidgets(
      'home preserves backend achievement Home order and opens view all',
      (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    final lesson = tester
        .getTopLeft(find.byKey(const Key('home-achievement-lessons-1-v1')));
    final streak = tester
        .getTopLeft(find.byKey(const Key('home-achievement-streak-7-v1')));
    expect(lesson.dx, lessThan(streak.dx));
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage)
                .assetName
                .startsWith('assets/achievements/')),
        findsNWidgets(2));
    expect(tester.getTopLeft(find.text('Achievements')).dy,
        lessThan(tester.getTopLeft(find.text('Your week')).dy));

    await tester.tap(find.byKey(const Key('home-achievement-streak-7-v1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievement-preview')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievement-preview')), findsNothing);

    await tester.tap(find.byKey(const Key('home-achievements-view-all')));
    await tester.pumpAndSettle();
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('1 of 41 unlocked'), findsOneWidget);
  });

  testWidgets('new unlocked achievements are shown once in backend order',
      (tester) async {
    final presentationStore = MemoryAchievementPresentationStore();
    final response = AchievementsResponse(
      generatedAtUtc: DateTime.utc(2026, 7, 20),
      calendarTimezone: 'UTC',
      activeStudyLanguage: 'English',
      summary: const AchievementSummary(unlocked: 2, total: 41),
      achievements: [
        _achievement('lessons-1-v1', unlocked: true),
        _achievement('streak-7-v1', unlocked: true),
      ],
      homeItems: const [],
    );
    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        achievementsResult: AchievementsResult.success(response),
      ),
      presentationStore: presentationStore,
    ));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Close lessons-1-v1 achievement preview'),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('Close streak-7-v1 achievement preview'),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('achievement-preview')), findsNothing);
    expect(presentationStore.presented, {'lessons-1-v1', 'streak-7-v1'});

    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        achievementsResult: AchievementsResult.success(response),
      ),
      presentationStore: presentationStore,
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievement-preview')), findsNothing);
  });

  testWidgets('close all dismisses and records every queued achievement',
      (tester) async {
    final presentationStore = MemoryAchievementPresentationStore();
    final response = AchievementsResponse(
      generatedAtUtc: DateTime.utc(2026, 7, 20),
      calendarTimezone: 'UTC',
      activeStudyLanguage: 'English',
      summary: const AchievementSummary(unlocked: 2, total: 41),
      achievements: [
        _achievement('lessons-1-v1', unlocked: true),
        _achievement('streak-7-v1', unlocked: true),
      ],
      homeItems: const [],
    );
    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        achievementsResult: AchievementsResult.success(response),
      ),
      presentationStore: presentationStore,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('achievement-preview-close-all')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievement-preview')), findsNothing);
    expect(presentationStore.presented, {'lessons-1-v1', 'streak-7-v1'});
  });

  testWidgets('unavailable achievements leave Home actions usable',
      (tester) async {
    await tester.pumpWidget(_home(
        authService: FakeAuthService(
      achievementsResult: AchievementsResult.unavailable(),
    )));
    await tester.pumpAndSettle();

    expect(
        find.text('Achievements are temporarily unavailable'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
  });

  testWidgets('large streak fits a narrow screen without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    await tester.pumpWidget(_home(
      authService: FakeAuthService(
        progressResult: ProgressResult.success(_progress(currentDays: 115)),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('115 🍪'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('progress unavailability keeps Home actions usable',
      (tester) async {
    await tester.pumpWidget(_home(
      authService:
          FakeAuthService(progressResult: ProgressResult.unavailable()),
    ));
    await tester.pumpAndSettle();

    expect(
        find.bySemanticsLabel('Learning streak unavailable'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Activity is unavailable right now.'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Activity is unavailable right now.'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Open Settings'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Open Settings'), findsOneWidget);
  });

  testWidgets('home does not show backend or debug wording', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.textContaining('Backend'), findsNothing);
    expect(find.textContaining('diagnostics'), findsNothing);
    expect(find.textContaining('debug'), findsNothing);
  });

  testWidgets('Home starts lesson at topic selection using saved level',
      (tester) async {
    final auth = FakeAuthService(currentLevel: 'A2');
    await tester.pumpWidget(
      _home(authService: auth, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Начать урок'));
    await tester.pumpAndSettle();

    expect(auth.fetchUserSettingsCallCount, 1);
    expect(find.text('Выбор темы'), findsOneWidget);
    expect(find.text('Уровень: A2 Базовый'), findsOneWidget);
    expect(find.text('Выбор уровня'), findsNothing);
    expect(find.text('Choose Level'), findsNothing);
    final topicScreen = tester.widget<ChooseTopicScreen>(
      find.byType(ChooseTopicScreen),
    );
    expect(topicScreen.selectedLevel.id, 'a2');
    expect(topicScreen.selectedLevel.label, 'A2 Elementary');
  });

  testWidgets('B2 start lesson opens Choose Topic with localized context',
      (tester) async {
    final auth = FakeAuthService(currentLevel: 'B2');
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(auth.fetchUserSettingsCallCount, 1);
    expect(find.text('Choose Topic'), findsOneWidget);
    expect(find.text('Level: B2 Upper-Intermediate'), findsOneWidget);
  });

  testWidgets('repeated start taps while loading do not duplicate requests',
      (tester) async {
    final settingsCompleter = Completer<UserSettings>();
    final auth = FakeAuthService(settingsCompleter: settingsCompleter);
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.tap(find.text('Start lesson'));
    await tester.pump();

    expect(auth.fetchUserSettingsCallCount, 1);
    expect(find.text('Loading settings...'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton).first);
    expect(button.onPressed, isNull);

    settingsCompleter.complete(_settings('A1'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Topic'), findsOneWidget);
    expect(find.text('Level: A1 Beginner'), findsOneWidget);
  });

  testWidgets('settings authentication failure routes to Login',
      (tester) async {
    final auth = FakeAuthService(
      settingsFailure: const ApiException('Please sign in again.'),
    );
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(auth.fetchUserSettingsCallCount, 1);
    expect(find.text('Login route'), findsOneWidget);
  });

  testWidgets('ordinary settings failure keeps Home and shows friendly error',
      (tester) async {
    final auth = FakeAuthService(
      settingsFailure: const ApiException('private network detail'),
    );
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(auth.fetchUserSettingsCallCount, 1);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
    expect(
      find.text(
        'Unable to load your learning settings right now. Please try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Choose Topic'), findsNothing);
  });

  testWidgets('open settings opens settings route', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Open Settings'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings route'), findsOneWidget);
  });
}
