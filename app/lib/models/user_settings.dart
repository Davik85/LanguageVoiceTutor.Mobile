class UserSettings {
  const UserSettings({
    required this.nativeLanguage,
    required this.studyLanguage,
    required this.explanationLanguage,
    required this.speechVoice,
    required this.speechSpeed,
    required this.conversationModeEnabled,
  });

  final String nativeLanguage;
  final String studyLanguage;
  final String explanationLanguage;
  final String speechVoice;
  final double speechSpeed;
  final bool conversationModeEnabled;

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        nativeLanguage: _string(json['nativeLanguage']),
        studyLanguage: _string(json['studyLanguage']),
        explanationLanguage: _string(json['explanationLanguage']),
        speechVoice: _string(json['speechVoice']),
        speechSpeed: _double(json['speechSpeed'], fallback: 1.0),
        conversationModeEnabled: _bool(json['conversationModeEnabled']),
      );

  Map<String, dynamic> toJson() => {
        'nativeLanguage': nativeLanguage,
        'studyLanguage': studyLanguage,
        'explanationLanguage': explanationLanguage,
        'speechVoice': speechVoice,
        'speechSpeed': speechSpeed,
        'conversationModeEnabled': conversationModeEnabled,
      };

  UserSettings copyWith({
    String? nativeLanguage,
    String? studyLanguage,
    String? explanationLanguage,
    String? speechVoice,
    double? speechSpeed,
    bool? conversationModeEnabled,
  }) =>
      UserSettings(
        nativeLanguage: nativeLanguage ?? this.nativeLanguage,
        studyLanguage: studyLanguage ?? this.studyLanguage,
        explanationLanguage: explanationLanguage ?? this.explanationLanguage,
        speechVoice: speechVoice ?? this.speechVoice,
        speechSpeed: speechSpeed ?? this.speechSpeed,
        conversationModeEnabled:
            conversationModeEnabled ?? this.conversationModeEnabled,
      );

  static String _string(Object? value) => value is String ? value : '';

  static bool _bool(Object? value) => value is bool ? value : false;

  static double _double(Object? value, {required double fallback}) =>
      value is num
          ? value.toDouble()
          : value is String
              ? double.tryParse(value) ?? fallback
              : fallback;
}
