class StartLessonSessionRequest {
  const StartLessonSessionRequest({
    required this.lessonContentId,
    required this.studyLanguage,
  });

  final String lessonContentId;
  final String studyLanguage;

  Map<String, dynamic> toJson() => {
        'lessonContentId': lessonContentId,
        'studyLanguage': studyLanguage,
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
            'You have used today’s free lesson. Please try again tomorrow or upgrade.',
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
