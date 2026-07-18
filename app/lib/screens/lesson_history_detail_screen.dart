import 'package:flutter/material.dart';

import '../models/lesson_history.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class LessonHistoryDetailScreen extends StatefulWidget {
  const LessonHistoryDetailScreen({
    super.key,
    required this.sessionId,
    required this.authService,
  });

  final String sessionId;
  final AuthService authService;

  @override
  State<LessonHistoryDetailScreen> createState() =>
      _LessonHistoryDetailScreenState();
}

class _LessonHistoryDetailScreenState extends State<LessonHistoryDetailScreen> {
  LessonHistoryDetail? _detail;
  String? _error;
  bool _isLoading = true;
  bool _isRequestInFlight = false;
  bool _canRetry = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (_isRequestInFlight) return;
    _isRequestInFlight = true;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
        _canRetry = false;
      });
    }

    final sessionId = widget.sessionId.trim();
    final result = sessionId.isEmpty
        ? LessonHistoryDetailResult.validation()
        : await widget.authService.fetchLessonHistoryDetail(sessionId);
    if (!mounted) return;
    if (result.status == LessonHistoryStatus.authRequired) {
      _isRequestInFlight = false;
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (_) => false);
      return;
    }
    setState(() {
      _isLoading = false;
      _detail = result.detail;
      _error = result.isSuccess ? null : result.message;
      _canRetry = result.status == LessonHistoryStatus.unavailable ||
          result.status == LessonHistoryStatus.failed;
    });
    _isRequestInFlight = false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: const Key('lesson-history-detail-screen'),
        appBar: AppBar(title: const Text('Lesson details')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _DetailError(
                    message: _error!,
                    canRetry: _canRetry,
                    onRetry: _loadDetail,
                  )
                : _detail == null
                    ? const SizedBox.shrink()
                    : _DetailContent(detail: _detail!),
      );
}

class _DetailError extends StatelessWidget {
  const _DetailError({
    required this.message,
    required this.canRetry,
    required this.onRetry,
  });
  final String message;
  final bool canRetry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (canRetry)
              OutlinedButton.icon(
                key: const Key('lesson-history-detail-retry'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ]),
        ),
      );
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});
  final LessonHistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    final feedbackByMessage = <String, List<LessonHistoryFeedbackResult>>{};
    for (final feedback in detail.feedbackResults) {
      feedbackByMessage.putIfAbsent(feedback.messageId, () => []).add(feedback);
    }
    return ListView(
      key: const Key('lesson-history-detail-content'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        _OverviewCard(detail: detail),
        const SizedBox(height: 24),
        Text('Summary', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _SummaryCard(summary: detail.summary),
        const SizedBox(height: 24),
        Text('Conversation', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (detail.messages.isEmpty)
          const Text('No conversation is available for this lesson.')
        else
          for (final message in detail.messages) ...[
            _HistoryMessageBubble(message: message),
            for (final feedback in feedbackByMessage[message.id] ?? const [])
              _FeedbackCard(feedback: feedback),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.detail});
  final LessonHistoryDetail detail;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_fallback(detail.topicTitle, 'Lesson'),
                style: Theme.of(context).textTheme.titleMedium),
            if (detail.subtopicTitle.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(detail.subtopicTitle),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 6, children: [
              Text(_fallback(detail.level, 'Level')),
              Text(_formatDate(detail.finishedAt ?? detail.startedAt)),
              Text(_modeLabel(detail.modeUsed)),
              Text(_statusLabel(detail.status)),
            ]),
            if (detail.selectedContextTitle?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 10),
              Text(detail.selectedContextTitle!.trim()),
            ],
          ]),
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final LessonHistorySummary? summary;

  @override
  Widget build(BuildContext context) {
    final sections = summary == null
        ? const <(String, String)>[]
        : <(String, String)>[
            ('Overall summary', summary!.summary),
            ('Strengths', summary!.strengths ?? ''),
            ('Improvements', summary!.improvements ?? ''),
            ('Vocabulary', summary!.vocabulary ?? ''),
            ('Grammar', summary!.grammar ?? ''),
            ('Next steps', summary!.nextSteps ?? ''),
          ].where((section) => section.$2.trim().isNotEmpty).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: sections.isEmpty
            ? const Text('No lesson summary is available.')
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var index = 0; index < sections.length; index++) ...[
                  if (index > 0) const SizedBox(height: 16),
                  Text(sections[index].$1,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(sections[index].$2.trim()),
                ],
              ]),
      ),
    );
  }
}

class _HistoryMessageBubble extends StatelessWidget {
  const _HistoryMessageBubble({required this.message});
  final LessonHistoryMessage message;

  @override
  Widget build(BuildContext context) {
    final isTutor = message.role.trim().toLowerCase() == 'tutor';
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isTutor ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: isTutor ? colors.surface : colors.primaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(26),
              topRight: const Radius.circular(26),
              bottomLeft: Radius.circular(isTutor ? 8 : 26),
              bottomRight: Radius.circular(isTutor ? 26 : 8),
            ),
            border:
                Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isTutor ? 'Tutor' : 'You',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isTutor
                        ? colors.onSurface
                        : colors.onPrimaryContainer)),
            const SizedBox(height: 4),
            Text(message.text,
                style: TextStyle(
                    color: isTutor
                        ? colors.onSurface
                        : colors.onPrimaryContainer)),
          ]),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});
  final LessonHistoryFeedbackResult feedback;

  @override
  Widget build(BuildContext context) {
    final sections = <(String, String)>[
      ('Corrected text', feedback.correctedText ?? ''),
      ('Explanation', feedback.explanation ?? ''),
      ('Grammar tip', feedback.grammarTip ?? ''),
      ('Vocabulary tip', feedback.vocabularyTip ?? ''),
      ('Culture tip', feedback.cultureTip ?? ''),
      ('Praise', feedback.praise ?? ''),
    ].where((section) => section.$2.trim().isNotEmpty).toList();
    if (sections.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Feedback',
                style: TextStyle(fontWeight: FontWeight.w600)),
            for (final section in sections) ...[
              const SizedBox(height: 8),
              Text(section.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(section.$2.trim()),
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

String _statusLabel(String status) =>
    status.trim().toLowerCase() == 'finished' ? 'Completed' : 'Completed';

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
