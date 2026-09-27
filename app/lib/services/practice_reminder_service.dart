import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'practice_reminder_preferences.dart';
import 'practice_reminder_messages.dart';

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
  Future<bool> setInterfaceLanguage(String? languageId);
  Future<bool> reconcile();
}

class LocalPracticeReminderService implements PracticeReminderService {
  LocalPracticeReminderService(
      {PracticeReminderPreferenceStore? store,
      ReminderNotificationAdapter? notifications,
      ReminderPlatformAdapter? platform,
      tz.TZDateTime Function()? now,
      void Function(String)? diagnosticLog})
      : _store = store ?? SecurePracticeReminderPreferenceStore(),
        _notifications = notifications ?? FlutterReminderNotificationAdapter(),
        _platform = platform ?? PermissionHandlerReminderPlatformAdapter(),
        _now = now ?? (() => tz.TZDateTime.now(tz.local)),
        _diagnosticLog = diagnosticLog ?? debugPrint;
  static const morningId = 41001;
  static const eveningId = 41002;
  final PracticeReminderPreferenceStore _store;
  final ReminderNotificationAdapter _notifications;
  final ReminderPlatformAdapter _platform;
  final tz.TZDateTime Function() _now;
  final void Function(String) _diagnosticLog;
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
      } catch (error) {
        _logFailure('timezone', error);
        tz.setLocalLocation(tz.UTC);
      }
      _timezoneReady = true;
      await _notifications.initialize();
      _initialized = true;
    } catch (error) {
      _logFailure('initialize', error);
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
  @override
  Future<bool> setInterfaceLanguage(String? languageId) async {
    final PracticeReminderPreferences preferences;
    try {
      preferences = await _store.read();
    } catch (error) {
      _logFailure('preference_read', error);
      return false;
    }
    final normalized = PracticeReminderMessages.normalizeLanguageId(languageId);
    final stored = PracticeReminderMessages.normalizeLanguageId(
        preferences.interfaceLanguageId);
    if (stored == normalized) return true;
    try {
      await _store.write(preferences.copyWith(interfaceLanguageId: normalized));
    } catch (error) {
      _logFailure('preference_write', error);
      return false;
    }
    return reconcile();
  }

  Future<bool> _save(
      PracticeReminderPreferences Function(PracticeReminderPreferences)
          change) async {
    final PracticeReminderPreferences preferences;
    try {
      preferences = await _store.read();
    } catch (error) {
      _logFailure('preference_read', error);
      return false;
    }
    try {
      await _store.write(change(preferences));
    } catch (error) {
      _logFailure('preference_write', error);
      return false;
    }
    return reconcile();
  }

  @override
  Future<bool> reconcile() async {
    await initialize();
    if (!_initialized || !_timezoneReady) return false;
    final PracticeReminderPreferences preferences;
    try {
      preferences = await _store.read();
    } catch (error) {
      _logFailure('preference_read', error);
      return false;
    }
    if (!preferences.enabled) return _cancel();
    final ReminderPermissionState permission;
    try {
      permission = await permissionState();
    } catch (error) {
      _logFailure('permission', error);
      return false;
    }
    if (permission != ReminderPermissionState.granted) {
      return _cancel();
    }
    final messages =
        PracticeReminderMessages.resolve(preferences.interfaceLanguageId);
    try {
      await _schedule(
          morningId,
          preferences.morningHour,
          preferences.morningMinute,
          messages.morningTitle,
          messages.morningBody);
    } catch (error) {
      _logFailure('schedule_morning', error);
      return false;
    }
    try {
      await _schedule(
          eveningId,
          preferences.eveningHour,
          preferences.eveningMinute,
          messages.eveningTitle,
          messages.eveningBody);
    } catch (error) {
      _logFailure('schedule_evening', error);
      return false;
    }
    return true;
  }

  Future<bool> _cancel() async {
    var success = true;
    try {
      await _notifications.cancel(morningId);
    } catch (error) {
      _logFailure('cancel_morning', error);
      success = false;
    }
    try {
      await _notifications.cancel(eveningId);
    } catch (error) {
      _logFailure('cancel_evening', error);
      success = false;
    }
    return success;
  }

  void _logFailure(String stage, Object error) {
    var line =
        'reminder_reconcile stage=$stage result=failure type=${error.runtimeType}';
    if (error is PlatformException) {
      final code = error.code;
      final safeCode = RegExp(r'^[A-Za-z][A-Za-z0-9_.-]{0,63}$').hasMatch(code)
          ? code
          : 'redacted';
      line += ' code=$safeCode';
    }
    _diagnosticLog(line);
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
