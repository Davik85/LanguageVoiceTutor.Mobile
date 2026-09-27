import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_preferences.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_messages.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _Store implements PracticeReminderPreferenceStore {
  _Store([this.value = const PracticeReminderPreferences()]);
  PracticeReminderPreferences value;
  bool fail = false;
  bool failWrite = false;
  @override
  Future<PracticeReminderPreferences> read() async {
    if (fail) throw StateError('storage');
    return value;
  }

  @override
  Future<void> write(PracticeReminderPreferences p) async {
    if (fail || failWrite) throw StateError('private storage detail');
    value = p;
  }
}

class _Notifications implements ReminderNotificationAdapter {
  final scheduled = <ReminderScheduleRequest>[];
  final cancelled = <int>[];
  final active = <int, ReminderScheduleRequest>{};
  final failScheduleIds = <int>{};
  final failCancelIds = <int>{};
  Object? scheduleError;
  bool fail = false;
  @override
  Future<void> initialize() async {
    if (fail) throw StateError('init');
  }

  @override
  Future<void> cancel(int id) async {
    if (failCancelIds.contains(id)) throw StateError('private cancel detail');
    cancelled.add(id);
    active.remove(id);
  }

  @override
  Future<void> schedule(ReminderScheduleRequest r) async {
    if (scheduleError != null) throw scheduleError!;
    if (fail || failScheduleIds.contains(r.id)) {
      throw StateError('private schedule detail');
    }
    scheduled.add(r);
    active[r.id] = r;
  }
}

class _Platform implements ReminderPlatformAdapter {
  _Platform(this.permission);
  ReminderPermissionState permission;
  String zone = 'Europe/Budapest';
  bool failZone = false;
  bool failPermission = false;
  @override
  Future<String> timezoneIdentifier() async {
    if (failZone) throw StateError('zone');
    return zone;
  }

  @override
  Future<ReminderPermissionState> permissionState() async {
    if (failPermission) throw StateError('private permission detail');
    return permission;
  }

  @override
  Future<bool> requestPermission() async =>
      permission == ReminderPermissionState.granted;
  @override
  Future<bool> openSettings() async => true;
}

void main() {
  setUp(tz_data.initializeTimeZones);
  LocalPracticeReminderService service(_Store store,
          _Notifications notifications, _Platform platform, tz.TZDateTime now,
          {void Function(String)? diagnosticLog}) =>
      LocalPracticeReminderService(
          store: store,
          notifications: notifications,
          platform: platform,
          now: () => now,
          diagnosticLog: diagnosticLog);
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
            _Platform(ReminderPermissionState.granted)..failPermission = true,
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
    expect(notifications.cancelled, isEmpty);
    expect(notifications.active.keys.toSet(), {
      LocalPracticeReminderService.morningId,
      LocalPracticeReminderService.eveningId
    });
  });
  test('failed morning replacement preserves both existing reminders',
      () async {
    final store = _Store();
    final notifications = _Notifications();
    final logs = <String>[];
    final reminderService = service(
        store,
        notifications,
        _Platform(ReminderPermissionState.granted),
        tz.TZDateTime(tz.getLocation('Europe/Budapest'), 2026, 7, 23, 8),
        diagnosticLog: logs.add);
    expect(await reminderService.reconcile(), isTrue);
    notifications.failScheduleIds.add(LocalPracticeReminderService.morningId);

    expect(await reminderService.setMorningTime(10, 30), isFalse);
    expect(store.value.morningHour, 10);
    expect(store.value.morningMinute, 30);
    expect(
        notifications.active[LocalPracticeReminderService.morningId]!.at.hour,
        9);
    expect(
        notifications.active[LocalPracticeReminderService.eveningId]!.at.hour,
        20);
    expect(notifications.cancelled, isEmpty);
    expect(logs, [
      'reminder_reconcile stage=schedule_morning result=failure type=StateError'
    ]);
    expect(logs.single, isNot(contains('private schedule detail')));
  });
  test('platform scheduling failure logs only its safe code', () async {
    final notifications = _Notifications()
      ..scheduleError = PlatformException(
          code: 'invalid_icon',
          message: 'private plugin message',
          details: {'token': 'private detail'});
    final logs = <String>[];
    final reminderService = service(
        _Store(),
        notifications,
        _Platform(ReminderPermissionState.granted),
        tz.TZDateTime.utc(2026),
        diagnosticLog: logs.add);

    expect(await reminderService.reconcile(), isFalse);
    expect(logs, [
      'reminder_reconcile stage=schedule_morning result=failure type=PlatformException code=invalid_icon'
    ]);
    expect(logs.single, isNot(contains('private plugin message')));
    expect(logs.single, isNot(contains('private detail')));
    expect(logs.single, isNot(contains('token')));

    logs.clear();
    notifications.scheduleError =
        PlatformException(code: 'invalid_icon\nprivate detail');
    expect(await reminderService.reconcile(), isFalse);
    expect(logs.single, endsWith('code=redacted'));
    expect(logs.single, isNot(contains('private detail')));
  });
  test('failed evening replacement retains its old alarm and stable IDs',
      () async {
    final store = _Store();
    final notifications = _Notifications();
    final logs = <String>[];
    final reminderService = service(
        store,
        notifications,
        _Platform(ReminderPermissionState.granted),
        tz.TZDateTime(tz.getLocation('Europe/Budapest'), 2026, 7, 23, 8),
        diagnosticLog: logs.add);
    expect(await reminderService.reconcile(), isTrue);
    notifications.failScheduleIds.add(LocalPracticeReminderService.eveningId);

    expect(await reminderService.setMorningTime(10, 30), isFalse);
    expect(notifications.active.keys.toSet(), {
      LocalPracticeReminderService.morningId,
      LocalPracticeReminderService.eveningId
    });
    expect(
        notifications.active[LocalPracticeReminderService.morningId]!.at.hour,
        10);
    expect(
        notifications.active[LocalPracticeReminderService.eveningId]!.at.hour,
        20);
    expect(notifications.cancelled, isEmpty);
    expect(logs.single, contains('stage=schedule_evening result=failure'));
  });
  test('blocked permission cancels existing IDs without scheduling', () async {
    final notifications = _Notifications();
    final platform = _Platform(ReminderPermissionState.granted);
    final reminderService =
        service(_Store(), notifications, platform, tz.TZDateTime.utc(2026));
    expect(await reminderService.reconcile(), isTrue);
    platform.permission = ReminderPermissionState.blocked;

    expect(await reminderService.reconcile(), isTrue);
    expect(notifications.active, isEmpty);
    expect(notifications.cancelled, [
      LocalPracticeReminderService.morningId,
      LocalPracticeReminderService.eveningId
    ]);
    expect(notifications.scheduled.length, 2);
  });
  test('diagnostics identify read, write, init and permission failures safely',
      () async {
    final now = tz.TZDateTime.utc(2026);
    final logs = <String>[];
    final failingRead = service(_Store()..fail = true, _Notifications(),
        _Platform(ReminderPermissionState.granted), now,
        diagnosticLog: logs.add);
    expect(await failingRead.reconcile(), isFalse);
    expect(logs.single, contains('stage=preference_read result=failure'));

    logs.clear();
    final failingWrite = service(_Store()..failWrite = true, _Notifications(),
        _Platform(ReminderPermissionState.granted), now,
        diagnosticLog: logs.add);
    expect(await failingWrite.setMorningTime(11, 0), isFalse);
    expect(logs.single, contains('stage=preference_write result=failure'));

    logs.clear();
    final failingInit = service(_Store(), _Notifications()..fail = true,
        _Platform(ReminderPermissionState.granted), now,
        diagnosticLog: logs.add);
    expect(await failingInit.reconcile(), isFalse);
    expect(logs.single, contains('stage=initialize result=failure'));

    logs.clear();
    final failingPermission = service(_Store(), _Notifications(),
        _Platform(ReminderPermissionState.granted)..failPermission = true, now,
        diagnosticLog: logs.add);
    expect(await failingPermission.reconcile(), isFalse);
    expect(logs.single, contains('stage=permission result=failure'));
    expect(logs.join(' '), isNot(contains('private')));
  });
  test('cancel failures are logged by reminder ID stage and both are tried',
      () async {
    final notifications = _Notifications()
      ..failCancelIds.addAll([
        LocalPracticeReminderService.morningId,
        LocalPracticeReminderService.eveningId
      ]);
    final logs = <String>[];
    final reminderService = service(
        _Store(const PracticeReminderPreferences(enabled: false)),
        notifications,
        _Platform(ReminderPermissionState.granted),
        tz.TZDateTime.utc(2026),
        diagnosticLog: logs.add);

    expect(await reminderService.reconcile(), isFalse);
    expect(logs, [
      'reminder_reconcile stage=cancel_morning result=failure type=StateError',
      'reminder_reconcile stage=cancel_evening result=failure type=StateError'
    ]);
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
  group('localized practice reminder messages', () {
    test('reconcile schedules localized copy for both stable IDs', () async {
      final notifications = _Notifications();
      await service(
              _Store(
                  const PracticeReminderPreferences(interfaceLanguageId: 'ja')),
              notifications,
              _Platform(ReminderPermissionState.granted),
              tz.TZDateTime.utc(2026))
          .reconcile();
      final messages = PracticeReminderMessages.resolve('ja');
      expect(notifications.scheduled.map((request) => request.id), [
        LocalPracticeReminderService.morningId,
        LocalPracticeReminderService.eveningId
      ]);
      expect(notifications.scheduled.map((request) => request.title),
          [messages.morningTitle, messages.eveningTitle]);
      expect(notifications.scheduled.map((request) => request.body),
          [messages.morningBody, messages.eveningBody]);
    });

    test('a language change reschedules the same IDs and preserves times',
        () async {
      final store = _Store(const PracticeReminderPreferences(
          interfaceLanguageId: 'en',
          morningHour: 7,
          morningMinute: 15,
          eveningHour: 21,
          eveningMinute: 45));
      final notifications = _Notifications();
      final reminderService = service(store, notifications,
          _Platform(ReminderPermissionState.granted), tz.TZDateTime.utc(2026));
      expect(await reminderService.setInterfaceLanguage('pt-PT'), isTrue);
      expect(store.value.interfaceLanguageId, 'pt');
      expect([
        store.value.morningHour,
        store.value.morningMinute,
        store.value.eveningHour,
        store.value.eveningMinute
      ], [
        7,
        15,
        21,
        45
      ]);
      expect(notifications.scheduled.map((request) => request.id), [
        LocalPracticeReminderService.morningId,
        LocalPracticeReminderService.eveningId
      ]);
      expect(notifications.scheduled.first.title,
          PracticeReminderMessages.resolve('pt').morningTitle);
    });

    test('an unchanged normalized language does not reschedule', () async {
      final notifications = _Notifications();
      final reminderService = service(
          _Store(const PracticeReminderPreferences(interfaceLanguageId: 'sr')),
          notifications,
          _Platform(ReminderPermissionState.granted),
          tz.TZDateTime.utc(2026));
      expect(await reminderService.setInterfaceLanguage('sr-Latn'), isTrue);
      expect(notifications.scheduled, isEmpty);
    });
  });
}
