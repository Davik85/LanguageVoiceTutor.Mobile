import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';

Map<String, dynamic> sessionJson(String id, String status) => {
      'id': id,
      'userId': '22222222-2222-2222-2222-222222222222',
      'lessonContentId': 'daily_introductions',
      'studyLanguage': 'Spanish',
      'topicId': 'daily-life',
      'topicTitle': 'Daily Life',
      'subtopicId': 'introductions',
      'subtopicTitle': 'Introductions',
      'level': 'A1',
      'selectedContextId': null,
      'selectedContextTitle': null,
      'modeUsed': 'text',
      'status': status,
      'startedAt': '2026-07-20T10:00:00Z',
      'finishedAt': null,
      'lastHeartbeatAtUtc': '2026-07-20T10:00:30Z',
      'validTurnCount': 0,
      'estimatedCost': 0,
      'createdAt': '2026-07-20T10:00:00Z',
      'updatedAt': '2026-07-20T10:00:30Z',
    };

void main() {
  test('parses an empty backend lesson-session response', () {
    final sessions = LessonSessionList.fromJson({'items': []});
    expect(sessions.items, isEmpty);
  });

  test('parses one real active backend session and ignores unknown fields', () {
    final session = sessionJson(
      '11111111-1111-1111-1111-111111111111',
      'Active',
    )..['futureField'] = {'ignored': true};
    final sessions = LessonSessionList.fromJson({
      'items': [session]
    });

    expect(sessions.items.single.sessionId,
        '11111111-1111-1111-1111-111111111111');
    expect(sessions.items.single.isActive, isTrue);
    expect(sessions.items.single.startedAt, DateTime.utc(2026, 7, 20, 10));
  });

  test('parses completed and active sessions together', () {
    final sessions = LessonSessionList.fromJson({
      'items': [
        sessionJson('11111111-1111-1111-1111-111111111111', 'Finished'),
        sessionJson('33333333-3333-3333-3333-333333333333', 'active'),
      ],
    });

    expect(sessions.items.where((item) => item.isActive).single.sessionId,
        '33333333-3333-3333-3333-333333333333');
  });

  test('rejects malformed required session fields', () {
    final invalidId = sessionJson('not-a-guid', 'Active');
    expect(
      () => LessonSessionList.fromJson({
        'items': [invalidId]
      }),
      throwsFormatException,
    );
    final blankStatus = sessionJson(
      '11111111-1111-1111-1111-111111111111',
      ' ',
    );
    expect(
      () => LessonSessionList.fromJson({
        'items': [blankStatus]
      }),
      throwsFormatException,
    );
  });
}
