import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/tutor_audio_diagnostics.dart';

void main() {
  test('diagnostics accept only allowlisted numeric/boolean fields', () {
    final lines = <String>[];
    final trace = TutorAudioDiagnostics(
        source: TutorAudioTraceSource.playback, output: lines.add);
    trace.record(TutorAudioTraceEvent.playerState, fields: {
      'positionMs': 1234,
      'playing': true,
      'volume': 1.0,
      'path': '/private/lesson.wav',
      'text': 'private lesson',
      'userId': 'backend-user',
      'token': 'secret-token',
      'nativeCode': 'secret-message',
      'speed': double.nan,
    });
    expect(lines.single, contains('[TutorAudio]'));
    expect(lines.single, contains('positionMs=1234'));
    expect(lines.single, contains('playing=true'));
    expect(lines.single, contains('volume=1.0'));
    for (final denied in [
      'private',
      'backend-user',
      'token',
      'secret',
      'NaN'
    ]) {
      expect(lines.single, isNot(contains(denied)));
    }
  });

  test('disabled diagnostics do not write and output failure never escapes',
      () {
    final lines = <String>[];
    TutorAudioDiagnostics(
            source: TutorAudioTraceSource.playback,
            enabled: false,
            output: lines.add)
        .record(TutorAudioTraceEvent.playInvoked);
    expect(lines, isEmpty);
    final throwing = TutorAudioDiagnostics(
        source: TutorAudioTraceSource.recorder,
        output: (_) => throw StateError('logger unavailable'));
    expect(() => throwing.record(TutorAudioTraceEvent.recordingStarted),
        returnsNormally);
  });
}
