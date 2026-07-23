import 'package:flutter/material.dart';
import '../services/practice_reminder_preferences.dart';
import '../services/practice_reminder_service.dart';

class PracticeRemindersCard extends StatelessWidget {
  const PracticeRemindersCard(
      {super.key,
      required this.preferences,
      required this.permission,
      required this.error,
      required this.onEnabled,
      required this.onMorning,
      required this.onEvening,
      required this.onAllow,
      required this.onSettings});
  final PracticeReminderPreferences? preferences;
  final ReminderPermissionState permission;
  final String? error;
  final ValueChanged<bool> onEnabled;
  final VoidCallback onMorning;
  final VoidCallback onEvening;
  final VoidCallback onAllow;
  final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) {
    final p = preferences ?? const PracticeReminderPreferences();
    final blocked = permission == ReminderPermissionState.blocked;
    String time(int h, int m) => TimeOfDay(hour: h, minute: m).format(context);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Practice reminders'),
              const SizedBox(height: 4),
              const Text('These reminders are local to this device.'),
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily practice reminders'),
                  value: p.enabled,
                  onChanged: onEnabled),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Morning reminder'),
                  trailing: Text(time(p.morningHour, p.morningMinute)),
                  onTap: onMorning),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Evening reminder'),
                  trailing: Text(time(p.eveningHour, p.eveningMinute)),
                  onTap: onEvening),
              Text(permission == ReminderPermissionState.granted
                  ? 'Notifications allowed'
                  : permission == ReminderPermissionState.unavailable
                      ? 'Notification status unavailable'
                      : 'Notifications are blocked by Android.'),
              if (error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!)),
              if (p.enabled && blocked)
                Wrap(spacing: 8, children: [
                  TextButton(
                      onPressed: onAllow,
                      child: const Text('Allow notifications')),
                  TextButton(
                      onPressed: onSettings,
                      child: const Text('Open Android settings'))
                ])
            ])));
  }
}
