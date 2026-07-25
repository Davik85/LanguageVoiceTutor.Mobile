import 'package:flutter/material.dart';

/// Holds the language of the application interface. It intentionally does not
/// affect the study language or the native language used for translations.
class AppLocaleController extends ChangeNotifier {
  static const backendLocaleMap = <String, Locale>{
    'en': Locale('en'),
    'ru': Locale('ru'),
    'es': Locale('es'),
    'fr': Locale('fr'),
    'de': Locale('de'),
    'it': Locale('it'),
    'pt': Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
    'bg': Locale('bg'),
  };

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
    Locale('bg'),
  ];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLanguageId(String? languageId) {
    final normalized = languageId?.trim().toLowerCase();
    final next = backendLocaleMap[normalized] ?? const Locale('en');
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
  }
}
