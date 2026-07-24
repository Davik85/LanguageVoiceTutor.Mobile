import 'package:flutter/material.dart';

import '../l10n/lesson_selection_localization.dart';
import '../models/lesson_start_selection.dart';

class LessonSelectionIntro extends StatelessWidget {
  const LessonSelectionIntro({
    super.key,
    required this.title,
    required this.subtitle,
    this.contextLabel,
  });

  final String title;
  final String subtitle;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final contextLabel = this.contextLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contextLabel != null) ...[
            Text(
              contextLabel,
              style: textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class LessonOptionCard extends StatelessWidget {
  const LessonOptionCard({
    super.key,
    required this.kind,
    required this.option,
    required this.style,
    required this.onTap,
    this.displayText,
    this.semanticLabel,
    this.tooltip,
  });

  final String kind;
  final LessonOption option;
  final LessonCardStyle style;
  final VoidCallback onTap;
  final LessonDisplayText? displayText;
  final String? semanticLabel;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final textTheme = Theme.of(context).textTheme;

    final displayText =
        this.displayText ?? LessonDisplayText(option.label, option.description);
    final card = MergeSemantics(
      child: Semantics(
        button: true,
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        child: Material(
          color: style.backgroundColor,
          borderRadius: borderRadius,
          child: InkWell(
            key: Key('lesson-$kind-card-${option.id}'),
            onTap: onTap,
            borderRadius: borderRadius,
            splashColor: style.pressedColor,
            highlightColor: style.pressedColor,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 92),
              decoration: BoxDecoration(
                border: Border.all(color: style.borderColor),
                borderRadius: borderRadius,
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 44,
                    decoration: BoxDecoration(
                      color: style.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayText.label,
                          style: textTheme.titleMedium?.copyWith(
                            color: style.foregroundColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayText.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: style.foregroundColor,
                            height: 1.25,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: style.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final tooltip = this.tooltip;
    return tooltip == null ? card : Tooltip(message: tooltip, child: card);
  }
}
