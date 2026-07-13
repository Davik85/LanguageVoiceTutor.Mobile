class TranscriptScriptNormalization {
  const TranscriptScriptNormalization({
    required this.normalizedText,
    required this.changed,
    required this.unsafeMixedScript,
    required this.latinLetterCount,
    required this.cyrillicLetterCount,
  });

  final String normalizedText;
  final bool changed;
  final bool unsafeMixedScript;
  final int latinLetterCount;
  final int cyrillicLetterCount;
}

class TranscriptScriptNormalizer {
  static const _homoglyphs = <String, String>{
    'А': 'A',
    'В': 'B',
    'С': 'C',
    'Е': 'E',
    'Н': 'H',
    'К': 'K',
    'М': 'M',
    'О': 'O',
    'Р': 'P',
    'Т': 'T',
    'Х': 'X',
    'а': 'a',
    'е': 'e',
    'о': 'o',
    'р': 'p',
    'с': 'c',
    'х': 'x',
    'у': 'y',
  };

  static TranscriptScriptNormalization normalize(String text,
      {required bool isEnglish}) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (!isEnglish) {
      return TranscriptScriptNormalization(
        normalizedText: cleaned,
        changed: cleaned != text,
        unsafeMixedScript: false,
        latinLetterCount: _count(cleaned, _latin),
        cyrillicLetterCount: _count(cleaned, _cyrillic),
      );
    }
    var latin = _count(cleaned, _latin);
    var cyrillic = _count(cleaned, _cyrillic);
    var value = cleaned;
    if (latin > 0 && cyrillic > 0) {
      value = cleaned.split('').map((char) => _homoglyphs[char] ?? char).join();
      latin = _count(value, _latin);
      cyrillic = _count(value, _cyrillic);
    }
    return TranscriptScriptNormalization(
      normalizedText: value,
      changed: value != text,
      unsafeMixedScript: cyrillic > 0,
      latinLetterCount: latin,
      cyrillicLetterCount: cyrillic,
    );
  }

  static final _latin = RegExp(r'[A-Za-z]');
  static final _cyrillic = RegExp(r'[\u0400-\u04FF]');
  static int _count(String text, RegExp pattern) =>
      pattern.allMatches(text).length;
}
