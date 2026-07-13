import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/tutor_avatar.dart';

/// Warms just the selected tutor's state GIFs for a surface.
class TutorAvatarPreloader {
  TutorAvatarPreloader({
    TutorAvatarAssetResolver? resolver,
    Future<Set<String>> Function()? loadAssets,
    Future<void> Function(ImageProvider<Object>, BuildContext)? precache,
  })  : _resolver = resolver ?? const TutorAvatarAssetResolver(),
        _loadAssets = loadAssets ?? _loadManifestAssets,
        _precache = precache ?? precacheImage;

  final TutorAvatarAssetResolver _resolver;
  final Future<Set<String>> Function() _loadAssets;
  final Future<void> Function(ImageProvider<Object>, BuildContext) _precache;
  final Map<String, Future<bool>> _preloads = {};
  static Future<Set<String>>? _manifestAssets;

  Future<bool> preload({
    required BuildContext context,
    required String tutorId,
    required TutorAvatarSurface surface,
  }) {
    final safeTutor = _resolver.normalizeTutorId(tutorId);
    final key = '${surface.name}:$safeTutor';
    return _preloads.putIfAbsent(key, () => _warm(context, safeTutor, surface));
  }

  Future<bool> _warm(
    BuildContext context,
    String tutorId,
    TutorAvatarSurface surface,
  ) async {
    final stopwatch = Stopwatch()..start();
    var success = true;
    final paths = TutorAvatarState.values
        .map((state) => _resolver.resolve(
              surface: surface,
              tutorId: tutorId,
              state: state,
            ))
        .toList(growable: false);
    final assets = await _loadAssets();
    if (!context.mounted) return false;
    for (final path in paths) {
      if (!assets.contains(path)) {
        success = false;
        continue;
      }
      try {
        if (!context.mounted) return false;
        await _precache(AssetImage(path), context);
      } catch (_) {
        success = false;
      }
    }
    if (kDebugMode) {
      debugPrint(
        'avatar_preload tutor=$tutorId surface=${surface.name} '
        'assets=${paths.length} durationMs=${stopwatch.elapsedMilliseconds} '
        'success=$success',
      );
    }
    return success;
  }

  static Future<Set<String>> _loadManifestAssets() =>
      _manifestAssets ??= AssetManifest.loadFromAssetBundle(rootBundle)
          .then((manifest) => manifest.listAssets().toSet());
}
