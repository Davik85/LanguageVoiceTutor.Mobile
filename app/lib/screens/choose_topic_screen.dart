import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import '../models/lesson_session.dart';
import '../services/auth_service.dart';
import '../widgets/lesson_option_card.dart';
import '../theme/app_visuals.dart';
import 'choose_situation_screen.dart';

class ChooseTopicScreen extends StatelessWidget {
  const ChooseTopicScreen({
    super.key,
    required this.selectedLevel,
    AuthService? authService,
  }) : _authService = authService;

  final LessonOption selectedLevel;
  final AuthService? _authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Topic')),
      body: AppVisuals.screenBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: lessonTopics.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return LessonSelectionIntro(
                  contextLabel: 'Level: ${selectedLevel.label}',
                  title: 'Choose a topic',
                  subtitle:
                      'Pick the kind of conversation you want to practice.',
                );
              }
              final topic = lessonTopics[index - 1];
              return LessonOptionCard(
                kind: 'topic',
                option: topic,
                style: lessonCardStyleForTopic(topic),
                onTap: () async {
                  final result = await Navigator.push<LessonExitResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChooseSituationScreen(
                        selectedLevel: selectedLevel,
                        selectedTopic: topic,
                        authService: _authService,
                      ),
                    ),
                  );
                  if (context.mounted && result == LessonExitResult.completed) {
                    Navigator.of(context).pop(result);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
