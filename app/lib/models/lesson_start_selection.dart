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
    LessonOption('Placeholder: grocery shopping'),
    LessonOption('Placeholder: meeting a neighbor'),
    LessonOption('Placeholder: making weekend plans'),
  ],
  'Work & Business': [
    LessonOption('Placeholder: team standup'),
    LessonOption('Placeholder: client introduction'),
    LessonOption('Placeholder: project update'),
  ],
  'Job Interview': [
    LessonOption('Placeholder: introducing yourself'),
    LessonOption('Placeholder: discussing experience'),
    LessonOption('Placeholder: asking about the role'),
  ],
  'Restaurant & Cafe': [
    LessonOption('Placeholder: ordering coffee'),
    LessonOption('Placeholder: asking about the menu'),
    LessonOption('Placeholder: paying the bill'),
  ],
  'Free Conversation': [
    LessonOption('Placeholder: open practice prompt'),
    LessonOption('Placeholder: hobby conversation'),
    LessonOption('Placeholder: current events chat'),
  ],
};
