class UserSettings {
  const UserSettings({
    required this.nativeLanguage,
    required this.studyLanguage,
    required this.explanationLanguage,
    required this.speechVoice,
    required this.speechSpeed,
    required this.conversationModeEnabled,
    required this.selectedTutorId,
  });

  final String nativeLanguage;
  final String studyLanguage;
  final String explanationLanguage;
  final String speechVoice;
  final double speechSpeed;
  final bool conversationModeEnabled;
  final String selectedTutorId;

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        nativeLanguage: _string(json['nativeLanguage']),
        studyLanguage: _string(json['studyLanguage']),
        explanationLanguage: _string(json['explanationLanguage']),
        speechVoice: _string(json['speechVoice']),
        speechSpeed: _double(json['speechSpeed'], fallback: 1.0),
        conversationModeEnabled: _bool(json['conversationModeEnabled']),
        selectedTutorId: _selectedTutorId(json['selectedTutorId']),
      );

  Map<String, dynamic> toJson() => {
        'nativeLanguage': nativeLanguage,
        'studyLanguage': studyLanguage,
        'explanationLanguage': explanationLanguage,
        'speechVoice': speechVoice,
        'speechSpeed': speechSpeed,
        'conversationModeEnabled': conversationModeEnabled,
        'selectedTutorId': selectedTutorId,
      };

  UserSettings copyWith({
    String? nativeLanguage,
    String? studyLanguage,
    String? explanationLanguage,
    String? speechVoice,
    double? speechSpeed,
    bool? conversationModeEnabled,
    String? selectedTutorId,
  }) =>
      UserSettings(
        nativeLanguage: nativeLanguage ?? this.nativeLanguage,
        studyLanguage: studyLanguage ?? this.studyLanguage,
        explanationLanguage: explanationLanguage ?? this.explanationLanguage,
        speechVoice: speechVoice ?? this.speechVoice,
        speechSpeed: speechSpeed ?? this.speechSpeed,
        conversationModeEnabled:
            conversationModeEnabled ?? this.conversationModeEnabled,
        selectedTutorId: selectedTutorId ?? this.selectedTutorId,
      );

  static const defaultTutorId = 'lana';

  static String _string(Object? value) => value is String ? value : '';

  static String _selectedTutorId(Object? value) {
    if (value is! String) return defaultTutorId;
    final trimmed = value.trim();
    return trimmed.isEmpty ? defaultTutorId : trimmed;
  }

  static bool _bool(Object? value) => value is bool ? value : false;

  static double _double(Object? value, {required double fallback}) =>
      value is num
          ? value.toDouble()
          : value is String
              ? double.tryParse(value) ?? fallback
              : fallback;
}
