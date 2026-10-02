import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/config/app_config.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/achievements.dart';
import 'package:language_voice_tutor_mobile/models/lesson_access_decision.dart';
import 'package:language_voice_tutor_mobile/models/progress.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/models/tutor_options.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/services/tutor_options_service.dart';
import 'package:language_voice_tutor_mobile/l10n/lesson_selection_localization.dart';
import 'package:language_voice_tutor_mobile/models/lesson_start_selection.dart';
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
    this.studyLanguage = 'es',
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
  String currentLevel;
  String studyLanguage;
  ApiException? settingsFailure;
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
    return _settings(currentLevel).copyWith(studyLanguage: studyLanguage);
  }

  @override
  Future<UserSettingsUpdateResult> updateUserSettings(
      UserSettings settings) async {
    currentLevel = settings.currentLevel;
    studyLanguage = settings.studyLanguage;
    return UserSettingsUpdateResult.success(settings);
  }

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async =>
      SubscriptionStatus(
          userId: 'user-1',
          planName: 'Free',
          premiumActive: false,
          trialActive: false,
          freeLessonUsedToday: 0,
          freeLessonRemainingToday: 1,
          checkedAtUtc: DateTime.utc(2026),
          enforcementEnabled: true);

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
      speechVoice: 'coral',
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

class HomeTutorOptionsService extends TutorOptionsService {
  HomeTutorOptionsService() : super(apiClient: FakeApiClient());
  @override
  Future<TutorOptions> fetchTutorOptions() async => const TutorOptions(tutors: [
        TutorOption(tutorId: 'lana', displayName: 'Lana', isActive: true),
        TutorOption(tutorId: 'david', displayName: 'David', isActive: true),
        TutorOption(tutorId: 'nelli', displayName: 'Nelli', isActive: true),
      ]);
}

Widget _home({
  FakeAuthService? authService,
  AchievementPresentationStore? presentationStore,
  Locale locale = const Locale('en'),
  WidgetBuilder? settingsBuilder,
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
        SettingsScreen.routeName: settingsBuilder ??
            (_) => const Scaffold(body: Center(child: Text('Settings route'))),
      },
    );

void main() {
  testWidgets(
      'Home learning settings use localized level and language in the account card',
      (tester) async {
    final auth = FakeAuthService(currentLevel: 'B2');
    await tester
        .pumpWidget(_home(authService: auth, locale: const Locale('ru')));
    await tester.pumpAndSettle();
    final level = find.byKey(const Key('home-current-level'));
    final language = find.byKey(const Key('home-study-language'));
    final l10n = AppLocalizations.of(tester.element(level));
    expect(find.descendant(of: level, matching: find.text(l10n.currentLevel)),
        findsOneWidget);
    expect(
        find.descendant(
            of: level,
            matching:
                find.text(l10n.localizedLevel(lessonLevelFor('B2')).label)),
        findsOneWidget);
    expect(
        find.descendant(of: language, matching: find.text('Spanish / Español')),
        findsOneWidget);
    expect(
        find
            .ancestor(of: level, matching: find.byType(Card))
            .evaluate()
            .single
            .widget,
        same(find
            .ancestor(
                of: find.text('Вы вошли как David'),
                matching: find.byType(Card))
            .evaluate()
            .single
            .widget));
    expect(tester.getTopLeft(level).dy,
        greaterThan(tester.getTopLeft(find.text('Бесплатный план')).dy));
    expect(tester.getTopLeft(level).dy,
        lessThan(tester.getTopLeft(find.text('Достижения')).dy));
    expect(auth.fetchUserSettingsCallCount, 1);
  });
  for (final locale in ['en', 'pl', 'ru', 'de']) {
    testWidgets(
        '$locale Home learning fields fit equally at 360dp without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_home(
          authService: FakeAuthService(currentLevel: 'B2', studyLanguage: 'pt'),
          locale: Locale(locale)));
      await tester.pumpAndSettle();
      final level = find.byKey(const Key('home-current-level'));
      final language = find.byKey(const Key('home-study-language'));
      expect(tester.getSize(level).width, tester.getSize(language).width);
      expect(tester.getRect(level).overlaps(tester.getRect(language)), isFalse);
      for (final field in [level, language]) {
        final texts = tester.widgetList<Text>(
            find.descendant(of: field, matching: find.byType(Text)));
        expect(
            texts.every((text) =>
                text.maxLines == 1 && text.overflow == TextOverflow.ellipsis),
            isTrue);
        expect(
            tester.getSemantics(field),
            matchesSemantics(
                isButton: true,
                hasEnabledState: true,
                isEnabled: true,
                hasTapAction: true,
                label: field == level
                    ? '${AppLocalizations.of(tester.element(field)).currentLevel}: ${AppLocalizations.of(tester.element(field)).localizedLevel(lessonLevelFor('B2')).label}'
                    : '${AppLocalizations.of(tester.element(field)).studyLanguage}: Portuguese / Português'));
      }
      expect(tester.takeException(), isNull);
    });
  }
  for (final key in ['home-current-level', 'home-study-language']) {
    testWidgets(
        '$key opens existing Settings on Profile and reloads saved values on return',
        (tester) async {
      final auth = FakeAuthService();
      await tester.pumpWidget(_home(
          authService: auth,
          settingsBuilder: (_) => SettingsScreen(
              authService: auth,
              tutorOptionsService: HomeTutorOptionsService())));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          0);
      final scrollable = find.byType(Scrollable).first;
      final levelDropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.scrollUntilVisible(levelDropdown, 200,
          scrollable: scrollable);
      await tester.tap(levelDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('B2 Upper-Intermediate').last);
      await tester.pumpAndSettle();
      final languageDropdown =
          find.byType(DropdownButtonFormField<String>).at(1);
      await tester.ensureVisible(languageDropdown);
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('French / Français').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Save settings'), 300,
          scrollable: scrollable);
      await tester.tap(find.text('Save settings'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byKey(const Key('home-current-level')),
              matching: find.text('B2 Upper-Intermediate')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('home-study-language')),
              matching: find.text('French / Français')),
          findsOneWidget);
      expect(auth.fetchUserSettingsCallCount, 3);
    });
  }
  testWidgets(
      'ordinary Home settings failure leaves account progress achievements and Settings usable',
      (tester) async {
    final auth = FakeAuthService(
        settingsFailure: const ApiException('private settings failure'));
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();
    expect(find.text('Signed in as David'), findsOneWidget);
    expect(find.bySemanticsLabel('6 day learning streak'), findsOneWidget);
    expect(
        find.byKey(const Key('home-achievement-lessons-1-v1')), findsOneWidget);
    for (final key in ['home-current-level', 'home-study-language']) {
      expect(
          find.descendant(of: find.byKey(Key(key)), matching: find.text('—')),
          findsOneWidget);
    }
    expect(find.text('private settings failure'), findsNothing);
    await tester.dragUntilVisible(find.text('Open Settings'),
        find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings route'), findsOneWidget);
  });
  testWidgets(
      'Home settings auth requirement preserves sign-in-again navigation',
      (tester) async {
    await tester.pumpWidget(_home(
        authService: FakeAuthService(
            settingsFailure: const ApiException('Please sign in again.'))));
    await tester.pumpAndSettle();
    expect(find.text('Login route'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
  testWidgets(
      'Start lesson fetches authoritative settings instead of cached Home level',
      (tester) async {
    final auth = FakeAuthService(currentLevel: 'A1');
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();
    expect(auth.fetchUserSettingsCallCount, 1);
    auth.currentLevel = 'B2';
    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    expect(auth.fetchUserSettingsCallCount, 2);
    expect(
        tester
            .widget<ChooseTopicScreen>(find.byType(ChooseTopicScreen))
            .selectedLevel
            .id,
        'b2');
  });
  testWidgets('pending Home settings do not block account or progress loading',
      (tester) async {
    final pending = Completer<UserSettings>();
    final auth = FakeAuthService(settingsCompleter: pending);
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();
    expect(find.text('Signed in as David'), findsOneWidget);
    expect(find.bySemanticsLabel('6 day learning streak'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
    pending.complete(_settings('B2'));
    await tester.pumpAndSettle();
    expect(find.text('B2 Upper-Intermediate'), findsOneWidget);
  });

  testWidgets('Russian Home localizes primary learner-facing sections',
      (tester) async {
    await tester.pumpWidget(_home(locale: const Locale('ru')));
    await tester.pumpAndSettle();

    expect(find.text('Начать урок'), findsOneWidget);
    expect(find.text('Вы вошли как David'), findsOneWidget);
    expect(find.text('Бесплатный план'), findsOneWidget);
    expect(find.text('Достижения'), findsOneWidget);
    expect(find.text('Все'), findsOneWidget);
    await tester.dragUntilVisible(
        find.text('Ваша неделя'), find.byType(ListView), const Offset(0, -200));
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
        find.bySemanticsLabel('Orralen, Language Voice Tutor'), findsOneWidget);
    expect(find.byKey(const Key('home-orralen-logo')), findsOneWidget);
    expect(find.byKey(const Key('home-language-voice-tutor-wordmark')),
        findsOneWidget);

    final orralenLogo = tester.widget<Image>(
      find.byKey(const Key('home-orralen-logo')),
    );
    final wordmark = tester.widget<Image>(
      find.byKey(const Key('home-language-voice-tutor-wordmark')),
    );
    expect((orralenLogo.image as AssetImage).assetName,
        AppConfig.homeOrralenAsset);
    expect(
        (wordmark.image as AssetImage).assetName, AppConfig.homeWordmarkAsset);
    expect(
        tester.getCenter(find.byKey(const Key('home-orralen-logo'))).dx,
        lessThan(tester
            .getCenter(
                find.byKey(const Key('home-language-voice-tutor-wordmark')))
            .dx));
    expect(
        tester.getSize(find.byKey(const Key('home-orralen-logo'))).height,
        greaterThan(tester
            .getSize(
                find.byKey(const Key('home-language-voice-tutor-wordmark')))
            .height));
    expect(
        tester
                .getTopLeft(
                    find.byKey(const Key('home-language-voice-tutor-wordmark')))
                .dx -
            tester.getTopRight(find.byKey(const Key('home-orralen-logo'))).dx,
        lessThanOrEqualTo(4));
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
    await tester.dragUntilVisible(find.text('4 lessons in the last 7 days'),
        find.byType(ListView), const Offset(0, -200));
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
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

  group('account achievement title localization', () {
    testWidgets('Home uses the shared localized account achievement title',
        (tester) async {
      await tester.pumpWidget(_home(locale: const Locale('ru')));
      await tester.pumpAndSettle();

      expect(find.text('Первый шаг'), findsOneWidget);
      expect(find.text('Серия 7 дней'), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-achievement-streak-7-v1')));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Закрыть просмотр достижения Серия 7 дней'),
        findsOneWidget,
      );
    });
  });

  group('daily life achievement title localization', () {
    testWidgets('Home uses the shared localized Daily Life title',
        (tester) async {
      final dailyLife =
          _achievement('topic-daily-life-complete-v1', unlocked: true);
      final response = AchievementsResponse(
        generatedAtUtc: DateTime.utc(2026, 7, 19),
        calendarTimezone: 'UTC',
        activeStudyLanguage: 'English',
        summary: const AchievementSummary(unlocked: 1, total: 1),
        achievements: [dailyLife],
        homeItems: [dailyLife],
      );
      await tester.pumpWidget(_home(
        authService: FakeAuthService(
          achievementsResult: AchievementsResult.success(response),
        ),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Герой будней'), findsOneWidget);
    });
  });

  group('travel and work achievement title localization', () {
    testWidgets('Home uses shared Travel and Work title resolution',
        (tester) async {
      final travel = _achievement('topic-travel-complete-v1', unlocked: true);
      final work =
          _achievement('topic-work-business-complete-v1', unlocked: true);
      final response = AchievementsResponse(
        generatedAtUtc: DateTime.utc(2026, 7, 19),
        calendarTimezone: 'UTC',
        activeStudyLanguage: 'English',
        summary: const AchievementSummary(unlocked: 2, total: 2),
        achievements: [travel, work],
        homeItems: [travel, work],
      );
      await tester.pumpWidget(_home(
        authService: FakeAuthService(
          achievementsResult: AchievementsResult.success(response),
        ),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Путешественник'), findsOneWidget);
      expect(find.text('Готов к делу'), findsOneWidget);
    });
  });

  group('job interview and restaurant achievement title localization', () {
    testWidgets(
        'Home uses shared Job Interview and Restaurant title resolution',
        (tester) async {
      final interview =
          _achievement('topic-job-interview-complete-v1', unlocked: true);
      final restaurant =
          _achievement('topic-restaurant-cafe-complete-v1', unlocked: true);
      final response = AchievementsResponse(
        generatedAtUtc: DateTime.utc(2026, 7, 19),
        calendarTimezone: 'UTC',
        activeStudyLanguage: 'English',
        summary: const AchievementSummary(unlocked: 2, total: 2),
        achievements: [interview, restaurant],
        homeItems: [interview, restaurant],
      );
      await tester.pumpWidget(_home(
        authService: FakeAuthService(
          achievementsResult: AchievementsResult.success(response),
        ),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Готов к собеседованию'), findsOneWidget);
      expect(find.text('Ресторанный профи'), findsOneWidget);
    });
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
      find.bySemanticsLabel('Close First Step achievement preview'),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('Close 7-Day Streak achievement preview'),
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
    await tester.dragUntilVisible(find.text('Open Settings'),
        find.byType(ListView), const Offset(0, -200));
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

    expect(find.text('115'), findsOneWidget);
    expect(find.byKey(const Key('home-streak-emerald')), findsOneWidget);
    final emerald = tester.widget<Image>(
      find.byKey(const Key('home-streak-emerald')),
    );
    expect((emerald.image as AssetImage).assetName, AppConfig.homeEmeraldAsset);
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
    await tester.dragUntilVisible(
        find.text('Start lesson'), find.byType(ListView), const Offset(0, 200));
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

    expect(auth.fetchUserSettingsCallCount, 2);
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

    expect(auth.fetchUserSettingsCallCount, 2);
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

    expect(auth.fetchUserSettingsCallCount, 2);
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
    final auth = FakeAuthService();
    await tester.pumpWidget(_home(authService: auth));
    await tester.pumpAndSettle();

    auth.settingsFailure = const ApiException('Please sign in again.');
    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(auth.fetchUserSettingsCallCount, 2);
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

    expect(auth.fetchUserSettingsCallCount, 2);
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
