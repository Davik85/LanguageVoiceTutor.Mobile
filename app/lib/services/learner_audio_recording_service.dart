import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:record/record.dart';

abstract class LearnerAudioRecorderAdapter {
  Future<bool> hasPermission();
  Future<void> start(
      {required String path, required LearnerRecordingConfig config});
  Future<String?> stop();
  Future<void> cancel();
  Future<void> dispose();
  Future<bool> get isRecording;
}

class LearnerRecordingConfig {
  const LearnerRecordingConfig({
    this.encoder = AudioEncoder.wav,
    this.sampleRate = 16000,
    this.numChannels = 1,
  });

  final AudioEncoder encoder;
  final int sampleRate;
  final int numChannels;
}

class RecordLearnerAudioRecorderAdapter implements LearnerAudioRecorderAdapter {
  RecordLearnerAudioRecorderAdapter({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start({
    required String path,
    required LearnerRecordingConfig config,
  }) =>
      _recorder.start(
        RecordConfig(
          encoder: config.encoder,
          sampleRate: config.sampleRate,
          numChannels: config.numChannels,
        ),
        path: path,
      );

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> cancel() => _recorder.cancel();

  @override
  Future<void> dispose() => _recorder.dispose();

  @override
  Future<bool> get isRecording => _recorder.isRecording();
}

class LearnerAudioRecordingService {
  LearnerAudioRecordingService({LearnerAudioRecorderAdapter? recorder})
      : _recorder = recorder ?? RecordLearnerAudioRecorderAdapter();

  static const config = LearnerRecordingConfig();
  static const noSpeechMessage =
      'No speech was detected. Check your microphone and try again.';
  final LearnerAudioRecorderAdapter _recorder;
  bool _disposed = false;

  Future<bool> requestPermission() async {
    if (_disposed) return false;
    return _recorder.hasPermission();
  }

  Future<void> start(String path) async {
    if (_disposed) throw StateError('Recorder has been disposed.');
    if (await _recorder.isRecording) return;
    await _recorder.start(path: path, config: config);
  }

  Future<String?> stop() async {
    if (_disposed || !await _recorder.isRecording) return null;
    return _recorder.stop();
  }

  Future<void> cancel() async {
    if (_disposed || !await _recorder.isRecording) return;
    await _recorder.cancel();
  }

  Future<bool> get isRecording async =>
      !_disposed && await _recorder.isRecording;

  Future<String> createTemporaryWavPath() async {
    final directory = Directory(
        '${Directory.systemTemp.path}${Platform.pathSeparator}language_voice_tutor_recordings');
    await directory.create(recursive: true);
    return '${directory.path}${Platform.pathSeparator}learner-${DateTime.now().microsecondsSinceEpoch}.wav';
  }

  Future<void> deleteFile(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await File(path).delete();
    } catch (_) {}
  }

  Future<LearnerWavValidationResult> validateWavFile(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final result = LearnerWavValidator.validate(bytes);
      if (kDebugMode) {
        debugPrint(
            'Learner WAV: bytes=${bytes.length}; valid=${result.isValid}; '
            'durationMs=${result.duration.inMilliseconds}; channels=${result.channels}; '
            'sampleRate=${result.sampleRate}; bits=${result.bitsPerSample}; '
            'peak=${result.peakAmplitude}; rms=${result.rmsAmplitude}; '
            'reason=${result.reason ?? 'ok'}');
      }
      return result;
    } catch (_) {
      return const LearnerWavValidationResult.invalid(
          'Invalid recording file.');
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _recorder.cancel();
    await _recorder.dispose();
  }
}

class LearnerWavValidationResult {
  const LearnerWavValidationResult({
    required this.isValid,
    required this.duration,
    this.reason,
    this.channels = 0,
    this.sampleRate = 0,
    this.bitsPerSample = 0,
    this.peakAmplitude = 0,
    this.rmsAmplitude = 0,
  });

  const LearnerWavValidationResult.invalid(String reason)
      : this(isValid: false, duration: Duration.zero, reason: reason);

  final bool isValid;
  final Duration duration;
  final String? reason;
  final int channels;
  final int sampleRate;
  final int bitsPerSample;
  final int peakAmplitude;
  final double rmsAmplitude;
}

/// Container and near-silence guard only; it deliberately does not attempt
/// local speech or language recognition.
class LearnerWavValidator {
  static const minimumDuration = Duration(milliseconds: 500);
  static const maximumDuration = Duration(seconds: 30);
  // Conservatively below quiet speech: protects against digital silence only.
  static const minimumPeakAmplitude = 80;
  static const minimumRmsAmplitude = 20.0;

  static LearnerWavValidationResult validate(List<int> bytes) {
    if (bytes.length <= 44 ||
        !_ascii(bytes, 0, 'RIFF') ||
        !_ascii(bytes, 8, 'WAVE')) {
      return const LearnerWavValidationResult.invalid('Invalid WAV recording.');
    }
    var offset = 12;
    int? channels, sampleRate, bits, dataOffset, dataLength;
    while (offset + 8 <= bytes.length) {
      final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final size = _u32(bytes, offset + 4);
      final chunkStart = offset + 8;
      if (size < 0 || chunkStart + size > bytes.length) {
        break;
      }
      if (id == 'fmt ' && size >= 16) {
        if (_u16(bytes, chunkStart) != 1) {
          return const LearnerWavValidationResult.invalid(
              'Unsupported WAV format.');
        }
        channels = _u16(bytes, chunkStart + 2);
        sampleRate = _u32(bytes, chunkStart + 4);
        bits = _u16(bytes, chunkStart + 14);
      } else if (id == 'data') {
        dataOffset = chunkStart;
        dataLength = size;
      }
      offset = chunkStart + size + (size.isOdd ? 1 : 0);
    }
    if (channels != 1 ||
        sampleRate != 16000 ||
        bits != 16 ||
        dataOffset == null ||
        dataLength == null ||
        dataLength < 2) {
      return const LearnerWavValidationResult.invalid(
          'Unsupported WAV recording.');
    }
    final channelCount = channels!;
    final rate = sampleRate!;
    final bitDepth = bits!;
    final audioOffset = dataOffset;
    final audioLength = dataLength;
    final samples = audioLength ~/ 2;
    final duration = Duration(microseconds: (samples * 1000000) ~/ rate);
    if (duration < minimumDuration || duration > maximumDuration) {
      return LearnerWavValidationResult(
          isValid: false,
          duration: duration,
          reason: 'Recording length is invalid.',
          channels: channelCount,
          sampleRate: rate,
          bitsPerSample: bitDepth);
    }
    var peak = 0;
    var sumSquares = 0.0;
    for (var i = audioOffset; i + 1 < audioOffset + audioLength; i += 2) {
      final value = _i16(bytes, i);
      final absolute = value.abs();
      peak = max(peak, absolute);
      sumSquares += value * value;
    }
    final rms = sqrt(sumSquares / samples);
    if (peak < minimumPeakAmplitude || rms < minimumRmsAmplitude) {
      return LearnerWavValidationResult(
          isValid: false,
          duration: duration,
          reason: LearnerAudioRecordingService.noSpeechMessage,
          channels: channelCount,
          sampleRate: rate,
          bitsPerSample: bitDepth,
          peakAmplitude: peak,
          rmsAmplitude: rms);
    }
    return LearnerWavValidationResult(
        isValid: true,
        duration: duration,
        channels: channelCount,
        sampleRate: rate,
        bitsPerSample: bitDepth,
        peakAmplitude: peak,
        rmsAmplitude: rms);
  }

  static bool _ascii(List<int> bytes, int offset, String value) =>
      offset + value.length <= bytes.length &&
      String.fromCharCodes(bytes.sublist(offset, offset + value.length)) ==
          value;
  static int _u16(List<int> b, int o) => b[o] | (b[o + 1] << 8);
  static int _u32(List<int> b, int o) => _u16(b, o) | (_u16(b, o + 2) << 16);
  static int _i16(List<int> b, int o) {
    final v = _u16(b, o);
    return v >= 0x8000 ? v - 0x10000 : v;
  }
}
