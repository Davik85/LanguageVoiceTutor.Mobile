import 'package:flutter/material.dart';

import '../models/lesson_history.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import '../theme/app_visuals.dart';
import 'lesson_history_detail_screen.dart';
import 'login_screen.dart';

class LessonHistoryScreen extends StatefulWidget {
  const LessonHistoryScreen({super.key, AuthService? authService})
      : _authService = authService;

  final AuthService? _authService;

  @override
  State<LessonHistoryScreen> createState() => _LessonHistoryScreenState();
}

class _LessonHistoryScreenState extends State<LessonHistoryScreen> {
  late final AuthService _authService;
  LessonHistoryList? _history;
  String? _error;
  bool _isLoading = true;
  bool _isRequestInFlight = false;
  bool _isNavigatingToDetail = false;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_isRequestInFlight) return;
    _isRequestInFlight = true;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final result = await _authService.fetchLessonHistory();
    if (!mounted) return;
    if (result.status == LessonHistoryStatus.authRequired) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (_) => false,
      );
      _isRequestInFlight = false;
      return;
    }
    setState(() {
      _isLoading = false;
      _history = result.history;
      _error = result.isSuccess ? null : result.message;
    });
    _isRequestInFlight = false;
  }

  @override
  Widget build(BuildContext context) {
    final items = _history?.items;
    return Scaffold(
      key: const Key('lesson-history-screen'),
      appBar: AppBar(title: const Text('Lesson history')),
      body: AppVisuals.screenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _HistoryError(message: _error!, onRetry: _loadHistory)
                : items == null || items.isEmpty
                    ? _HistoryEmpty(onReturnHome: () => Navigator.pop(context))
                    : ListView(
                        key: const Key('lesson-history-list'),
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        children: [
                          Text('Your recent completed lessons',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          for (final item in items) ...[
                            _LessonHistoryCard(
                              item: item,
                              onTap: () => _openDetail(item.sessionId),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
      ),
    );
  }

  Future<void> _openDetail(String sessionId) async {
    if (_isNavigatingToDetail || sessionId.trim().isEmpty) return;
    _isNavigatingToDetail = true;
    try {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => LessonHistoryDetailScreen(
          sessionId: sessionId,
          authService: _authService,
        ),
      ));
    } finally {
      if (mounted) _isNavigatingToDetail = false;
    }
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});
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
              key: const Key('lesson-history-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ]),
        ),
      );
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.onReturnHome});
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) => Center(
        key: const Key('lesson-history-empty'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('No completed lessons yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Completed lessons will appear here.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
                onPressed: onReturnHome, child: const Text('Back to Home')),
          ]),
        ),
      );
}

class _LessonHistoryCard extends StatelessWidget {
  const _LessonHistoryCard({required this.item, required this.onTap});
  final LessonHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contextTitle = item.selectedContextTitle?.trim();
    final summary = item.summaryPreview?.trim();
    final turnLabel =
        item.validTurnCount == 1 ? '1 turn' : '${item.validTurnCount} turns';
    return Card(
      key: Key('lesson-history-item-${item.sessionId}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_fallback(item.topicTitle, 'Lesson'),
                style: Theme.of(context).textTheme.titleMedium),
            if (item.subtopicTitle.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.subtopicTitle),
            ],
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 4, children: [
              Text(_fallback(item.level, 'Level')),
              Text(_formatDate(item.finishedAt ?? item.startedAt)),
              Text(_modeLabel(item.modeUsed)),
              Text(item.status.toLowerCase() == 'finished'
                  ? 'Completed'
                  : 'Finished'),
            ]),
            if (contextTitle != null && contextTitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(contextTitle),
            ],
            const SizedBox(height: 8),
            Text(turnLabel),
            if (summary != null && summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),
      ),
    );
  }
}

String _fallback(String value, String fallback) =>
    value.trim().isEmpty ? fallback : value;

String _modeLabel(String mode) {
  switch (mode.trim().toLowerCase()) {
    case 'text':
      return 'Lesson chat';
    case 'voice':
    case 'conversation':
      return 'Conversation';
    default:
      return 'Lesson';
  }
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
  final local = date.toLocal();
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}
