import '../models/lesson_runtime.dart';

enum VoiceScenarioDeterministicDecision {
  publishedScenario,
  backendSemantic,
  unsafeTranscript,
}

class VoiceScenarioDeterministicResult {
  const VoiceScenarioDeterministicResult({
    required this.decision,
    this.matchedVariant,
    this.confidence = 0,
    this.matchingSignals = const [],
  });

  final VoiceScenarioDeterministicDecision decision;
  final LessonRuntimeContextVariant? matchedVariant;
  final double confidence;
  final List<String> matchingSignals;
}

/// Stage A resolves only universally safe selections from the current CMS list.
/// All semantic or vocabulary-dependent interpretation belongs to the backend.
class VoiceScenarioIntentResolver {
  static const _ordinals = <String, int>{
    'one': 1,
    'first': 1,
    'two': 2,
    'second': 2,
    'three': 3,
    'third': 3,
    'four': 4,
    'fourth': 4,
    'five': 5,
    'fifth': 5,
    'six': 6,
    'sixth': 6,
    'seven': 7,
    'seventh': 7,
    'eight': 8,
    'eighth': 8,
    'nine': 9,
    'ninth': 9,
    'ten': 10,
    'tenth': 10,
  };

  static VoiceScenarioDeterministicResult resolve({
    required String transcript,
    required List<LessonRuntimeContextVariant> variants,
    bool unsafeTranscript = false,
  }) {
    if (unsafeTranscript) {
      return const VoiceScenarioDeterministicResult(
        decision: VoiceScenarioDeterministicDecision.unsafeTranscript,
        matchingSignals: ['unsafe_script'],
      );
    }

    final tokens = _tokens(transcript);
    final numeric = _displayedPosition(tokens, variants.length);
    if (numeric != null) {
      return VoiceScenarioDeterministicResult(
        decision: VoiceScenarioDeterministicDecision.publishedScenario,
        matchedVariant: variants[numeric - 1],
        confidence: 1,
        matchingSignals: const ['displayed_position'],
      );
    }

    final normalized = _normalize(transcript);
    final exact = variants
        .where((variant) =>
            _normalize(variant.title) == normalized ||
            (variant.localizedTitle.trim().isNotEmpty &&
                _normalize(variant.localizedTitle) == normalized))
        .toList();
    if (exact.length == 1) {
      return VoiceScenarioDeterministicResult(
        decision: VoiceScenarioDeterministicDecision.publishedScenario,
        matchedVariant: exact.single,
        confidence: 1,
        matchingSignals: const ['exact_title'],
      );
    }

    // Permit only tiny whole-title ASR damage, and only with a unique result.
    final close = variants.where((variant) {
      final title = _normalize(variant.title);
      if (title.length < 5 || normalized.length < 5) return false;
      final allowed = title.length > 12 || normalized.length > 12 ? 2 : 1;
      return _editDistance(normalized, title) <= allowed;
    }).toList();
    if (close.length == 1) {
      return VoiceScenarioDeterministicResult(
        decision: VoiceScenarioDeterministicDecision.publishedScenario,
        matchedVariant: close.single,
        confidence: .98,
        matchingSignals: const ['unique_small_title_edit'],
      );
    }

    return const VoiceScenarioDeterministicResult(
      decision: VoiceScenarioDeterministicDecision.backendSemantic,
      matchingSignals: ['semantic_required'],
    );
  }

  static int? _displayedPosition(List<String> tokens, int count) {
    if (tokens.isEmpty || tokens.length > 3) return null;
    final compact = tokens.where((token) => token != 'option').toList();
    if (compact.length != 1) return null;
    final token = compact.single;
    final numericToken = token.replaceFirst(RegExp(r'(st|nd|rd|th)$'), '');
    final value = int.tryParse(numericToken) ?? _ordinals[token];
    return value != null && value >= 1 && value <= count ? value : null;
  }

  static List<String> _tokens(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  static int _editDistance(String a, String b) {
    var previous = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 1; i <= a.length; i++) {
      final current = <int>[i];
      for (var j = 1; j <= b.length; j++) {
        current.add([
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
        ].reduce((left, right) => left < right ? left : right));
      }
      previous = current;
    }
    return previous.last;
  }
}
