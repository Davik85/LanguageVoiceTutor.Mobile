import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
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
}
