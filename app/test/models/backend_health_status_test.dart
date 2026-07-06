import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/backend_health_status.dart';

void main() {
  group('BackendHealthStatus', () {
    test('parses a valid health response', () {
      final status = BackendHealthStatus.fromJson({
        'status': 'ok',
        'environment': 'production',
        'checkedAtUtc': '2026-07-06T12:00:00Z',
      });

      expect(status.status, 'ok');
      expect(status.environment, 'production');
      expect(status.checkedAtUtc, DateTime.utc(2026, 7, 6, 12));
    });

    test('throws for missing fields', () {
      expect(
        () => BackendHealthStatus.fromJson({'status': 'ok'}),
        throwsFormatException,
      );
    });
  });
}
