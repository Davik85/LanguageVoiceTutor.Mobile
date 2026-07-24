import 'package:flutter/material.dart';

import '../achievements/achievement_title_resolver.dart';
import '../achievements/achievement_visual_resolver.dart';
import '../l10n/app_localizations_context.dart';
import '../models/achievements.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    this.compact = false,
  });

  final AchievementItem achievement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(achievement.iconKey);
    final visual = AchievementVisualResolver.resolve(achievement);
    final title = AchievementTitleResolver.resolve(context, achievement);
    return Semantics(
      label: achievement.unlocked
          ? context.l10n.achievementUnlockedSemantics(title)
          : context.l10n.achievementLockedSemantics(
              title,
              achievement.currentProgress,
              achievement.targetProgress,
            ),
      child: ExcludeSemantics(
        child: Opacity(
          opacity: achievement.unlocked ? 1 : 0.58,
          child: SizedBox(
            height: compact ? 142 : 58,
            child: compact
                ? _CompactBadge(
                    title: title,
                    visual: visual,
                    color: color,
                    unlocked: achievement.unlocked,
                    progress: achievement.unlocked
                        ? null
                        : '${achievement.currentProgress} / ${achievement.targetProgress}',
                  )
                : _ListBadge(
                    visual: visual,
                    color: color,
                    unlocked: achievement.unlocked,
                  ),
          ),
        ),
      ),
    );
  }

  static Color _colorFor(String iconKey) {
    if (iconKey == 'streak') {
      return const Color(0xFFE8791A);
    }
    if (iconKey == 'lesson-milestone') {
      return const Color(0xFF8B5CF6);
    }
    if (iconKey.startsWith('travel-') || iconKey == 'topic-travel') {
      return const Color(0xFF16856A);
    }
    if (iconKey.startsWith('work-business') ||
        iconKey == 'topic-work-business') {
      return const Color(0xFF2E6FB8);
    }
    if (iconKey.startsWith('job-interview') ||
        iconKey == 'topic-job-interview') {
      return const Color(0xFF5D6D7E);
    }
    if (iconKey.startsWith('restaurant-cafe') ||
        iconKey == 'topic-restaurant-cafe') {
      return const Color(0xFFC76A28);
    }
    return const Color(0xFF3575B8);
  }
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge(
      {required this.title,
      required this.visual,
      required this.color,
      required this.unlocked,
      this.progress});
  final String title;
  final AchievementVisual visual;
  final Color color;
  final bool unlocked;
  final String? progress;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AchievementArtwork(visual: visual, color: color, size: 84),
              if (!unlocked)
                const Positioned(
                  right: -7,
                  bottom: -5,
                  child: Icon(Icons.lock_rounded, size: 15),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall),
          if (progress != null) ...[
            const SizedBox(height: 2),
            Text(progress!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ],
      );
}

class _ListBadge extends StatelessWidget {
  const _ListBadge(
      {required this.visual, required this.color, required this.unlocked});
  final AchievementVisual visual;
  final Color color;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          AchievementArtwork(visual: visual, color: color, size: 28),
          if (!unlocked)
            const Positioned(
                right: -7,
                bottom: -5,
                child: Icon(Icons.lock_rounded, size: 15)),
        ],
      );
}
