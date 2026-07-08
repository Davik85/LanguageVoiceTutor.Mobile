import 'language_options.dart';

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
    required this.status,
    this.lessonSessionId,
  });

  final String status;
  final String? lessonSessionId;

  factory LessonSessionResponse.fromJson(Map<String, dynamic> json) =>
      LessonSessionResponse(
        status: _string(json['status'], fallback: 'ready'),
        lessonSessionId: _nullableString(
          json['lessonSessionId'] ?? json['sessionId'] ?? json['id'],
        ),
      );
}

class LessonAccessDeniedResponse {
  const LessonAccessDeniedResponse({this.code});

  final String? code;

  factory LessonAccessDeniedResponse.fromJson(Map<String, dynamic> json) =>
      LessonAccessDeniedResponse(code: _nullableString(json['code']));
}

class ActiveLessonExistsResponse {
  const ActiveLessonExistsResponse({this.code});

  final String? code;

  factory ActiveLessonExistsResponse.fromJson(Map<String, dynamic> json) =>
      ActiveLessonExistsResponse(code: _nullableString(json['code']));
}

enum LessonSessionStartStatus {
  ready,
  accessDenied,
  activeLessonExists,
  unauthorized,
  unavailable,
  failure,
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

  static LessonSessionStartResult ready(LessonSessionResponse session) =>
      LessonSessionStartResult._(
        status: LessonSessionStartStatus.ready,
        message: 'Lesson session is ready',
        session: session,
      );

  static const accessDenied = LessonSessionStartResult._(
    status: LessonSessionStartStatus.accessDenied,
    message: 'You have used today’s free lesson. Please try again tomorrow or upgrade.',
  );

  static const activeLessonExists = LessonSessionStartResult._(
    status: LessonSessionStartStatus.activeLessonExists,
    message:
        'You already have an active lesson on another device. Finish it there before starting a new one.',
  );

  static const unauthorized = LessonSessionStartResult._(
    status: LessonSessionStartStatus.unauthorized,
    message: 'Please sign in again to start a lesson.',
  );

  static const unavailable = LessonSessionStartResult._(
    status: LessonSessionStartStatus.unavailable,
    message: 'Could not start the lesson. Please check your connection and try again.',
  );

  static const failure = LessonSessionStartResult._(
    status: LessonSessionStartStatus.failure,
    message: 'Could not start the lesson. Please try again.',
  );
}

String studyLanguageEnglishName(String id) {
  for (final option in LanguageOptions.studyLanguages) {
    if (option.id == id) return option.label;
  }
  return LanguageOptions.studyLanguages.first.label;
}

String _string(Object? value, {required String fallback}) {
  if (value is! String) return fallback;
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String? _nullableString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
