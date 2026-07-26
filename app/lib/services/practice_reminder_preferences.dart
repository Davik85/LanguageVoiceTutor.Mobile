import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'practice_reminder_messages.dart';

class PracticeReminderPreferences {
  const PracticeReminderPreferences({
    this.enabled = true,
    this.morningHour = 9,
    this.morningMinute = 0,
    this.eveningHour = 20,
    this.eveningMinute = 0,
    this.permissionExplanationHandled = false,
    this.interfaceLanguageId = 'en',
  });

  final bool enabled;
  final int morningHour;
  final int morningMinute;
  final int eveningHour;
  final int eveningMinute;
  final bool permissionExplanationHandled;
  final String interfaceLanguageId;

  PracticeReminderPreferences copyWith(
          {bool? enabled,
          int? morningHour,
          int? morningMinute,
          int? eveningHour,
          int? eveningMinute,
          bool? permissionExplanationHandled,
          String? interfaceLanguageId}) =>
      PracticeReminderPreferences(
        enabled: enabled ?? this.enabled,
        morningHour: morningHour ?? this.morningHour,
        morningMinute: morningMinute ?? this.morningMinute,
        eveningHour: eveningHour ?? this.eveningHour,
        eveningMinute: eveningMinute ?? this.eveningMinute,
        permissionExplanationHandled:
            permissionExplanationHandled ?? this.permissionExplanationHandled,
        interfaceLanguageId: interfaceLanguageId ?? this.interfaceLanguageId,
      );
}

abstract class PracticeReminderPreferenceStore {
  Future<PracticeReminderPreferences> read();
  Future<void> write(PracticeReminderPreferences preferences);
}

class SecurePracticeReminderPreferenceStore
    implements PracticeReminderPreferenceStore {
  SecurePracticeReminderPreferenceStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  static const enabledKey = 'lvt_practice_reminder_enabled';
  static const morningHourKey = 'lvt_practice_reminder_morning_hour';
  static const morningMinuteKey = 'lvt_practice_reminder_morning_minute';
  static const eveningHourKey = 'lvt_practice_reminder_evening_hour';
  static const eveningMinuteKey = 'lvt_practice_reminder_evening_minute';
  static const explanationHandledKey =
      'lvt_practice_reminder_permission_explanation_handled';
  static const interfaceLanguageIdKey =
      'lvt_practice_reminder_interface_language_id';

  @override
  Future<PracticeReminderPreferences> read() async {
    try {
      final values = await _storage.readAll();
      int value(String key, int fallback, int max) {
        final parsed = int.tryParse(values[key] ?? '');
        return parsed != null && parsed >= 0 && parsed <= max
            ? parsed
            : fallback;
      }

      return PracticeReminderPreferences(
        enabled: values[enabledKey] != 'false',
        morningHour: value(morningHourKey, 9, 23),
        morningMinute: value(morningMinuteKey, 0, 59),
        eveningHour: value(eveningHourKey, 20, 23),
        eveningMinute: value(eveningMinuteKey, 0, 59),
        permissionExplanationHandled: values[explanationHandledKey] == 'true',
        interfaceLanguageId: PracticeReminderMessages.normalizeLanguageId(
            values[interfaceLanguageIdKey]),
      );
    } catch (_) {
      return const PracticeReminderPreferences();
    }
  }

  @override
  Future<void> write(PracticeReminderPreferences p) async {
    await Future.wait([
      _storage.write(key: enabledKey, value: '${p.enabled}'),
      _storage.write(key: morningHourKey, value: '${p.morningHour}'),
      _storage.write(key: morningMinuteKey, value: '${p.morningMinute}'),
      _storage.write(key: eveningHourKey, value: '${p.eveningHour}'),
      _storage.write(key: eveningMinuteKey, value: '${p.eveningMinute}'),
      _storage.write(
          key: explanationHandledKey,
          value: '${p.permissionExplanationHandled}'),
      _storage.write(
          key: interfaceLanguageIdKey,
          value: PracticeReminderMessages.normalizeLanguageId(
              p.interfaceLanguageId)),
    ]);
  }
}
