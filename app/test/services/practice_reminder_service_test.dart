import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_preferences.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _Store implements PracticeReminderPreferenceStore {
  _Store([this.value = const PracticeReminderPreferences()]);
  PracticeReminderPreferences value;
  bool fail = false;
  @override
  Future<PracticeReminderPreferences> read() async {
    if (fail) throw StateError('storage');
    return value;
  }

  @override
  Future<void> write(PracticeReminderPreferences p) async {
    if (fail) throw StateError('storage');
    value = p;
  }
}

class _Notifications implements ReminderNotificationAdapter {
  final scheduled = <ReminderScheduleRequest>[];
  final cancelled = <int>[];
  bool fail = false;
  @override
  Future<void> initialize() async {
    if (fail) throw StateError('init');
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
  @override
  Future<void> schedule(ReminderScheduleRequest r) async {
    if (fail) throw StateError('schedule');
    scheduled.add(r);
  }
}

class _Platform implements ReminderPlatformAdapter {
  _Platform(this.permission);
  ReminderPermissionState permission;
  String zone = 'Europe/Budapest';
  bool failZone = false;
  @override
  Future<String> timezoneIdentifier() async {
    if (failZone) throw StateError('zone');
    return zone;
  }

  @override
  Future<ReminderPermissionState> permissionState() async => permission;
  @override
  Future<bool> requestPermission() async =>
      permission == ReminderPermissionState.granted;
  @override
  Future<bool> openSettings() async => true;
}

void main() {
  setUp(tz_data.initializeTimeZones);
  LocalPracticeReminderService service(
          _Store store,
          _Notifications notifications,
          _Platform platform,
          tz.TZDateTime now) =>
      LocalPracticeReminderService(
          store: store,
          notifications: notifications,
          platform: platform,
          now: () => now);
  test(
      'enabled permitted reminders schedule the two stable IDs in the device timezone',
      () async {
    final store = _Store();
    final notifications = _Notifications();
    final platform = _Platform(ReminderPermissionState.granted);
    final result = await service(store, notifications, platform,
            tz.TZDateTime(tz.getLocation('Europe/Budapest'), 2026, 7, 23, 8))
        .reconcile();
    expect(result, isTrue);
    expect(notifications.scheduled.map((r) => r.id), [
      LocalPracticeReminderService.morningId,
      LocalPracticeReminderService.eveningId
    ]);
    expect(notifications.scheduled.map((r) => r.at.location.name).toSet(),
        {'Europe/Budapest'});
    expect(notifications.scheduled.first.at.hour, 9);
    expect(notifications.scheduled.last.at.hour, 20);
  });
  test('disabled or blocked reminders cancel only the two reminder IDs',
      () async {
    final notifications = _Notifications();
    await service(
            _Store(const PracticeReminderPreferences(enabled: false)),
            notifications,
            _Platform(ReminderPermissionState.granted),
            tz.TZDateTime.utc(2026))
        .reconcile();
    expect(notifications.scheduled, isEmpty);
    expect(notifications.cancelled, [
      LocalPracticeReminderService.morningId,
      LocalPracticeReminderService.eveningId
    ]);
  });
  test('a past time moves to tomorrow while a future time stays today',
      () async {
    final notifications = _Notifications();
    await service(
            _Store(const PracticeReminderPreferences(
                morningHour: 9, eveningHour: 20)),
            notifications,
            _Platform(ReminderPermissionState.granted),
            tz.TZDateTime(tz.getLocation('Europe/Budapest'), 2026, 7, 23, 10))
        .reconcile();
    expect(notifications.scheduled.first.at.day, 24);
    expect(notifications.scheduled.last.at.day, 23);
  });
  test('changing a time reconciles both schedules without duplicate IDs',
      () async {
    final store = _Store();
    final notifications = _Notifications();
    final s = service(
        store,
        notifications,
        _Platform(ReminderPermissionState.granted),
        tz.TZDateTime(tz.getLocation('Europe/Budapest'), 2026, 7, 23, 8));
    await s.setMorningTime(10, 30);
    expect(notifications.scheduled.map((r) => r.id).toSet().length, 2);
    expect(notifications.scheduled.first.at.hour, 10);
  });
  test('storage and scheduling failures are returned safely', () async {
    final store = _Store()..fail = true;
    expect(
        await service(
                store,
                _Notifications(),
                _Platform(ReminderPermissionState.granted),
                tz.TZDateTime.utc(2026))
            .reconcile(),
        isFalse);
    expect(
        await service(
                _Store(),
                _Notifications()..fail = true,
                _Platform(ReminderPermissionState.granted),
                tz.TZDateTime.utc(2026))
            .reconcile(),
        isFalse);
  });
}
