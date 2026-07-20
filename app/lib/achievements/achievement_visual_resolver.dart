import 'package:flutter/material.dart';

import '../models/achievements.dart';

class AchievementVisual {
  const AchievementVisual({this.assetPath, required this.fallbackIcon});

  final String? assetPath;
  final IconData fallbackIcon;
}

/// Resolves approved local artwork only from the stable backend definition ID.
class AchievementVisualResolver {
  const AchievementVisualResolver._();

  static AchievementVisual resolve(AchievementItem achievement) =>
      AchievementVisual(
        assetPath: _assetPathByDefinitionId[achievement.id],
        fallbackIcon: _fallbackIconFor(achievement.iconKey),
      );

  static const Map<String, String> _assetPathByDefinitionId = {
    'streak-7-v1': 'assets/achievements/streak-7.webp',
    'streak-30-v1': 'assets/achievements/streak-30.webp',
    'streak-60-v1': 'assets/achievements/streak-60.webp',
    'streak-100-v1': 'assets/achievements/streak-100.webp',
    'streak-365-v1': 'assets/achievements/streak-365.webp',
    'lessons-1-v1': 'assets/achievements/lessons-1.webp',
    'lessons-5-v1': 'assets/achievements/lessons-5.webp',
    'lessons-10-v1': 'assets/achievements/lessons-10.webp',
    'lessons-25-v1': 'assets/achievements/lessons-25.webp',
    'lessons-50-v1': 'assets/achievements/lessons-50.webp',
    'lessons-100-v1': 'assets/achievements/lessons-100.webp',
    'topic-daily-life-complete-v1': 'assets/achievements/topic-daily-life.webp',
    'topic-travel-complete-v1': 'assets/achievements/topic-travel.webp',
    'topic-work-business-complete-v1':
        'assets/achievements/topic-work-business.webp',
    'topic-job-interview-complete-v1':
        'assets/achievements/topic-job-interview.webp',
    'topic-restaurant-cafe-complete-v1':
        'assets/achievements/topic-restaurant-cafe.webp',
    'subtopic-daily-life-everyday_english_introductions-v1':
        'assets/achievements/daily-life-introductions.webp',
    'subtopic-daily-life-everyday_english_small_talk_with_a_neighbor-v1':
        'assets/achievements/daily-life-neighbor-chat.webp',
    'subtopic-daily-life-everyday_english_asking_for_help-v1':
        'assets/achievements/daily-life-asking-for-help.webp',
    'subtopic-daily-life-everyday_english_making_plans-v1':
        'assets/achievements/daily-life-making-plans.webp',
    'subtopic-daily-life-everyday_english_talking_about_your_day-v1':
        'assets/achievements/daily-life-talking-about-your-day.webp',
    'subtopic-travel-travel_airport_check_in-v1':
        'assets/achievements/travel-airport-check-in.webp',
    'subtopic-travel-travel_hotel_check_in-v1':
        'assets/achievements/travel-hotel-check-in.webp',
    'subtopic-travel-travel_asking_for_directions-v1':
        'assets/achievements/travel-asking-for-directions.webp',
    'subtopic-travel-travel_ordering_transport-v1':
        'assets/achievements/travel-ordering-transport.webp',
    'subtopic-travel-travel_lost_luggage-v1':
        'assets/achievements/travel-lost-luggage.webp',
    'subtopic-work-business-work_business_first_meeting-v1':
        'assets/achievements/work-business-first-meeting.webp',
    'subtopic-work-business-work_business_daily_standup-v1':
        'assets/achievements/work-business-daily-standup.webp',
    'subtopic-work-business-work_business_phone_call_with_a_client-v1':
        'assets/achievements/work-business-client-call.webp',
    'subtopic-work-business-work_business_asking_for_clarification-v1':
        'assets/achievements/work-business-asking-for-clarification.webp',
    'subtopic-work-business-work_business_discussing_deadlines-v1':
        'assets/achievements/work-business-discussing-deadlines.webp',
    'subtopic-job-interview-job_interview_tell_me_about_yourself-v1':
        'assets/achievements/job-interview-tell-me-about-yourself.webp',
    'subtopic-job-interview-job_interview_work_experience-v1':
        'assets/achievements/job-interview-work-experience.webp',
    'subtopic-job-interview-job_interview_strengths_and_weaknesses-v1':
        'assets/achievements/job-interview-strengths-and-weaknesses.webp',
    'subtopic-job-interview-job_interview_why_do_you_want_this_job-v1':
        'assets/achievements/job-interview-why-this-job.webp',
    'subtopic-job-interview-job_interview_asking_questions_at_the_end-v1':
        'assets/achievements/job-interview-questions-at-end.webp',
    'subtopic-restaurant-cafe-restaurant_and_cafe_booking_a_table-v1':
        'assets/achievements/restaurant-cafe-booking-a-table.webp',
    'subtopic-restaurant-cafe-restaurant_and_cafe_ordering_food-v1':
        'assets/achievements/restaurant-cafe-ordering-food.webp',
    'subtopic-restaurant-cafe-restaurant_and_cafe_asking_about_ingredients-v1':
        'assets/achievements/restaurant-cafe-asking-about-ingredients.webp',
    'subtopic-restaurant-cafe-restaurant_and_cafe_handling_a_wrong_order-v1':
        'assets/achievements/restaurant-cafe-wrong-order.webp',
    'subtopic-restaurant-cafe-restaurant_and_cafe_paying_the_bill-v1':
        'assets/achievements/restaurant-cafe-paying-the-bill.webp',
  };

  static IconData _fallbackIconFor(String iconKey) => switch (iconKey) {
        'streak' => Icons.local_fire_department_rounded,
        'lesson-milestone' => Icons.emoji_events_rounded,
        'topic-daily-life' => Icons.home_rounded,
        'topic-travel' => Icons.explore_rounded,
        'topic-work-business' => Icons.business_center_rounded,
        'topic-job-interview' => Icons.work_outline_rounded,
        'topic-restaurant-cafe' => Icons.restaurant_rounded,
        'travel-airport' => Icons.flight_takeoff_rounded,
        'travel-hotel' => Icons.hotel_rounded,
        'travel-directions' => Icons.directions_rounded,
        'travel-transport' => Icons.directions_car_rounded,
        'travel-luggage' => Icons.luggage_rounded,
        _ => Icons.emoji_events_outlined,
      };
}

class AchievementArtwork extends StatelessWidget {
  const AchievementArtwork(
      {super.key,
      required this.visual,
      required this.color,
      required this.size});

  final AchievementVisual visual;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = visual.assetPath;
    if (assetPath == null) {
      return Icon(visual.fallbackIcon, color: color, size: size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(visual.fallbackIcon, color: color, size: size)),
    );
  }
}
