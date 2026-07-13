import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/services/lesson_roleplay_opening_builder.dart';

void main() {
  const variant = LessonRuntimeContextVariant(
      id: 'c',
      title: 'Context',
      localizedTitle: '',
      openingLine: 'Welcome, {tutorName}.',
      contextConfirmationLine: 'Great choice.',
      openingIntent: 'start');
  test('builds from runtime fields and supplied tutor identity', () {
    final text = const LessonRoleplayOpeningBuilder().buildKnownContextOpening(
        variant: variant, tutorDisplayName: 'Runtime Tutor');
    expect(text, 'Great choice.\n\nWelcome, Runtime Tutor.');
    expect(text, isNot(contains('Lana')));
  });
  test('missing optional fields degrade safely', () {
    const empty = LessonRuntimeContextVariant(
        id: 'c',
        title: 'C',
        localizedTitle: '',
        openingLine: '',
        contextConfirmationLine: '',
        openingIntent: '');
    expect(
        const LessonRoleplayOpeningBuilder()
            .buildKnownContextOpening(variant: empty, tutorDisplayName: 'T'),
        isEmpty);
  });
}
