import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/widgets/tutor_avatar.dart';

void main() {
  const resolver = TutorAvatarAssetResolver();

  test('conversation avatar resolves Lana canonical idle asset', () {
    expect(
      resolver.resolve(
        surface: TutorAvatarSurface.conversationMode,
        tutorId: ' Lana ',
        state: TutorAvatarState.idle,
      ),
      'assets/avatars/conversation_mode/lana/avatar-idle.gif',
    );
  });

  test('conversation avatar resolves David canonical state asset', () {
    expect(
      resolver.resolve(
        surface: TutorAvatarSurface.conversationMode,
        tutorId: 'david',
        state: TutorAvatarState.speaking,
      ),
      'assets/avatars/conversation_mode/david/avatar-speaking.gif',
    );
  });

  test('normalizes missing and unsupported tutor IDs to Lana only', () {
    expect(resolver.normalizeTutorId(''), 'lana');
    expect(resolver.normalizeTutorId('unknown'), 'lana');
  });
}
