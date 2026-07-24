import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import '../l10n/app_localizations_context.dart';
import '../l10n/lesson_selection_localization.dart';
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
      appBar: AppBar(title: Text(context.l10n.chooseTopic)),
      body: AppVisuals.screenBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: lessonTopics.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return LessonSelectionIntro(
                  contextLabel: context.l10n.selectedLevelContext(
                    context.l10n.localizedLevel(selectedLevel).label,
                  ),
                  title: context.l10n.chooseTopicTitle,
                  subtitle: context.l10n.chooseTopicSubtitle,
                );
              }
              final topic = lessonTopics[index - 1];
              final displayText = context.l10n.localizedTopic(topic);
              return LessonOptionCard(
                kind: 'topic',
                option: topic,
                style: lessonCardStyleForTopic(topic),
                displayText: displayText,
                semanticLabel: context.l10n.topicCardSemantics(
                  displayText.label,
                  displayText.description,
                ),
                tooltip: context.l10n.openTopicTooltip(displayText.label),
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
