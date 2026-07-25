import 'package:flutter/widgets.dart';

import '../models/language_options.dart';

/// The interface and native-language defaults derived from Android preferences.
class DeviceLanguageDefaults {
  const DeviceLanguageDefaults({
    required this.interfaceLanguageId,
    required this.nativeLanguageId,
  });

  final String interfaceLanguageId;
  final String nativeLanguageId;
}

/// Resolves each setting independently, retaining Android's locale priority.
DeviceLanguageDefaults resolveDeviceLanguageDefaults(
        Iterable<Locale> locales) =>
    DeviceLanguageDefaults(
      interfaceLanguageId: _firstMatch(
        locales,
        LanguageOptions.interfaceLanguages.map((option) => option.id),
      ),
      nativeLanguageId: _firstMatch(
        locales,
        LanguageOptions.nativeLanguages.map((option) => option.id),
      ),
    );

String _firstMatch(Iterable<Locale> locales, Iterable<String> supportedIds) {
  final supported = {for (final id in supportedIds) id.toLowerCase(): id};
  for (final locale in locales) {
    final match = _matchLocale(locale, supported);
    if (match != null) return match;
  }
  return LanguageOptions.defaultLanguageId;
}

String? _matchLocale(Locale locale, Map<String, String> supported) {
  final parts = locale.toLanguageTag().replaceAll('_', '-').split('-');
  if (parts.isEmpty || parts.first.isEmpty) return null;

  var language = parts.first.toLowerCase();
  if (language == 'iw') language = 'he';
  if (language == 'in') language = 'id';

  final script = parts
      .skip(1)
      .firstWhere(
        (part) => part.length == 4,
        orElse: () => '',
      )
      .toLowerCase();
  final region = parts
      .skip(1)
      .firstWhere(
        (part) => part.length == 2 || part.length == 3,
        orElse: () => '',
      )
      .toUpperCase();

  if (language == 'zh') {
    if (script == 'hant') return null;
    if (script == 'hans') return supported['zh-hans'];
    if (region == 'CN' || region == 'SG') return supported['zh-hans'];
    return null;
  }
  if (language == 'nb' || language == 'nn') return supported['no'];
  return supported[language];
}
