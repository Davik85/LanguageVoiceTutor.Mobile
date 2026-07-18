import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/lesson_history.dart';
import 'package:language_voice_tutor_mobile/screens/lesson_history_detail_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _Api implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) =>
      throw UnimplementedError();
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) =>
      throw UnimplementedError();
}

class _Storage implements SessionStorage {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {}
}

class _DetailAuthService extends AuthService {
  _DetailAuthService(this.responses)
      : super(apiClient: _Api(), storage: _Storage());
  final List<Future<LessonHistoryDetailResult> Function(String)> responses;
  final List<String> sessionIds = [];

  @override
  Future<LessonHistoryDetailResult> fetchLessonHistoryDetail(String sessionId) {
    sessionIds.add(sessionId);
    return responses.removeAt(0)(sessionId);
  }
}

LessonHistoryDetail _detail({LessonHistorySummary? summary}) {
  final now = DateTime.utc(2026, 7, 10, 14, 30);
  return LessonHistoryDetail(
    sessionId: 'private-session-id',
    userId: 'private-user-id',
    lessonContentId: 'internal-content-id',
    studyLanguage: 'Spanish',
    topicId: 'topic-id',
    topicTitle: 'Daily Life',
    subtopicId: 'subtopic-id',
    subtopicTitle: 'Introductions',
    level: 'A1',
    selectedContextId: 'context-id',
    selectedContextTitle: 'At a cafe',
    modeUsed: 'voice',
    status: 'finished',
    startedAt: now,
    finishedAt: now,
    validTurnCount: 2,
    estimatedCost: 12.5,
    createdAt: now,
    updatedAt: now,
    summary: summary,
    messages: [
      LessonHistoryMessage(
          id: 'learner-message-id',
          role: 'user',
          text: 'Hola',
          source: 'voice',
          turnNumber: 1,
          isValidLessonTurn: true,
          studyLanguage: 'Spanish',
          transcriptConfidence: .88,
          audioDurationMs: 850,
          createdAt: now),
      LessonHistoryMessage(
          id: 'tutor-message-id',
          role: 'tutor',
          text: '¡Hola!',
          source: 'generated',
          turnNumber: 1,
          isValidLessonTurn: true,
          studyLanguage: 'Spanish',
          transcriptConfidence: null,
          audioDurationMs: null,
          createdAt: now),
    ],
    feedbackResults: [
      LessonHistoryFeedbackResult(
          id: 'feedback-id',
          sessionId: 'private-session-id',
          messageId: 'learner-message-id',
          feedbackType: 'grammar',
          correctedText: 'Hola.',
          explanation: 'Add punctuation.',
          grammarTip: '',
          vocabularyTip: 'A greeting is a useful opener.',
          cultureTip: null,
          praise: 'Nice greeting!',
          createdAt: now),
    ],
  );
}

LessonHistorySummary _summary() {
  final now = DateTime.utc(2026, 7, 10);
  return LessonHistorySummary(
      id: 'summary-id',
      summary: 'You greeted clearly.',
      strengths: 'Friendly tone',
      improvements: 'Try a longer reply.',
      vocabulary: '',
      grammar: null,
      nextSteps: 'Practise greetings tomorrow.',
      createdAt: now,
      updatedAt: now);
}

Widget _screen(_DetailAuthService auth, {String sessionId = 'session-123'}) =>
    MaterialApp(
      home: LessonHistoryDetailScreen(sessionId: sessionId, authService: auth),
      routes: {'/login': (_) => const Scaffold(body: Text('Login route'))},
    );

void main() {
  testWidgets('loads once and renders learner-facing detail content',
      (tester) async {
    final auth = _DetailAuthService([
      (_) async =>
          LessonHistoryDetailResult.success(_detail(summary: _summary())),
    ]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    expect(auth.sessionIds, ['session-123']);
    for (final text in [
      'Daily Life',
      'Introductions',
      'A1',
      'Jul 10, 2026',
      'Completed',
      'At a cafe',
      'Overall summary',
      'You greeted clearly.',
      'Strengths',
      'Friendly tone',
      'Improvements',
      'Try a longer reply.',
      'Next steps',
      'Practise greetings tomorrow.',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.text('¡Hola!'),
      300,
      scrollable: find.byType(Scrollable),
    );
    for (final text in [
      'Hola',
      '¡Hola!',
      'You',
      'Tutor',
      'Feedback',
      'Corrected text',
      'Hola.'
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.getTopLeft(find.text('Hola')).dy,
        lessThan(tester.getTopLeft(find.text('¡Hola!')).dy));
    for (final hidden in [
      'private-session-id',
      'private-user-id',
      'internal-content-id',
      'topic-id',
      'summary-id',
      'learner-message-id',
      'feedback-id',
      '12.5',
      '0.88',
      '850',
      'voice',
      'generated'
    ]) {
      expect(find.text(hidden), findsNothing);
    }
    expect(find.text('Vocabulary'), findsNothing);
    expect(find.text('Grammar'), findsNothing);
  });

  testWidgets('shows loading and missing-summary fallback', (tester) async {
    final pending = Completer<LessonHistoryDetailResult>();
    final auth = _DetailAuthService([(_) => pending.future]);
    await tester.pumpWidget(_screen(auth));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(auth.sessionIds, ['session-123']);
    pending.complete(LessonHistoryDetailResult.success(_detail()));
    await tester.pumpAndSettle();
    expect(find.text('No lesson summary is available.'), findsOneWidget);
  });

  testWidgets('not found offers Back and retry is single-flight then succeeds',
      (tester) async {
    final pending = Completer<LessonHistoryDetailResult>();
    final auth = _DetailAuthService([
      (_) async => LessonHistoryDetailResult.unavailable(),
      (_) => pending.future,
    ]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('lesson-history-detail-retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-history-detail-retry')));
    await tester.tap(find.byKey(const Key('lesson-history-detail-retry')));
    await tester.pump();
    expect(auth.sessionIds.length, 2);
    pending.complete(LessonHistoryDetailResult.success(_detail()));
    await tester.pumpAndSettle();
    expect(find.text('Daily Life'), findsOneWidget);
  });

  testWidgets('not found message offers Back', (tester) async {
    final notFound =
        _DetailAuthService([(_) async => LessonHistoryDetailResult.notFound()]);
    await tester.pumpWidget(_screen(notFound));
    await tester.pumpAndSettle();
    expect(find.text('This lesson is no longer available.'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('authentication uses the established Login route',
      (tester) async {
    final authRequired = _DetailAuthService(
        [(_) async => LessonHistoryDetailResult.authRequired()]);
    await tester.pumpWidget(_screen(authRequired));
    await tester.pumpAndSettle();
    expect(find.text('Login route'), findsOneWidget);
  });

  testWidgets('invalid id does not make a detail request', (tester) async {
    final auth = _DetailAuthService([]);
    await tester.pumpWidget(_screen(auth, sessionId: '  '));
    await tester.pumpAndSettle();
    expect(auth.sessionIds, isEmpty);
    expect(find.text('That lesson is not available.'), findsOneWidget);
  });
}
