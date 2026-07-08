class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (displayName != null && displayName!.trim().isNotEmpty)
          'displayName': displayName!.trim(),
      };
}

class RefreshTokenRequest {
  const RefreshTokenRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class RevokeRefreshTokenRequest {
  const RevokeRefreshTokenRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class PasswordResetRequest {
  const PasswordResetRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class PasswordResetConfirmRequest {
  const PasswordResetConfirmRequest({
    required this.token,
    required this.newPassword,
  });

  final String token;
  final String newPassword;

  Map<String, dynamic> toJson() => {'token': token, 'newPassword': newPassword};
}

class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };
}

class PasswordOperationResponse {
  const PasswordOperationResponse({required this.message});

  final String message;

  factory PasswordOperationResponse.fromJson(Map<String, dynamic> json) =>
      PasswordOperationResponse(message: _string(json, 'message'));
}

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAtUtc,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final DateTime expiresAtUtc;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;
  final AuthUser user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: _string(json, 'accessToken'),
        tokenType: _string(json, 'tokenType', fallback: 'Bearer'),
        expiresAtUtc: _date(json, 'expiresAtUtc'),
        refreshToken: _string(json, 'refreshToken'),
        refreshTokenExpiresAtUtc: _date(json, 'refreshTokenExpiresAtUtc'),
        user: AuthUser.fromJson(_object(json, 'user')),
      );
}

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  final String userId;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      return AuthUser.fromJson(userJson);
    }

    return AuthUser(
      userId: _string(json, 'userId', fallback: _string(json, 'id')),
      email: _string(json, 'email'),
      displayName:
          _nullableString(json, 'displayName') ?? _nullableString(json, 'name'),
      createdAt: _nullableDate(json, 'createdAt') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

String _string(Map<String, dynamic> json, String key, {String fallback = ''}) =>
    _nullableString(json, key) ?? fallback;

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

DateTime _date(Map<String, dynamic> json, String key) =>
    _nullableDate(json, key) ??
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

DateTime? _nullableDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
