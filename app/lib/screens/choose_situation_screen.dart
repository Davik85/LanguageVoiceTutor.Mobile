import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import '../widgets/lesson_option_card.dart';
import 'lesson_screen.dart';

class ChooseSituationScreen extends StatelessWidget {
  const ChooseSituationScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedTopic,
  });

  final String selectedLevel;
  final String selectedTopic;

  @override
  Widget build(BuildContext context) {
    final situations = lessonSituationsByTopic[selectedTopic] ?? const [];
    final situationStyle = lessonCardStyleForSituationTopic(selectedTopic);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Situation')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemCount: situations.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return LessonSelectionIntro(
                contextLabel: '$selectedLevel / $selectedTopic',
                title: 'Choose a situation',
                subtitle: 'Practice one specific moment from this topic.',
              );
            }
            final situation = situations[index - 1];
            return LessonOptionCard(
              kind: 'situation',
              option: situation,
              style: situationStyle,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    selection: LessonStartSelection(
                      level: selectedLevel,
                      topic: selectedTopic,
                      situation: situation.label,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
