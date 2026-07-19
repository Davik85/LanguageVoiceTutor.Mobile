import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import '../services/auth_service.dart';
import '../widgets/lesson_option_card.dart';
import '../theme/app_visuals.dart';
import 'lesson_screen.dart';

class ChooseSituationScreen extends StatelessWidget {
  const ChooseSituationScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedTopic,
    AuthService? authService,
  }) : _authService = authService;

  final LessonOption selectedLevel;
  final LessonOption selectedTopic;
  final AuthService? _authService;

  @override
  Widget build(BuildContext context) {
    final situations = lessonSituationsByTopic[selectedTopic.label] ??
        const <LessonSituationOption>[];
    final situationStyle =
        lessonCardStyleForSituationTopic(selectedTopic.label);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Situation')),
      body: AppVisuals.screenBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: situations.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return LessonSelectionIntro(
                  contextLabel:
                      '${selectedLevel.label} / ${selectedTopic.label}',
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
                      authService: _authService,
                      selection: LessonStartSelection(
                        level: selectedLevel.label,
                        topicId: situation.topicId,
                        topicTitle: situation.topicTitle,
                        subtopicId: situation.subtopicId,
                        subtopicTitle: situation.subtopicTitle,
                        situation: situation.label,
                        lessonContentId: situation.lessonContentId,
                        selectedContextId: situation.selectedContextId,
                        selectedContextTitle: situation.selectedContextTitle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
