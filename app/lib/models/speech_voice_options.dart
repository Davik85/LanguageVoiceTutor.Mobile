class SpeechVoiceOption {
  const SpeechVoiceOption(this.id, this.label);

  final String id;
  final String label;
}

abstract final class SpeechVoiceOptions {
  static const all = [
    SpeechVoiceOption('alloy', 'Alloy'),
    SpeechVoiceOption('ash', 'Ash'),
    SpeechVoiceOption('ballad', 'Ballad'),
    SpeechVoiceOption('coral', 'Coral'),
    SpeechVoiceOption('echo', 'Echo'),
    SpeechVoiceOption('sage', 'Sage'),
    SpeechVoiceOption('shimmer', 'Shimmer'),
    SpeechVoiceOption('verse', 'Verse'),
    SpeechVoiceOption('marin', 'Marin'),
    SpeechVoiceOption('cedar', 'Cedar'),
  ];

  static String? supportedIdFor(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim().toLowerCase();
    for (final voice in all) {
      if (voice.id == normalized) return voice.id;
    }
    return null;
  }

  static bool isSupported(Object? value) => supportedIdFor(value) != null;

  static String preferredIdForTutor(String? selectedTutorId) =>
      selectedTutorId?.trim().toLowerCase() == 'david' ? 'cedar' : 'coral';

  static String resolve(Object? value, {String? selectedTutorId}) =>
      supportedIdFor(value) ?? preferredIdForTutor(selectedTutorId);
}
