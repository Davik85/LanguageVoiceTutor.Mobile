import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_locale_controller.dart';
import 'services/auth_service.dart';
import 'services/service_factory.dart';
import 'services/practice_reminder_service.dart';
import 'services/premium_purchase_adapter.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/login_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_visuals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final reminders = LocalPracticeReminderService();
  try {
    await reminders.initialize();
  } catch (_) {}
  runApp(LanguageVoiceTutorApp(practiceReminderService: reminders));
}

class LanguageVoiceTutorApp extends StatefulWidget {
  LanguageVoiceTutorApp({
    super.key,
    AuthService? authService,
    PracticeReminderService? practiceReminderService,
  })  : _authService = authService ?? createAuthService(),
        _practiceReminderService =
            practiceReminderService ?? LocalPracticeReminderService(),
        _premiumPurchaseAdapter = const UnavailablePremiumPurchaseAdapter();

  final AuthService _authService;
  final PracticeReminderService _practiceReminderService;
  final PremiumPurchaseAdapter _premiumPurchaseAdapter;

  @override
  State<LanguageVoiceTutorApp> createState() => _LanguageVoiceTutorAppState();
}

class _LanguageVoiceTutorAppState extends State<LanguageVoiceTutorApp> {
  late final AppLocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = AppLocaleController();
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppVisuals.textBlue),
      useMaterial3: true,
    );
    final baseTextTheme = baseTheme.textTheme;
    final softBlueTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      displayMedium: baseTextTheme.displayMedium
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      displaySmall: baseTextTheme.displaySmall
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      headlineLarge: baseTextTheme.headlineLarge
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w700),
      headlineMedium: baseTextTheme.headlineMedium
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w700),
      headlineSmall: baseTextTheme.headlineSmall
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w700),
      titleLarge: baseTextTheme.titleLarge
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w700),
      titleMedium: baseTextTheme.titleMedium
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      titleSmall: baseTextTheme.titleSmall
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      bodyLarge: baseTextTheme.bodyLarge
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      bodyMedium: baseTextTheme.bodyMedium
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      bodySmall: baseTextTheme.bodySmall
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      labelLarge: baseTextTheme.labelLarge
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      labelMedium: baseTextTheme.labelMedium
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
      labelSmall: baseTextTheme.labelSmall
          ?.copyWith(color: AppVisuals.textBlue, fontWeight: FontWeight.w600),
    );
    return AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) => MaterialApp(
              title: AppConfig.appName,
              locale: _localeController.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ru'),
                Locale('es'),
                Locale('fr'),
                Locale('de'),
              ],
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: baseTheme.copyWith(
                textTheme: softBlueTextTheme,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFFDCEFFA),
                  foregroundColor: AppVisuals.textBlue,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                ),
                cardTheme: CardThemeData(
                  color: AppVisuals.translucentCard,
                  elevation: 1,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0x66FFFFFF)),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: const Color(0x80FFFFFF),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x55FFFFFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppVisuals.textBlue, width: 1.5),
                  ),
                ),
                expansionTileTheme: ExpansionTileThemeData(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                ),
              ),
              initialRoute: SplashScreen.routeName,
              routes: {
                SplashScreen.routeName: (_) => SplashScreen(
                    authService: widget._authService,
                    onInterfaceLanguageLoaded: _localeController.setLanguageId),
                LoginScreen.routeName: (_) =>
                    LoginScreen(authService: widget._authService),
                HomeScreen.routeName: (_) => HomeScreen(
                    authService: widget._authService,
                    practiceReminderService: widget._practiceReminderService),
                LessonScreen.routeName: (_) =>
                    LessonScreen(authService: widget._authService),
                SettingsScreen.routeName: (_) => SettingsScreen(
                    authService: widget._authService,
                    practiceReminderService: widget._practiceReminderService,
                    onInterfaceLanguageSaved: _localeController.setLanguageId),
                PremiumScreen.routeName: (_) => PremiumScreen(
                    authService: widget._authService,
                    purchaseAdapter: widget._premiumPurchaseAdapter),
              },
            ));
  }
}
