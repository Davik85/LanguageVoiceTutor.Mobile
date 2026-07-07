import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Situation')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: situations.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Choose a situation for $selectedTopic.',
              style: Theme.of(context).textTheme.titleMedium,
            );
          }
          final situation = situations[index - 1].label;
          return FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonScreen(
                  selection: LessonStartSelection(
                    level: selectedLevel,
                    topic: selectedTopic,
                    situation: situation,
                  ),
                ),
              ),
            ),
            child: Text(situation),
          );
        },
      ),
    );
  }
}
