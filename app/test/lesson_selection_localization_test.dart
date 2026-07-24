import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations_de.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations_en.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations_es.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations_fr.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations_ru.dart';
import 'package:language_voice_tutor_mobile/l10n/lesson_selection_localization.dart';
import 'package:language_voice_tutor_mobile/models/lesson_start_selection.dart';
import 'package:language_voice_tutor_mobile/screens/choose_situation_screen.dart';
import 'package:language_voice_tutor_mobile/screens/choose_topic_screen.dart';

const _locales = [
  Locale('en'),
  Locale('ru'),
  Locale('es'),
  Locale('fr'),
  Locale('de'),
];

const _canonicalSituationMatrix = [
  (
    topicLookupId: 'daily_life',
    situationId: 'introductions',
    topicId: '1',
    topicTitle: 'Daily Life',
    subtopicId: '101',
    subtopicTitle: 'Introductions',
    situation: 'Introductions',
    lessonContentId: 'everyday_english_introductions',
  ),
  (
    topicLookupId: 'daily_life',
    situationId: 'asking_for_help',
    topicId: '1',
    topicTitle: 'Daily Life',
    subtopicId: '103',
    subtopicTitle: 'Asking for help',
    situation: 'Asking for help',
    lessonContentId: 'everyday_english_asking_for_help',
  ),
  (
    topicLookupId: 'daily_life',
    situationId: 'small_talk_neighbor',
    topicId: '1',
    topicTitle: 'Daily Life',
    subtopicId: '102',
    subtopicTitle: 'Small talk with a neighbor',
    situation: 'Small talk with a neighbor',
    lessonContentId: 'everyday_english_small_talk_with_a_neighbor',
  ),
  (
    topicLookupId: 'daily_life',
    situationId: 'talking_about_day',
    topicId: '1',
    topicTitle: 'Daily Life',
    subtopicId: '105',
    subtopicTitle: 'Talking about your day',
    situation: 'Talking about your day',
    lessonContentId: 'everyday_english_talking_about_your_day',
  ),
  (
    topicLookupId: 'daily_life',
    situationId: 'making_plans',
    topicId: '1',
    topicTitle: 'Daily Life',
    subtopicId: '104',
    subtopicTitle: 'Making plans',
    situation: 'Making plans',
    lessonContentId: 'everyday_english_making_plans',
  ),
  (
    topicLookupId: 'travel',
    situationId: 'airport_check_in',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '201',
    subtopicTitle: 'Airport check-in',
    situation: 'Airport check-in',
    lessonContentId: 'travel_airport_check_in',
  ),
  (
    topicLookupId: 'travel',
    situationId: 'hotel_check_in',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '202',
    subtopicTitle: 'Hotel check-in',
    situation: 'Hotel check-in',
    lessonContentId: 'travel_hotel_check_in',
  ),
  (
    topicLookupId: 'travel',
    situationId: 'asking_for_directions',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '203',
    subtopicTitle: 'Asking for directions',
    situation: 'Asking for directions',
    lessonContentId: 'travel_asking_for_directions',
  ),
  (
    topicLookupId: 'travel',
    situationId: 'ordering_transport',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '204',
    subtopicTitle: 'Ordering transport',
    situation: 'Ordering transport',
    lessonContentId: 'travel_ordering_transport',
  ),
  (
    topicLookupId: 'travel',
    situationId: 'lost_luggage',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '205',
    subtopicTitle: 'Lost luggage',
    situation: 'Lost luggage',
    lessonContentId: 'travel_lost_luggage',
  ),
  (
    topicLookupId: 'work_business',
    situationId: 'asking_for_clarification',
    topicId: '3',
    topicTitle: 'Work & Business',
    subtopicId: '304',
    subtopicTitle: 'Asking for clarification',
    situation: 'Asking for clarification',
    lessonContentId: 'work_business_asking_for_clarification',
  ),
  (
    topicLookupId: 'work_business',
    situationId: 'daily_standup',
    topicId: '3',
    topicTitle: 'Work & Business',
    subtopicId: '302',
    subtopicTitle: 'Daily standup',
    situation: 'Daily standup',
    lessonContentId: 'work_business_daily_standup',
  ),
  (
    topicLookupId: 'work_business',
    situationId: 'client_phone_call',
    topicId: '3',
    topicTitle: 'Work & Business',
    subtopicId: '303',
    subtopicTitle: 'Phone call with a client',
    situation: 'Phone call with a client',
    lessonContentId: 'work_business_phone_call_with_a_client',
  ),
  (
    topicLookupId: 'work_business',
    situationId: 'discussing_deadlines',
    topicId: '3',
    topicTitle: 'Work & Business',
    subtopicId: '305',
    subtopicTitle: 'Discussing deadlines',
    situation: 'Discussing deadlines',
    lessonContentId: 'work_business_discussing_deadlines',
  ),
  (
    topicLookupId: 'work_business',
    situationId: 'first_meeting',
    topicId: '3',
    topicTitle: 'Work & Business',
    subtopicId: '301',
    subtopicTitle: 'First meeting',
    situation: 'First meeting',
    lessonContentId: 'work_business_first_meeting',
  ),
  (
    topicLookupId: 'job_interview',
    situationId: 'tell_me_about_yourself',
    topicId: '4',
    topicTitle: 'Job Interview',
    subtopicId: '401',
    subtopicTitle: 'Tell me about yourself',
    situation: 'Tell me about yourself',
    lessonContentId: 'job_interview_tell_me_about_yourself',
  ),
  (
    topicLookupId: 'job_interview',
    situationId: 'questions_at_end',
    topicId: '4',
    topicTitle: 'Job Interview',
    subtopicId: '405',
    subtopicTitle: 'Asking questions at the end',
    situation: 'Asking questions at the end',
    lessonContentId: 'job_interview_asking_questions_at_the_end',
  ),
  (
    topicLookupId: 'job_interview',
    situationId: 'work_experience',
    topicId: '4',
    topicTitle: 'Job Interview',
    subtopicId: '402',
    subtopicTitle: 'Work experience',
    situation: 'Work experience',
    lessonContentId: 'job_interview_work_experience',
  ),
  (
    topicLookupId: 'job_interview',
    situationId: 'why_this_job',
    topicId: '4',
    topicTitle: 'Job Interview',
    subtopicId: '404',
    subtopicTitle: 'Why do you want this job?',
    situation: 'Why do you want this job?',
    lessonContentId: 'job_interview_why_do_you_want_this_job',
  ),
  (
    topicLookupId: 'job_interview',
    situationId: 'strengths_weaknesses',
    topicId: '4',
    topicTitle: 'Job Interview',
    subtopicId: '403',
    subtopicTitle: 'Strengths and weaknesses',
    situation: 'Strengths and weaknesses',
    lessonContentId: 'job_interview_strengths_and_weaknesses',
  ),
  (
    topicLookupId: 'restaurant_cafe',
    situationId: 'wrong_order',
    topicId: '5',
    topicTitle: 'Restaurant & Cafe',
    subtopicId: '504',
    subtopicTitle: 'Handling a wrong order',
    situation: 'Handling a wrong order',
    lessonContentId: 'restaurant_and_cafe_handling_a_wrong_order',
  ),
  (
    topicLookupId: 'restaurant_cafe',
    situationId: 'booking_table',
    topicId: '5',
    topicTitle: 'Restaurant & Cafe',
    subtopicId: '501',
    subtopicTitle: 'Booking a table',
    situation: 'Booking a table',
    lessonContentId: 'restaurant_and_cafe_booking_a_table',
  ),
  (
    topicLookupId: 'restaurant_cafe',
    situationId: 'ordering_food',
    topicId: '5',
    topicTitle: 'Restaurant & Cafe',
    subtopicId: '502',
    subtopicTitle: 'Ordering food',
    situation: 'Ordering food',
    lessonContentId: 'restaurant_and_cafe_ordering_food',
  ),
  (
    topicLookupId: 'restaurant_cafe',
    situationId: 'asking_ingredients',
    topicId: '5',
    topicTitle: 'Restaurant & Cafe',
    subtopicId: '503',
    subtopicTitle: 'Asking about ingredients',
    situation: 'Asking about ingredients',
    lessonContentId: 'restaurant_and_cafe_asking_about_ingredients',
  ),
  (
    topicLookupId: 'restaurant_cafe',
    situationId: 'paying_bill',
    topicId: '5',
    topicTitle: 'Restaurant & Cafe',
    subtopicId: '505',
    subtopicTitle: 'Paying the bill',
    situation: 'Paying the bill',
    lessonContentId: 'restaurant_and_cafe_paying_the_bill',
  ),
  (
    topicLookupId: 'free_conversation',
    situationId: 'open_conversation',
    topicId: '6',
    topicTitle: 'Free Conversation',
    subtopicId: '601',
    subtopicTitle: 'Open conversation',
    situation: 'Open conversation',
    lessonContentId: 'free_conversation_open_conversation',
  ),
];

AppLocalizations _l10n(Locale locale) => switch (locale.languageCode) {
      'ru' => AppLocalizationsRu(),
      'es' => AppLocalizationsEs(),
      'fr' => AppLocalizationsFr(),
      'de' => AppLocalizationsDe(),
      _ => AppLocalizationsEn(),
    };

Widget _app(Locale locale, Widget child) => MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

class _LanguageBoundaryHarness extends StatefulWidget {
  const _LanguageBoundaryHarness();

  @override
  State<_LanguageBoundaryHarness> createState() =>
      _LanguageBoundaryHarnessState();
}

class _LanguageBoundaryHarnessState extends State<_LanguageBoundaryHarness> {
  String studyLanguage = 'en';
  String nativeLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          key: const Key('change-study-language'),
          onPressed: () => setState(() => studyLanguage = 'es'),
          child: const Text('study'),
        ),
        FilledButton(
          key: const Key('change-native-language'),
          onPressed: () => setState(() => nativeLanguage = 'de'),
          child: const Text('native'),
        ),
        Expanded(
          key: Key('languages-$studyLanguage-$nativeLanguage'),
          child: ChooseTopicScreen(selectedLevel: lessonLevels.first),
        ),
      ],
    );
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .physicalSize = const Size(1200, 12000);
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .resetPhysicalSize();
  });

  for (final locale in _locales) {
    testWidgets('${locale.languageCode} topic screen shows the full catalog',
        (tester) async {
      final l10n = _l10n(locale);
      await tester.pumpWidget(_app(
        locale,
        ChooseTopicScreen(selectedLevel: lessonLevels.first),
      ));
      await tester.pumpAndSettle();

      expect(find.text(l10n.chooseTopic), findsOneWidget);
      expect(find.text(l10n.chooseTopicTitle), findsOneWidget);
      expect(find.text(l10n.chooseTopicSubtitle), findsOneWidget);
      for (final topic in lessonTopics) {
        final display = l10n.localizedTopic(topic);
        expect(find.text(display.label), findsOneWidget);
        expect(find.text(display.description), findsOneWidget);
      }
    });

    testWidgets('${locale.languageCode} situation screens show every item',
        (tester) async {
      final l10n = _l10n(locale);
      for (final topic in lessonTopics) {
        await tester.pumpWidget(_app(
          locale,
          ChooseSituationScreen(
            selectedLevel: lessonLevels.first,
            selectedTopic: topic,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chooseSituation), findsOneWidget);
        expect(find.text(l10n.chooseSituationTitle), findsOneWidget);
        expect(find.text(l10n.chooseSituationSubtitle), findsOneWidget);
        for (final situation in lessonSituationsByTopic[topic.id]!) {
          final display = l10n.localizedSituation(situation);
          expect(find.text(display.label), findsOneWidget);
          expect(find.text(display.description), findsOneWidget);
        }
      }
    });
  }

  test('every catalog ID has a localized Stage 1 display mapping', () {
    for (final locale in _locales) {
      final l10n = _l10n(locale);
      for (final level in lessonLevels) {
        final display = l10n.localizedLevel(level);
        expect(display.label, isNotEmpty);
        expect(display.description, isNotEmpty);
      }
      for (final topic in lessonTopics) {
        final display = l10n.localizedTopic(topic);
        expect(display.label, isNotEmpty);
        expect(display.description, isNotEmpty);
        for (final situation in lessonSituationsByTopic[topic.id]!) {
          final situationDisplay = l10n.localizedSituation(situation);
          expect(situationDisplay.label, isNotEmpty);
          expect(situationDisplay.description, isNotEmpty);
        }
      }
    }
  });

  test('unknown IDs safely fall back to canonical display text', () {
    final l10n = AppLocalizationsRu();
    const unknown = LessonOption(
      id: 'future',
      label: 'Future label',
      description: 'Future description',
    );
    const unknownSituation = LessonSituationOption(
      id: 'future',
      label: 'Future situation',
      description: 'Future situation description',
      topicId: '99',
      topicTitle: 'Future topic',
      subtopicId: '999',
      subtopicTitle: 'Future situation',
      lessonContentId: 'future_content',
    );

    expect(l10n.localizedLevel(unknown).label, unknown.label);
    expect(l10n.localizedTopic(unknown).description, unknown.description);
    expect(
      l10n.localizedSituation(unknownSituation).label,
      unknownSituation.label,
    );
  });

  test('topic lookup is keyed by stable topic ID', () {
    expect(lessonSituationsByTopic.keys.toSet(),
        lessonTopics.map((topic) => topic.id).toSet());
    expect(lessonSituationsByTopic.containsKey('Daily Life'), isFalse);
    expect(lessonSituationsByTopic['daily_life']!.first.id, 'introductions');
  });

  test('all 26 situations match the pre-localization canonical catalog', () {
    final actualSituations = lessonSituationsByTopic.values
        .expand((situations) => situations)
        .toList(growable: false);
    expect(actualSituations, hasLength(26));
    expect(_canonicalSituationMatrix, hasLength(26));

    for (final expected in _canonicalSituationMatrix) {
      final situation = lessonSituationsByTopic[expected.topicLookupId]!
          .singleWhere((candidate) => candidate.id == expected.situationId);
      expect(situation.topicId, expected.topicId);
      expect(situation.topicTitle, expected.topicTitle);
      expect(situation.subtopicId, expected.subtopicId);
      expect(situation.subtopicTitle, expected.subtopicTitle);
      expect(situation.label, expected.situation);
      expect(situation.lessonContentId, expected.lessonContentId);
      expect(situation.selectedContextId, isNull);
      expect(situation.selectedContextTitle, isNull);
    }
  });

  test('selection construction rejects translated presentation values', () {
    const translatedLevel = LessonOption(
      id: 'a2',
      label: 'A2 Базовый',
      description: 'localized',
    );
    const translatedSituation = LessonSituationOption(
      id: 'introductions',
      label: 'Знакомство',
      description: 'localized',
      topicId: 'translated-topic',
      topicTitle: 'Повседневная жизнь',
      subtopicId: 'translated-subtopic',
      subtopicTitle: 'Знакомство',
      lessonContentId: 'translated-scenario-key',
      selectedContextId: 'translated-context',
      selectedContextTitle: 'Локализованный контекст',
    );

    final selection =
        lessonStartSelectionFor(translatedLevel, translatedSituation);

    expect(selection.level, 'A2 Elementary');
    expect(selection.topicId, '1');
    expect(selection.topicTitle, 'Daily Life');
    expect(selection.subtopicId, '101');
    expect(selection.subtopicTitle, 'Introductions');
    expect(selection.situation, 'Introductions');
    expect(selection.lessonContentId, 'everyday_english_introductions');
    expect(selection.selectedContextId, isNull);
    expect(selection.selectedContextTitle, isNull);
  });

  testWidgets('localized topic opens its canonical situation list',
      (tester) async {
    final l10n = AppLocalizationsRu();
    await tester.pumpWidget(_app(
      const Locale('ru'),
      ChooseTopicScreen(selectedLevel: lessonLevels.first),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.topicDailyLifeLabel));
    await tester.pumpAndSettle();

    expect(find.text(l10n.situationIntroductionsLabel), findsOneWidget);
    expect(find.text(l10n.situationAirportCheckInLabel), findsNothing);
  });

  testWidgets('localized situation preserves all canonical selection fields',
      (tester) async {
    LessonStartSelection? captured;
    final topic = lessonTopics.first;
    final situation = lessonSituationsByTopic[topic.id]!.first;
    final l10n = AppLocalizationsRu();
    await tester.pumpWidget(_app(
      const Locale('ru'),
      ChooseSituationScreen(
        selectedLevel: lessonLevels.first,
        selectedTopic: topic,
        onSituationSelected: (selection) => captured = selection,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.situationIntroductionsLabel));
    await tester.pump();

    expect(captured?.level, lessonLevels.first.label);
    expect(captured?.topicId, situation.topicId);
    expect(captured?.topicTitle, situation.topicTitle);
    expect(captured?.subtopicId, situation.subtopicId);
    expect(captured?.subtopicTitle, situation.subtopicTitle);
    expect(captured?.situation, situation.label);
    expect(captured?.lessonContentId, situation.lessonContentId);
    expect(captured?.selectedContextId, situation.selectedContextId);
    expect(captured?.selectedContextTitle, situation.selectedContextTitle);
    expect(captured?.topicTitle, isNot(l10n.topicDailyLifeLabel));
  });

  testWidgets('study and native language changes do not change display locale',
      (tester) async {
    final l10n = AppLocalizationsRu();
    await tester.pumpWidget(_app(
      const Locale('ru'),
      const Scaffold(body: _LanguageBoundaryHarness()),
    ));
    await tester.pumpAndSettle();

    expect(find.text(l10n.topicDailyLifeLabel), findsOneWidget);
    await tester.tap(find.byKey(const Key('change-study-language')));
    await tester.tap(find.byKey(const Key('change-native-language')));
    await tester.pump();

    expect(find.text(l10n.topicDailyLifeLabel), findsOneWidget);
    expect(find.text('Daily Life'), findsNothing);
  });
}
