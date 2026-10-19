import 'package:flutter/foundation.dart';

enum TutorAudioTraceSource { playback, lesson, conversation, recorder }

enum TutorAudioTraceEvent {
  playbackRequested,
  overlappingRequest,
  fileLoaded,
  playInvoked,
  playFutureReturned,
  completed,
  stopped,
  failed,
  timedOut,
  stopRequested,
  stopApplied,
  disposeRequested,
  disposed,
  playerState,
  playerError,
  position,
  volume,
  speed,
  skipSilence,
  sessionObserved,
  sessionConfiguration,
  interruptionBegin,
  interruptionEnd,
  becomingNoisy,
  devicesChanged,
  observerFailed,
  lifecycle,
  stopOrigin,
  recordingRequested,
  recordingStarted,
  recordingStopRequested,
  recordingStopped,
  recordingCancelRequested,
  recordingCancelled,
}

enum TutorAudioTraceReason { user, replacement, recording, lifecycle, cleanup }

/// Local Debug/Profile diagnostics only. Never accepts text, file paths, error
/// messages, backend identifiers or audio bytes. This does not use Analytics.
class TutorAudioDiagnostics {
  TutorAudioDiagnostics({
    required this.source,
    bool enabled = true,
    void Function(String)? output,
  })  : _enabled = enabled,
        _output = output ?? debugPrint;

  static final _clock = Stopwatch()..start();
  static int _nextInstance = 0;
  final int _instance = ++_nextInstance;
  final TutorAudioTraceSource source;
  final bool _enabled;
  final void Function(String) _output;
  bool get enabled => !kReleaseMode && _enabled;

  static const _allowedFields = {
    'request',
    'processing',
    'playing',
    'positionMs',
    'bufferedMs',
    'durationMs',
    'volume',
    'speed',
    'skipSilence',
    'timeoutMs',
    'lifecycle',
    'configured',
    'usage',
    'contentType',
    'focusGain',
    'pauseWhenDucked',
    'interruptionType',
    'devicesAdded',
    'devicesRemoved',
    'nativeCode',
  };

  void record(
    TutorAudioTraceEvent event, {
    TutorAudioTraceReason? reason,
    Map<String, Object?> fields = const {},
  }) {
    if (!enabled) return;
    // Whitelisted scalar diagnostics only, including when a future caller
    // accidentally supplies content or an exception message.
    final safe = <String>[];
    for (final entry in fields.entries) {
      final value = entry.value;
      if (_allowedFields.contains(entry.key) &&
          (value is bool || (value is num && value.isFinite))) {
        safe.add('${entry.key}=$value');
      }
    }
    try {
      _output('[TutorAudio] tMs=${_clock.elapsedMilliseconds} '
          'source=${source.name} instance=$_instance event=${event.name}'
          '${reason == null ? '' : ' reason=${reason.name}'}'
          '${safe.isEmpty ? '' : ' ${safe.join(' ')}'}');
    } catch (_) {
      // Diagnostics must not change playback, stop, disposal or recording.
    }
  }
}
