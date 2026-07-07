class LanguageOption {
  const LanguageOption(this.id, this.label);

  final String id;
  final String label;

  bool matches(String value) {
    final normalizedValue = value.trim().toLowerCase();
    return normalizedValue == id.toLowerCase() ||
        normalizedValue == label.toLowerCase();
  }
}
