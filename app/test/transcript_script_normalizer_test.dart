import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/transcript_script_normalizer.dart';

void main() {
  test('keeps normal English text apart from whitespace cleanup', () {
    final result = TranscriptScriptNormalizer.normalize(
      '  Hello   there  ',
      isEnglish: true,
    );
    expect(result.normalizedText, 'Hello there');
    expect(result.unsafeMixedScript, isFalse);
  });

  test('normalizes isolated Cyrillic homoglyphs in Latin text', () {
    final result = TranscriptScriptNormalizer.normalize(
      'He llo Сat',
      isEnglish: true,
    );
    expect(result.normalizedText, 'He llo Cat');
    expect(result.changed, isTrue);
    expect(result.unsafeMixedScript, isFalse);
  });

  test('does not transliterate a whole Cyrillic word', () {
    final result =
        TranscriptScriptNormalizer.normalize('Привет', isEnglish: true);
    expect(result.normalizedText, 'Привет');
    expect(result.unsafeMixedScript, isTrue);
    expect(result.cyrillicLetterCount, 6);
  });
}
