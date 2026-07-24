import 'package:flutter/material.dart';

import '../l10n/app_localizations_context.dart';
import '../models/progress.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import '../theme/app_visuals.dart';
import 'login_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, AuthService? authService})
      : _authService = authService;

  final AuthService? _authService;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final AuthService _authService;
  ProgressResponse? _progress;
  ProgressStatus? _errorStatus;
  bool _isLoading = true;
  bool _isRequestInFlight = false;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (_isRequestInFlight) return;
    _isRequestInFlight = true;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorStatus = null;
      });
    }

    final result = await _authService.fetchProgress();
    if (!mounted) return;
    if (result.status == ProgressStatus.authRequired) {
      _isRequestInFlight = false;
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (_) => false,
      );
      return;
    }

    setState(() {
      _isLoading = false;
      _progress = result.progress;
      _errorStatus = result.isSuccess ? null : result.status;
    });
    _isRequestInFlight = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('progress-screen'),
      appBar: AppBar(title: Text(context.l10n.progress)),
      body: AppVisuals.screenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorStatus != null
                ? _ProgressError(status: _errorStatus!, onRetry: _loadProgress)
                : _isEmpty(_progress)
                    ? _ProgressEmpty(onReturnHome: () => Navigator.pop(context))
                    : _ProgressContent(progress: _progress!),
      ),
    );
  }

  static bool _isEmpty(ProgressResponse? progress) =>
      progress != null &&
      progress.completedLessons.allTime == 0 &&
      progress.lastCompletedLesson == null &&
      progress.completedLessonsByStudyLanguage.isEmpty &&
      progress.completedLessonsByLevel.isEmpty &&
      progress.dailyActivity.every((item) => item.completedLessons == 0);
}

class _ProgressError extends StatelessWidget {
  const _ProgressError({required this.status, required this.onRetry});
  final ProgressStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_message(context), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('progress-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ]),
        ),
      );

  String _message(BuildContext context) => switch (status) {
        ProgressStatus.unavailable => context.l10n.progressUnavailable,
        ProgressStatus.failed => context.l10n.progressLoadFailed,
        _ => context.l10n.progressLoadFailed,
      };
}

class _ProgressEmpty extends StatelessWidget {
  const _ProgressEmpty({required this.onReturnHome});
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) => Center(
        key: const Key('progress-empty'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(context.l10n.progressEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              context.l10n.progressEmptyDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onReturnHome,
              child: Text(context.l10n.backToHome),
            ),
          ]),
        ),
      );
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({required this.progress});
  final ProgressResponse progress;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: ListView(
          key: const Key('progress-content'),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            _SectionCard(
              title: context.l10n.progressCompletedLessons,
              child: Wrap(spacing: 20, runSpacing: 12, children: [
                _Statistic(
                  label: context.l10n.progressAllTime,
                  value: context.l10n
                      .lessonsCompleted(progress.completedLessons.allTime),
                  semanticLabel:
                      '${context.l10n.progressAllTime}: ${context.l10n.lessonsCompleted(progress.completedLessons.allTime)}',
                ),
                _Statistic(
                  label: context.l10n.progressLast7Days,
                  value: context.l10n
                      .lessonsCompleted(progress.completedLessons.last7Days),
                  semanticLabel:
                      '${context.l10n.progressLast7Days}: ${context.l10n.lessonsCompleted(progress.completedLessons.last7Days)}',
                ),
                _Statistic(
                  label: context.l10n.progressLast30Days,
                  value: context.l10n
                      .lessonsCompleted(progress.completedLessons.last30Days),
                  semanticLabel:
                      '${context.l10n.progressLast30Days}: ${context.l10n.lessonsCompleted(progress.completedLessons.last30Days)}',
                ),
              ]),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: context.l10n.streaks,
              child: Wrap(spacing: 28, runSpacing: 12, children: [
                _Statistic(
                  label: context.l10n.progressCurrentStreak,
                  value: context.l10n
                      .progressStreakDays(progress.streaks.currentDays),
                  semanticLabel:
                      '${context.l10n.progressCurrentStreak}: ${context.l10n.progressStreakDays(progress.streaks.currentDays)}',
                ),
                _Statistic(
                  label: context.l10n.progressLongestStreak,
                  value: context.l10n
                      .progressStreakDays(progress.streaks.longestDays),
                  semanticLabel:
                      '${context.l10n.progressLongestStreak}: ${context.l10n.progressStreakDays(progress.streaks.longestDays)}',
                ),
              ]),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: context.l10n.progressRecentActivity,
              child: _ActivityStrip(items: progress.dailyActivity),
            ),
            if (progress.lastCompletedLesson != null) ...[
              const SizedBox(height: 12),
              _LastLessonCard(lesson: progress.lastCompletedLesson!),
            ],
            if (progress.completedLessonsByStudyLanguage.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DistributionCard(
                title: context.l10n.progressLessonsByLanguage,
                rows: progress.completedLessonsByStudyLanguage
                    .map((item) => (item.studyLanguage, item.completedLessons))
                    .toList(growable: false),
              ),
            ],
            if (progress.completedLessonsByLevel.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DistributionCard(
                title: context.l10n.progressLessonsByLevel,
                rows: progress.completedLessonsByLevel
                    .map((item) => (item.level, item.completedLessons))
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      );
}

class _Statistic extends StatelessWidget {
  const _Statistic({
    required this.label,
    required this.value,
    required this.semanticLabel,
  });
  final String label;
  final String value;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ]),
        ),
      );
}

class _ActivityStrip extends StatelessWidget {
  const _ActivityStrip({required this.items});
  final List<ProgressDailyActivityItem> items;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final item in items)
            Semantics(
              label: context.l10n.activityDaySemantics(
                _formatDate(context, item.activityDate),
                item.completedLessons,
              ),
              child: Container(
                key: Key(
                  'progress-activity-${item.activityDate.toIso8601String().substring(0, 10)}',
                ),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.completedLessons > 0
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${item.completedLessons}'),
              ),
            ),
        ],
      );
}

class _LastLessonCard extends StatelessWidget {
  const _LastLessonCard({required this.lesson});
  final ProgressLastCompletedLesson lesson;

  @override
  Widget build(BuildContext context) {
    final details = [
      lesson.studyLanguage,
      lesson.level,
      lesson.topicTitle,
      lesson.subtopicTitle,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    return _SectionCard(
      title: context.l10n.progressLastCompletedLesson,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_formatDate(context, lesson.completedAtUtc)),
        for (final detail in details) ...[
          const SizedBox(height: 4),
          Text(detail),
        ],
      ]),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.title, required this.rows});
  final String title;
  final List<(String, int)> rows;

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: title,
        child: Column(
          children: [
            for (final row in rows)
              Semantics(
                label: '${row.$1}: ${context.l10n.lessonsCompleted(row.$2)}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(child: Text(row.$1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.lessonsCompleted(row.$2),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      );
}

String _formatDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatMediumDate(date);
