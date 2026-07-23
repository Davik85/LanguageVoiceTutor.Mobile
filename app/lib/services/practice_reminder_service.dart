import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'practice_reminder_preferences.dart';

enum ReminderPermissionState { granted, blocked, unavailable }

class ReminderScheduleRequest {
  const ReminderScheduleRequest(
      {required this.id,
      required this.title,
      required this.body,
      required this.at});
  final int id;
  final String title;
  final String body;
  final tz.TZDateTime at;
}

abstract class ReminderNotificationAdapter {
  Future<void> initialize();
  Future<void> cancel(int id);
  Future<void> schedule(ReminderScheduleRequest request);
}

abstract class ReminderPlatformAdapter {
  Future<String> timezoneIdentifier();
  Future<ReminderPermissionState> permissionState();
  Future<bool> requestPermission();
  Future<bool> openSettings();
}

class FlutterReminderNotificationAdapter
    implements ReminderNotificationAdapter {
  FlutterReminderNotificationAdapter({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  @override
  Future<void> initialize() => _plugin.initialize(
      settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_lvt_notification')));
  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
  @override
  Future<void> schedule(ReminderScheduleRequest r) => _plugin.zonedSchedule(
      id: r.id,
      title: r.title,
      body: r.body,
      scheduledDate: r.at,
      notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
              'practice_reminders', 'Practice reminders',
              channelDescription: 'Daily local practice reminders',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              icon: 'ic_stat_lvt_notification')),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time);
}

class PermissionHandlerReminderPlatformAdapter
    implements ReminderPlatformAdapter {
  @override
  Future<String> timezoneIdentifier() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;
  @override
  Future<ReminderPermissionState> permissionState() async {
    try {
      return await Permission.notification.isGranted
          ? ReminderPermissionState.granted
          : ReminderPermissionState.blocked;
    } catch (_) {
      return ReminderPermissionState.unavailable;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      return await Permission.notification.request().isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openSettings() => openAppSettings();
}

abstract class PracticeReminderService {
  Future<void> initialize();
  Future<PracticeReminderPreferences> preferences();
  Future<ReminderPermissionState> permissionState();
  Future<bool> requestPermission();
  Future<bool> openAndroidSettings();
  Future<bool> setEnabled(bool enabled);
  Future<bool> setMorningTime(int hour, int minute);
  Future<bool> setEveningTime(int hour, int minute);
  Future<bool> markExplanationHandled();
  Future<bool> reconcile();
}

class LocalPracticeReminderService implements PracticeReminderService {
  LocalPracticeReminderService(
      {PracticeReminderPreferenceStore? store,
      ReminderNotificationAdapter? notifications,
      ReminderPlatformAdapter? platform,
      tz.TZDateTime Function()? now})
      : _store = store ?? SecurePracticeReminderPreferenceStore(),
        _notifications = notifications ?? FlutterReminderNotificationAdapter(),
        _platform = platform ?? PermissionHandlerReminderPlatformAdapter(),
        _now = now ?? (() => tz.TZDateTime.now(tz.local));
  static const morningId = 41001;
  static const eveningId = 41002;
  final PracticeReminderPreferenceStore _store;
  final ReminderNotificationAdapter _notifications;
  final ReminderPlatformAdapter _platform;
  final tz.TZDateTime Function() _now;
  bool _initialized = false;
  bool _timezoneReady = false;
  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        tz.setLocalLocation(
            tz.getLocation(await _platform.timezoneIdentifier()));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
      _timezoneReady = true;
      await _notifications.initialize();
    } catch (_) {
    } finally {
      _initialized = true;
    }
  }

  @override
  Future<PracticeReminderPreferences> preferences() => _store.read();
  @override
  Future<ReminderPermissionState> permissionState() =>
      _platform.permissionState();
  @override
  Future<bool> requestPermission() => _platform.requestPermission();
  @override
  Future<bool> openAndroidSettings() => _platform.openSettings();
  @override
  Future<bool> markExplanationHandled() =>
      _save((p) => p.copyWith(permissionExplanationHandled: true));
  @override
  Future<bool> setEnabled(bool value) =>
      _save((p) => p.copyWith(enabled: value));
  @override
  Future<bool> setMorningTime(int h, int m) =>
      _save((p) => p.copyWith(morningHour: h, morningMinute: m));
  @override
  Future<bool> setEveningTime(int h, int m) =>
      _save((p) => p.copyWith(eveningHour: h, eveningMinute: m));
  Future<bool> _save(
      PracticeReminderPreferences Function(PracticeReminderPreferences)
          change) async {
    try {
      await _store.write(change(await _store.read()));
      return reconcile();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> reconcile() async {
    try {
      await initialize();
      final p = await _store.read();
      if (!p.enabled ||
          await permissionState() != ReminderPermissionState.granted ||
          !_timezoneReady) {
        await _cancel();
        return _timezoneReady;
      }
      await _cancel();
      await _schedule(
          morningId,
          p.morningHour,
          p.morningMinute,
          'Ready for a tiny language win? 🌞',
          'A few minutes of practice today can make a big difference. Let’s go!');
      await _schedule(
          eveningId,
          p.eveningHour,
          p.eveningMinute,
          'Keep your streak glowing! 🔥',
          'There’s still time for a quick lesson and one more win today.');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _cancel() async {
    await _notifications.cancel(morningId);
    await _notifications.cancel(eveningId);
  }

  Future<void> _schedule(
      int id, int hour, int minute, String title, String body) async {
    final now = _now();
    var at =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    await _notifications.schedule(
        ReminderScheduleRequest(id: id, title: title, body: body, at: at));
  }
}
