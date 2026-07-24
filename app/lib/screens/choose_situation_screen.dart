import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';
import '../l10n/app_localizations_context.dart';
import '../l10n/lesson_selection_localization.dart';
import '../models/lesson_session.dart';
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
    this.onSituationSelected,
  }) : _authService = authService;

  final LessonOption selectedLevel;
  final LessonOption selectedTopic;
  final AuthService? _authService;
  final ValueChanged<LessonStartSelection>? onSituationSelected;

  @override
  Widget build(BuildContext context) {
    final situations = lessonSituationsByTopic[selectedTopic.id] ??
        const <LessonSituationOption>[];
    final situationStyle = lessonCardStyleForSituationTopic(selectedTopic.id);
    final levelDisplay = context.l10n.localizedLevel(selectedLevel);
    final topicDisplay = context.l10n.localizedTopic(selectedTopic);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.chooseSituation)),
      body: AppVisuals.screenBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: situations.isEmpty ? 2 : situations.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return LessonSelectionIntro(
                  contextLabel: context.l10n.selectedLevelTopicContext(
                    levelDisplay.label,
                    topicDisplay.label,
                  ),
                  title: context.l10n.chooseSituationTitle,
                  subtitle: context.l10n.chooseSituationSubtitle,
                );
              }
              if (situations.isEmpty) {
                return Text(
                  context.l10n.noSituationsAvailable,
                  key: const Key('lesson-situations-empty'),
                );
              }
              final situation = situations[index - 1];
              final displayText = context.l10n.localizedSituation(situation);
              return LessonOptionCard(
                kind: 'situation',
                option: situation,
                style: situationStyle,
                displayText: displayText,
                semanticLabel: context.l10n.situationCardSemantics(
                  displayText.label,
                  displayText.description,
                ),
                tooltip: context.l10n.openSituationTooltip(displayText.label),
                onTap: () async {
                  final selection =
                      lessonStartSelectionFor(selectedLevel, situation);
                  final onSituationSelected = this.onSituationSelected;
                  if (onSituationSelected != null) {
                    onSituationSelected(selection);
                    return;
                  }
                  final result = await Navigator.push<LessonExitResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(
                        authService: _authService,
                        selection: selection,
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
