import 'dart:async';

import 'package:just_audio/just_audio.dart';

abstract class TutorAudioPlaybackService {
  Stream<Object?> get completed;
  Future<void> playFile(String path);
  Future<TutorPlaybackResult> playToCompletion(
    String path, {
    required Duration timeout,
    void Function()? onStarted,
  });
  Future<void> stop();
  Future<void> dispose();
}

enum TutorPlaybackStatus { completed, stopped, failed, timedOut, disposed }

class TutorPlaybackResult {
  const TutorPlaybackResult(this.status, [this.error]);
  final TutorPlaybackStatus status;
  final Object? error;
}

abstract class TutorAudioPlayerAdapter {
  Stream<Object?> get completed;
  Future<void> setFilePath(String path);
  Future<void> play();
  Future<void> stop();
  Future<void> dispose();
}

class JustAudioTutorPlaybackService implements TutorAudioPlaybackService {
  JustAudioTutorPlaybackService({TutorAudioPlayerAdapter? player})
      : _player = player ?? JustAudioPlayerAdapter();

  final TutorAudioPlayerAdapter _player;
  bool _disposed = false;
  Future<void> _operation = Future.value();
  Future<void>? _disposeOperation;
  Completer<TutorPlaybackResult>? _activePlayback;

  @override
  Stream<Object?> get completed => _player.completed;

  @override
  Future<void> playFile(String path) => _enqueue(() async {
        if (_disposed) return;
        await _player.setFilePath(path);
        if (!_disposed) await _player.play();
      });

  @override
  Future<TutorPlaybackResult> playToCompletion(
    String path, {
    required Duration timeout,
    void Function()? onStarted,
  }) async {
    if (_disposed) {
      return const TutorPlaybackResult(TutorPlaybackStatus.disposed);
    }
    final result = Completer<TutorPlaybackResult>();
    _activePlayback = result;
    StreamSubscription<Object?>? subscription;
    void finish(TutorPlaybackResult value) {
      if (!result.isCompleted) result.complete(value);
    }

    subscription = _player.completed.listen((_) {
      finish(const TutorPlaybackResult(TutorPlaybackStatus.completed));
    });
    Timer? timer;
    try {
      await _player.setFilePath(path);
      if (_disposed) {
        finish(const TutorPlaybackResult(TutorPlaybackStatus.disposed));
      } else {
        await _player.play();
        onStarted?.call();
        timer = Timer(timeout, () {
          finish(const TutorPlaybackResult(TutorPlaybackStatus.timedOut));
          unawaited(_player.stop());
        });
        final value = await result.future;
        return value;
      }
      return await result.future;
    } catch (error) {
      finish(TutorPlaybackResult(TutorPlaybackStatus.failed, error));
      return result.future;
    } finally {
      timer?.cancel();
      await subscription.cancel();
      if (identical(_activePlayback, result)) _activePlayback = null;
    }
  }

  @override
  Future<void> stop() => _enqueue(() async {
        if (!_disposed) {
          final playback = _activePlayback;
          if (playback != null && !playback.isCompleted) {
            playback.complete(
                const TutorPlaybackResult(TutorPlaybackStatus.stopped));
          }
          await _player.stop();
        }
      });

  @override
  Future<void> dispose() {
    if (_disposeOperation != null) return _disposeOperation!;
    _disposed = true;
    final playback = _activePlayback;
    if (playback != null && !playback.isCompleted) {
      playback
          .complete(const TutorPlaybackResult(TutorPlaybackStatus.disposed));
    }
    return _disposeOperation = _enqueue(() async {
      await _player.dispose();
    });
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _operation = _operation.catchError((_) {}).then((_) => action());
    return _operation;
  }
}

class JustAudioPlayerAdapter implements TutorAudioPlayerAdapter {
  JustAudioPlayerAdapter() {
    _subscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _completed.add(null);
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final StreamController<Object?> _completed = StreamController.broadcast();
  late final StreamSubscription<PlayerState> _subscription;
  Future<void>? _disposeOperation;

  @override
  Stream<Object?> get completed => _completed.stream;

  @override
  Future<void> setFilePath(String path) => _player.setFilePath(path);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() {
    return _disposeOperation ??= _dispose();
  }

  Future<void> _dispose() async {
    await _subscription.cancel();
    try {
      await _player.stop();
    } catch (_) {}
    await _player.dispose();
    await _completed.close();
  }
}
