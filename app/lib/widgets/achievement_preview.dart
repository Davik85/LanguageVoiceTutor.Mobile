import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../achievements/achievement_title_resolver.dart';
import '../achievements/achievement_visual_resolver.dart';
import '../l10n/app_localizations_context.dart';
import '../models/achievements.dart';

enum AchievementPreviewDismissal { dismissed, closeAll }

Future<AchievementPreviewDismissal> showAchievementPreview(
  BuildContext context,
  AchievementItem achievement,
) =>
    _showAchievementPreview(context, achievement);

Future<AchievementPreviewDismissal> showQueuedAchievementPreview(
  BuildContext context,
  AchievementItem achievement,
) =>
    _showAchievementPreview(context, achievement, showCloseAll: true);

Future<AchievementPreviewDismissal> _showAchievementPreview(
  BuildContext context,
  AchievementItem achievement, {
  bool showCloseAll = false,
}) async =>
    await showDialog<AchievementPreviewDismissal>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) => _AchievementPreview(
        achievement: achievement,
        showCloseAll: showCloseAll,
      ),
    ) ??
    AchievementPreviewDismissal.dismissed;

class _AchievementPreview extends StatelessWidget {
  const _AchievementPreview({
    required this.achievement,
    required this.showCloseAll,
  });

  final AchievementItem achievement;
  final bool showCloseAll;

  @override
  Widget build(BuildContext context) {
    final visual = AchievementVisualResolver.resolve(achievement);
    final title = AchievementTitleResolver.resolve(context, achievement);
    return Dialog(
      key: const Key('achievement-preview'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            Navigator.of(context).pop(AchievementPreviewDismissal.dismissed),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final size = math.min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ) *
                    .936;
                return Center(
                  child: Semantics(
                    button: true,
                    label: context.l10n.closeAchievementPreview(title),
                    child: InteractiveViewer(
                      clipBehavior: Clip.none,
                      boundaryMargin: const EdgeInsets.all(1000),
                      minScale: 1,
                      maxScale: 3,
                      child: AchievementArtwork(
                        visual: visual,
                        color: Theme.of(context).colorScheme.primary,
                        size: size,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (showCloseAll)
              Positioned(
                top: 12,
                right: 12,
                child: Semantics(
                  button: true,
                  label: context.l10n.closeAllAchievementPreviews,
                  child: IconButton(
                    key: const Key('achievement-preview-close-all'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .9),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pop(AchievementPreviewDismissal.closeAll),
                    icon: const Icon(Icons.close_rounded, size: 34),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
