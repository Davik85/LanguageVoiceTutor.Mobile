import '../models/lesson_start_selection.dart';
import 'app_localizations.dart';

class LessonDisplayText {
  const LessonDisplayText(this.label, this.description);

  final String label;
  final String description;
}

extension LessonSelectionLocalization on AppLocalizations {
  LessonDisplayText localizedLevel(LessonOption option) {
    return switch (option.id) {
      'a1' => LessonDisplayText(levelA1Label, levelA1Description),
      'a2' => LessonDisplayText(levelA2Label, levelA2Description),
      'b1' => LessonDisplayText(levelB1Label, levelB1Description),
      'b2' => LessonDisplayText(levelB2Label, levelB2Description),
      _ => LessonDisplayText(option.label, option.description),
    };
  }

  LessonDisplayText localizedTopic(LessonOption option) {
    return switch (option.id) {
      'daily_life' =>
        LessonDisplayText(topicDailyLifeLabel, topicDailyLifeDescription),
      'travel' => LessonDisplayText(topicTravelLabel, topicTravelDescription),
      'work_business' =>
        LessonDisplayText(topicWorkBusinessLabel, topicWorkBusinessDescription),
      'job_interview' =>
        LessonDisplayText(topicJobInterviewLabel, topicJobInterviewDescription),
      'restaurant_cafe' => LessonDisplayText(
          topicRestaurantCafeLabel, topicRestaurantCafeDescription),
      'free_conversation' => LessonDisplayText(
          topicFreeConversationLabel, topicFreeConversationDescription),
      _ => LessonDisplayText(option.label, option.description),
    };
  }

  LessonDisplayText localizedSituation(LessonSituationOption option) {
    return switch (option.id) {
      'introductions' => LessonDisplayText(
          situationIntroductionsLabel, situationIntroductionsDescription),
      'asking_for_help' => LessonDisplayText(
          situationAskingForHelpLabel, situationAskingForHelpDescription),
      'small_talk_neighbor' => LessonDisplayText(
          situationSmallTalkNeighborLabel,
          situationSmallTalkNeighborDescription),
      'talking_about_day' => LessonDisplayText(
          situationTalkingAboutDayLabel, situationTalkingAboutDayDescription),
      'making_plans' => LessonDisplayText(
          situationMakingPlansLabel, situationMakingPlansDescription),
      'airport_check_in' => LessonDisplayText(
          situationAirportCheckInLabel, situationAirportCheckInDescription),
      'hotel_check_in' => LessonDisplayText(
          situationHotelCheckInLabel, situationHotelCheckInDescription),
      'asking_for_directions' => LessonDisplayText(
          situationAskingForDirectionsLabel,
          situationAskingForDirectionsDescription),
      'ordering_transport' => LessonDisplayText(situationOrderingTransportLabel,
          situationOrderingTransportDescription),
      'lost_luggage' => LessonDisplayText(
          situationLostLuggageLabel, situationLostLuggageDescription),
      'asking_for_clarification' => LessonDisplayText(
          situationAskingForClarificationLabel,
          situationAskingForClarificationDescription),
      'daily_standup' => LessonDisplayText(
          situationDailyStandupLabel, situationDailyStandupDescription),
      'client_phone_call' => LessonDisplayText(
          situationClientPhoneCallLabel, situationClientPhoneCallDescription),
      'discussing_deadlines' => LessonDisplayText(
          situationDiscussingDeadlinesLabel,
          situationDiscussingDeadlinesDescription),
      'first_meeting' => LessonDisplayText(
          situationFirstMeetingLabel, situationFirstMeetingDescription),
      'tell_me_about_yourself' => LessonDisplayText(
          situationTellMeAboutYourselfLabel,
          situationTellMeAboutYourselfDescription),
      'questions_at_end' => LessonDisplayText(
          situationQuestionsAtEndLabel, situationQuestionsAtEndDescription),
      'work_experience' => LessonDisplayText(
          situationWorkExperienceLabel, situationWorkExperienceDescription),
      'why_this_job' => LessonDisplayText(
          situationWhyThisJobLabel, situationWhyThisJobDescription),
      'strengths_weaknesses' => LessonDisplayText(
          situationStrengthsWeaknessesLabel,
          situationStrengthsWeaknessesDescription),
      'wrong_order' => LessonDisplayText(
          situationWrongOrderLabel, situationWrongOrderDescription),
      'booking_table' => LessonDisplayText(
          situationBookingTableLabel, situationBookingTableDescription),
      'ordering_food' => LessonDisplayText(
          situationOrderingFoodLabel, situationOrderingFoodDescription),
      'asking_ingredients' => LessonDisplayText(situationAskingIngredientsLabel,
          situationAskingIngredientsDescription),
      'paying_bill' => LessonDisplayText(
          situationPayingBillLabel, situationPayingBillDescription),
      'open_conversation' => LessonDisplayText(
          situationOpenConversationLabel, situationOpenConversationDescription),
      _ => LessonDisplayText(option.label, option.description),
    };
  }
}
