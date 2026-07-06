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
        accessToken: json['accessToken'] as String? ?? '',
        tokenType: json['tokenType'] as String? ?? 'Bearer',
        expiresAtUtc: DateTime.parse(json['expiresAtUtc'] as String),
        refreshToken: json['refreshToken'] as String? ?? '',
        refreshTokenExpiresAtUtc:
            DateTime.parse(json['refreshTokenExpiresAtUtc'] as String),
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
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

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userId: json['userId'] as String? ?? '',
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
