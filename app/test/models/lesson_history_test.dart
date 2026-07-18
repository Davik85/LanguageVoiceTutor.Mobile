import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_history.dart';

Map<String, dynamic> historyItem(String id, {Object? selectedContextTitle}) => {
      'sessionId': id,
      'lessonContentId': 'daily_introductions',
      'studyLanguage': 'Spanish',
      'topicTitle': 'Daily Life',
      'subtopicTitle': 'Introductions',
      'level': 'A1',
      'selectedContextTitle': selectedContextTitle,
      'modeUsed': 'text',
      'status': 'finished',
      'startedAt': '2026-07-10T10:00:00Z',
      'finishedAt': null,
      'validTurnCount': 3,
      'estimatedCost': 0.12,
      'hasSummary': false,
      'summaryPreview': null,
      'messageCount': 6,
      'updatedAt': '2026-07-10T10:05:00Z',
    };

Map<String, dynamic> detailJson({bool includeSummary = true}) => {
      ...historyItem('11111111-1111-1111-1111-111111111111'),
      'userId': '22222222-2222-2222-2222-222222222222',
      'topicId': 'daily-life',
      'subtopicId': 'introductions',
      'selectedContextId': null,
      'createdAt': '2026-07-10T09:59:00Z',
      'summary': includeSummary
          ? {
              'id': '33333333-3333-3333-3333-333333333333',
              'summary': 'A strong introduction lesson.',
              'strengths': null,
              'improvements': 'Ask one follow-up question.',
              'vocabulary': null,
              'grammar': null,
              'nextSteps': null,
              'createdAt': '2026-07-10T10:06:00Z',
              'updatedAt': '2026-07-10T10:06:00Z',
            }
          : null,
      'messages': [
        {
          'id': '44444444-4444-4444-4444-444444444444',
          'role': 'user',
          'text': 'Hello!',
          'source': 'typed',
          'turnNumber': 1,
          'isValidLessonTurn': true,
          'studyLanguage': 'Spanish',
          'transcriptConfidence': null,
          'audioDurationMs': null,
          'createdAt': '2026-07-10T10:00:01Z',
        },
      ],
      'feedbackResults': [
        {
          'id': '55555555-5555-5555-5555-555555555555',
          'sessionId': '11111111-1111-1111-1111-111111111111',
          'messageId': '44444444-4444-4444-4444-444444444444',
          'feedbackType': 'grammar',
          'correctedText': null,
          'explanation': 'Nice greeting.',
          'grammarTip': null,
          'vocabularyTip': null,
          'cultureTip': null,
          'praise': 'Good job.',
          'createdAt': '2026-07-10T10:01:00Z',
        },
      ],
    };

void main() {
  test('parses a history list, preserves ordering, and ignores extra fields',
      () {
    final first = historyItem('11111111-1111-1111-1111-111111111111',
        selectedContextTitle: 'At a cafe')
      ..['futureBackendField'] = {'ignored': true};
    final second = historyItem('22222222-2222-2222-2222-222222222222');

    final history = LessonHistoryList.fromJson({
      'items': [first, second]
    });

    expect(history.items.map((item) => item.sessionId), [
      '11111111-1111-1111-1111-111111111111',
      '22222222-2222-2222-2222-222222222222',
    ]);
    expect(history.items.first.selectedContextTitle, 'At a cafe');
    expect(history.items.last.finishedAt, isNull);
    expect(history.items.last.summaryPreview, isNull);
  });

  test('parses complete detail with summary, messages, and feedback', () {
    final detail = LessonHistoryDetail.fromJson(detailJson());

    expect(detail.summary?.summary, 'A strong introduction lesson.');
    expect(detail.messages.single.text, 'Hello!');
    expect(detail.feedbackResults.single.feedbackType, 'grammar');
    expect(detail.feedbackResults.single.correctedText, isNull);
  });

  test('parses detail with absent optional summary and empty feedback', () {
    final json = detailJson(includeSummary: false)..['feedbackResults'] = [];
    final detail = LessonHistoryDetail.fromJson(json);

    expect(detail.summary, isNull);
    expect(detail.feedbackResults, isEmpty);
  });

  test('rejects malformed required identifiers and required data', () {
    final blankId = historyItem('   ');
    expect(() => LessonHistoryItem.fromJson(blankId), throwsFormatException);

    final malformedDate = historyItem('11111111-1111-1111-1111-111111111111')
      ..['startedAt'] = 'not-a-date';
    expect(
      () => LessonHistoryItem.fromJson(malformedDate),
      throwsFormatException,
    );
  });
}
