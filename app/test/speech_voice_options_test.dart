import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/speech_voice_options.dart';

void main() {
  const expected = [
    'alloy',
    'ash',
    'ballad',
    'coral',
    'echo',
    'sage',
    'shimmer',
    'verse',
    'marin',
    'cedar'
  ];
  test('catalog contains exactly ten canonical IDs and friendly labels', () {
    expect(SpeechVoiceOptions.all.map((voice) => voice.id), expected);
    expect(SpeechVoiceOptions.all.map((voice) => voice.label), [
      'Alloy',
      'Ash',
      'Ballad',
      'Coral',
      'Echo',
      'Sage',
      'Shimmer',
      'Verse',
      'Marin',
      'Cedar'
    ]);
    for (final legacy in ['nova', 'onyx', 'fable']) {
      expect(SpeechVoiceOptions.isSupported(legacy), isFalse);
    }
  });
  for (final voice in expected) {
    test('$voice resolves supported mixed-case input to lowercase', () {
      expect(
          SpeechVoiceOptions.isSupported(' ${voice.toUpperCase()} '), isTrue);
      expect(
          SpeechVoiceOptions.resolve(' ${voice.toUpperCase()} ',
              selectedTutorId: 'david'),
          voice);
      expect(SpeechVoiceOptions.resolve(voice), voice);
    });
  }
  for (final stale in [
    null,
    '',
    ' ',
    'nova',
    'onyx',
    'fable',
    'unknown',
    ' NOVA ',
    42
  ]) {
    test('$stale uses only canonical tutor fallback voices', () {
      expect(SpeechVoiceOptions.supportedIdFor(stale), isNull);
      expect(SpeechVoiceOptions.resolve(stale, selectedTutorId: ' DAVID '),
          'cedar');
      for (final tutor in [null, '', 'lana', 'nelli', 'unknown']) {
        expect(
            SpeechVoiceOptions.resolve(stale, selectedTutorId: tutor), 'coral');
      }
    });
  }
}
