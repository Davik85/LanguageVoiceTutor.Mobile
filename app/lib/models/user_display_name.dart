final _displayNameNonLetters = RegExp(r'\P{L}', unicode: true);

bool isValidUserDisplayName(String? value) =>
    value == null ||
    value.trim().isEmpty ||
    (value == value.trim() && !_displayNameNonLetters.hasMatch(value));
