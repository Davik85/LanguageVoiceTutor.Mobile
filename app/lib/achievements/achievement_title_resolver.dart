import 'package:flutter/widgets.dart';

import '../l10n/app_localizations_context.dart';
import '../models/achievements.dart';

/// Resolves only the achievement titles approved for localization.
class AchievementTitleResolver {
  const AchievementTitleResolver._();

  static String resolve(BuildContext context, AchievementItem achievement) =>
      switch (achievement.id) {
        'streak-7-v1' => context.l10n.achievementTitleStreak7,
        'streak-30-v1' => context.l10n.achievementTitleStreak30,
        'streak-60-v1' => context.l10n.achievementTitleStreak60,
        'streak-100-v1' => context.l10n.achievementTitleStreak100,
        'streak-365-v1' => context.l10n.achievementTitleStreak365,
        'lessons-1-v1' => context.l10n.achievementTitleLessons1,
        'lessons-5-v1' => context.l10n.achievementTitleLessons5,
        'lessons-10-v1' => context.l10n.achievementTitleLessons10,
        'lessons-25-v1' => context.l10n.achievementTitleLessons25,
        'lessons-50-v1' => context.l10n.achievementTitleLessons50,
        'lessons-100-v1' => context.l10n.achievementTitleLessons100,
        'subtopic-daily-life-everyday_english_introductions-v1' =>
          context.l10n.achievementTitleDailyLifeIntroductions,
        'subtopic-daily-life-everyday_english_small_talk_with_a_neighbor-v1' =>
          context.l10n.achievementTitleDailyLifeNeighborChat,
        'subtopic-daily-life-everyday_english_asking_for_help-v1' =>
          context.l10n.achievementTitleDailyLifeHelpfulHand,
        'subtopic-daily-life-everyday_english_making_plans-v1' =>
          context.l10n.achievementTitleDailyLifePlanMaker,
        'subtopic-daily-life-everyday_english_talking_about_your_day-v1' =>
          context.l10n.achievementTitleDailyLifeDayTeller,
        'topic-daily-life-complete-v1' =>
          context.l10n.achievementTitleDailyLifeEverydayHero,
        'subtopic-travel-travel_airport_check_in-v1' =>
          context.l10n.achievementTitleTravelAirportExpert,
        'subtopic-travel-travel_hotel_check_in-v1' =>
          context.l10n.achievementTitleTravelHonoredGuest,
        'subtopic-travel-travel_asking_for_directions-v1' =>
          context.l10n.achievementTitleTravelCityNavigator,
        'subtopic-travel-travel_ordering_transport-v1' =>
          context.l10n.achievementTitleTravelRideReady,
        'subtopic-travel-travel_lost_luggage-v1' =>
          context.l10n.achievementTitleTravelBaggageFinder,
        'topic-travel-complete-v1' =>
          context.l10n.achievementTitleTravelTraveler,
        'subtopic-work-business-work_business_first_meeting-v1' =>
          context.l10n.achievementTitleWorkMeetingReady,
        'subtopic-work-business-work_business_daily_standup-v1' =>
          context.l10n.achievementTitleWorkStandupStar,
        'subtopic-work-business-work_business_phone_call_with_a_client-v1' =>
          context.l10n.achievementTitleWorkClientCaller,
        'subtopic-work-business-work_business_asking_for_clarification-v1' =>
          context.l10n.achievementTitleWorkClearCommunicator,
        'subtopic-work-business-work_business_discussing_deadlines-v1' =>
          context.l10n.achievementTitleWorkDeadlineDriver,
        'topic-work-business-complete-v1' =>
          context.l10n.achievementTitleWorkBusinessReady,
        _ => achievement.title,
      };
}
