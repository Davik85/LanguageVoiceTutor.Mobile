import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';
import 'package:language_voice_tutor_mobile/services/learner_audio_recording_service.dart';

class _FakeRecorder implements LearnerAudioRecorderAdapter {
  bool permission = true;
  bool recording = false;
  LearnerRecordingConfig? config;
  String? path;
  bool disposed = false;

  @override
  Future<void> cancel() async => recording = false;
  @override
  Future<void> dispose() async => disposed = true;
  @override
  Future<bool> hasPermission() async => permission;
  @override
  Future<bool> get isRecording async => recording;
  @override
  Future<void> start(
      {required String path, required LearnerRecordingConfig config}) async {
    this.path = path;
    this.config = config;
    recording = true;
  }

  @override
  Future<String?> stop() async {
    recording = false;
    return path;
  }
}

void main() {
  test('uses permission-gated 16 kHz mono WAV recorder configuration',
      () async {
    final adapter = _FakeRecorder();
    final service = LearnerAudioRecordingService(recorder: adapter);
    expect(await service.requestPermission(), isTrue);
    await service.start('recording.wav');
    expect(adapter.config?.sampleRate, 16000);
    expect(adapter.config?.numChannels, 1);
    expect(adapter.config?.encoder, AudioEncoder.wav);
    expect(await service.stop(), 'recording.wav');
    await service.cancel();
    await service.dispose();
    expect(adapter.disposed, isTrue);
  });

  test('accepts valid voiced mono 16 kHz PCM16 WAV and rejects silence', () {
    expect(LearnerWavValidator.validate(_wav(List.filled(8000, 900))).isValid,
        isTrue);
    final silence = LearnerWavValidator.validate(List.filled(16044, 0));
    // A raw PCM payload is not a WAV container.
    expect(silence.isValid, isFalse);
    expect(LearnerWavValidator.validate(_wav(List.filled(8000, 0))).isValid,
        isFalse);
  });

  test('rejects malformed, wrong-rate, and stereo WAV files', () {
    final valid = _wav(List.filled(8000, 900));
    valid[0] = 0;
    expect(LearnerWavValidator.validate(valid).isValid, isFalse);
    expect(
        LearnerWavValidator.validate(_wav(List.filled(8000, 900), rate: 8000))
            .isValid,
        isFalse);
    expect(
        LearnerWavValidator.validate(_wav(List.filled(8000, 900), channels: 2))
            .isValid,
        isFalse);
  });
}

List<int> _wav(List<int> samples, {int rate = 16000, int channels = 1}) {
  final dataLength = samples.length * 2;
  final bytes = List<int>.filled(44 + dataLength, 0);
  void text(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes[offset + i] = value.codeUnitAt(i);
    }
  }

  void u16(int offset, int value) {
    bytes[offset] = value & 255;
    bytes[offset + 1] = value >> 8;
  }

  void u32(int offset, int value) {
    u16(offset, value & 0xffff);
    u16(offset + 2, value >> 16);
  }

  text(0, 'RIFF');
  u32(4, 36 + dataLength);
  text(8, 'WAVE');
  text(12, 'fmt ');
  u32(16, 16);
  u16(20, 1);
  u16(22, channels);
  u32(24, rate);
  u32(28, rate * channels * 2);
  u16(32, channels * 2);
  u16(34, 16);
  text(36, 'data');
  u32(40, dataLength);
  for (var i = 0; i < samples.length; i++) {
    u16(44 + i * 2, samples[i] & 0xffff);
  }
  return bytes;
}
