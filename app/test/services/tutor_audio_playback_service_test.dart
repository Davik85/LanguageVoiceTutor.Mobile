import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/tutor_audio_playback_service.dart';
import 'package:language_voice_tutor_mobile/services/tutor_audio_diagnostics.dart';

class _FakePlayerAdapter implements TutorAudioPlayerAdapter {
  final completedController = StreamController<Object?>.broadcast();
  final paths = <String>[];
  int playCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  Object? setPathError;

  @override
  Stream<Object?> get completed => completedController.stream;

  @override
  Future<void> dispose() async => disposeCalls++;

  @override
  Future<void> play() async => playCalls++;

  @override
  Future<void> setFilePath(String path) async {
    if (setPathError != null) throw setPathError!;
    paths.add(path);
  }

  @override
  Future<void> stop() async => stopCalls++;
}

void main() {
  test('diagnostics never treat a returned play future as audio completion',
      () async {
    final player = _FakePlayerAdapter();
    final logs = <String>[];
    final service = JustAudioTutorPlaybackService(
        player: player,
        diagnostics: TutorAudioDiagnostics(
            source: TutorAudioTraceSource.playback, output: logs.add));
    var finished = false;
    final pending = service.playToCompletion('/private/cached.wav',
        timeout: const Duration(seconds: 1));
    unawaited(pending.then((_) => finished = true));
    await Future<void>.delayed(Duration.zero);
    expect(logs.any((l) => l.contains('event=playbackRequested')), isTrue);
    expect(logs.any((l) => l.contains('event=fileLoaded')), isTrue);
    expect(logs.any((l) => l.contains('event=playInvoked')), isTrue);
    expect(logs.any((l) => l.contains('event=playFutureReturned')), isTrue);
    expect(finished, isFalse);
    expect(player.stopCalls, 0);
    player.completedController.add(null);
    expect((await pending).status, TutorPlaybackStatus.completed);
    expect(logs.any((l) => l.contains('event=completed')), isTrue);
    expect(logs.join(), isNot(contains('/private/')));
    await service.dispose();
    await player.completedController.close();
  });

  test(
      'rapid explicit stop and replay retains completion and native call counts',
      () async {
    final player = _FakePlayerAdapter();
    final logs = <String>[];
    final service = JustAudioTutorPlaybackService(
        player: player,
        diagnostics: TutorAudioDiagnostics(
            source: TutorAudioTraceSource.playback, output: logs.add));
    final first = service.playToCompletion('first.wav',
        timeout: const Duration(seconds: 1));
    await Future<void>.delayed(Duration.zero);
    await service.stop();
    expect((await first).status, TutorPlaybackStatus.stopped);
    final second = service.playToCompletion('second.wav',
        timeout: const Duration(seconds: 1));
    await Future<void>.delayed(Duration.zero);
    player.completedController.add(null);
    expect((await second).status, TutorPlaybackStatus.completed);
    expect(player.paths, ['first.wav', 'second.wav']);
    expect(player.playCalls, 2);
    expect(player.stopCalls, 1);
    expect(logs.any((l) => l.contains('event=stopRequested')), isTrue);
    expect(logs.any((l) => l.contains('event=stopApplied')), isTrue);
    await service.dispose();
    await player.completedController.close();
  });

  test(
      'load failure is reported without error text and a failing logger is isolated',
      () async {
    final player = _FakePlayerAdapter()
      ..setPathError = StateError('private path and lesson');
    final logs = <String>[];
    final service = JustAudioTutorPlaybackService(
        player: player,
        diagnostics: TutorAudioDiagnostics(
            source: TutorAudioTraceSource.playback, output: logs.add));
    final result = await service.playToCompletion('private.wav',
        timeout: const Duration(seconds: 1));
    expect(result.status, TutorPlaybackStatus.failed);
    expect(logs.any((l) => l.contains('event=failed')), isTrue);
    expect(logs.join(), isNot(contains('private')));
    await service.dispose();
    final other = _FakePlayerAdapter();
    final isolated = JustAudioTutorPlaybackService(
        player: other,
        diagnostics: TutorAudioDiagnostics(
            source: TutorAudioTraceSource.playback,
            output: (_) => throw StateError('log failure')));
    await isolated.playFile('cached.wav');
    expect(other.playCalls, 1);
    await isolated.stop();
    await isolated.dispose();
    expect(other.stopCalls, 1);
    expect(other.disposeCalls, 1);
    await player.completedController.close();
    await other.completedController.close();
  });

  test('play delegates the temporary WAV path', () async {
    final player = _FakePlayerAdapter();
    final service = JustAudioTutorPlaybackService(player: player);

    await service.playFile('C:/temp/tutor.wav');

    expect(player.paths, ['C:/temp/tutor.wav']);
    expect(player.playCalls, 1);
  });

  test('stop delegates and completion is surfaced', () async {
    final player = _FakePlayerAdapter();
    final service = JustAudioTutorPlaybackService(player: player);
    final completed =
        expectLater(service.completed, emitsInOrder([isNull, emitsDone]));

    await service.stop();
    player.completedController.add(null);
    await player.completedController.close();
    await completed;

    expect(player.stopCalls, 1);
  });

  test('playback errors are surfaced to the caller', () async {
    final player = _FakePlayerAdapter()..setPathError = StateError('failed');
    final service = JustAudioTutorPlaybackService(player: player);

    expect(service.playFile('C:/temp/tutor.wav'), throwsStateError);
  });

  test('dispose is idempotent and prevents further player calls', () async {
    final player = _FakePlayerAdapter();
    final service = JustAudioTutorPlaybackService(player: player);

    await service.dispose();
    await service.dispose();
    await service.stop();
    await service.playFile('C:/temp/tutor.wav');

    expect(player.disposeCalls, 1);
    expect(player.stopCalls, 0);
    expect(player.paths, isEmpty);
  });

  test('playToCompletion returns completion and stop results', () async {
    final player = _FakePlayerAdapter();
    final service = JustAudioTutorPlaybackService(player: player);
    final completed = service.playToCompletion(
      'one.wav',
      timeout: const Duration(seconds: 1),
    );
    await Future<void>.delayed(Duration.zero);
    player.completedController.add(null);
    expect((await completed).status, TutorPlaybackStatus.completed);

    final stopped = service.playToCompletion(
      'two.wav',
      timeout: const Duration(seconds: 1),
    );
    await Future<void>.delayed(Duration.zero);
    await service.stop();
    expect((await stopped).status, TutorPlaybackStatus.stopped);
  });

  test('playToCompletion times out and dispose completes an active wait',
      () async {
    final player = _FakePlayerAdapter();
    final service = JustAudioTutorPlaybackService(player: player);
    final timedOut = await service.playToCompletion(
      'timeout.wav',
      timeout: const Duration(milliseconds: 1),
    );
    expect(timedOut.status, TutorPlaybackStatus.timedOut);

    final disposedWait = service.playToCompletion(
      'disposed.wav',
      timeout: const Duration(seconds: 1),
    );
    await service.dispose();
    expect((await disposedWait).status, TutorPlaybackStatus.disposed);
  });
}
