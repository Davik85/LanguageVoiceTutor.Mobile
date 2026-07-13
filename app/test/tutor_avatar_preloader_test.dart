import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/tutor_avatar_preloader.dart';
import 'package:language_voice_tutor_mobile/widgets/tutor_avatar.dart';

void main() {
  testWidgets('preloads only selected tutor assets and reuses its Future',
      (tester) async {
    final loaded = <String>[];
    final preloader = TutorAvatarPreloader(
      loadAssets: () async => TutorAvatarState.values
          .map((state) =>
              'assets/avatars/lesson_chat/lana/avatar-${state.name}.gif')
          .toSet(),
      precache: (provider, _) async =>
          loaded.add((provider as AssetImage).assetName),
    );
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      final first = preloader.preload(
          context: context,
          tutorId: 'lana',
          surface: TutorAvatarSurface.lessonChat);
      final second = preloader.preload(
          context: context,
          tutorId: 'lana',
          surface: TutorAvatarSurface.lessonChat);
      expect(identical(first, second), isTrue);
      return const SizedBox();
    })));
    await tester.pumpAndSettle();
    expect(loaded, hasLength(TutorAvatarState.values.length));
    expect(loaded.every((path) => path.contains('/lana/')), isTrue);
  });

  testWidgets('missing assets fail safely', (tester) async {
    final preloader = TutorAvatarPreloader(loadAssets: () async => <String>{});
    late Future<bool> result;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      result = preloader.preload(
          context: context,
          tutorId: 'lana',
          surface: TutorAvatarSurface.lessonChat);
      return const SizedBox();
    })));
    expect(await result, isFalse);
  });
}
