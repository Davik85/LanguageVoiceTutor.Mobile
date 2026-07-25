import 'package:flutter/material.dart';

import '../l10n/app_localizations_context.dart';
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
  LessonHistoryStatus? _errorStatus;
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
        _errorStatus = null;
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
      _errorStatus = result.isSuccess ? null : result.status;
      _canRetry = result.status == LessonHistoryStatus.unavailable ||
          result.status == LessonHistoryStatus.failed;
    });
    _isRequestInFlight = false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: const Key('lesson-history-detail-screen'),
        appBar: AppBar(title: Text(context.l10n.lessonHistoryDetails)),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorStatus != null
                ? _DetailError(
                    status: _errorStatus!,
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
    required this.status,
    required this.canRetry,
    required this.onRetry,
  });
  final LessonHistoryStatus status;
  final bool canRetry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_errorMessage(context, status), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (canRetry)
              OutlinedButton.icon(
                key: const Key('lesson-history-detail-retry'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.back),
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
        Text(context.l10n.historySummary,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _SummaryCard(summary: detail.summary),
        const SizedBox(height: 24),
        Text(context.l10n.conversation,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (detail.messages.isEmpty)
          Text(context.l10n.noHistoryConversation)
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
            Text(_fallback(detail.topicTitle, context.l10n.lesson),
                style: Theme.of(context).textTheme.titleMedium),
            if (detail.subtopicTitle.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(detail.subtopicTitle),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 6, children: [
              Text(_fallback(detail.level, context.l10n.level)),
              Text(_formatDate(context, detail.finishedAt ?? detail.startedAt)),
              Text(_modeLabel(context, detail.modeUsed)),
              Text(_statusLabel(context, detail.status)),
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
            (context.l10n.overallSummary, summary!.summary),
            (context.l10n.summaryStrengths, summary!.strengths ?? ''),
            (context.l10n.summaryImprovements, summary!.improvements ?? ''),
            (context.l10n.summaryVocabulary, summary!.vocabulary ?? ''),
            (context.l10n.summaryGrammar, summary!.grammar ?? ''),
            (context.l10n.summaryNextSteps, summary!.nextSteps ?? ''),
          ].where((section) => section.$2.trim().isNotEmpty).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: sections.isEmpty
            ? Text(context.l10n.noHistorySummary)
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
            Text(isTutor ? context.l10n.historyTutor : context.l10n.historyYou,
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
      (context.l10n.feedbackCorrectedText, feedback.correctedText ?? ''),
      (context.l10n.feedbackExplanation, feedback.explanation ?? ''),
      (context.l10n.feedbackGrammarTip, feedback.grammarTip ?? ''),
      (context.l10n.feedbackVocabularyTip, feedback.vocabularyTip ?? ''),
      (context.l10n.feedbackCultureTip, feedback.cultureTip ?? ''),
      (context.l10n.feedbackPraise, feedback.praise ?? ''),
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
            Text(context.l10n.lessonFeedback,
                style: const TextStyle(fontWeight: FontWeight.w600)),
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

String _modeLabel(BuildContext context, String mode) {
  switch (mode.trim().toLowerCase()) {
    case 'text':
      return context.l10n.lessonChat;
    case 'voice':
    case 'conversation':
      return context.l10n.conversation;
    default:
      return context.l10n.lesson;
  }
}

String _statusLabel(BuildContext context, String status) =>
    context.l10n.completed;

String _formatDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatMediumDate(date.toLocal());

String _errorMessage(BuildContext context, LessonHistoryStatus status) =>
    switch (status) {
      LessonHistoryStatus.validation => context.l10n.lessonUnavailable,
      LessonHistoryStatus.notFound => context.l10n.lessonNoLongerAvailable,
      LessonHistoryStatus.unavailable => context.l10n.lessonHistoryUnavailable,
      LessonHistoryStatus.failed ||
      LessonHistoryStatus.success =>
        context.l10n.lessonDetailLoadFailed,
      LessonHistoryStatus.authRequired => context.l10n.lessonDetailLoadFailed,
    };
