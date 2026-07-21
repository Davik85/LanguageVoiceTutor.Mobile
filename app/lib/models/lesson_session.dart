class StartLessonSessionRequest {
  const StartLessonSessionRequest({
    required this.lessonContentId,
    required this.studyLanguage,
    required this.topicId,
    required this.topicTitle,
    required this.subtopicId,
    required this.subtopicTitle,
    required this.level,
    this.selectedContextId,
    this.selectedContextTitle,
    this.modeUsed = 'text',
  });

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

  Map<String, dynamic> toJson() => {
        'lessonContentId': lessonContentId,
        'studyLanguage': studyLanguage,
        'topicId': topicId,
        'topicTitle': topicTitle,
        'subtopicId': subtopicId,
        'subtopicTitle': subtopicTitle,
        'level': level,
        'selectedContextId': selectedContextId,
        'selectedContextTitle': selectedContextTitle,
        'modeUsed': modeUsed,
      };
}

class LessonSessionResponse {
  const LessonSessionResponse({
    required this.lessonSessionId,
    required this.lessonContentId,
    required this.studyLanguage,
  });

  final String lessonSessionId;
  final String lessonContentId;
  final String studyLanguage;

  factory LessonSessionResponse.fromJson(Map<String, dynamic> json) {
    final sessionJson =
        _object(json, 'lessonSession') ?? _object(json, 'session');
    final source = sessionJson ?? json;

    return LessonSessionResponse(
      lessonSessionId: _firstString(source, const [
        'lessonSessionId',
        'sessionId',
        'id',
      ]),
      lessonContentId: _firstString(source, const ['lessonContentId']),
      studyLanguage: _firstString(source, const ['studyLanguage']),
    );
  }
}

/// The minimal authenticated lesson-session list contract needed to discover
/// whether the backend currently has an active session for the learner.
class LessonSessionList {
  const LessonSessionList({required this.items});

  final List<LessonSessionListItem> items;

  factory LessonSessionList.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Invalid lesson session list.');
    }
    return LessonSessionList(
      items: rawItems
          .map((item) => LessonSessionListItem.fromJson(_requiredObject(item)))
          .toList(growable: false),
    );
  }
}

class LessonSessionListItem {
  const LessonSessionListItem({
    required this.sessionId,
    required this.status,
    required this.startedAt,
  });

  final String sessionId;
  final String status;
  final DateTime startedAt;

  bool get isActive => status.toLowerCase() == 'active';

  factory LessonSessionListItem.fromJson(Map<String, dynamic> json) {
    final sessionId = _requiredGuid(json, 'id');
    final status = _requiredNonBlankString(json, 'status');
    return LessonSessionListItem(
      sessionId: sessionId,
      status: status,
      startedAt: _requiredDateTime(json, 'startedAt'),
    );
  }
}

enum ActiveLessonSessionDiscoveryStatus {
  success,
  authRequired,
  unavailable,
  inconsistent,
  failed,
}

class ActiveLessonSessionDiscoveryResult {
  const ActiveLessonSessionDiscoveryResult._({
    required this.status,
    required this.message,
    this.session,
  });

  final ActiveLessonSessionDiscoveryStatus status;
  final String message;
  final LessonSessionListItem? session;

  bool get isSuccess => status == ActiveLessonSessionDiscoveryStatus.success;

  factory ActiveLessonSessionDiscoveryResult.none() =>
      const ActiveLessonSessionDiscoveryResult._(
        status: ActiveLessonSessionDiscoveryStatus.success,
        message: '',
      );

  factory ActiveLessonSessionDiscoveryResult.active(
    LessonSessionListItem session,
  ) =>
      ActiveLessonSessionDiscoveryResult._(
        status: ActiveLessonSessionDiscoveryStatus.success,
        message: '',
        session: session,
      );

  factory ActiveLessonSessionDiscoveryResult.authRequired() =>
      const ActiveLessonSessionDiscoveryResult._(
        status: ActiveLessonSessionDiscoveryStatus.authRequired,
        message: 'Please sign in again.',
      );

  factory ActiveLessonSessionDiscoveryResult.unavailable() =>
      const ActiveLessonSessionDiscoveryResult._(
        status: ActiveLessonSessionDiscoveryStatus.unavailable,
        message:
            'Lesson sessions are temporarily unavailable. Please try again.',
      );

  factory ActiveLessonSessionDiscoveryResult.inconsistent() =>
      const ActiveLessonSessionDiscoveryResult._(
        status: ActiveLessonSessionDiscoveryStatus.inconsistent,
        message:
            'Your lesson session state needs to be checked. Please try again.',
      );

  factory ActiveLessonSessionDiscoveryResult.failed() =>
      const ActiveLessonSessionDiscoveryResult._(
        status: ActiveLessonSessionDiscoveryStatus.failed,
        message: 'Could not check your lesson sessions. Please try again.',
      );
}

class FinishLessonSessionRequest {
  const FinishLessonSessionRequest({required this.validTurnCount});

  final int validTurnCount;

  Map<String, dynamic> toJson() => {'validTurnCount': validTurnCount};
}

class LessonSummaryResponse {
  const LessonSummaryResponse({
    required this.status,
    this.studyLanguage,
    this.topicTitle,
    this.subtopicTitle,
    this.level,
    this.summary,
    this.strengths = const [],
    this.improvements = const [],
    this.vocabulary = const [],
    this.grammar = const [],
    this.nextSteps = const [],
  });

  final String status;
  final String? studyLanguage;
  final String? topicTitle;
  final String? subtopicTitle;
  final String? level;
  final String? summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> vocabulary;
  final List<String> grammar;
  final List<String> nextSteps;

  bool get isReady => status == 'ready';
  bool get isUnavailable => status == 'unavailable';

  factory LessonSummaryResponse.fromJson(Map<String, dynamic> json) =>
      LessonSummaryResponse(
        status: _firstString(json, const ['status']).toLowerCase(),
        studyLanguage: _nullableString(json, 'studyLanguage'),
        topicTitle: _nullableString(json, 'topicTitle'),
        subtopicTitle: _nullableString(json, 'subtopicTitle'),
        level: _nullableString(json, 'level'),
        summary: _nullableString(json, 'summary'),
        strengths: _stringList(json['strengths']),
        improvements: _stringList(json['improvements']),
        vocabulary: _stringList(json['vocabulary']),
        grammar: _stringList(json['grammar']),
        nextSteps: _stringList(json['nextSteps']),
      );
}

enum LessonCompletionStatus {
  summaryReady,
  summaryUnavailable,
  authRequired,
  notFound,
  summaryLoadError,
  unavailable,
  failed,
}

enum LessonSessionAbandonStatus {
  abandoned,
  authRequired,
  unavailable,
  failed,
}

enum LessonSessionHeartbeatStatus {
  active,
  authRequired,
  notFound,
  sessionEnded,
  unavailable,
  failed,
}

class LessonSessionHeartbeatResult {
  const LessonSessionHeartbeatResult._(this.status);

  final LessonSessionHeartbeatStatus status;
  bool get isActive => status == LessonSessionHeartbeatStatus.active;
  bool get isTerminal =>
      status == LessonSessionHeartbeatStatus.notFound ||
      status == LessonSessionHeartbeatStatus.sessionEnded;

  factory LessonSessionHeartbeatResult.active() =>
      const LessonSessionHeartbeatResult._(LessonSessionHeartbeatStatus.active);
  factory LessonSessionHeartbeatResult.authRequired() =>
      const LessonSessionHeartbeatResult._(
          LessonSessionHeartbeatStatus.authRequired);
  factory LessonSessionHeartbeatResult.notFound() =>
      const LessonSessionHeartbeatResult._(
          LessonSessionHeartbeatStatus.notFound);
  factory LessonSessionHeartbeatResult.sessionEnded() =>
      const LessonSessionHeartbeatResult._(
          LessonSessionHeartbeatStatus.sessionEnded);
  factory LessonSessionHeartbeatResult.unavailable() =>
      const LessonSessionHeartbeatResult._(
          LessonSessionHeartbeatStatus.unavailable);
  factory LessonSessionHeartbeatResult.failed() =>
      const LessonSessionHeartbeatResult._(LessonSessionHeartbeatStatus.failed);
}

class LessonSessionAbandonResult {
  const LessonSessionAbandonResult._(
      {required this.status, required this.message});

  final LessonSessionAbandonStatus status;
  final String message;

  bool get canLeave => status == LessonSessionAbandonStatus.abandoned;

  factory LessonSessionAbandonResult.abandoned() =>
      const LessonSessionAbandonResult._(
        status: LessonSessionAbandonStatus.abandoned,
        message: 'Lesson ended.',
      );

  factory LessonSessionAbandonResult.authRequired() =>
      const LessonSessionAbandonResult._(
        status: LessonSessionAbandonStatus.authRequired,
        message: 'Please sign in again to continue the lesson.',
      );

  factory LessonSessionAbandonResult.unavailable() =>
      const LessonSessionAbandonResult._(
        status: LessonSessionAbandonStatus.unavailable,
        message:
            'Could not leave the lesson. Please check your connection and try again.',
      );

  factory LessonSessionAbandonResult.failed() =>
      const LessonSessionAbandonResult._(
        status: LessonSessionAbandonStatus.failed,
        message: 'Could not leave the lesson. Please try again.',
      );
}

class LessonCompletionResult {
  const LessonCompletionResult._({required this.status, this.summary});

  final LessonCompletionStatus status;
  final LessonSummaryResponse? summary;

  bool get isCompleted =>
      status == LessonCompletionStatus.summaryReady ||
      status == LessonCompletionStatus.summaryUnavailable ||
      status == LessonCompletionStatus.summaryLoadError;

  factory LessonCompletionResult.summaryReady(LessonSummaryResponse summary) =>
      LessonCompletionResult._(
          status: LessonCompletionStatus.summaryReady, summary: summary);
  factory LessonCompletionResult.summaryUnavailable() =>
      const LessonCompletionResult._(
          status: LessonCompletionStatus.summaryUnavailable);
  factory LessonCompletionResult.authRequired() =>
      const LessonCompletionResult._(
          status: LessonCompletionStatus.authRequired);
  factory LessonCompletionResult.notFound() =>
      const LessonCompletionResult._(status: LessonCompletionStatus.notFound);
  factory LessonCompletionResult.summaryLoadError() =>
      const LessonCompletionResult._(
          status: LessonCompletionStatus.summaryLoadError);
  factory LessonCompletionResult.unavailable() =>
      const LessonCompletionResult._(
          status: LessonCompletionStatus.unavailable);
  factory LessonCompletionResult.failed() =>
      const LessonCompletionResult._(status: LessonCompletionStatus.failed);
}

/// The outcome returned when a learner leaves a lesson route.
///
/// A completed result is emitted only after the backend finish operation has
/// succeeded. Callers must not infer completion from a route pop alone.
enum LessonExitResult { completed, unfinished, abandoned }

enum LessonSessionStartStatus {
  ready,
  blocked,
  conflict,
  authRequired,
  unavailable,
  failed,
}

class LessonSessionStartResult {
  const LessonSessionStartResult._({
    required this.status,
    required this.message,
    this.session,
  });

  final LessonSessionStartStatus status;
  final String message;
  final LessonSessionResponse? session;

  bool get isReady => status == LessonSessionStartStatus.ready;

  factory LessonSessionStartResult.ready(LessonSessionResponse session) =>
      LessonSessionStartResult._(
        status: LessonSessionStartStatus.ready,
        message: 'Lesson session is ready.',
        session: session,
      );

  factory LessonSessionStartResult.blocked() =>
      const LessonSessionStartResult._(
        status: LessonSessionStartStatus.blocked,
        message:
            'You have used today\'s free lesson. Please try again tomorrow or upgrade.',
      );

  factory LessonSessionStartResult.conflict() =>
      const LessonSessionStartResult._(
        status: LessonSessionStartStatus.conflict,
        message:
            'You already have an active lesson. Finish or leave it before starting a new one.',
      );

  factory LessonSessionStartResult.authRequired() =>
      const LessonSessionStartResult._(
        status: LessonSessionStartStatus.authRequired,
        message: 'Please sign in again to start a lesson.',
      );

  factory LessonSessionStartResult.unavailable() =>
      const LessonSessionStartResult._(
        status: LessonSessionStartStatus.unavailable,
        message:
            'Could not start the lesson. Please check your connection and try again.',
      );

  factory LessonSessionStartResult.failed() => const LessonSessionStartResult._(
        status: LessonSessionStartStatus.failed,
        message: 'Could not start the lesson. Please try again.',
      );
}

Map<String, dynamic>? _object(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is Map<String, dynamic> ? value : null;
}

Map<String, dynamic> _requiredObject(Object? value) {
  if (value is Map<String, dynamic>) return value;
  throw const FormatException('Invalid lesson session.');
}

String _requiredNonBlankString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Invalid $key.');
  }
  return value;
}

String _requiredGuid(Map<String, dynamic> json, String key) {
  final value = _requiredNonBlankString(json, key);
  if (!RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(value)) {
    throw FormatException('Invalid $key.');
  }
  return value;
}

DateTime _requiredDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Invalid $key.');
  return DateTime.parse(value).toUtc();
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
  }
  return '';
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is String && value.trim().isNotEmpty ? value : null;
}

List<String> _stringList(dynamic value) => value is List
    ? value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false)
    : const [];
