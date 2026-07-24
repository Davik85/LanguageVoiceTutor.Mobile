import 'package:flutter/material.dart';

import '../models/achievements.dart';
import '../l10n/app_localizations_context.dart';
import '../services/auth_service.dart';
import '../theme/app_visuals.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/achievement_preview.dart';
import 'login_screen.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key, required AuthService authService})
      : _authService = authService;
  final AuthService _authService;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  AchievementsResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget._authService.fetchAchievements();
    if (!mounted) return;
    if (result.status == AchievementsStatus.authRequired) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (_) => false);
      return;
    }
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.achievements)),
        body: AppVisuals.screenBackground(
          child: SafeArea(
            child: _result == null
                ? const Center(child: CircularProgressIndicator())
                : _AchievementsContent(result: _result!),
          ),
        ),
      );
}

class _AchievementsContent extends StatelessWidget {
  const _AchievementsContent({required this.result});
  final AchievementsResult result;

  @override
  Widget build(BuildContext context) {
    if (!result.isSuccess || result.achievements == null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24), child: Text(result.message)));
    }
    final response = result.achievements!;
    if (response.achievements.isEmpty) {
      return Center(child: Text(context.l10n.achievementsUnavailable));
    }
    final groups = <String, List<AchievementItem>>{};
    for (final item in response.achievements) {
      final title = switch (item.category) {
        'streak' => context.l10n.streaks,
        'lesson' => context.l10n.lessonMilestones,
        'topic' => context.l10n.topics,
        'subtopic' => context.l10n.situations,
        _ => context.l10n.otherAchievements,
      };
      (groups[title] ??= []).add(item);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
            context.l10n.unlockedCount(
                response.summary.unlocked, response.summary.total),
            style: Theme.of(context).textTheme.titleMedium),
        if (response.activeStudyLanguage?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(context.l10n.learningLanguage(response.activeStudyLanguage!),
              style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        for (final entry in groups.entries) ...[
          Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 182,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) =>
                    _AchievementGridItem(item: entry.value[index]),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _AchievementGridItem extends StatelessWidget {
  const _AchievementGridItem({required this.item});
  final AchievementItem item;

  @override
  Widget build(BuildContext context) => InkWell(
        key: Key('all-achievement-${item.id}'),
        onTap:
            item.unlocked ? () => showAchievementPreview(context, item) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Expanded(
                  child: AchievementBadge(achievement: item, compact: true)),
              Text(
                item.unlocked
                    ? context.l10n.completed
                    : context.l10n.progressCount(
                        item.currentProgress, item.targetProgress),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
}
