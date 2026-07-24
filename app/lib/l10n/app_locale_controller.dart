import 'package:flutter/material.dart';

/// Holds the language of the application interface. It intentionally does not
/// affect the study language or the native language used for translations.
class AppLocaleController extends ChangeNotifier {
  static const supportedLanguageIds = {'en', 'ru', 'es', 'fr', 'de'};

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLanguageId(String? languageId) {
    final normalized = languageId?.trim().toLowerCase();
    final next = supportedLanguageIds.contains(normalized) ? normalized! : 'en';
    if (_locale.languageCode == next) return;
    _locale = Locale(next);
    notifyListeners();
  }
}
