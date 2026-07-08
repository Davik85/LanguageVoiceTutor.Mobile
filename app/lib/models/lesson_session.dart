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

class LessonSessionReplyRequest {
  const LessonSessionReplyRequest({required this.messageText});

  final String messageText;

  Map<String, dynamic> toJson() => {'messageText': messageText};
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

class LessonSessionReplyResponse {
  const LessonSessionReplyResponse({
    this.messageText,
    this.sessionId,
  });

  final String? messageText;
  final String? sessionId;

  factory LessonSessionReplyResponse.fromJson(Map<String, dynamic> json) {
    final replyJson = _object(json, 'reply') ??
        _object(json, 'message') ??
        _object(json, 'assistantMessage');
    final source = replyJson ?? json;

    return LessonSessionReplyResponse(
      messageText: _nullableFirstString(source, const [
        'messageText',
        'replyText',
        'text',
      ]),
      sessionId: _nullableFirstString(source, const [
        'lessonSessionId',
        'sessionId',
        'id',
      ]),
    );
  }
}

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
            'You already have an active lesson on another device. Finish it there before starting a new one.',
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

enum LessonSessionReplyStatus {
  success,
  validation,
  authRequired,
  notFound,
  notImplemented,
  conflict,
  limited,
  unavailable,
  failed,
}

class LessonSessionReplyResult {
  const LessonSessionReplyResult._({
    required this.status,
    required this.message,
    this.reply,
  });

  final LessonSessionReplyStatus status;
  final String message;
  final LessonSessionReplyResponse? reply;

  bool get isSuccess => status == LessonSessionReplyStatus.success;

  factory LessonSessionReplyResult.success(
          [LessonSessionReplyResponse? reply]) =>
      LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.success,
        message: 'Message sent.',
        reply: reply,
      );

  factory LessonSessionReplyResult.validation() =>
      const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.validation,
        message: 'Please enter a message.',
      );

  factory LessonSessionReplyResult.authRequired() =>
      const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.authRequired,
        message: 'Please sign in again to continue the lesson.',
      );

  factory LessonSessionReplyResult.notFound() =>
      const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.notFound,
        message: 'This lesson session is no longer available.',
      );

  factory LessonSessionReplyResult.notImplemented() =>
      const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.notImplemented,
        message: 'Text chat is not available yet.',
      );

  factory LessonSessionReplyResult.conflict() =>
      const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.conflict,
        message: 'This lesson has already ended.',
      );

  factory LessonSessionReplyResult.limited() =>
      const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.limited,
        message:
            'You have used today\'s free lesson. Please try again tomorrow or upgrade.',
      );

  factory LessonSessionReplyResult.unavailable() =>
      const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.unavailable,
        message:
            'Could not send the message. Please check your connection and try again.',
      );

  factory LessonSessionReplyResult.failed() => const LessonSessionReplyResult._(
        status: LessonSessionReplyStatus.failed,
        message: 'Could not send the message. Please try again.',
      );
}

Map<String, dynamic>? _object(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is Map<String, dynamic> ? value : null;
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
  }
  return '';
}

String? _nullableFirstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
