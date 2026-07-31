import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/widgets/tutor_avatar.dart';

void main() {
  const resolver = TutorAvatarAssetResolver();

  for (final surface in TutorAvatarSurface.values) {
    final surfacePath = switch (surface) {
      TutorAvatarSurface.lessonChat => 'lesson_chat',
      TutorAvatarSurface.conversationMode => 'conversation_mode',
    };

    group('$surfacePath avatar mapping', () {
      test('maps idle, listening, thinking, and transcribing to idle', () {
        for (final state in <TutorAvatarState>[
          TutorAvatarState.idle,
          TutorAvatarState.listening,
          TutorAvatarState.thinking,
          TutorAvatarState.transcribing,
        ]) {
          expect(
            resolver.resolve(surface: surface, tutorId: ' Lana ', state: state),
            'assets/avatars/$surfacePath/lana/avatar-idle.gif',
          );
        }
      });

      test('maps speaking to the tutor-specific speaking GIF', () {
        expect(
          resolver.resolve(
            surface: surface,
            tutorId: 'david',
            state: TutorAvatarState.speaking,
          ),
          'assets/avatars/$surfacePath/david/avatar-speaking.gif',
        );
      });
    });
  }

  test('preserves safe fallback for unsupported tutor IDs', () {
    expect(
      resolver.resolve(
        surface: TutorAvatarSurface.lessonChat,
        tutorId: 'unknown',
        state: TutorAvatarState.speaking,
      ),
      'assets/avatars/lesson_chat/lana/avatar-speaking.gif',
    );
  });

  test('normalizes missing and unsupported tutor IDs to Lana only', () {
    expect(resolver.normalizeTutorId(''), 'lana');
    expect(resolver.normalizeTutorId('unknown'), 'lana');
  });
}
