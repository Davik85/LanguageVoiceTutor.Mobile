class LessonHistoryList {
  const LessonHistoryList({required this.items});

  final List<LessonHistoryItem> items;

  factory LessonHistoryList.fromJson(Map<String, dynamic> json) =>
      LessonHistoryList(
        items: _list(json['items'])
            .map((value) => LessonHistoryItem.fromJson(_map(value)))
            .toList(growable: false),
      );
}

class LessonHistoryItem {
  const LessonHistoryItem({
    required this.sessionId,
    required this.lessonContentId,
    required this.studyLanguage,
    required this.topicTitle,
    required this.subtopicTitle,
    required this.level,
    required this.selectedContextTitle,
    required this.modeUsed,
    required this.status,
    required this.startedAt,
    required this.finishedAt,
    required this.validTurnCount,
    required this.estimatedCost,
    required this.hasSummary,
    required this.summaryPreview,
    required this.messageCount,
    required this.updatedAt,
  });

  final String sessionId;
  final String lessonContentId;
  final String studyLanguage;
  final String topicTitle;
  final String subtopicTitle;
  final String level;
  final String? selectedContextTitle;
  final String modeUsed;
  final String status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int validTurnCount;
  final double estimatedCost;
  final bool hasSummary;
  final String? summaryPreview;
  final int messageCount;
  final DateTime updatedAt;

  factory LessonHistoryItem.fromJson(Map<String, dynamic> json) =>
      LessonHistoryItem(
        sessionId: _requiredId(json, 'sessionId'),
        lessonContentId: _requiredString(json, 'lessonContentId'),
        studyLanguage: _requiredString(json, 'studyLanguage'),
        topicTitle: _requiredString(json, 'topicTitle'),
        subtopicTitle: _requiredString(json, 'subtopicTitle'),
        level: _requiredString(json, 'level'),
        selectedContextTitle: _nullableString(json['selectedContextTitle']),
        modeUsed: _requiredString(json, 'modeUsed'),
        status: _requiredString(json, 'status'),
        startedAt: _requiredDate(json, 'startedAt'),
        finishedAt: _nullableDate(json['finishedAt']),
        validTurnCount: _requiredInt(json, 'validTurnCount'),
        estimatedCost: _requiredDouble(json, 'estimatedCost'),
        hasSummary: _requiredBool(json, 'hasSummary'),
        summaryPreview: _nullableString(json['summaryPreview']),
        messageCount: _requiredInt(json, 'messageCount'),
        updatedAt: _requiredDate(json, 'updatedAt'),
      );
}

class LessonHistoryDetail {
  const LessonHistoryDetail({
    required this.sessionId,
    required this.userId,
    required this.lessonContentId,
    required this.studyLanguage,
    required this.topicId,
    required this.topicTitle,
    required this.subtopicId,
    required this.subtopicTitle,
    required this.level,
    required this.selectedContextId,
    required this.selectedContextTitle,
    required this.modeUsed,
    required this.status,
    required this.startedAt,
    required this.finishedAt,
    required this.validTurnCount,
    required this.estimatedCost,
    required this.createdAt,
    required this.updatedAt,
    required this.summary,
    required this.messages,
    required this.feedbackResults,
  });

  final String sessionId;
  final String userId;
  final String lessonContentId;
  final String studyLanguage;
  final String topicId;
  final String topicTitle;
  final String subtopicId;
  final String subtopicTitle;
  final String level;
  final String? selectedContextId;
  final String? selectedContextTitle;
  final String modeUsed;
  final String status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int validTurnCount;
  final double estimatedCost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LessonHistorySummary? summary;
  final List<LessonHistoryMessage> messages;
  final List<LessonHistoryFeedbackResult> feedbackResults;

  factory LessonHistoryDetail.fromJson(Map<String, dynamic> json) =>
      LessonHistoryDetail(
        sessionId: _requiredId(json, 'sessionId'),
        userId: _requiredId(json, 'userId'),
        lessonContentId: _requiredString(json, 'lessonContentId'),
        studyLanguage: _requiredString(json, 'studyLanguage'),
        topicId: _requiredString(json, 'topicId'),
        topicTitle: _requiredString(json, 'topicTitle'),
        subtopicId: _requiredString(json, 'subtopicId'),
        subtopicTitle: _requiredString(json, 'subtopicTitle'),
        level: _requiredString(json, 'level'),
        selectedContextId: _nullableString(json['selectedContextId']),
        selectedContextTitle: _nullableString(json['selectedContextTitle']),
        modeUsed: _requiredString(json, 'modeUsed'),
        status: _requiredString(json, 'status'),
        startedAt: _requiredDate(json, 'startedAt'),
        finishedAt: _nullableDate(json['finishedAt']),
        validTurnCount: _requiredInt(json, 'validTurnCount'),
        estimatedCost: _requiredDouble(json, 'estimatedCost'),
        createdAt: _requiredDate(json, 'createdAt'),
        updatedAt: _requiredDate(json, 'updatedAt'),
        summary: json['summary'] == null
            ? null
            : LessonHistorySummary.fromJson(_map(json['summary'])),
        messages: _list(json['messages'])
            .map((value) => LessonHistoryMessage.fromJson(_map(value)))
            .toList(growable: false),
        feedbackResults: _list(json['feedbackResults'])
            .map((value) => LessonHistoryFeedbackResult.fromJson(_map(value)))
            .toList(growable: false),
      );
}

class LessonHistorySummary {
  const LessonHistorySummary({
    required this.id,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.vocabulary,
    required this.grammar,
    required this.nextSteps,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String summary;
  final String? strengths;
  final String? improvements;
  final String? vocabulary;
  final String? grammar;
  final String? nextSteps;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LessonHistorySummary.fromJson(Map<String, dynamic> json) =>
      LessonHistorySummary(
        id: _requiredId(json, 'id'),
        summary: _requiredString(json, 'summary'),
        strengths: _nullableString(json['strengths']),
        improvements: _nullableString(json['improvements']),
        vocabulary: _nullableString(json['vocabulary']),
        grammar: _nullableString(json['grammar']),
        nextSteps: _nullableString(json['nextSteps']),
        createdAt: _requiredDate(json, 'createdAt'),
        updatedAt: _requiredDate(json, 'updatedAt'),
      );
}

class LessonHistoryMessage {
  const LessonHistoryMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.source,
    required this.turnNumber,
    required this.isValidLessonTurn,
    required this.studyLanguage,
    required this.transcriptConfidence,
    required this.audioDurationMs,
    required this.createdAt,
  });

  final String id;
  final String role;
  final String text;
  final String source;
  final int turnNumber;
  final bool isValidLessonTurn;
  final String studyLanguage;
  final double? transcriptConfidence;
  final int? audioDurationMs;
  final DateTime createdAt;

  factory LessonHistoryMessage.fromJson(Map<String, dynamic> json) =>
      LessonHistoryMessage(
        id: _requiredId(json, 'id'),
        role: _requiredString(json, 'role'),
        text: _requiredString(json, 'text'),
        source: _requiredString(json, 'source'),
        turnNumber: _requiredInt(json, 'turnNumber'),
        isValidLessonTurn: _requiredBool(json, 'isValidLessonTurn'),
        studyLanguage: _requiredString(json, 'studyLanguage'),
        transcriptConfidence: _nullableDouble(json['transcriptConfidence']),
        audioDurationMs: _nullableInt(json['audioDurationMs']),
        createdAt: _requiredDate(json, 'createdAt'),
      );
}

class LessonHistoryFeedbackResult {
  const LessonHistoryFeedbackResult({
    required this.id,
    required this.sessionId,
    required this.messageId,
    required this.feedbackType,
    required this.correctedText,
    required this.explanation,
    required this.grammarTip,
    required this.vocabularyTip,
    required this.cultureTip,
    required this.praise,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String messageId;
  final String feedbackType;
  final String? correctedText;
  final String? explanation;
  final String? grammarTip;
  final String? vocabularyTip;
  final String? cultureTip;
  final String? praise;
  final DateTime createdAt;

  factory LessonHistoryFeedbackResult.fromJson(Map<String, dynamic> json) =>
      LessonHistoryFeedbackResult(
        id: _requiredId(json, 'id'),
        sessionId: _requiredId(json, 'sessionId'),
        messageId: _requiredId(json, 'messageId'),
        feedbackType: _requiredString(json, 'feedbackType'),
        correctedText: _nullableString(json['correctedText']),
        explanation: _nullableString(json['explanation']),
        grammarTip: _nullableString(json['grammarTip']),
        vocabularyTip: _nullableString(json['vocabularyTip']),
        cultureTip: _nullableString(json['cultureTip']),
        praise: _nullableString(json['praise']),
        createdAt: _requiredDate(json, 'createdAt'),
      );
}

enum LessonHistoryStatus {
  success,
  validation,
  authRequired,
  notFound,
  unavailable,
  failed
}

class LessonHistoryListResult {
  const LessonHistoryListResult._(
      {required this.status, required this.message, this.history});
  final LessonHistoryStatus status;
  final String message;
  final LessonHistoryList? history;
  bool get isSuccess => status == LessonHistoryStatus.success;
  factory LessonHistoryListResult.success(LessonHistoryList history) =>
      LessonHistoryListResult._(
          status: LessonHistoryStatus.success, message: '', history: history);
  factory LessonHistoryListResult.authRequired() =>
      const LessonHistoryListResult._(
          status: LessonHistoryStatus.authRequired,
          message: 'Please sign in again to view lesson history.');
  factory LessonHistoryListResult.unavailable() => const LessonHistoryListResult
      ._(
      status: LessonHistoryStatus.unavailable,
      message: 'Lesson history is temporarily unavailable. Please try again.');
  factory LessonHistoryListResult.failed() => const LessonHistoryListResult._(
      status: LessonHistoryStatus.failed,
      message: 'Could not load lesson history. Please try again.');
}

class LessonHistoryDetailResult {
  const LessonHistoryDetailResult._(
      {required this.status, required this.message, this.detail});
  final LessonHistoryStatus status;
  final String message;
  final LessonHistoryDetail? detail;
  bool get isSuccess => status == LessonHistoryStatus.success;
  factory LessonHistoryDetailResult.success(LessonHistoryDetail detail) =>
      LessonHistoryDetailResult._(
          status: LessonHistoryStatus.success, message: '', detail: detail);
  factory LessonHistoryDetailResult.validation() =>
      const LessonHistoryDetailResult._(
          status: LessonHistoryStatus.validation,
          message: 'That lesson is not available.');
  factory LessonHistoryDetailResult.authRequired() =>
      const LessonHistoryDetailResult._(
          status: LessonHistoryStatus.authRequired,
          message: 'Please sign in again to view lesson history.');
  factory LessonHistoryDetailResult.notFound() =>
      const LessonHistoryDetailResult._(
          status: LessonHistoryStatus.notFound,
          message: 'This lesson is no longer available.');
  factory LessonHistoryDetailResult.unavailable() =>
      const LessonHistoryDetailResult._(
          status: LessonHistoryStatus.unavailable,
          message:
              'Lesson history is temporarily unavailable. Please try again.');
  factory LessonHistoryDetailResult.failed() =>
      const LessonHistoryDetailResult._(
          status: LessonHistoryStatus.failed,
          message: 'Could not load lesson details. Please try again.');
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  throw const FormatException('Expected a JSON object.');
}

List<Object?> _list(Object? value) {
  if (value is List) return value;
  throw const FormatException('Expected a JSON array.');
}

String _requiredId(Map<String, dynamic> json, String key) {
  final value = _requiredString(json, key).trim();
  if (value.isEmpty) throw FormatException('Missing $key.');
  return value;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Invalid $key.');
  return value;
}

String? _nullableString(Object? value) => value is String ? value : null;
int _requiredInt(Map<String, dynamic> json, String key) => _int(json[key], key);
int? _nullableInt(Object? value) =>
    value is num && value == value.roundToDouble() ? value.toInt() : null;
int _int(Object? value, String key) {
  if (value is num && value == value.roundToDouble()) return value.toInt();
  throw FormatException('Invalid $key.');
}

double _requiredDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toDouble();
  throw FormatException('Invalid $key.');
}

double? _nullableDouble(Object? value) =>
    value is num ? value.toDouble() : null;
bool _requiredBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException('Invalid $key.');
}

DateTime _requiredDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Invalid $key.');
  return DateTime.parse(value);
}

DateTime? _nullableDate(Object? value) =>
    value is String ? DateTime.parse(value) : null;
