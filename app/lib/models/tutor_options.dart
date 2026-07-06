class TutorOptions {
  const TutorOptions({
    required this.studyLanguages,
    required this.levels,
    required this.topics,
    required this.scenarios,
    required this.contexts,
    required this.tutors,
    required this.modes,
  });

  final List<String> studyLanguages;
  final List<String> levels;
  final List<String> topics;
  final List<String> scenarios;
  final List<String> contexts;
  final List<String> tutors;
  final List<String> modes;

  factory TutorOptions.fromJson(Map<String, dynamic> json) {
    return TutorOptions(
      studyLanguages: _labelsFromAny(json, const [
        'studyLanguages',
        'languages',
        'availableLanguages',
        'targetLanguages',
      ]),
      levels: _labelsFromAny(json, const ['levels', 'availableLevels']),
      topics: _labelsFromAny(json, const ['topics', 'topicOptions']),
      scenarios: _labelsFromAny(json, const ['scenarios', 'scenarioOptions']),
      contexts: _labelsFromAny(json, const ['contexts', 'contextOptions']),
      tutors: _labelsFromAny(json, const ['tutors', 'tutorOptions']),
      modes: _labelsFromAny(json, const ['modes', 'lessonModes', 'modeOptions']),
    );
  }

  bool get hasAnyOptions =>
      studyLanguages.isNotEmpty ||
      levels.isNotEmpty ||
      topics.isNotEmpty ||
      scenarios.isNotEmpty ||
      contexts.isNotEmpty ||
      tutors.isNotEmpty ||
      modes.isNotEmpty;

  int get optionGroupCount => [
        studyLanguages,
        levels,
        topics,
        scenarios,
        contexts,
        tutors,
        modes,
      ].where((options) => options.isNotEmpty).length;

  static List<String> _labelsFromAny(
      Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      final labels = _labelsFromValue(value);
      if (labels.isNotEmpty) return labels;
    }
    return const [];
  }

  static List<String> _labelsFromValue(dynamic value) {
    if (value is List) {
      return value.map(_labelFromValue).whereType<String>().toList();
    }
    if (value is Map<String, dynamic>) {
      final nested = <String>[];
      for (final entry in value.entries) {
        final label = _labelFromValue(entry.value) ?? _cleanLabel(entry.key);
        if (label != null) nested.add(label);
      }
      return nested;
    }
    final label = _labelFromValue(value);
    return label == null ? const [] : [label];
  }

  static String? _labelFromValue(dynamic value) {
    if (value is String) return _cleanLabel(value);
    if (value is num || value is bool) return _cleanLabel(value.toString());
    if (value is Map<String, dynamic>) {
      for (final key in const [
        'title',
        'displayName',
        'name',
        'label',
        'languageName',
        'level',
        'topicTitle',
        'scenarioTitle',
        'contextTitle',
        'mode',
        'key',
        'id',
      ]) {
        final label = _labelFromValue(value[key]);
        if (label != null) return label;
      }
    }
    return null;
  }

  static String? _cleanLabel(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
