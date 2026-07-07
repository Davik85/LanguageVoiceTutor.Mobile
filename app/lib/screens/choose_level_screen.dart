import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import 'choose_topic_screen.dart';

class ChooseLevelScreen extends StatelessWidget {
  const ChooseLevelScreen({super.key});

  static const String routeName = '/choose-level';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Level')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: lessonLevels.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Choose a practice level to start the lesson skeleton.',
              style: Theme.of(context).textTheme.titleMedium,
            );
          }
          final level = lessonLevels[index - 1].label;
          return FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChooseTopicScreen(selectedLevel: level),
              ),
            ),
            child: Text(level),
          );
        },
      ),
    );
  }
}
