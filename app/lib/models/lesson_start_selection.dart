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

class LessonStartSelection {
  const LessonStartSelection({
    required this.level,
    required this.topic,
    required this.situation,
  });

  final String level;
  final String topic;
  final String situation;
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
  LessonOption(
    id: 'airport_check_in',
    label: 'Airport check-in',
    description: 'Check documents, luggage, seats, and gate details.',
  ),
  LessonOption(
    id: 'hotel_check_in',
    label: 'Hotel check-in',
    description: 'Confirm a reservation, room details, and arrival needs.',
  ),
  LessonOption(
    id: 'asking_for_directions',
    label: 'Asking for directions',
    description: 'Ask where to go and understand simple route help.',
  ),
  LessonOption(
    id: 'ordering_transport',
    label: 'Ordering transport',
    description: 'Book a ride, explain a destination, and confirm price.',
  ),
  LessonOption(
    id: 'lost_luggage',
    label: 'Lost luggage',
    description: 'Report a missing bag and give practical details.',
  ),
];

const Map<String, List<LessonOption>> lessonSituationsByTopic = {
  'Travel': travelSituations,
  'Daily Life': [
    LessonOption(
      id: 'introductions',
      label: 'Introductions',
      description: 'Say who you are and ask friendly first questions.',
    ),
    LessonOption(
      id: 'asking_for_help',
      label: 'Asking for help',
      description: 'Explain what you need and respond politely.',
    ),
    LessonOption(
      id: 'small_talk_neighbor',
      label: 'Small talk with a neighbor',
      description: 'Chat about daily life, weather, and local plans.',
    ),
    LessonOption(
      id: 'talking_about_day',
      label: 'Talking about your day',
      description: 'Describe routines, timing, and what happened.',
    ),
    LessonOption(
      id: 'making_plans',
      label: 'Making plans',
      description: 'Suggest a time, agree, reschedule, or decline.',
    ),
  ],
  'Work & Business': [
    LessonOption(
      id: 'asking_for_clarification',
      label: 'Asking for clarification',
      description: 'Check meaning, next steps, and expectations.',
    ),
    LessonOption(
      id: 'daily_standup',
      label: 'Daily standup',
      description: 'Share progress, blockers, and priorities.',
    ),
    LessonOption(
      id: 'client_phone_call',
      label: 'Phone call with a client',
      description: 'Open a call, ask questions, and confirm follow-up.',
    ),
    LessonOption(
      id: 'discussing_deadlines',
      label: 'Discussing deadlines',
      description: 'Negotiate timing and explain constraints.',
    ),
    LessonOption(
      id: 'first_meeting',
      label: 'First meeting',
      description: 'Introduce yourself, your role, and the project.',
    ),
  ],
  'Job Interview': [
    LessonOption(
      id: 'tell_me_about_yourself',
      label: 'Tell me about yourself',
      description: 'Give a concise personal and professional answer.',
    ),
    LessonOption(
      id: 'questions_at_end',
      label: 'Asking questions at the end',
      description: 'Ask about the role, team, and next steps.',
    ),
    LessonOption(
      id: 'work_experience',
      label: 'Work experience',
      description: 'Describe responsibilities, results, and examples.',
    ),
    LessonOption(
      id: 'why_this_job',
      label: 'Why do you want this job?',
      description: 'Explain motivation and fit naturally.',
    ),
    LessonOption(
      id: 'strengths_weaknesses',
      label: 'Strengths and weaknesses',
      description: 'Talk about skills and growth areas clearly.',
    ),
  ],
  'Restaurant & Cafe': [
    LessonOption(
      id: 'wrong_order',
      label: 'Handling a wrong order',
      description: 'Explain the issue and ask for a fix politely.',
    ),
    LessonOption(
      id: 'booking_table',
      label: 'Booking a table',
      description: 'Reserve a table and confirm date, time, and guests.',
    ),
    LessonOption(
      id: 'ordering_food',
      label: 'Ordering food',
      description: 'Choose dishes, ask questions, and order clearly.',
    ),
    LessonOption(
      id: 'asking_ingredients',
      label: 'Asking about ingredients',
      description: 'Check allergens, preferences, and preparation.',
    ),
    LessonOption(
      id: 'paying_bill',
      label: 'Paying the bill',
      description: 'Ask for the check and handle payment details.',
    ),
  ],
  'Free Conversation': [
    LessonOption(
      id: 'open_conversation',
      label: 'Open conversation',
      description: 'Practice any topic with flexible follow-up.',
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

const lessonLevelCardStylesById = {
  'a1': LessonCardStyle(
    familyId: 'level-a1',
    backgroundColor: Color(0xFFEAF8EC),
    borderColor: Color(0xFFC9EAD0),
    accentColor: Color(0xFF2E8B57),
    foregroundColor: Color(0xFF173D2A),
    pressedColor: Color(0xFFDCEFE1),
  ),
  'a2': LessonCardStyle(
    familyId: 'level-a2',
    backgroundColor: Color(0xFFE7F8F8),
    borderColor: Color(0xFFC5E9EA),
    accentColor: Color(0xFF188A92),
    foregroundColor: Color(0xFF123E45),
    pressedColor: Color(0xFFD9EEEE),
  ),
  'b1': LessonCardStyle(
    familyId: 'level-b1',
    backgroundColor: Color(0xFFFFF6D7),
    borderColor: Color(0xFFF2E2A5),
    accentColor: Color(0xFFC18A12),
    foregroundColor: Color(0xFF4A3410),
    pressedColor: Color(0xFFF7ECC7),
  ),
  'b2': LessonCardStyle(
    familyId: 'level-b2',
    backgroundColor: Color(0xFFF1ECFF),
    borderColor: Color(0xFFD9CEF5),
    accentColor: Color(0xFF7153B8),
    foregroundColor: Color(0xFF33235F),
    pressedColor: Color(0xFFE6DFFA),
  ),
};

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

LessonCardStyle lessonCardStyleForLevel(LessonOption level) {
  return lessonLevelCardStylesById[level.id] ?? _defaultLessonCardStyle;
}

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
