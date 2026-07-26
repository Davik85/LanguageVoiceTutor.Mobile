import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_preferences.dart';

class _MemorySecureStorage extends FlutterSecureStorage {
  final values = <String, String>{};
  @override
  Future<Map<String, String>> readAll({dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions, dynamic mOptions, dynamic wOptions}) async => Map.of(values);
  @override
  Future<void> write({required String key, required String? value, dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions, dynamic mOptions, dynamic wOptions}) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

void main() {
  test('defaults represent enabled 09:00 and 20:00 reminders', () {
    const p = PracticeReminderPreferences();
    expect(p.enabled, isTrue);
    expect([p.morningHour, p.morningMinute], [9, 0]);
    expect([p.eveningHour, p.eveningMinute], [20, 0]);
    expect(p.permissionExplanationHandled, isFalse);
    expect(p.interfaceLanguageId, 'en');
  });
  test('copyWith preserves and changes dedicated preference values', () {
    const p = PracticeReminderPreferences();
    final changed = p.copyWith(
        enabled: false,
        morningHour: 7,
        eveningMinute: 45,
        permissionExplanationHandled: true,
        interfaceLanguageId: 'pt');
    expect(changed.enabled, isFalse);
    expect([changed.morningHour, changed.morningMinute], [7, 0]);
    expect([changed.eveningHour, changed.eveningMinute], [20, 45]);
    expect(changed.permissionExplanationHandled, isTrue);
    expect(changed.interfaceLanguageId, 'pt');
  });
  test('reminder keys are distinct from session token keys', () {
    expect(SecurePracticeReminderPreferenceStore.enabledKey,
        isNot(equals('lvt_access_token')));
    expect(SecurePracticeReminderPreferenceStore.enabledKey,
        isNot(equals('lvt_refresh_token')));
    expect(SecurePracticeReminderPreferenceStore.explanationHandledKey,
        contains('lvt_practice_reminder_'));
    expect(SecurePracticeReminderPreferenceStore.interfaceLanguageIdKey,
        contains('lvt_practice_reminder_'));
  });
  test('normalized language ID survives secure preference storage', () async {
    final storage = _MemorySecureStorage();
    final store = SecurePracticeReminderPreferenceStore(storage: storage);
    await store.write(const PracticeReminderPreferences(interfaceLanguageId: 'sr_Latn'));
    expect((await store.read()).interfaceLanguageId, 'sr');
    expect(storage.values[SecurePracticeReminderPreferenceStore.interfaceLanguageIdKey], 'sr');
  });
  test('old preferences without a language key use English', () async {
    final storage = _MemorySecureStorage()
      ..values[SecurePracticeReminderPreferenceStore.enabledKey] = 'false';
    final preferences = await SecurePracticeReminderPreferenceStore(storage: storage).read();
    expect(preferences.enabled, isFalse);
    expect(preferences.interfaceLanguageId, 'en');
  });
}
