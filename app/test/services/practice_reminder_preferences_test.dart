import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_preferences.dart';

void main() {
  test('defaults represent enabled 09:00 and 20:00 reminders', () {
    const p = PracticeReminderPreferences();
    expect(p.enabled, isTrue);
    expect([p.morningHour, p.morningMinute], [9, 0]);
    expect([p.eveningHour, p.eveningMinute], [20, 0]);
    expect(p.permissionExplanationHandled, isFalse);
  });
  test('copyWith preserves and changes dedicated preference values', () {
    const p = PracticeReminderPreferences();
    final changed = p.copyWith(
        enabled: false,
        morningHour: 7,
        eveningMinute: 45,
        permissionExplanationHandled: true);
    expect(changed.enabled, isFalse);
    expect([changed.morningHour, changed.morningMinute], [7, 0]);
    expect([changed.eveningHour, changed.eveningMinute], [20, 45]);
    expect(changed.permissionExplanationHandled, isTrue);
  });
  test('reminder keys are distinct from session token keys', () {
    expect(SecurePracticeReminderPreferenceStore.enabledKey,
        isNot(equals('lvt_access_token')));
    expect(SecurePracticeReminderPreferenceStore.enabledKey,
        isNot(equals('lvt_refresh_token')));
    expect(SecurePracticeReminderPreferenceStore.explanationHandledKey,
        contains('lvt_practice_reminder_'));
  });
}
