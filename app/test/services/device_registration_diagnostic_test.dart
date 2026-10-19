import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/audio_speech.dart';
import 'package:language_voice_tutor_mobile/models/device_registration.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/device_activity_tracker.dart';

import '../support/tracking_fakes.dart';

class _Metadata extends FakeDeviceMetadata {
  int reads = 0;

  @override
  Future<DeviceRegistrationRequest> read() {
    reads++;
    return super.read();
  }
}

class _SpeechApi extends TrackingApi implements BinaryApiClient {
  int speechCalls = 0;
  final audio = Uint8List.fromList([82, 73, 70, 70]);

  @override
  Future<BinaryApiResponse> postBinary(String path,
      {required Map<String, dynamic> body, String? accessToken}) async {
    expect(path, '/api/audio/speech');
    speechCalls++;
    expect(accessToken, speechCalls == 1 ? 'access' : 'access-user-1');
    return BinaryApiResponse(
        statusCode: speechCalls == 1 ? 401 : 200,
        bodyBytes: speechCalls == 1 ? Uint8List(0) : audio,
        headers: const {'content-type': 'audio/wav'});
  }
}

void main() {
  const disabled = bool.fromEnvironment('LVT_DIAG_DISABLE_DEVICE_REGISTRATION');
  late TrackingApi api;
  late TrackingStorage storage;
  late AuthService auth;
  late DebugPrintCallback originalDebugPrint;
  late List<String?> logs;

  setUp(() {
    api = TrackingApi();
    storage = TrackingStorage();
    auth = AuthService(apiClient: api, storage: storage);
    logs = [];
    originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message);
  });
  tearDown(() => debugPrint = originalDebugPrint);

  test('auth and resume retain metadata and throttling with either flag value',
      () async {
    final metadata = _Metadata();
    var now = DateTime.utc(2026, 10, 19);
    final tracker = DeviceActivityTracker(
        authenticatedUser: auth.authenticatedUser,
        metadata: metadata,
        now: () => now,
        register: (user, request) async {
          await auth.registerDevice(user, request, canSend: () => true);
        });
    addTearDown(tracker.dispose);
    tracker.setForeground(true);
    await auth.login('private@example.test', 'private-password');
    await flushTracking();
    expect(metadata.reads, 1);
    expect(api.deviceCalls(), disabled ? 0 : 1);

    tracker.setForeground(false);
    tracker.setForeground(true);
    await flushTracking();
    expect(metadata.reads, 1);
    now = now.add(const Duration(minutes: 1));
    tracker.setForeground(false);
    tracker.setForeground(true);
    await flushTracking();
    expect(metadata.reads, 2);
    expect(api.deviceCalls(), disabled ? 0 : 2);
    expect(auth.authenticatedUser.value, 'user-1');
    expect(storage.access, 'access-user-1');
    expect(storage.refresh, 'refresh-user-1');
    expect(api.calls.where((c) => c.path == '/api/auth/refresh'), isEmpty);
    expect(
        logs,
        List.filled(
            2, '[DeviceRegistration] ${disabled ? 'suppressed' : 'enabled'}'));
  });

  test('only enabled registration enters its existing unauthorized recovery',
      () async {
    await auth.loadCurrentUser();
    api.deviceStatus = 401;
    await auth.registerDevice('user-1', await FakeDeviceMetadata().read());
    expect(api.deviceCalls(), disabled ? 0 : 2);
    expect(api.calls.where((c) => c.path == '/api/auth/refresh').length,
        disabled ? 0 : 1);
    expect(storage.access, disabled ? 'access' : null);
    expect(storage.refresh, disabled ? 'refresh' : null);
    expect(auth.authenticatedUser.value, disabled ? 'user-1' : null);
  });

  test('speech retains its own 401 recovery and returns identical audio bytes',
      () async {
    final speechApi = _SpeechApi();
    auth = AuthService(apiClient: speechApi, storage: storage);
    await auth.loadCurrentUser();
    await auth.registerDevice('user-1', await FakeDeviceMetadata().read());
    final result = await auth.requestTutorSpeech(
        request: const AudioSpeechRequest(
            text: 'Test reply',
            speechVoice: 'cedar',
            speechSpeed: 1.0,
            targetLanguageId: 'en',
            targetLanguageName: 'English',
            targetLanguageNativeName: 'English',
            targetLanguageCode: 'en',
            backendSessionId: TrackingApi.session));
    expect(result.isSuccess, isTrue);
    expect(result.audioBytes, orderedEquals(speechApi.audio));
    expect(speechApi.speechCalls, 2);
    expect(speechApi.deviceCalls(), disabled ? 0 : 1);
    expect(
        speechApi.calls.where((c) => c.path == '/api/auth/refresh').length, 1);
    expect(storage.access, 'access-user-1');
    expect(storage.refresh, 'refresh-user-1');
    expect(auth.authenticatedUser.value, 'user-1');
  });
}
