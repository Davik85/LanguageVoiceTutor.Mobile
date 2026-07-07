import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import 'choose_situation_screen.dart';

class ChooseTopicScreen extends StatelessWidget {
  const ChooseTopicScreen({super.key, required this.selectedLevel});

  final String selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Topic')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: lessonTopics.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Choose a topic for $selectedLevel.',
              style: Theme.of(context).textTheme.titleMedium,
            );
          }
          final topic = lessonTopics[index - 1].label;
          return FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChooseSituationScreen(
                  selectedLevel: selectedLevel,
                  selectedTopic: topic,
                ),
              ),
            ),
            child: Text(topic),
          );
        },
      ),
    );
  }
}
