import 'package:flutter/widgets.dart';

import '../l10n/app_localizations_context.dart';
import '../models/achievements.dart';

/// Resolves only the account-wide achievement titles approved for localization.
class AchievementTitleResolver {
  const AchievementTitleResolver._();

  static String resolve(BuildContext context, AchievementItem achievement) =>
      switch (achievement.id) {
        'streak-7-v1' => context.l10n.achievementTitleStreak7,
        'streak-30-v1' => context.l10n.achievementTitleStreak30,
        'streak-60-v1' => context.l10n.achievementTitleStreak60,
        'streak-100-v1' => context.l10n.achievementTitleStreak100,
        'streak-365-v1' => context.l10n.achievementTitleStreak365,
        'lessons-1-v1' => context.l10n.achievementTitleLessons1,
        'lessons-5-v1' => context.l10n.achievementTitleLessons5,
        'lessons-10-v1' => context.l10n.achievementTitleLessons10,
        'lessons-25-v1' => context.l10n.achievementTitleLessons25,
        'lessons-50-v1' => context.l10n.achievementTitleLessons50,
        'lessons-100-v1' => context.l10n.achievementTitleLessons100,
        _ => achievement.title,
      };
}
