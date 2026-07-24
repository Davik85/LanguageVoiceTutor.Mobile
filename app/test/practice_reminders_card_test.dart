import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/l10n/app_localizations.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_preferences.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_service.dart';
import 'package:language_voice_tutor_mobile/widgets/practice_reminders_card.dart';

Widget _card(ReminderPermissionState permission) => MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PracticeRemindersCard(
          preferences: const PracticeReminderPreferences(enabled: true),
          permission: permission,
          error: null,
          onEnabled: (_) {},
          onMorning: () {},
          onEvening: () {},
          onAllow: () {},
          onSettings: () {},
        ),
      ),
    );

void main() {
  testWidgets('Russian reminder permission states are localized',
      (tester) async {
    await tester.pumpWidget(_card(ReminderPermissionState.granted));
    expect(find.text('Уведомления разрешены'), findsOneWidget);

    await tester.pumpWidget(_card(ReminderPermissionState.unavailable));
    expect(find.text('Статус уведомлений недоступен'), findsOneWidget);

    await tester.pumpWidget(_card(ReminderPermissionState.blocked));
    expect(find.text('Уведомления заблокированы в Android.'), findsOneWidget);
    expect(find.text('Разрешить уведомления'), findsOneWidget);
    expect(find.text('Открыть настройки Android'), findsOneWidget);
  });
}
