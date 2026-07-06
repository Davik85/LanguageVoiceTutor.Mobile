class TutorOption {
  const TutorOption({
    required this.tutorId,
    required this.displayName,
    required this.isActive,
  });

  final String tutorId;
  final String displayName;
  final bool isActive;

  factory TutorOption.fromJson(Map<String, dynamic> json) {
    return TutorOption(
      tutorId: _cleanString(json['tutorId']) ?? '',
      displayName: _cleanString(json['displayName']) ?? '',
      isActive: json['isActive'] == true,
    );
  }

  String get label => displayName.isNotEmpty ? displayName : tutorId;

  static String? _cleanString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class TutorOptions {
  const TutorOptions({required this.tutors});

  final List<TutorOption> tutors;

  factory TutorOptions.fromJsonList(List<dynamic> json) {
    return TutorOptions(
      tutors: json
          .whereType<Map<String, dynamic>>()
          .map(TutorOption.fromJson)
          .toList(growable: false),
    );
  }

  List<TutorOption> get activeTutors =>
      tutors.where((tutor) => tutor.isActive).toList(growable: false);

  bool get hasActiveTutors => activeTutors.isNotEmpty;
}
