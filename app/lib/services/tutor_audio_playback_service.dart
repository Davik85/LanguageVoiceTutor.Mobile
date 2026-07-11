import 'dart:async';

import 'package:just_audio/just_audio.dart';

abstract class TutorAudioPlaybackService {
  Stream<Object?> get completed;
  Future<void> playFile(String path);
  Future<void> stop();
  Future<void> dispose();
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

  @override
  Stream<Object?> get completed => _player.completed;

  @override
  Future<void> playFile(String path) async {
    if (_disposed) return;
    await _player.setFilePath(path);
    if (!_disposed) unawaited(_player.play());
  }

  @override
  Future<void> stop() => _disposed ? Future.value() : _player.stop();

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _player.dispose();
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

  @override
  Stream<Object?> get completed => _completed.stream;

  @override
  Future<void> setFilePath(String path) => _player.setFilePath(path);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _player.dispose();
    await _completed.close();
  }
}
