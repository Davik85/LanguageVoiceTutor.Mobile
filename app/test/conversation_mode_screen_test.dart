import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/screens/conversation_mode_screen.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/learner_audio_recording_service.dart';
import 'package:language_voice_tutor_mobile/services/learner_microphone_permission_service.dart';
import 'package:language_voice_tutor_mobile/services/lesson_context_selection_resolver.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';
import 'package:language_voice_tutor_mobile/services/transcript_script_normalizer.dart';
import 'package:language_voice_tutor_mobile/services/tutor_audio_playback_service.dart';

class _Api implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 200, body: '{}');
}

class _Storage implements SessionStorage {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {}
}

class _Playback implements TutorAudioPlaybackService {
  final _completed = StreamController<Object?>.broadcast();
  @override
  Stream<Object?> get completed => _completed.stream;
  @override
  Future<void> dispose() => _completed.close();
  @override
  Future<void> playFile(String path) async {}
  @override
  Future<TutorPlaybackResult> playToCompletion(String path,
          {required Duration timeout, void Function()? onStarted}) async =>
      const TutorPlaybackResult(TutorPlaybackStatus.completed);
  @override
  Future<void> stop() async {}
}

class _Recording extends LearnerAudioRecordingService {
  _Recording() : super(recorder: _RecorderAdapter());

  bool recording = false;
  @override
  Future<String> createTemporaryWavPath() async => 'fake.wav';
  @override
  Future<void> start(String path) async => recording = true;
  @override
  Future<String?> stop() async {
    recording = false;
    return 'fake.wav';
  }

  @override
  Future<void> cancel() async => recording = false;
  @override
  Future<bool> get isRecording async => recording;
  @override
  Future<void> deleteFile(String? path) async {}
  @override
  Future<void> dispose() async {}
}

class _RecorderAdapter implements LearnerAudioRecorderAdapter {
  @override
  Future<void> cancel() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<bool> get isRecording async => false;
  @override
  Future<void> start(
      {required String path, required LearnerRecordingConfig config}) async {}
  @override
  Future<String?> stop() async => null;
}

class _Permission implements LearnerMicrophonePermissionService {
  _Permission({
    List<LearnerMicrophonePermissionStatus>? statuses,
    this.openResult = true,
    this.openSettingsFuture,
  }) : _statuses = statuses ?? [LearnerMicrophonePermissionStatus.granted];

  final List<LearnerMicrophonePermissionStatus> _statuses;
  final bool openResult;
  final Future<bool>? openSettingsFuture;
  int checkCalls = 0;
  int requestCalls = 0;
  int openSettingsCalls = 0;

  LearnerMicrophonePermissionStatus get _nextStatus => _statuses.isEmpty
      ? LearnerMicrophonePermissionStatus.denied
      : _statuses.removeAt(0);

  @override
  Future<LearnerMicrophonePermissionStatus> check() async {
    checkCalls++;
    return _nextStatus;
  }

  @override
  Future<LearnerMicrophonePermissionStatus> request() async {
    requestCalls++;
    return _nextStatus;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCalls++;
    return openSettingsFuture ?? openResult;
  }
}

final _scenario = LessonRuntimeScenario.fromJson({
  'id': 'scenario',
  'metadata': {},
  'lessonSetup': {},
  'learningGoal': {},
  'situation': {},
  'targetLanguage': {},
  'levelProfiles': {},
  'conversationFlow': {},
  'roleplayBeats': [],
  'reciprocalQuestionHandling': {},
  'expectedScenarioProgression': [],
  'aiTutorPromptInstructions': [],
  'promptTemplates': {},
  'controlledVariation': {'contextVariants': []},
  'hintRules': {},
  'runtimeContent': {},
});

Widget _screen({_Recording? recording, _Permission? permission}) =>
    ConversationModeScreen(
      authService: AuthService(apiClient: _Api(), storage: _Storage()),
      audioPlaybackService: _Playback(),
      recordingService: recording ?? _Recording(),
      microphonePermissionService: permission ?? _Permission(),
      session: const LessonSessionResponse(
          lessonSessionId: 's',
          lessonContentId: 'scenario',
          studyLanguage: 'English'),
      scenario: _scenario,
      settings: const UserSettings(
          nativeLanguage: 'en',
          studyLanguage: 'en',
          explanationLanguage: 'en',
          speechVoice: '',
          speechSpeed: 1,
          conversationModeEnabled: true,
          selectedTutorId: 'lana',
          currentLevel: 'A1'),
      selectedContextTitle: '',
      tutorDisplayName: 'Tutor',
      initialTranscript: const ['Hello'],
      onSubmitTranscript: (text) async => 'Reply',
      onHint: () async => 'Try saying hello.',
      onFinish: () async {},
      ownsAudioPlaybackService: false,
    );

Widget _conversation({_Recording? recording, _Permission? permission}) =>
    MaterialApp(home: _screen(recording: recording, permission: permission));

void main() {
  test('Conversation turn prerequisites are resolved before submission', () {
    final script = TranscriptScriptNormalizer.normalize(
      'MEETING A NEW NEIGHBOR.',
      isEnglish: true,
    );
    expect(script.unsafeMixedScript, isFalse);
    expect(LessonContextSelectionResolver.normalize(script.normalizedText),
        'meeting a new neighbor');
  });

  test('unsafe mixed-script recovery has no submit-ready transcript', () {
    final script =
        TranscriptScriptNormalizer.normalize('Привет', isEnglish: true);
    expect(script.unsafeMixedScript, isTrue);
    expect(script.normalizedText, 'Привет');
  });

  testWidgets('Hint toggles and pointer taps dismiss it without an overlay',
      (tester) async {
    await tester.pumpWidget(_conversation());
    await tester.pumpAndSettle();
    final hint = find.byKey(const Key('conversation-mode-hint-button'));

    await tester.tap(hint);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-hint-card')), findsOneWidget);
    await tester.tap(hint);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-hint-card')), findsNothing);

    await tester.tap(hint);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 300));
    await tester.pump();
    expect(find.byKey(const Key('conversation-hint-card')), findsNothing);

    await tester.tap(hint);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('conversation-dialogue-card')));
    await tester.pump();
    expect(find.byKey(const Key('conversation-hint-card')), findsNothing);

    await tester.tap(hint);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('conversation-hint-card')));
    await tester.pump();
    expect(find.byKey(const Key('conversation-hint-card')), findsNothing);
  });

  testWidgets('Record dismisses Hint and still starts a learner turn',
      (tester) async {
    final recording = _Recording();
    await tester.pumpWidget(_conversation(recording: recording));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('conversation-mode-hint-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('conversation-mode-record-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-hint-card')), findsNothing);
    expect(recording.recording, isTrue);
  });

  testWidgets('temporary microphone denial stays retryable without settings',
      (tester) async {
    final recording = _Recording();
    final permission = _Permission(statuses: [
      LearnerMicrophonePermissionStatus.denied,
      LearnerMicrophonePermissionStatus.denied,
      LearnerMicrophonePermissionStatus.granted,
    ]);
    await tester.pumpWidget(
        _conversation(recording: recording, permission: permission));
    await tester.tap(find.byKey(const Key('conversation-mode-record-button')));
    await tester.pumpAndSettle();

    expect(
        find.text(
            'Microphone access was not granted. Tap the microphone to try again.'),
        findsOneWidget);
    expect(find.byKey(const Key('conversation-open-microphone-settings')),
        findsNothing);
    expect(permission.requestCalls, 1);
    expect(recording.recording, isFalse);

    await tester.tap(find.byKey(const Key('conversation-mode-record-button')));
    await tester.pumpAndSettle();
    expect(recording.recording, isTrue);
    expect(permission.openSettingsCalls, 0);
  });

  testWidgets(
      'permanent and restricted denial expose Android settings recovery',
      (tester) async {
    for (final status in [
      LearnerMicrophonePermissionStatus.permanentlyDenied,
      LearnerMicrophonePermissionStatus.restricted,
    ]) {
      final permission = _Permission(statuses: [status]);
      await tester.pumpWidget(_conversation(permission: permission));
      await tester
          .tap(find.byKey(const Key('conversation-mode-record-button')));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Microphone access is blocked. Open Android settings to enable it.'),
          findsOneWidget);
      expect(find.byKey(const Key('conversation-open-microphone-settings')),
          findsOneWidget);
      expect(permission.requestCalls, 0);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('settings action is single-flight and keeps the lesson usable',
      (tester) async {
    final opening = Completer<bool>();
    final permission = _Permission(
      statuses: [LearnerMicrophonePermissionStatus.permanentlyDenied],
      openSettingsFuture: opening.future,
    );
    await tester.pumpWidget(_conversation(permission: permission));
    await tester.tap(find.byKey(const Key('conversation-mode-record-button')));
    await tester.pumpAndSettle();

    final settings =
        find.byKey(const Key('conversation-open-microphone-settings'));
    await tester.tap(settings);
    await tester.pump();
    await tester.tap(settings, warnIfMissed: false);
    await tester.pump();
    expect(permission.openSettingsCalls, 1);
    opening.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-mode-record-button')),
        findsOneWidget);
  });

  testWidgets(
      'settings return rechecks permission and allows the next recording',
      (tester) async {
    final recording = _Recording();
    final permission = _Permission(statuses: [
      LearnerMicrophonePermissionStatus.permanentlyDenied,
      LearnerMicrophonePermissionStatus.granted,
      LearnerMicrophonePermissionStatus.granted,
    ]);
    await tester.pumpWidget(
        _conversation(recording: recording, permission: permission));
    await tester.tap(find.byKey(const Key('conversation-mode-record-button')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const Key('conversation-open-microphone-settings')));
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-open-microphone-settings')),
        findsNothing);
    await tester.tap(find.byKey(const Key('conversation-mode-record-button')));
    await tester.pumpAndSettle();
    expect(recording.recording, isTrue);
  });

  testWidgets('remaining denial and settings-open failure stay learner-safe',
      (tester) async {
    final permission = _Permission(
      statuses: [
        LearnerMicrophonePermissionStatus.permanentlyDenied,
        LearnerMicrophonePermissionStatus.restricted,
      ],
      openResult: false,
    );
    await tester.pumpWidget(_conversation(permission: permission));
    await tester.tap(find.byKey(const Key('conversation-mode-record-button')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const Key('conversation-open-microphone-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Could not open Android settings. Please try again.'),
        findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-open-microphone-settings')),
        findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('Back dismisses Hint and pops the Conversation route',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => _screen())),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('conversation-mode-hint-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('conversation-mode-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(find.byKey(const Key('conversation-hint-card')), findsNothing);
  });
}
