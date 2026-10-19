import 'dart:async';

// Observe the audio_session version already locked by just_audio; no package
// dependency/configuration change is needed for these temporary diagnostics.
// ignore: depend_on_referenced_packages
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'tutor_audio_diagnostics.dart';

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
  JustAudioTutorPlaybackService({
    TutorAudioPlayerAdapter? player,
    TutorAudioDiagnostics? diagnostics,
  }) : _diagnostics = diagnostics ??
            TutorAudioDiagnostics(source: TutorAudioTraceSource.playback) {
    _player = player ?? JustAudioPlayerAdapter(diagnostics: _diagnostics);
  }

  late final TutorAudioPlayerAdapter _player;
  final TutorAudioDiagnostics _diagnostics;
  int _traceRequest = 0;
  bool _disposed = false;
  Future<void> _operation = Future.value();
  Future<void>? _disposeOperation;
  Completer<TutorPlaybackResult>? _activePlayback;
  int _playbackGeneration = 0;

  @override
  Stream<Object?> get completed => _player.completed;

  @override
  Future<void> playFile(String path) {
    final request = ++_traceRequest;
    _diagnostics.record(TutorAudioTraceEvent.playbackRequested,
        fields: {'request': request});
    return _enqueue(() async {
      if (_disposed) return;
      try {
        await _player.setFilePath(path);
        _diagnostics.record(TutorAudioTraceEvent.fileLoaded,
            fields: {'request': request});
        if (!_disposed) {
          _diagnostics.record(TutorAudioTraceEvent.playInvoked,
              fields: {'request': request});
          await _player.play();
          _diagnostics.record(TutorAudioTraceEvent.playFutureReturned,
              fields: {'request': request});
        }
      } catch (_) {
        _diagnostics
            .record(TutorAudioTraceEvent.failed, fields: {'request': request});
        rethrow;
      }
    });
  }

  @override
  Future<TutorPlaybackResult> playToCompletion(
    String path, {
    required Duration timeout,
    void Function()? onStarted,
  }) async {
    final request = ++_traceRequest;
    _diagnostics.record(TutorAudioTraceEvent.playbackRequested,
        fields: {'request': request, 'timeoutMs': timeout.inMilliseconds});
    if (_activePlayback != null && !_activePlayback!.isCompleted) {
      _diagnostics.record(TutorAudioTraceEvent.overlappingRequest,
          fields: {'request': request});
    }
    if (_disposed) {
      return const TutorPlaybackResult(TutorPlaybackStatus.disposed);
    }
    final generation = ++_playbackGeneration;
    final result = Completer<TutorPlaybackResult>();
    _activePlayback = result;
    StreamSubscription<Object?>? subscription;
    void finish(TutorPlaybackResult value) {
      if (!result.isCompleted) {
        final event = switch (value.status) {
          TutorPlaybackStatus.completed => TutorAudioTraceEvent.completed,
          TutorPlaybackStatus.stopped => TutorAudioTraceEvent.stopped,
          TutorPlaybackStatus.failed => TutorAudioTraceEvent.failed,
          TutorPlaybackStatus.timedOut => TutorAudioTraceEvent.timedOut,
          TutorPlaybackStatus.disposed => TutorAudioTraceEvent.disposed,
        };
        _diagnostics.record(event, fields: {'request': request});
        result.complete(value);
      }
    }

    subscription = _player.completed.listen((_) {
      if (_isCurrentPlayback(generation, result)) {
        finish(const TutorPlaybackResult(TutorPlaybackStatus.completed));
      }
    });
    Timer? timer;
    try {
      await _player.setFilePath(path);
      _diagnostics.record(TutorAudioTraceEvent.fileLoaded,
          fields: {'request': request});
      if (_disposed) {
        finish(const TutorPlaybackResult(TutorPlaybackStatus.disposed));
      } else {
        _diagnostics.record(TutorAudioTraceEvent.playInvoked,
            fields: {'request': request});
        final playOperation = _player.play();
        if (_isCurrentPlayback(generation, result)) {
          onStarted?.call();
        }
        timer = Timer(timeout, () {
          if (_isCurrentPlayback(generation, result)) {
            finish(const TutorPlaybackResult(TutorPlaybackStatus.timedOut));
            _diagnostics.record(TutorAudioTraceEvent.stopRequested);
            unawaited(_player.stop());
          }
        });
        unawaited(playOperation.then((_) {
          _diagnostics.record(TutorAudioTraceEvent.playFutureReturned,
              fields: {'request': request});
        }).catchError((Object error) {
          if (_isCurrentPlayback(generation, result)) {
            finish(TutorPlaybackResult(TutorPlaybackStatus.failed, error));
          }
        }));
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
  Future<void> stop() {
    _diagnostics.record(TutorAudioTraceEvent.stopRequested);
    return _enqueue(() async {
      if (!_disposed) {
        _playbackGeneration++;
        final playback = _activePlayback;
        if (playback != null && !playback.isCompleted) {
          playback
              .complete(const TutorPlaybackResult(TutorPlaybackStatus.stopped));
        }
        await _player.stop();
        _diagnostics.record(TutorAudioTraceEvent.stopApplied);
      }
    });
  }

  @override
  Future<void> dispose() {
    if (_disposeOperation != null) return _disposeOperation!;
    _diagnostics.record(TutorAudioTraceEvent.disposeRequested);
    _disposed = true;
    _playbackGeneration++;
    final playback = _activePlayback;
    if (playback != null && !playback.isCompleted) {
      playback
          .complete(const TutorPlaybackResult(TutorPlaybackStatus.disposed));
    }
    return _disposeOperation = _enqueue(() async {
      await _player.dispose();
      _diagnostics.record(TutorAudioTraceEvent.disposed);
    });
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _operation = _operation.catchError((_) {}).then((_) => action());
    return _operation;
  }

  bool _isCurrentPlayback(
    int generation,
    Completer<TutorPlaybackResult> playback,
  ) =>
      !_disposed &&
      generation == _playbackGeneration &&
      identical(_activePlayback, playback);
}

class JustAudioPlayerAdapter implements TutorAudioPlayerAdapter {
  JustAudioPlayerAdapter({TutorAudioDiagnostics? diagnostics})
      : _diagnostics = diagnostics ??
            TutorAudioDiagnostics(source: TutorAudioTraceSource.playback) {
    _subscription = _player.playerStateStream.listen((state) {
      _snapshot(TutorAudioTraceEvent.playerState);
      if (state.processingState == ProcessingState.completed) {
        _completed.add(null);
      }
    });
    if (_diagnostics.enabled) {
      _observers.add(
          _player.playbackEventStream.listen((_) {}, onError: (Object error) {
        _diagnostics.record(TutorAudioTraceEvent.playerError, fields: {
          'nativeCode': error is PlayerException ? error.code : null,
        });
      }));
      _observers.add(
          _player.positionStream.map((p) => p.inSeconds).distinct().listen((_) {
        if (_player.playing) _snapshot(TutorAudioTraceEvent.position);
      }, onError: _observerError));
      _observers.add(_player.volumeStream.listen(
          (_) => _snapshot(TutorAudioTraceEvent.volume),
          onError: _observerError));
      _observers.add(_player.speedStream.listen(
          (_) => _snapshot(TutorAudioTraceEvent.speed),
          onError: _observerError));
      _observers.add(_player.skipSilenceEnabledStream.listen(
          (_) => _snapshot(TutorAudioTraceEvent.skipSilence),
          onError: _observerError));
      unawaited(_observeSession());
    }
  }

  final TutorAudioDiagnostics _diagnostics;
  final _observers = <StreamSubscription<dynamic>>[];
  bool _observationsDisposed = false;

  void _observerError(Object _) {
    _diagnostics.record(TutorAudioTraceEvent.observerFailed);
  }

  void _snapshot(TutorAudioTraceEvent event) {
    if (!_diagnostics.enabled) return;
    _diagnostics.record(event, fields: {
      'processing': _player.processingState.index,
      'playing': _player.playing,
      'positionMs': _player.position.inMilliseconds,
      'bufferedMs': _player.bufferedPosition.inMilliseconds,
      'durationMs': _player.duration?.inMilliseconds,
      'volume': _player.volume,
      'speed': _player.speed,
      'skipSilence': _player.skipSilenceEnabled,
    });
  }

  Future<void> _observeSession() async {
    try {
      final session = await AudioSession.instance;
      if (_observationsDisposed) return;
      _diagnostics.record(TutorAudioTraceEvent.sessionObserved,
          fields: {'configured': session.isConfigured});
      _observers.add(session.configurationStream.listen((config) {
        _diagnostics.record(TutorAudioTraceEvent.sessionConfiguration, fields: {
          'usage': config.androidAudioAttributes?.usage.value,
          'contentType': config.androidAudioAttributes?.contentType.index,
          'focusGain': config.androidAudioFocusGainType.index,
          'pauseWhenDucked': config.androidWillPauseWhenDucked,
        });
      }, onError: _observerError));
      _observers.add(session.interruptionEventStream.listen((event) {
        _snapshot(event.begin
            ? TutorAudioTraceEvent.interruptionBegin
            : TutorAudioTraceEvent.interruptionEnd);
        _diagnostics.record(
            event.begin
                ? TutorAudioTraceEvent.interruptionBegin
                : TutorAudioTraceEvent.interruptionEnd,
            fields: {'interruptionType': event.type.index});
      }, onError: _observerError));
      _observers.add(session.becomingNoisyEventStream.listen(
          (_) => _snapshot(TutorAudioTraceEvent.becomingNoisy),
          onError: _observerError));
      _observers.add(session.devicesChangedEventStream.listen((event) {
        _diagnostics.record(TutorAudioTraceEvent.devicesChanged, fields: {
          'devicesAdded': event.devicesAdded.length,
          'devicesRemoved': event.devicesRemoved.length
        });
      }, onError: _observerError));
    } catch (_) {
      _diagnostics.record(TutorAudioTraceEvent.observerFailed);
    }
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
    _observationsDisposed = true;
    for (final observer in _observers) {
      try {
        await observer.cancel();
      } catch (_) {
        _diagnostics.record(TutorAudioTraceEvent.observerFailed);
      }
    }
    await _subscription.cancel();
    try {
      await _player.stop();
    } catch (_) {}
    await _player.dispose();
    await _completed.close();
  }
}
