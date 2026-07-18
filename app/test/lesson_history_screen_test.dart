import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/lesson_history.dart';
import 'package:language_voice_tutor_mobile/screens/home_screen.dart';
import 'package:language_voice_tutor_mobile/screens/lesson_history_screen.dart';
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

class _HistoryAuthService extends AuthService {
  _HistoryAuthService(this.responses)
      : super(apiClient: _Api(), storage: _Storage());
  final List<Future<LessonHistoryListResult> Function()> responses;
  int historyCalls = 0;
  int detailCalls = 0;

  @override
  Future<LessonHistoryListResult> fetchLessonHistory() {
    historyCalls += 1;
    return responses.removeAt(0)();
  }

  @override
  Future<LessonHistoryDetailResult> fetchLessonHistoryDetail(String sessionId) {
    detailCalls += 1;
    return super.fetchLessonHistoryDetail(sessionId);
  }
}

LessonHistoryItem _item({
  required String topic,
  String subtopic = 'Introductions',
  String level = 'A1',
  String? context = 'At a cafe',
  String mode = 'text',
  String? summary = 'You practised a friendly greeting.',
}) =>
    LessonHistoryItem(
      sessionId: 'private-session-id',
      lessonContentId: 'internal-content-id',
      studyLanguage: 'Spanish',
      topicTitle: topic,
      subtopicTitle: subtopic,
      level: level,
      selectedContextTitle: context,
      modeUsed: mode,
      status: 'finished',
      startedAt: DateTime.utc(2026, 7, 10),
      finishedAt: DateTime.utc(2026, 7, 10),
      validTurnCount: 3,
      estimatedCost: 12.50,
      hasSummary: summary != null,
      summaryPreview: summary,
      messageCount: 6,
      updatedAt: DateTime.utc(2026, 7, 10),
    );

Widget _screen(_HistoryAuthService auth) => MaterialApp(
      home: LessonHistoryScreen(authService: auth),
      routes: {'/login': (_) => const Scaffold(body: Text('Login route'))},
    );

void main() {
  testWidgets('shows an initial loading state', (tester) async {
    final pending = Completer<LessonHistoryListResult>();
    final auth = _HistoryAuthService([() => pending.future]);
    await tester.pumpWidget(_screen(auth));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(auth.historyCalls, 1);
    pending.complete(
        LessonHistoryListResult.success(const LessonHistoryList(items: [])));
  });

  testWidgets('renders lessons in backend order with learner fields only',
      (tester) async {
    final auth = _HistoryAuthService([
      () async => LessonHistoryListResult.success(
            LessonHistoryList(items: [
              _item(topic: 'Daily Life'),
              _item(topic: 'Travel', mode: 'voice')
            ]),
          )
    ]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    expect(find.text('Daily Life'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Daily Life')).dy,
        lessThan(tester.getTopLeft(find.text('Travel')).dy));
    expect(find.text('Introductions'), findsNWidgets(2));
    expect(find.text('A1'), findsNWidgets(2));
    expect(find.text('Jul 10, 2026'), findsNWidgets(2));
    expect(find.text('At a cafe'), findsNWidgets(2));
    expect(find.text('Lesson chat'), findsOneWidget);
    expect(find.text('Conversation'), findsOneWidget);
    expect(find.text('private-session-id'), findsNothing);
    expect(find.text('internal-content-id'), findsNothing);
    expect(find.text('12.5'), findsNothing);
    expect(auth.detailCalls, 0);
  });

  testWidgets('shows the empty state and returns Home', (tester) async {
    final auth = _HistoryAuthService([
      () async =>
          LessonHistoryListResult.success(const LessonHistoryList(items: []))
    ]);
    await tester.pumpWidget(MaterialApp(
        home: HomeScreen(authService: auth),
        routes: {'/login': (_) => const Scaffold(body: Text('Login route'))}));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-lesson-history')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-history-empty')), findsOneWidget);
    expect(find.text('No completed lessons yet'), findsOneWidget);
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('system back returns from History to Home', (tester) async {
    final auth = _HistoryAuthService([
      () async => LessonHistoryListResult.success(
            LessonHistoryList(items: [_item(topic: 'Daily Life')]),
          ),
    ]);
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(authService: auth),
      routes: {'/login': (_) => const Scaffold(body: Text('Login route'))},
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-lesson-history')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('failure retries once and prevents duplicate concurrent retries',
      (tester) async {
    final pending = Completer<LessonHistoryListResult>();
    final auth = _HistoryAuthService([
      () async => LessonHistoryListResult.unavailable(),
      () => pending.future,
    ]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Lesson history is temporarily unavailable. Please try again.'),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-history-retry')));
    await tester.tap(find.byKey(const Key('lesson-history-retry')));
    await tester.pump();
    expect(auth.historyCalls, 2);
    pending.complete(LessonHistoryListResult.success(
        LessonHistoryList(items: [_item(topic: 'Food', context: null)])));
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('authentication required clears History and opens Login',
      (tester) async {
    final auth = _HistoryAuthService(
        [() async => LessonHistoryListResult.authRequired()]);
    await tester.pumpWidget(_screen(auth));
    await tester.pumpAndSettle();
    expect(find.text('Login route'), findsOneWidget);
  });
}
