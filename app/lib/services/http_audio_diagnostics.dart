import 'dart:math' as math;

import 'package:flutter/foundation.dart';

// The same UTC millisecond clock labels HTTP dispatch/completion and WAV receipt.
String _utcMillis() =>
    DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch,
            isUtc: true)
        .toIso8601String();

void _write(void Function(String) output, String line) {
  try {
    output(line);
  } catch (_) {
    // Local diagnostics must never change transport or audio delivery.
  }
}

enum DeviceRegistrationFailure { timeout, network, transport, unknown }

/// Observational links only: weak byte keys, at most 64 path-to-metadata links.
/// No text, bytes or paths enter a log. No file IO or playback ownership here.
class TutorSpeechTrace {
  TutorSpeechTrace._(this.request);
  static int _nextRequest = 0;
  static final _bytes = Expando<TutorSpeechTrace>();
  static final _paths = <String, TutorSpeechTrace>{};
  final int request;
  String? _httpFingerprint;
  int? _httpLength;

  static TutorSpeechTrace? start(Object? text) {
    if (!ReceivedTutorWavDiagnostics.configuredEnabled) return null;
    try {
      final trace = TutorSpeechTrace._(++_nextRequest);
      trace._log(
          'request',
          text is String
              ? 'textUtf16=${text.length} utf8Bytes=${_utf8Length(text)}'
              : 'textUtf16=unavailable utf8Bytes=unavailable');
      return trace;
    } catch (_) {
      return null;
    }
  }

  // Count without allocating an encoded copy. Unpaired surrogates use U+FFFD,
  // matching Dart UTF-8 encoding. Large text is explicitly left unmeasured.
  static String _utf8Length(String text) {
    if (text.length > 65536) return 'unavailable';
    var count = 0;
    for (var i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      if (c < 128) {
        count++;
      } else if (c < 2048) {
        count += 2;
      } else if (c >= 0xd800 &&
          c <= 0xdbff &&
          i + 1 < text.length &&
          text.codeUnitAt(i + 1) >= 0xdc00 &&
          text.codeUnitAt(i + 1) <= 0xdfff) {
        count += 4;
        i++;
      } else {
        count += 3;
      }
    }
    return '$count';
  }

  // Non-cryptographic indicator only: FNV-1a32 over <=4096 uniformly spaced
  // byte positions, including both ends. Full coverage only for <=4096 bytes.
  // Length is compared separately. Does not copy or retain the audio buffer.
  static String _fingerprint(Uint8List bytes) {
    final count = math.min(bytes.length, 4096);
    var hash = 0x811c9dc5;
    for (var i = 0; i < count; i++) {
      final at = count <= 1 ? 0 : i * (bytes.length - 1) ~/ (count - 1);
      hash = ((hash ^ bytes[at]) * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  void received(Uint8List bytes, int status) {
    try {
      _httpFingerprint = _fingerprint(bytes);
      _httpLength = bytes.length;
      _bytes[bytes] = this;
      _log(
          'http_complete',
          'status=$status bytes=${bytes.length} '
              'fpSample4096=$_httpFingerprint');
    } catch (_) {}
  }

  void failed(String category) {
    if (!const {'timeout', 'network', 'transport', 'unknown'}
        .contains(category)) {
      return;
    }
    _log('http_failed', 'failure=$category');
  }

  /// Called only AFTER an existing write has completed. This checks the buffer
  /// supplied to that write, NOT file contents. No disk read-back is performed.
  static void prepared(Uint8List? bytes, String path) {
    if (!ReceivedTutorWavDiagnostics.configuredEnabled) return;
    try {
      final trace = bytes == null ? null : _bytes[bytes];
      if (trace == null || bytes == null) {
        _write(
            debugPrint,
            '[TutorSpeech] utc=${_utcMillis()} '
            'request=unavailable event=prepared integrity=unavailable');
        return;
      }
      final fingerprint = _fingerprint(bytes);
      final matches = trace._httpLength == bytes.length &&
          trace._httpFingerprint == fingerprint;
      _paths.remove(path);
      if (_paths.length >= 64) _paths.remove(_paths.keys.first);
      _paths[path] = trace;
      trace._log(
          'prepared',
          'bytes=${bytes.length} fpSample4096=$fingerprint '
              'matchesHttp=$matches diskReadback=unavailable');
    } catch (_) {}
  }

  static TutorSpeechPlaybackTrace? beforePlayback(String path,
      {Uint8List? sourceBytes}) {
    if (!ReceivedTutorWavDiagnostics.configuredEnabled) return null;
    try {
      return TutorSpeechPlaybackTrace._(
          _paths[path] ?? (sourceBytes == null ? null : _bytes[sourceBytes]),
          sourceBytes);
    } catch (_) {
      return null;
    }
  }

  void _log(String event, String fields) {
    try {
      _write(
          debugPrint,
          '[TutorSpeech] utc=${_utcMillis()} request=$request '
          'event=$event $fields');
    } catch (_) {}
  }
}

/// A new anonymous playback number distinguishes replays of a cached response.
class TutorSpeechPlaybackTrace {
  TutorSpeechPlaybackTrace._(this._speech, Uint8List? sourceBytes)
      : _playback = ++_nextPlayback {
    if (sourceBytes == null) {
      _log('handoff', 'rawBytes=unavailable fileContent=unverified');
    } else {
      final fingerprint = TutorSpeechTrace._fingerprint(sourceBytes);
      final matches = _speech == null
          ? 'unavailable'
          : '${_speech._httpLength == sourceBytes.length && _speech._httpFingerprint == fingerprint}';
      _log(
          'handoff',
          'rawBytes=available source=write_buffer '
              'bytes=${sourceBytes.length} fpSample4096=$fingerprint '
              'matchesHttp=$matches fileContent=unverified');
    }
  }
  static int _nextPlayback = 0;
  final TutorSpeechTrace? _speech;
  final int _playback;
  void started() => _log('started', '');
  void completed(String status) {
    if (const {'completed', 'stopped', 'failed', 'timedOut', 'disposed'}
        .contains(status)) {
      _log('result', 'status=$status');
    }
  }

  void _log(String event, String fields) {
    try {
      _write(
          debugPrint,
          '[TutorSpeechPlayback] utc=${_utcMillis()} '
          'request=${_speech?.request ?? 'unavailable'} playback=$_playback '
          'event=$event${fields.isEmpty ? '' : ' $fields'}');
    } catch (_) {}
  }
}

/// One anonymous number per actual close() attempt, including HTTP retries.
/// Independent of the WAV flag. No instance exists for skipped registrations.
class DeviceRegistrationHttpTrace {
  DeviceRegistrationHttpTrace._() : _attempt = ++_nextAttempt;
  static const enabled = !kReleaseMode;
  static int _nextAttempt = 0;
  final int _attempt;
  final _clock = Stopwatch()..start();
  bool _finished = false;

  static DeviceRegistrationHttpTrace? start() {
    if (!enabled) return null;
    try {
      final trace = DeviceRegistrationHttpTrace._();
      trace._emit('dispatch');
      return trace;
    } catch (_) {
      return null;
    }
  }

  void complete(int status) => _finish('status=$status');
  void failed(DeviceRegistrationFailure failure) =>
      _finish('failure=${failure.name}');

  void _finish(String result) {
    if (_finished) return;
    _finished = true;
    _emit('complete', result);
  }

  void _emit(String event, [String result = '']) {
    try {
      _write(
          debugPrint,
          '[DeviceRegistrationHTTP] utc=${_utcMillis()} attempt=$_attempt '
          'event=$event elapsedMs=${_clock.elapsedMilliseconds}'
          '${result.isEmpty ? '' : ' $result'}');
    } catch (_) {}
  }
}

/// Temporary received-signal measurements, never speech/content recognition.
/// PCM format 1 only: unsigned 8-bit or signed little-endian 16/24/32-bit.
/// Conservative near-silence: RMS <= 0.001 (-60 dBFS) AND peak <= 0.01
/// (-40 dBFS), across ALL channels in each ~250 ms (last may be short) window.
/// Sustained intervals/tails require >= 2 seconds; all-zero is reported separately.
/// Low signal is SEPARATE: RMS <= 10^(-50/20), without rounding dB values.
/// All contiguous low runs are measured, including a partial final window.
/// Near-end means ending within the final second; this is not missing-word proof.
/// Exact scan, no downsampling: at most 2M scalar samples and 120 seconds,
/// 256 chunks and 16 MiB input. Oversize inputs are reported unsupported.
/// Output is capped at 16 window levels and 6 intervals. Bytes are never copied
/// or modified here. Existing TutorAudio diagnostics are independent.
class ReceivedTutorWavDiagnostics {
  ReceivedTutorWavDiagnostics({
    bool enabled = configuredEnabled,
    void Function(String)? output,
  })  : _enabled = enabled,
        _output = output;

  static const configuredEnabled = !kReleaseMode &&
      bool.fromEnvironment('LVT_DIAG_AUDIO_TRACE', defaultValue: false);
  static int _nextResponse = 0;
  final bool _enabled;
  final void Function(String)? _output;
  bool get enabled => !kReleaseMode && _enabled;

  void record(Uint8List bytes, {required int status, int? request}) {
    if (!enabled) return;
    try {
      final utc =
          _utcMillis(); // Receipt time, captured BEFORE the signal scan.
      final response = ++_nextResponse;
      String summary;
      try {
        summary = status == 200
            ? _measure(bytes)
            : 'analysis=unsupported reason=http_status';
      } catch (_) {
        summary = 'analysis=invalid reason=diagnostic_failure';
      }
      _write(
          _output ?? debugPrint,
          '[TutorWavReceived] utc=$utc response=$response '
          'request=${request ?? 'unavailable'} '
          'status=$status bytes=${bytes.length} $summary');
    } catch (_) {}
  }

  static String _measure(Uint8List bytes) {
    if (bytes.length > 16 * 1024 * 1024) {
      return 'analysis=unsupported reason=size_limit';
    }
    if (bytes.length < 12) return 'analysis=invalid reason=header';
    final view = ByteData.sublistView(bytes);
    int u16(int at) => view.getUint16(at, Endian.little);
    int u32(int at) => view.getUint32(at, Endian.little);
    if (u32(0) != 0x46464952 || u32(8) != 0x45564157) {
      return 'analysis=unsupported reason=container';
    }
    final end = u32(4) + 8;
    if (end != bytes.length || end < 12) {
      return 'analysis=invalid reason=riff_size';
    }
    int? formatAt, formatLength, dataAt, dataLength;
    var at = 12;
    var chunks = 0;
    while (at < end) {
      if (++chunks > 256) return 'analysis=unsupported reason=chunk_limit';
      if (at + 8 > end) return 'analysis=invalid reason=chunk_header';
      final id = u32(at);
      final length = u32(at + 4);
      final body = at + 8;
      final next = body + length + (length & 1);
      if (next > end) return 'analysis=invalid reason=chunk_bounds';
      if (id == 0x20746d66) {
        if (formatAt != null) return 'analysis=invalid reason=duplicate_fmt';
        formatAt = body;
        formatLength = length;
      } else if (id == 0x61746164) {
        if (dataAt != null) return 'analysis=unsupported reason=multiple_data';
        dataAt = body;
        dataLength = length;
      }
      at = next;
    }
    if (formatAt == null || dataAt == null || formatLength! < 16) {
      return 'analysis=invalid reason=missing_fmt_or_data';
    }
    if (formatLength > 16 &&
        (formatLength < 18 || u16(formatAt + 16) > formatLength - 18)) {
      return 'analysis=invalid reason=fmt_extension';
    }
    if (u16(formatAt) != 1) return 'analysis=unsupported reason=encoding';
    final channels = u16(formatAt + 2);
    final rate = u32(formatAt + 4);
    final byteRate = u32(formatAt + 8);
    final align = u16(formatAt + 12);
    final bits = u16(formatAt + 14);
    if (channels == 0 || rate == 0) {
      return 'analysis=invalid reason=fmt_values';
    }
    if (channels > 8 || rate > 384000 || ![8, 16, 24, 32].contains(bits)) {
      return 'analysis=unsupported reason=pcm_layout';
    }
    if (align != channels * (bits ~/ 8) ||
        byteRate != rate * align ||
        dataLength == 0 ||
        dataLength! % align != 0) {
      return 'analysis=invalid reason=pcm_alignment';
    }
    final frames = dataLength ~/ align;
    final durationMs = (frames * 1000 / rate).round();
    final metadata = 'rate=$rate channels=$channels bits=$bits '
        'durationMs=$durationMs';
    final windowFrames = math.max(1, (rate / 4).round());
    final windows = (frames + windowFrames - 1) ~/ windowFrames;
    if (frames > rate * 120 || frames * channels > 2000000) {
      return 'analysis=unsupported reason=scan_limit $metadata';
    }
    final width = bits ~/ 8;
    final scale = (1 << (bits - 1)).toDouble();
    double sample(int offset) => switch (bits) {
          8 => (view.getUint8(offset) - 128) / scale,
          16 => view.getInt16(offset, Endian.little) / scale,
          24 => (view.getUint8(offset) |
                      (view.getUint8(offset + 1) << 8) |
                      (view.getUint8(offset + 2) << 16))
                  .toSigned(24) /
              scale,
          _ => view.getInt32(offset, Endian.little) / scale,
        };
    int db(double amplitude) => amplitude == 0
        ? -120
        : (20 * math.log(amplitude) / math.ln10).round().clamp(-120, 0);
    final levels = <String>[];
    final intervals = <String>[];
    var intervalCount = 0;
    var quietWindows = 0;
    var allZero = true;
    int? quietStart;
    var tailMs = 0;
    var lowWindows = 0;
    int? lowStart;
    var lowCount = 0;
    var lowMiddle = false;
    var lowNearEnd = false;
    var longestLowFrames = 0;
    var longestLowAt = 'none';
    var lowTailMs = 0;
    final lowIntervals = <String>[];
    int ms(int frame) => (frame * 1000 / rate).round();
    void closeLow(int finish) {
      if (lowStart == null) return;
      final start = lowStart!;
      final length = finish - start;
      final nearEnd = finish >= math.max(0, frames - rate);
      final position = start == 0 && finish == frames
          ? 'whole'
          : finish == frames
              ? 'tail'
              : nearEnd
                  ? 'near_end'
                  : start == 0
                      ? 'head'
                      : 'middle';
      final range = '${ms(start)}-${ms(finish)}';
      lowCount++;
      if (lowIntervals.length < 6) lowIntervals.add('$range:$position');
      lowMiddle = lowMiddle || position == 'middle';
      lowNearEnd = lowNearEnd || nearEnd;
      if (length > longestLowFrames) {
        longestLowFrames = length;
        longestLowAt = range;
      }
      if (finish == frames) lowTailMs = ms(length);
      lowStart = null;
    }

    void closeQuiet(int finish) {
      if (quietStart == null) return;
      final length = finish - quietStart!;
      if (length >= 2 * rate) {
        intervalCount++;
        if (intervals.length < 6) {
          intervals.add('${(quietStart! * 1000 / rate).round()}-'
              '${(finish * 1000 / rate).round()}');
        }
        if (finish == frames) tailMs = (length * 1000 / rate).round();
      }
      quietStart = null;
    }

    for (var w = 0; w < windows; w++) {
      final firstFrame = w * windowFrames;
      final count = math.min(windowFrames, frames - firstFrame) * channels;
      var offset = dataAt + firstFrame * align;
      var sum = 0.0;
      var peak = 0.0;
      for (var n = 0; n < count; n++, offset += width) {
        final value = sample(offset);
        sum += value * value;
        peak = math.max(peak, value.abs());
      }
      final rms = math.sqrt(sum / count);
      allZero = allZero && peak == 0;
      final quiet = rms <= 0.001 && peak <= 0.01;
      if (rms <= 0.0031622776601683794) {
        lowWindows++;
        lowStart ??= firstFrame;
      } else {
        closeLow(firstFrame);
      }
      if (quiet) {
        quietWindows++;
        quietStart ??= firstFrame;
      } else {
        closeQuiet(firstFrame);
      }
      if (windows <= 16 || w < 8 || w >= windows - 8) {
        levels.add('$w:${db(rms)}/${db(peak)}');
      }
    }
    closeQuiet(frames);
    closeLow(frames);
    final activity = allZero
        ? 'all_zero'
        : quietWindows == windows
            ? 'all_near_silent'
            : quietWindows > 0
                ? 'partial_near_silence'
                : 'active';
    return 'analysis=pcm $metadata windowMs=${ms(windowFrames)} '
        'lastWindowMs=${ms(frames - (windows - 1) * windowFrames)} '
        'windows=$windows activity=$activity '
        'quietWindows=$quietWindows levelsDbRmsPeak=[${levels.join(',')}] '
        'levelsOmitted=${windows - levels.length} '
        'quietMs=[${intervals.join(',')}] '
        'intervalsOmitted=${intervalCount - intervals.length} '
        'tailMs=$tailMs tailAfterActive=${tailMs > 0 && quietWindows < windows} '
        'lowWindows=$lowWindows lowMs=[${lowIntervals.join(',')}] '
        'lowIntervalsOmitted=${lowCount - lowIntervals.length} '
        'lowMiddle=$lowMiddle lowNearEnd=$lowNearEnd '
        'longestLowMs=${ms(longestLowFrames)} longestLowAt=$longestLowAt '
        'lowTailMs=$lowTailMs';
  }
}
