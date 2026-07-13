import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TutorAvatarSurface { lessonChat, conversationMode }

enum TutorAvatarState { idle, listening, transcribing, thinking, speaking }

class TutorAvatarAssetResolver {
  const TutorAvatarAssetResolver();

  static const _knownTutorIds = {'lana', 'nelli', 'david'};

  String resolve({
    required TutorAvatarSurface surface,
    required String tutorId,
    required TutorAvatarState state,
  }) {
    final normalizedTutor = normalizeTutorId(tutorId);
    final surfacePath = switch (surface) {
      TutorAvatarSurface.lessonChat => 'lesson_chat',
      TutorAvatarSurface.conversationMode => 'conversation_mode',
    };
    return 'assets/avatars/$surfacePath/$normalizedTutor/'
        'avatar-${_stateName(state)}.gif';
  }

  String idlePath({
    required TutorAvatarSurface surface,
    required String tutorId,
  }) =>
      resolve(surface: surface, tutorId: tutorId, state: TutorAvatarState.idle);

  String normalizeTutorId(String tutorId) {
    final normalized = tutorId.trim().toLowerCase();
    return _knownTutorIds.contains(normalized) ? normalized : 'lana';
  }

  String _stateName(TutorAvatarState state) => switch (state) {
        TutorAvatarState.idle => 'idle',
        TutorAvatarState.listening => 'listening',
        TutorAvatarState.transcribing => 'transcribing',
        TutorAvatarState.thinking => 'thinking',
        TutorAvatarState.speaking => 'speaking',
      };
}

class TutorAvatar extends StatefulWidget {
  const TutorAvatar({
    super.key,
    required this.surface,
    required this.tutorId,
    required this.state,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  final TutorAvatarSurface surface;
  final String tutorId;
  final TutorAvatarState state;
  final Widget placeholder;
  final BoxFit fit;

  @override
  State<TutorAvatar> createState() => _TutorAvatarState();
}

class _TutorAvatarState extends State<TutorAvatar> {
  static Future<Set<String>>? _manifestAssets;
  static final Set<String> _reportedMissingPaths = {};
  final _resolver = const TutorAvatarAssetResolver();

  Future<Set<String>> _assets() =>
      _manifestAssets ??= AssetManifest.loadFromAssetBundle(rootBundle)
          .then((manifest) => manifest.listAssets().toSet());

  @override
  Widget build(BuildContext context) {
    final requested = _resolver.resolve(
      surface: widget.surface,
      tutorId: widget.tutorId,
      state: widget.state,
    );
    final idle = _resolver.idlePath(
      surface: widget.surface,
      tutorId: widget.tutorId,
    );
    return FutureBuilder<Set<String>>(
      future: _assets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return widget.placeholder;
        final assets = snapshot.data!;
        final path = assets.contains(requested)
            ? requested
            : assets.contains(idle)
                ? idle
                : null;
        if (path == null) {
          _reportMissing(requested);
          return widget.placeholder;
        }
        if (path != requested) _reportMissing(requested);
        return Image.asset(
          path,
          key: Key('tutor-avatar-$path'),
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) {
            _reportMissing(path);
            return widget.placeholder;
          },
        );
      },
    );
  }

  void _reportMissing(String path) {
    if (kDebugMode && _reportedMissingPaths.add(path)) {
      debugPrint('Missing tutor avatar asset: $path');
    }
  }
}
