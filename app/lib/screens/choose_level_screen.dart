import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import '../services/auth_service.dart';
import '../widgets/lesson_option_card.dart';
import 'choose_topic_screen.dart';

class ChooseLevelScreen extends StatelessWidget {
  const ChooseLevelScreen({super.key, AuthService? authService})
      : _authService = authService;

  static const String routeName = '/choose-level';
  final AuthService? _authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Level')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemCount: lessonLevels.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const LessonSelectionIntro(
                title: 'Start with your level',
                subtitle: 'Choose a practice level for today.',
              );
            }
            final level = lessonLevels[index - 1];
            return LessonOptionCard(
              kind: 'level',
              option: level,
              style: lessonCardStyleForLevel(level),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChooseTopicScreen(
                    selectedLevel: level,
                    authService: _authService,
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
