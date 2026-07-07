class LessonOption {
  const LessonOption(this.label);

  final String label;
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
  LessonOption('A1 Beginner'),
  LessonOption('A2 Elementary'),
  LessonOption('B1 Intermediate'),
  LessonOption('B2 Upper-Intermediate'),
];

const lessonTopics = [
  LessonOption('Daily Life'),
  LessonOption('Travel'),
  LessonOption('Work & Business'),
  LessonOption('Job Interview'),
  LessonOption('Restaurant & Cafe'),
  LessonOption('Free Conversation'),
];

const travelSituations = [
  LessonOption('Airport check-in'),
  LessonOption('Hotel check-in'),
  LessonOption('Asking for directions'),
  LessonOption('Ordering transport'),
  LessonOption('Lost luggage'),
];

const Map<String, List<LessonOption>> lessonSituationsByTopic = {
  'Travel': travelSituations,
  'Daily Life': [
    LessonOption('Introductions'),
    LessonOption('Asking for help'),
    LessonOption('Small talk with a neighbor'),
    LessonOption('Talking about your day'),
    LessonOption('Making plans'),
  ],
  'Work & Business': [
    LessonOption('Asking for clarification'),
    LessonOption('Daily standup'),
    LessonOption('Phone call with a client'),
    LessonOption('Discussing deadlines'),
    LessonOption('First meeting'),
  ],
  'Job Interview': [
    LessonOption('Tell me about yourself'),
    LessonOption('Asking questions at the end'),
    LessonOption('Work experience'),
    LessonOption('Why do you want this job?'),
    LessonOption('Strengths and weaknesses'),
  ],
  'Restaurant & Cafe': [
    LessonOption('Handling a wrong order'),
    LessonOption('Booking a table'),
    LessonOption('Ordering food'),
    LessonOption('Asking about ingredients'),
    LessonOption('Paying the bill'),
  ],
  'Free Conversation': [
    LessonOption('Open conversation'),
  ],
};
