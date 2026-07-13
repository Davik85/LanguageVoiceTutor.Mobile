import 'dart:ui';

class LessonOption {
  const LessonOption({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

class LessonCardStyle {
  const LessonCardStyle({
    required this.familyId,
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
    required this.foregroundColor,
    required this.pressedColor,
  });

  final String familyId;
  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final Color foregroundColor;
  final Color pressedColor;
}

class LessonSituationOption extends LessonOption {
  const LessonSituationOption({
    required super.id,
    required super.label,
    required super.description,
    required this.topicId,
    required this.topicTitle,
    required this.subtopicId,
    required this.subtopicTitle,
    required this.lessonContentId,
    this.selectedContextId,
    this.selectedContextTitle,
  });

  final String topicId;
  final String topicTitle;
  final String subtopicId;
  final String subtopicTitle;
  final String lessonContentId;
  final String? selectedContextId;
  final String? selectedContextTitle;
}

class LessonStartSelection {
  const LessonStartSelection({
    required this.level,
    required this.topicId,
    required this.topicTitle,
    required this.subtopicId,
    required this.subtopicTitle,
    required this.situation,
    required this.lessonContentId,
    this.selectedContextId,
    this.selectedContextTitle,
    this.modeUsed = 'text',
  });

  final String level;
  final String topicId;
  final String topicTitle;
  final String subtopicId;
  final String subtopicTitle;
  final String situation;
  final String lessonContentId;
  final String? selectedContextId;
  final String? selectedContextTitle;
  final String modeUsed;

  String get topic => topicTitle;
}

const lessonLevels = [
  LessonOption(
    id: 'a1',
    label: 'A1 Beginner',
    description: 'Build simple greetings, needs, and short everyday answers.',
  ),
  LessonOption(
    id: 'a2',
    label: 'A2 Elementary',
    description:
        'Handle routine conversations with familiar words and phrases.',
  ),
  LessonOption(
    id: 'b1',
    label: 'B1 Intermediate',
    description:
        'Practice longer exchanges, opinions, and everyday problem solving.',
  ),
  LessonOption(
    id: 'b2',
    label: 'B2 Upper-Intermediate',
    description: 'Sharpen nuanced conversations with more natural detail.',
  ),
];

String canonicalLessonLevel(Object? value) {
  final fallback = lessonLevels.first.id.toUpperCase();
  if (value is! String) return fallback;

  final normalized = value.trim().toUpperCase();
  for (final level in lessonLevels) {
    final canonical = level.id.toUpperCase();
    if (canonical == normalized) return canonical;
  }
  return fallback;
}

LessonOption lessonLevelFor(Object? value) {
  final canonical = canonicalLessonLevel(value);
  return lessonLevels.firstWhere(
    (level) => level.id.toUpperCase() == canonical,
    orElse: () => lessonLevels.first,
  );
}

const lessonTopics = [
  LessonOption(
    id: 'daily_life',
    label: 'Daily Life',
    description: 'Everyday routines, errands, and casual conversations.',
  ),
  LessonOption(
    id: 'travel',
    label: 'Travel',
    description: 'Hotels, airports, directions, transport, and trip help.',
  ),
  LessonOption(
    id: 'work_business',
    label: 'Work & Business',
    description: 'Meetings, deadlines, clients, and professional requests.',
  ),
  LessonOption(
    id: 'job_interview',
    label: 'Job Interview',
    description:
        'Common interview answers, questions, and confidence practice.',
  ),
  LessonOption(
    id: 'restaurant_cafe',
    label: 'Restaurant & Cafe',
    description: 'Ordering, reservations, ingredients, and paying.',
  ),
  LessonOption(
    id: 'free_conversation',
    label: 'Free Conversation',
    description: 'Open-ended practice shaped around what you want to say.',
  ),
];

const travelSituations = [
  LessonSituationOption(
    id: 'airport_check_in',
    label: 'Airport check-in',
    description: 'Check documents, luggage, seats, and gate details.',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '201',
    subtopicTitle: 'Airport check-in',
    lessonContentId: 'travel_airport_check_in',
  ),
  LessonSituationOption(
    id: 'hotel_check_in',
    label: 'Hotel check-in',
    description: 'Confirm a reservation, room details, and arrival needs.',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '202',
    subtopicTitle: 'Hotel check-in',
    lessonContentId: 'travel_hotel_check_in',
  ),
  LessonSituationOption(
    id: 'asking_for_directions',
    label: 'Asking for directions',
    description: 'Ask where to go and understand simple route help.',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '203',
    subtopicTitle: 'Asking for directions',
    lessonContentId: 'travel_asking_for_directions',
  ),
  LessonSituationOption(
    id: 'ordering_transport',
    label: 'Ordering transport',
    description: 'Book a ride, explain a destination, and confirm price.',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '204',
    subtopicTitle: 'Ordering transport',
    lessonContentId: 'travel_ordering_transport',
  ),
  LessonSituationOption(
    id: 'lost_luggage',
    label: 'Lost luggage',
    description: 'Report a missing bag and give practical details.',
    topicId: '2',
    topicTitle: 'Travel',
    subtopicId: '205',
    subtopicTitle: 'Lost luggage',
    lessonContentId: 'travel_lost_luggage',
  ),
];

const Map<String, List<LessonSituationOption>> lessonSituationsByTopic = {
  'Travel': travelSituations,
  'Daily Life': [
    LessonSituationOption(
      id: 'introductions',
      label: 'Introductions',
      description: 'Say who you are and ask friendly first questions.',
      topicId: '1',
      topicTitle: 'Daily Life',
      subtopicId: '101',
      subtopicTitle: 'Introductions',
      lessonContentId: 'everyday_english_introductions',
    ),
    LessonSituationOption(
      id: 'asking_for_help',
      label: 'Asking for help',
      description: 'Explain what you need and respond politely.',
      topicId: '1',
      topicTitle: 'Daily Life',
      subtopicId: '103',
      subtopicTitle: 'Asking for help',
      lessonContentId: 'everyday_english_asking_for_help',
    ),
    LessonSituationOption(
      id: 'small_talk_neighbor',
      label: 'Small talk with a neighbor',
      description: 'Chat about daily life, weather, and local plans.',
      topicId: '1',
      topicTitle: 'Daily Life',
      subtopicId: '102',
      subtopicTitle: 'Small talk with a neighbor',
      lessonContentId: 'everyday_english_small_talk_with_a_neighbor',
    ),
    LessonSituationOption(
      id: 'talking_about_day',
      label: 'Talking about your day',
      description: 'Describe routines, timing, and what happened.',
      topicId: '1',
      topicTitle: 'Daily Life',
      subtopicId: '105',
      subtopicTitle: 'Talking about your day',
      lessonContentId: 'everyday_english_talking_about_your_day',
    ),
    LessonSituationOption(
      id: 'making_plans',
      label: 'Making plans',
      description: 'Suggest a time, agree, reschedule, or decline.',
      topicId: '1',
      topicTitle: 'Daily Life',
      subtopicId: '104',
      subtopicTitle: 'Making plans',
      lessonContentId: 'everyday_english_making_plans',
    ),
  ],
  'Work & Business': [
    LessonSituationOption(
      id: 'asking_for_clarification',
      label: 'Asking for clarification',
      description: 'Check meaning, next steps, and expectations.',
      topicId: '3',
      topicTitle: 'Work & Business',
      subtopicId: '304',
      subtopicTitle: 'Asking for clarification',
      lessonContentId: 'work_business_asking_for_clarification',
    ),
    LessonSituationOption(
      id: 'daily_standup',
      label: 'Daily standup',
      description: 'Share progress, blockers, and priorities.',
      topicId: '3',
      topicTitle: 'Work & Business',
      subtopicId: '302',
      subtopicTitle: 'Daily standup',
      lessonContentId: 'work_business_daily_standup',
    ),
    LessonSituationOption(
      id: 'client_phone_call',
      label: 'Phone call with a client',
      description: 'Open a call, ask questions, and confirm follow-up.',
      topicId: '3',
      topicTitle: 'Work & Business',
      subtopicId: '303',
      subtopicTitle: 'Phone call with a client',
      lessonContentId: 'work_business_phone_call_with_a_client',
    ),
    LessonSituationOption(
      id: 'discussing_deadlines',
      label: 'Discussing deadlines',
      description: 'Negotiate timing and explain constraints.',
      topicId: '3',
      topicTitle: 'Work & Business',
      subtopicId: '305',
      subtopicTitle: 'Discussing deadlines',
      lessonContentId: 'work_business_discussing_deadlines',
    ),
    LessonSituationOption(
      id: 'first_meeting',
      label: 'First meeting',
      description: 'Introduce yourself, your role, and the project.',
      topicId: '3',
      topicTitle: 'Work & Business',
      subtopicId: '301',
      subtopicTitle: 'First meeting',
      lessonContentId: 'work_business_first_meeting',
    ),
  ],
  'Job Interview': [
    LessonSituationOption(
      id: 'tell_me_about_yourself',
      label: 'Tell me about yourself',
      description: 'Give a concise personal and professional answer.',
      topicId: '4',
      topicTitle: 'Job Interview',
      subtopicId: '401',
      subtopicTitle: 'Tell me about yourself',
      lessonContentId: 'job_interview_tell_me_about_yourself',
    ),
    LessonSituationOption(
      id: 'questions_at_end',
      label: 'Asking questions at the end',
      description: 'Ask about the role, team, and next steps.',
      topicId: '4',
      topicTitle: 'Job Interview',
      subtopicId: '405',
      subtopicTitle: 'Asking questions at the end',
      lessonContentId: 'job_interview_asking_questions_at_the_end',
    ),
    LessonSituationOption(
      id: 'work_experience',
      label: 'Work experience',
      description: 'Describe responsibilities, results, and examples.',
      topicId: '4',
      topicTitle: 'Job Interview',
      subtopicId: '402',
      subtopicTitle: 'Work experience',
      lessonContentId: 'job_interview_work_experience',
    ),
    LessonSituationOption(
      id: 'why_this_job',
      label: 'Why do you want this job?',
      description: 'Explain motivation and fit naturally.',
      topicId: '4',
      topicTitle: 'Job Interview',
      subtopicId: '404',
      subtopicTitle: 'Why do you want this job?',
      lessonContentId: 'job_interview_why_do_you_want_this_job',
    ),
    LessonSituationOption(
      id: 'strengths_weaknesses',
      label: 'Strengths and weaknesses',
      description: 'Talk about skills and growth areas clearly.',
      topicId: '4',
      topicTitle: 'Job Interview',
      subtopicId: '403',
      subtopicTitle: 'Strengths and weaknesses',
      lessonContentId: 'job_interview_strengths_and_weaknesses',
    ),
  ],
  'Restaurant & Cafe': [
    LessonSituationOption(
      id: 'wrong_order',
      label: 'Handling a wrong order',
      description: 'Explain the issue and ask for a fix politely.',
      topicId: '5',
      topicTitle: 'Restaurant & Cafe',
      subtopicId: '504',
      subtopicTitle: 'Handling a wrong order',
      lessonContentId: 'restaurant_and_cafe_handling_a_wrong_order',
    ),
    LessonSituationOption(
      id: 'booking_table',
      label: 'Booking a table',
      description: 'Reserve a table and confirm date, time, and guests.',
      topicId: '5',
      topicTitle: 'Restaurant & Cafe',
      subtopicId: '501',
      subtopicTitle: 'Booking a table',
      lessonContentId: 'restaurant_and_cafe_booking_a_table',
    ),
    LessonSituationOption(
      id: 'ordering_food',
      label: 'Ordering food',
      description: 'Choose dishes, ask questions, and order clearly.',
      topicId: '5',
      topicTitle: 'Restaurant & Cafe',
      subtopicId: '502',
      subtopicTitle: 'Ordering food',
      lessonContentId: 'restaurant_and_cafe_ordering_food',
    ),
    LessonSituationOption(
      id: 'asking_ingredients',
      label: 'Asking about ingredients',
      description: 'Check allergens, preferences, and preparation.',
      topicId: '5',
      topicTitle: 'Restaurant & Cafe',
      subtopicId: '503',
      subtopicTitle: 'Asking about ingredients',
      lessonContentId: 'restaurant_and_cafe_asking_about_ingredients',
    ),
    LessonSituationOption(
      id: 'paying_bill',
      label: 'Paying the bill',
      description: 'Ask for the check and handle payment details.',
      topicId: '5',
      topicTitle: 'Restaurant & Cafe',
      subtopicId: '505',
      subtopicTitle: 'Paying the bill',
      lessonContentId: 'restaurant_and_cafe_paying_the_bill',
    ),
  ],
  'Free Conversation': [
    LessonSituationOption(
      id: 'open_conversation',
      label: 'Open conversation',
      description: 'Practice any topic with flexible follow-up.',
      topicId: '6',
      topicTitle: 'Free Conversation',
      subtopicId: '601',
      subtopicTitle: 'Open conversation',
      lessonContentId: 'free_conversation_open_conversation',
    ),
  ],
};

const _defaultLessonCardStyle = LessonCardStyle(
  familyId: 'default',
  backgroundColor: Color(0xFFF6F7FB),
  borderColor: Color(0xFFE1E5EE),
  accentColor: Color(0xFF526178),
  foregroundColor: Color(0xFF253044),
  pressedColor: Color(0xFFE9EDF5),
);

const lessonTopicCardStylesById = {
  'daily_life': LessonCardStyle(
    familyId: 'topic-daily-life',
    backgroundColor: Color(0xFFEAF4FF),
    borderColor: Color(0xFFCAE0F8),
    accentColor: Color(0xFF2F78B7),
    foregroundColor: Color(0xFF173758),
    pressedColor: Color(0xFFDDECFB),
  ),
  'travel': LessonCardStyle(
    familyId: 'topic-travel',
    backgroundColor: Color(0xFFEAF8EC),
    borderColor: Color(0xFFC9EAD0),
    accentColor: Color(0xFF2E8B57),
    foregroundColor: Color(0xFF173D2A),
    pressedColor: Color(0xFFDCEFE1),
  ),
  'work_business': LessonCardStyle(
    familyId: 'topic-work-business',
    backgroundColor: Color(0xFFE9F2FF),
    borderColor: Color(0xFFC9DCF5),
    accentColor: Color(0xFF3369A8),
    foregroundColor: Color(0xFF183656),
    pressedColor: Color(0xFFDCE9F8),
  ),
  'job_interview': LessonCardStyle(
    familyId: 'topic-job-interview',
    backgroundColor: Color(0xFFEFF3F7),
    borderColor: Color(0xFFD4DDE7),
    accentColor: Color(0xFF64748B),
    foregroundColor: Color(0xFF26364A),
    pressedColor: Color(0xFFE2E8F0),
  ),
  'restaurant_cafe': LessonCardStyle(
    familyId: 'topic-restaurant-cafe',
    backgroundColor: Color(0xFFFFF0E3),
    borderColor: Color(0xFFF4D2B5),
    accentColor: Color(0xFFD56A2C),
    foregroundColor: Color(0xFF593014),
    pressedColor: Color(0xFFF8E4D2),
  ),
  'free_conversation': LessonCardStyle(
    familyId: 'topic-free-conversation',
    backgroundColor: Color(0xFFF3EDFF),
    borderColor: Color(0xFFDCCEF7),
    accentColor: Color(0xFF7B55C7),
    foregroundColor: Color(0xFF35225F),
    pressedColor: Color(0xFFE8DFFC),
  ),
};

LessonCardStyle lessonCardStyleForTopic(LessonOption topic) {
  return lessonTopicCardStylesById[topic.id] ?? _defaultLessonCardStyle;
}

LessonCardStyle lessonCardStyleForTopicLabel(String topicLabel) {
  return lessonCardStyleForTopic(
    lessonTopics.firstWhere(
      (topic) => topic.label == topicLabel,
      orElse: () => LessonOption(
        id: 'unknown',
        label: topicLabel,
        description: '',
      ),
    ),
  );
}

LessonCardStyle lessonCardStyleForSituationTopic(String topicLabel) {
  return lessonCardStyleForTopicLabel(topicLabel);
}
