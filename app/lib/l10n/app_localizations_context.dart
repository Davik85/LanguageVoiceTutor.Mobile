import 'package:flutter/widgets.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';

extension AppLocalizationsContext on BuildContext {
  /// English is a safe fallback while the app is starting or a focused widget
  /// test intentionally supplies no localization delegates.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsEn();
}
