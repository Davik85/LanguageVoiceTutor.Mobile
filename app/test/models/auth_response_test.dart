import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';

void main() {
  test('parses auth response', () {
    final auth = AuthResponse.fromJson({
      'accessToken': 'access',
      'tokenType': 'Bearer',
      'expiresAtUtc': '2026-07-06T12:30:00Z',
      'refreshToken': 'refresh',
      'refreshTokenExpiresAtUtc': '2026-08-06T12:00:00Z',
      'user': {
        'userId': 'u1',
        'email': 'user@example.com',
        'displayName': 'User',
        'createdAt': '2026-07-01T12:00:00Z',
      },
    });

    expect(auth.tokenType, 'Bearer');
    expect(auth.user.email, 'user@example.com');
  });
}
