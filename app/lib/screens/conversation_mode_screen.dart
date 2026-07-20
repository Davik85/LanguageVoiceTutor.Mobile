import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/audio_speech.dart';
import '../models/audio_transcription.dart';
import '../models/language_options.dart';
import '../models/lesson_runtime.dart';
import '../models/lesson_session.dart';
import '../models/user_settings.dart';
import '../services/auth_service.dart';
import '../services/learner_audio_recording_service.dart';
import '../services/learner_microphone_permission_service.dart';
import '../services/mobile_transcription_request_builder.dart';
import '../services/tutor_audio_playback_service.dart';
import '../services/tutor_speech_request_builder.dart';
import '../services/transcript_script_normalizer.dart';
import '../widgets/tutor_avatar.dart';

class ConversationModeScreen extends StatefulWidget {
  const ConversationModeScreen({
    super.key,
    required this.authService,
    required this.audioPlaybackService,
    required this.recordingService,
    required this.microphonePermissionService,
    required this.session,
    required this.scenario,
    required this.settings,
    required this.selectedContextTitle,
    required this.tutorDisplayName,
    required this.initialTranscript,
    required this.onSubmitTranscript,
    required this.onHint,
    required this.onFinish,
    this.ownsAudioPlaybackService = true,
  });

  final AuthService authService;
  final TutorAudioPlaybackService audioPlaybackService;
  final LearnerAudioRecordingService recordingService;
  final LearnerMicrophonePermissionService microphonePermissionService;
  final LessonSessionResponse session;
  final LessonRuntimeScenario scenario;
  final UserSettings settings;
  final String selectedContextTitle;
  final String tutorDisplayName;
  final List<String> initialTranscript;
  final Future<String?> Function(String text) onSubmitTranscript;
  final Future<String?> Function() onHint;
  final Future<void> Function() onFinish;
  final bool ownsAudioPlaybackService;

  @override
  State<ConversationModeScreen> createState() => _ConversationModeScreenState();
}

enum _ConversationState {
  idle,
  listening,
  transcribing,
  thinking,
  speaking,
  error
}

class _ConversationModeScreenState extends State<ConversationModeScreen>
    with WidgetsBindingObserver {
  static const _transcriptionRequestBuilder =
      MobileTranscriptionRequestBuilder();
  static const _speechRequestBuilder = TutorSpeechRequestBuilder();
  final List<String> _transcript = [];
  Timer? _recordingTimer;
  DateTime? _recordingStartedAt;
  String? _recordingFilePath;
  String? _error;
  String? _hint;
  String? _playbackFilePath;
  _ConversationState _state = _ConversationState.idle;
  bool _operationEligible = true;
  int _operationGeneration = 0;
  bool _disposed = false;
  bool _showOpenMicrophoneSettings = false;
  bool _openingMicrophoneSettings = false;
  DateTime? _hintDismissedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _transcript.addAll(widget.initialTranscript);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _invalidateOperation();
    unawaited(_stopAndDeleteRecording());
    unawaited(widget.audioPlaybackService.stop());
    unawaited(_deletePlaybackFile());
    unawaited(widget.recordingService.dispose());
    if (widget.ownsAudioPlaybackService) {
      unawaited(widget.audioPlaybackService.dispose());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _finishConversationOperation(_operationGeneration,
          message: 'Conversation paused. You can record again.');
      _invalidateOperation();
      unawaited(_stopAndDeleteRecording());
      unawaited(widget.audioPlaybackService.stop());
      if (mounted) setState(() => _state = _ConversationState.idle);
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshMicrophonePermissionAfterResume());
    }
  }

  void _invalidateOperation() {
    _operationGeneration++;
    _operationEligible = false;
  }

  bool _finishConversationOperation(int generation, {String? message}) {
    if (!_isCurrent(generation)) return false;
    setState(() {
      _state = _ConversationState.idle;
      _error = message;
    });
    return true;
  }

  Future<void> _startRecording() async {
    if (_state != _ConversationState.idle &&
        _state != _ConversationState.error) {
      return;
    }
    await widget.audioPlaybackService.stop();
    if (!mounted) return;
    final generation = ++_operationGeneration;
    _operationEligible = true;
    setState(() {
      _error = null;
      _hint = null;
      _showOpenMicrophoneSettings = false;
    });
    try {
      var permission = await widget.microphonePermissionService.check();
      if (permission == LearnerMicrophonePermissionStatus.denied) {
        permission = await widget.microphonePermissionService.request();
      }
      if (!_isCurrent(generation)) return;
      if (permission != LearnerMicrophonePermissionStatus.granted) {
        setState(() {
          _state = _ConversationState.idle;
          final requiresSettings = permission ==
                  LearnerMicrophonePermissionStatus.permanentlyDenied ||
              permission == LearnerMicrophonePermissionStatus.restricted;
          _error = requiresSettings
              ? 'Microphone access is blocked. Open Android settings to enable it.'
              : 'Microphone access was not granted. Tap the microphone to try again.';
          _showOpenMicrophoneSettings = requiresSettings;
        });
        return;
      }
      final path = await widget.recordingService.createTemporaryWavPath();
      await widget.recordingService.start(path);
      if (!_isCurrent(generation)) {
        await widget.recordingService.cancel();
        await widget.recordingService.deleteFile(path);
        return;
      }
      _recordingFilePath = path;
      _recordingStartedAt = DateTime.now();
      setState(() => _state = _ConversationState.listening);
      _recordingTimer?.cancel();
      _recordingTimer = Timer(const Duration(seconds: 30), () {
        unawaited(_stopAndTranscribe(generation));
      });
    } catch (_) {
      if (_isCurrent(generation)) {
        setState(() {
          _state = _ConversationState.idle;
          _error = 'Could not start recording. Please try again.';
        });
      }
    }
  }

  Future<void> _stopAndTranscribe([int? expectedGeneration]) async {
    if (_state != _ConversationState.listening) return;
    final generation = expectedGeneration ?? _operationGeneration;
    _recordingTimer?.cancel();
    setState(() => _state = _ConversationState.transcribing);
    final startedAt = _recordingStartedAt;
    final intendedPath = _recordingFilePath;
    try {
      final path = await widget.recordingService.stop() ?? intendedPath;
      final duration = startedAt == null
          ? Duration.zero
          : DateTime.now().difference(startedAt);
      if (path == null || duration < const Duration(milliseconds: 500)) {
        await widget.recordingService.deleteFile(path);
        if (_isCurrent(generation)) {
          setState(() {
            _state = _ConversationState.idle;
            _error = 'Please record a slightly longer answer.';
          });
        }
        return;
      }
      final wav = await widget.recordingService.validateWavFile(path);
      if (!wav.isValid) {
        await widget.recordingService.deleteFile(path);
        if (_isCurrent(generation)) {
          setState(() {
            _state = _ConversationState.idle;
            _error = wav.reason;
          });
        }
        return;
      }
      await _transcribe(path, generation);
    } catch (_) {
      if (_isCurrent(generation)) {
        setState(() {
          _state = _ConversationState.idle;
          _error = 'Could not process that recording. Please try again.';
        });
      }
    } finally {
      await widget.recordingService.deleteFile(intendedPath);
      _recordingFilePath = null;
      _recordingStartedAt = null;
    }
  }

  Future<void> _transcribe(String path, int generation) async {
    if (!_isCurrent(generation)) return;
    final studyLanguageId =
        LanguageOptions.studyLanguageIdFor(widget.settings.studyLanguage);
    AudioTranscriptionResult result;
    try {
      result = await widget.authService
          .transcribeLearnerAudio(
            request: _transcriptionRequestBuilder.build(
              audioFilePath: path,
              backendSessionId: widget.session.lessonSessionId,
              settings: widget.settings,
              scenario: widget.scenario,
              selectedContextTitle: widget.selectedContextTitle,
            ),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      _finishConversationOperation(generation,
          message: 'Transcription took too long. Please try again.');
      return;
    } catch (_) {
      _finishConversationOperation(generation,
          message: 'Could not transcribe that recording. Please try again.');
      return;
    }
    if (!_isCurrent(generation)) return;
    final text = result.text?.trim() ?? '';
    if (!result.isSuccess || text.isEmpty) {
      setState(() {
        _state = _ConversationState.idle;
        _error = result.message;
      });
      return;
    }
    final normalized = TranscriptScriptNormalizer.normalize(
      text,
      isEnglish: studyLanguageId == 'en',
    );
    if (kDebugMode) {
      debugPrint(
        'transcript_script surface=conversation_mode target=$studyLanguageId '
        'latin=${normalized.latinLetterCount} '
        'cyrillic=${normalized.cyrillicLetterCount} '
        'normalized=${normalized.changed} '
        'unsafeMixed=${normalized.unsafeMixedScript} '
        'action=${normalized.unsafeMixedScript ? 'rejected' : 'accepted'}',
      );
    }
    if (normalized.unsafeMixedScript) {
      _finishConversationOperation(generation,
          message: 'I could not recognize that clearly. Please try again.');
      return;
    }
    final normalizedText = normalized.normalizedText;
    setState(() => _state = _ConversationState.thinking);
    String? botText;
    try {
      botText = await widget
          .onSubmitTranscript(normalizedText)
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      _finishConversationOperation(generation,
          message: 'The tutor took too long to reply. Please try again.');
      return;
    } catch (_) {
      _finishConversationOperation(generation,
          message: 'Could not send that answer. Please try recording again.');
      return;
    }
    if (!_isCurrent(generation)) return;
    if (botText == null || botText.trim().isEmpty) {
      setState(() {
        _state = _ConversationState.idle;
        _error = 'Could not send that answer. Please try recording again.';
      });
      return;
    }
    final replyText = botText.trim();
    setState(() => _transcript
      ..add(normalizedText)
      ..add(replyText));
    await _speak(replyText, generation);
  }

  Future<void> _speak(String text, int generation) async {
    if (!_isCurrent(generation)) return;
    AudioSpeechResult result;
    try {
      result = await widget.authService
          .requestTutorSpeech(
            request: _speechRequestBuilder.build(
              text: text,
              settings: widget.settings,
              backendSessionId: widget.session.lessonSessionId,
              purpose: AudioSpeechPurpose.conversationModeTts,
            ),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      _finishConversationOperation(generation,
          message: 'Voice playback took too long. Please try again.');
      return;
    } catch (_) {
      _finishConversationOperation(generation,
          message: 'Could not play voice. Please try again.');
      return;
    }
    if (!_isCurrent(generation)) return;
    if (!result.isSuccess || result.audioBytes == null) {
      setState(() {
        _state = _ConversationState.idle;
        _error = result.message;
      });
      return;
    }
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'language-voice-conversation-${DateTime.now().microsecondsSinceEpoch}.wav',
    );
    try {
      await file.writeAsBytes(result.audioBytes!, flush: true);
      _playbackFilePath = file.path;
      final playbackResult = await widget.audioPlaybackService.playToCompletion(
        file.path,
        timeout: const Duration(seconds: 90),
        onStarted: () {
          if (_isCurrent(generation)) {
            setState(() => _state = _ConversationState.speaking);
          }
        },
      );
      if (!_isCurrent(generation)) return;
      final message = switch (playbackResult.status) {
        TutorPlaybackStatus.completed => null,
        TutorPlaybackStatus.stopped =>
          'Voice playback stopped. You can record again.',
        TutorPlaybackStatus.timedOut =>
          'Voice playback took too long. Please try again.',
        TutorPlaybackStatus.failed ||
        TutorPlaybackStatus.disposed =>
          'Could not play voice. Please try again.',
      };
      _finishConversationOperation(generation, message: message);
    } catch (_) {
      if (_isCurrent(generation)) {
        setState(() {
          _state = _ConversationState.idle;
          _error = 'Could not play voice. Please try again.';
        });
      }
    }
  }

  bool _isCurrent(int generation) =>
      mounted &&
      !_disposed &&
      _operationEligible &&
      generation == _operationGeneration;

  Future<void> _stopAndDeleteRecording() async {
    _recordingTimer?.cancel();
    await widget.recordingService.cancel();
    await widget.recordingService.deleteFile(_recordingFilePath);
    _recordingFilePath = null;
  }

  Future<void> _openMicrophoneSettings() async {
    if (_openingMicrophoneSettings) return;
    setState(() => _openingMicrophoneSettings = true);
    try {
      final opened = await widget.microphonePermissionService.openSettings();
      if (mounted && !opened) {
        setState(() {
          _error = 'Could not open Android settings. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not open Android settings. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _openingMicrophoneSettings = false);
    }
  }

  Future<void> _refreshMicrophonePermissionAfterResume() async {
    try {
      final permission = await widget.microphonePermissionService.check();
      if (!mounted) return;
      final requiresSettings =
          permission == LearnerMicrophonePermissionStatus.permanentlyDenied ||
              permission == LearnerMicrophonePermissionStatus.restricted;
      setState(() {
        _showOpenMicrophoneSettings = requiresSettings;
        if (permission == LearnerMicrophonePermissionStatus.granted &&
            _state == _ConversationState.error) {
          _state = _ConversationState.idle;
          _error = null;
        } else if (requiresSettings) {
          _error =
              'Microphone access is blocked. Open Android settings to enable it.';
        } else if (permission == LearnerMicrophonePermissionStatus.denied) {
          _error =
              'Microphone access was not granted. Tap the microphone to try again.';
        }
      });
    } catch (_) {
      // Retain the existing learner-safe permission state.
    }
  }

  Future<void> _deletePlaybackFile() async {
    final path = _playbackFilePath;
    _playbackFilePath = null;
    if (path == null) return;
    try {
      await File(path).delete();
    } catch (_) {}
  }

  Future<void> _leave() async {
    _finishConversationOperation(_operationGeneration);
    _invalidateOperation();
    await _stopAndDeleteRecording();
    await widget.audioPlaybackService.stop();
    await _deletePlaybackFile();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _showHint() async {
    final dismissedAt = _hintDismissedAt;
    if (dismissedAt != null &&
        DateTime.now().difference(dismissedAt) < const Duration(seconds: 1)) {
      _hintDismissedAt = null;
      return;
    }
    if (_hint != null) {
      setState(() => _hint = null);
      return;
    }
    final hint = await widget.onHint();
    if (mounted && hint != null && hint.trim().isNotEmpty) {
      setState(() => _hint = hint.trim());
    }
  }

  void _dismissVisibleHintForPointer() {
    if (_hint == null) return;
    _hintDismissedAt = DateTime.now();
    setState(() => _hint = null);
  }

  TutorAvatarState get _avatarState => switch (_state) {
        _ConversationState.idle ||
        _ConversationState.error =>
          TutorAvatarState.idle,
        _ConversationState.listening => TutorAvatarState.listening,
        _ConversationState.transcribing => TutorAvatarState.transcribing,
        _ConversationState.thinking => TutorAvatarState.thinking,
        _ConversationState.speaking => TutorAvatarState.speaking,
      };

  String get _dialogueText {
    if (_transcript.isEmpty) return 'Your conversation is ready.';
    if (_transcript.length == 1) return _transcript.single;
    return _transcript.sublist(_transcript.length - 2).join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _state == _ConversationState.listening;
    final canRecord =
        _state == _ConversationState.idle || _state == _ConversationState.error;
    return Scaffold(
      body: Listener(
        key: const Key('conversation-root-surface'),
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _dismissVisibleHintForPointer(),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  label: 'Tutor avatar',
                  child: TutorAvatar(
                    key: const Key('conversation-mode-avatar'),
                    surface: TutorAvatarSurface.conversationMode,
                    tutorId: widget.settings.selectedTutorId,
                    state: _avatarState,
                    placeholder: const ColoredBox(
                      color: Color(0xFF28313A),
                      child: Center(
                        child: Icon(Icons.person,
                            size: 140, color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66000000),
                        Colors.transparent,
                        Color(0xAA000000)
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      key: const Key('conversation-mode-back-button'),
                      onPressed: _leave,
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.tutorDisplayName} · Conversation',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    IconButton.filledTonal(
                      key: const Key('conversation-mode-finish-button'),
                      onPressed: () async {
                        _finishConversationOperation(_operationGeneration);
                        _invalidateOperation();
                        await widget.onFinish();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Finish lesson',
                      icon: const Icon(Icons.flag_outlined),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 170),
                      child: _ConversationCard(
                        key: const Key('conversation-dialogue-card'),
                        child: SingleChildScrollView(
                          child: Text(
                            _dialogueText,
                            key: const Key('conversation-mode-dialogue'),
                            style: const TextStyle(
                                color: Colors.white, height: 1.35),
                          ),
                        ),
                      ),
                    ),
                    if (_hint != null || _error != null) ...[
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 112),
                        child: _ConversationCard(
                          key: const Key('conversation-hint-card'),
                          child: SingleChildScrollView(
                            child: Text(
                              _hint ?? _error!,
                              key: Key(_hint != null
                                  ? 'conversation-mode-hint'
                                  : 'conversation-mode-error'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_showOpenMicrophoneSettings) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('conversation-open-microphone-settings'),
                        onPressed: _openingMicrophoneSettings
                            ? null
                            : _openMicrophoneSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Open Android settings'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      key: const Key('conversation-bottom-controls'),
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          key: const Key('conversation-mode-hint-button'),
                          onPressed: canRecord ? _showHint : null,
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Hint'),
                        ),
                        KeyedSubtree(
                          key: const Key('conversation-record-button'),
                          child: FilledButton.icon(
                            key: const Key('conversation-mode-record-button'),
                            onPressed: isListening
                                ? _stopAndTranscribe
                                : canRecord
                                    ? _startRecording
                                    : null,
                            icon: Icon(isListening ? Icons.stop : Icons.mic),
                            label: Text(isListening
                                ? 'Stop recording'
                                : 'Start recording'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xC9000000),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      );
}
