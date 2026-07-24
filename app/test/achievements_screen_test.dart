import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/achievements/achievement_title_resolver.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/models/achievements.dart';
import 'package:language_voice_tutor_mobile/screens/achievements_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';
import 'package:language_voice_tutor_mobile/widgets/achievement_preview.dart';

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
        {bool unlocked = false, String? language, String? title}) =>
    AchievementItem(
        id: id,
        category: category,
        scope: language == null ? 'account' : 'studyLanguage',
        studyLanguage: language,
        topicId: null,
        lessonContentId: null,
        title: title ?? id,
        description: 'Short description',
        iconKey: id == 'unknown' ? 'unrecognized' : 'streak',
        unlocked: unlocked,
        unlockedAtUtc: unlocked ? DateTime.utc(2026, 7, 18) : null,
        currentProgress: unlocked ? 7 : 3,
        targetProgress: 7);

Widget _screen(
  AchievementsResult result, {
  Locale locale = const Locale('en'),
}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AchievementsScreen(
        key: ValueKey(result),
        authService: _Service(result),
      ),
      routes: {'/login': (_) => const Scaffold(body: Text('Login route'))},
    );

Finder _semanticsLabel(String label) => find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == label,
    );

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
    expect(tester.getTopLeft(find.text('30-Day Streak')).dx,
        lessThan(tester.getTopLeft(find.text('7-Day Streak')).dx));
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

  group('achievements static localization', () {
    final response = AchievementsResponse(
      generatedAtUtc: DateTime.utc(2026, 7, 19),
      calendarTimezone: 'UTC',
      activeStudyLanguage: 'English',
      summary: const AchievementSummary(unlocked: 1, total: 2),
      achievements: [
        _item('Backend streak title', 'streak', unlocked: true),
        _item('Backend topic title', 'topic', language: 'English'),
      ],
      homeItems: const [],
    );

    testWidgets('Russian success keeps backend titles and localizes progress',
        (tester) async {
      await tester.pumpWidget(_screen(
        AchievementsResult.success(response),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Достижения'), findsOneWidget);
      expect(find.text('Открыто: 1 из 2'), findsOneWidget);
      expect(find.text('Серии'), findsOneWidget);
      expect(find.text('Темы'), findsOneWidget);
      expect(find.text('Завершено'), findsOneWidget);
      expect(find.text('3 из 7'), findsOneWidget);
      expect(find.text('Backend streak title'), findsOneWidget);
    });

    testWidgets('Russian empty and error states are localized', (tester) async {
      final empty = AchievementsResponse(
        generatedAtUtc: DateTime.utc(2026, 7, 19),
        calendarTimezone: 'UTC',
        activeStudyLanguage: null,
        summary: const AchievementSummary(unlocked: 0, total: 0),
        achievements: const [],
        homeItems: const [],
      );
      await tester.pumpWidget(_screen(
        AchievementsResult.success(empty),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Здесь появятся ваши достижения.'), findsOneWidget);

      await tester.pumpWidget(_screen(
        AchievementsResult.unavailable(),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Достижения временно недоступны'), findsOneWidget);

      await tester.pumpWidget(_screen(
        AchievementsResult.failed(),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(
        find.text('Не удалось загрузить достижения. Попробуйте ещё раз.'),
        findsOneWidget,
      );
    });

    testWidgets('Russian badge and preview semantics are localized',
        (tester) async {
      await tester.pumpWidget(_screen(
        AchievementsResult.success(response),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(
        _semanticsLabel('Разблокированное достижение: Backend streak title'),
        findsOneWidget,
      );
      expect(
        _semanticsLabel(
          'Заблокированное достижение: Backend topic title. Прогресс: 3 из 7.',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showQueuedAchievementPreview(
              context,
              response.achievements.first,
            ),
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        _semanticsLabel('Закрыть просмотр достижения Backend streak title'),
        findsOneWidget,
      );
      expect(
        _semanticsLabel('Закрыть все просмотры достижений'),
        findsOneWidget,
      );
    });

    for (final localeCase in const {
      'en': 'Achievements',
      'es': 'Logros',
      'fr': 'Succès',
      'de': 'Erfolge',
    }.entries) {
      testWidgets('${localeCase.key} renders static achievements UI',
          (tester) async {
        await tester.pumpWidget(_screen(
          AchievementsResult.success(response),
          locale: Locale(localeCase.key),
        ));
        await tester.pumpAndSettle();
        expect(find.text(localeCase.value), findsOneWidget);
      });
    }

    testWidgets('authRequired routing remains unchanged', (tester) async {
      await tester.pumpWidget(_screen(
        AchievementsResult.authRequired(),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Login route'), findsOneWidget);
    });
  });

  group('account achievement title localization', () {
    const ids = [
      'streak-7-v1',
      'streak-30-v1',
      'streak-60-v1',
      'streak-100-v1',
      'streak-365-v1',
      'lessons-1-v1',
      'lessons-5-v1',
      'lessons-10-v1',
      'lessons-25-v1',
      'lessons-50-v1',
      'lessons-100-v1',
    ];
    const titlesByLocale = {
      'en': [
        '7-Day Streak',
        '30-Day Streak',
        '60-Day Streak',
        '100-Day Streak',
        '365-Day Streak',
        'First Step',
        'Getting Started',
        '10 Lessons Strong',
        'Steady Learner',
        '50 Lessons Strong',
        'Century Club',
      ],
      'ru': [
        'Серия 7 дней',
        'Серия 30 дней',
        'Серия 60 дней',
        'Серия 100 дней',
        'Серия 365 дней',
        'Первый шаг',
        'Начало пути',
        '10 уроков — уверенно',
        'Стабильный ученик',
        '50 уроков — уверенно',
        'Клуб 100',
      ],
      'es': [
        'Racha de 7 días',
        'Racha de 30 días',
        'Racha de 60 días',
        'Racha de 100 días',
        'Racha de 365 días',
        'Primer paso',
        'Empezando',
        '10 lecciones superadas',
        'Estudiante constante',
        '50 lecciones superadas',
        'Club de los 100',
      ],
      'fr': [
        'Série de 7 jours',
        'Série de 30 jours',
        'Série de 60 jours',
        'Série de 100 jours',
        'Série de 365 jours',
        'Premier pas',
        'Bien commencé',
        '10 leçons réussies',
        'Apprenant régulier',
        '50 leçons réussies',
        'Club des 100',
      ],
      'de': [
        '7-Tage-Serie',
        '30-Tage-Serie',
        '60-Tage-Serie',
        '100-Tage-Serie',
        '365-Tage-Serie',
        'Erster Schritt',
        'Guter Start',
        '10 Lektionen gemeistert',
        'Beständig Lernende',
        '50 Lektionen gemeistert',
        'Hunderterclub',
      ],
    };

    testWidgets('all approved IDs resolve in every interface locale',
        (tester) async {
      for (final localeTitles in titlesByLocale.entries) {
        late List<String> resolvedTitles;
        await tester.pumpWidget(MaterialApp(
          locale: Locale(localeTitles.key),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              resolvedTitles = [
                for (final id in ids)
                  AchievementTitleResolver.resolve(
                      context, _item(id, 'streak')),
              ];
              return const SizedBox();
            },
          ),
        ));
        await tester.pumpAndSettle();
        expect(resolvedTitles, localeTitles.value);
      }
    });

    testWidgets('Russian cards, preview, and unknown fallback use titles',
        (tester) async {
      final response = AchievementsResponse(
        generatedAtUtc: DateTime.utc(2026, 7, 19),
        calendarTimezone: 'UTC',
        activeStudyLanguage: null,
        summary: const AchievementSummary(unlocked: 1, total: 3),
        achievements: [
          _item('streak-7-v1', 'streak', unlocked: true),
          _item('lessons-1-v1', 'lesson'),
          _item('unknown-id', 'other'),
        ],
        homeItems: const [],
      );
      await tester.pumpWidget(_screen(
        AchievementsResult.success(response),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Серия 7 дней'), findsOneWidget);
      expect(find.text('Первый шаг'), findsOneWidget);

      await tester.tap(find.byKey(const Key('all-achievement-streak-7-v1')));
      await tester.pumpAndSettle();
      expect(
        _semanticsLabel('Закрыть просмотр достижения Серия 7 дней'),
        findsOneWidget,
      );
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.text('unknown-id'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      expect(find.text('unknown-id'), findsOneWidget);
    });
  });

  group('daily life achievement title localization', () {
    const ids = [
      'subtopic-daily-life-everyday_english_introductions-v1',
      'subtopic-daily-life-everyday_english_small_talk_with_a_neighbor-v1',
      'subtopic-daily-life-everyday_english_asking_for_help-v1',
      'subtopic-daily-life-everyday_english_making_plans-v1',
      'subtopic-daily-life-everyday_english_talking_about_your_day-v1',
      'topic-daily-life-complete-v1',
    ];
    const titlesByLocale = {
      'en': [
        'First Hello',
        'Neighbor Chat',
        'Helpful Hand',
        'Plan Maker',
        'Day Teller',
        'Everyday Hero',
      ],
      'ru': [
        'Первое приветствие',
        'Разговор с соседом',
        'Рука помощи',
        'Планировщик',
        'Рассказ о дне',
        'Герой будней',
      ],
      'es': [
        'Primer saludo',
        'Charla con un vecino',
        'Mano amiga',
        'Creador de planes',
        'Cronista del día',
        'Héroe cotidiano',
      ],
      'fr': [
        'Premier bonjour',
        'Discussion de voisinage',
        'Coup de main',
        'Créateur de plans',
        'Récit du jour',
        'Héros du quotidien',
      ],
      'de': [
        'Erstes Hallo',
        'Nachbarschaftsplausch',
        'Helfende Hand',
        'Planmacher',
        'Tageserzähler',
        'Alltagsheld',
      ],
    };

    testWidgets('all Daily Life IDs resolve in every interface locale',
        (tester) async {
      for (final localeTitles in titlesByLocale.entries) {
        late List<String> resolvedTitles;
        late String accountTitle;
        await tester.pumpWidget(MaterialApp(
          locale: Locale(localeTitles.key),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              resolvedTitles = [
                for (final id in ids)
                  AchievementTitleResolver.resolve(context, _item(id, 'topic')),
              ];
              accountTitle = AchievementTitleResolver.resolve(
                context,
                _item('streak-7-v1', 'streak'),
              );
              return const SizedBox();
            },
          ),
        ));
        await tester.pumpAndSettle();
        expect(resolvedTitles, localeTitles.value);
        expect(accountTitle,
            localeTitles.key == 'ru' ? 'Серия 7 дней' : isNotEmpty);
      }
    });

    testWidgets('Russian cards and semantics use localized Daily Life titles',
        (tester) async {
      final response = AchievementsResponse(
        generatedAtUtc: DateTime.utc(2026, 7, 19),
        calendarTimezone: 'UTC',
        activeStudyLanguage: 'English',
        summary: const AchievementSummary(unlocked: 1, total: 3),
        achievements: [
          _item(ids.first, 'subtopic', unlocked: true),
          _item(ids[1], 'subtopic'),
          _item('unknown-daily-id', 'subtopic',
              title: 'Backend fallback title'),
        ],
        homeItems: const [],
      );
      await tester.pumpWidget(_screen(
        AchievementsResult.success(response),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Первое приветствие'), findsOneWidget);
      expect(find.text('Разговор с соседом'), findsOneWidget);
      expect(find.text('Backend fallback title'), findsOneWidget);
      expect(
        _semanticsLabel('Разблокированное достижение: Первое приветствие'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(Key('all-achievement-${ids.first}')));
      await tester.pumpAndSettle();
      expect(
        _semanticsLabel('Закрыть просмотр достижения Первое приветствие'),
        findsOneWidget,
      );
    });
  });
}
