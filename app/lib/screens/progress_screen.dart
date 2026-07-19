import 'package:flutter/material.dart';

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
  String? _error;
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
        _error = null;
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
      _error = result.isSuccess ? null : result.message;
    });
    _isRequestInFlight = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('progress-screen'),
      appBar: AppBar(title: const Text('Progress')),
      body: AppVisuals.screenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ProgressError(message: _error!, onRetry: _loadProgress)
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
  const _ProgressError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('progress-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ]),
        ),
      );
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
            Text('Your progress will appear here',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Completed lessons will appear here after you finish a lesson.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onReturnHome,
              child: const Text('Back to Home'),
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
              title: 'Completed lessons',
              child: Wrap(spacing: 20, runSpacing: 12, children: [
                _Statistic(
                  label: 'All time',
                  value: progress.completedLessons.allTime,
                  semanticLabel:
                      '${progress.completedLessons.allTime} completed lessons all time',
                ),
                _Statistic(
                  label: 'Last 7 days',
                  value: progress.completedLessons.last7Days,
                  semanticLabel:
                      '${progress.completedLessons.last7Days} completed lessons in the last 7 days',
                ),
                _Statistic(
                  label: 'Last 30 days',
                  value: progress.completedLessons.last30Days,
                  semanticLabel:
                      '${progress.completedLessons.last30Days} completed lessons in the last 30 days',
                ),
              ]),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Streaks',
              child: Wrap(spacing: 28, runSpacing: 12, children: [
                _Statistic(
                  label: 'Current streak',
                  value: progress.streaks.currentDays,
                  suffix: 'days',
                  semanticLabel:
                      '${progress.streaks.currentDays} day current streak',
                ),
                _Statistic(
                  label: 'Longest streak',
                  value: progress.streaks.longestDays,
                  suffix: 'days',
                  semanticLabel:
                      '${progress.streaks.longestDays} day longest streak',
                ),
              ]),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Recent activity',
              child: _ActivityStrip(items: progress.dailyActivity),
            ),
            if (progress.lastCompletedLesson != null) ...[
              const SizedBox(height: 12),
              _LastLessonCard(lesson: progress.lastCompletedLesson!),
            ],
            if (progress.completedLessonsByStudyLanguage.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DistributionCard(
                title: 'Lessons by language',
                rows: progress.completedLessonsByStudyLanguage
                    .map((item) => (item.studyLanguage, item.completedLessons))
                    .toList(growable: false),
              ),
            ],
            if (progress.completedLessonsByLevel.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DistributionCard(
                title: 'Lessons by level',
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
    this.suffix,
  });
  final String label;
  final int value;
  final String semanticLabel;
  final String? suffix;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$value${suffix == null ? '' : ' $suffix'}',
                style: Theme.of(context).textTheme.headlineSmall),
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
              label:
                  '${_formatDate(item.activityDate)}: ${item.completedLessons} completed lessons',
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
      title: 'Last completed lesson',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_formatDate(lesson.completedAtUtc)),
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
                label: '${row.$1}: ${row.$2} completed lessons',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(child: Text(row.$1)),
                    Text('${row.$2}'),
                  ]),
                ),
              ),
          ],
        ),
      );
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
