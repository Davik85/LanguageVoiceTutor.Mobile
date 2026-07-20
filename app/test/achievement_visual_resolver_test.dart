import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/achievements/achievement_visual_resolver.dart';
import 'package:language_voice_tutor_mobile/models/achievements.dart';

AchievementItem _item({required String id, required String iconKey}) =>
    AchievementItem(
      id: id,
      category: 'streak',
      scope: 'account',
      studyLanguage: null,
      topicId: null,
      lessonContentId: null,
      title: 'Test achievement',
      description: 'Test',
      iconKey: iconKey,
      unlocked: false,
      unlockedAtUtc: null,
      currentProgress: 0,
      targetProgress: 7,
    );

void main() {
  test('known definition ID resolves to its approved WebP asset', () {
    final visual = AchievementVisualResolver.resolve(
        _item(id: 'streak-7-v1', iconKey: 'streak'));
    expect(visual.assetPath, 'assets/achievements/streak-7.webp');
  });

  test('unknown definition ID uses a deterministic Material fallback', () {
    final visual = AchievementVisualResolver.resolve(
        _item(id: 'unknown-v1', iconKey: 'unrecognized'));
    expect(visual.assetPath, isNull);
    expect(visual.fallbackIcon, Icons.emoji_events_outlined);
  });

  testWidgets('failed asset rendering falls back without an exception',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AchievementArtwork(
        visual: AchievementVisual(
          assetPath: 'assets/achievements/missing.webp',
          fallbackIcon: Icons.emoji_events_outlined,
        ),
        color: Colors.blue,
        size: 28,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
