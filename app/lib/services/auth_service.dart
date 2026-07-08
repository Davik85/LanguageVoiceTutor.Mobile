import 'dart:convert';

import '../api/api_client.dart';
import '../models/auth_models.dart';
import '../models/lesson_access_decision.dart';
import '../models/subscription_status.dart';
import '../models/user_settings.dart';
import 'session_storage.dart';

class AuthService {
  const AuthService(
      {required ApiClient apiClient, required SessionStorage storage})
      : _apiClient = apiClient,
        _storage = storage;

  final ApiClient _apiClient;
  final SessionStorage _storage;

  Future<AuthUser> login(String email, String password) async {
    final auth = await _authenticate('/api/auth/login',
        LoginRequest(email: email, password: password).toJson());
    return auth.user;
  }

  Future<AuthUser> register(
      String email, String password, String? displayName) async {
    final auth = await _authenticate(
        '/api/auth/register',
        RegisterRequest(
                email: email, password: password, displayName: displayName)
            .toJson());
    return auth.user;
  }

  Future<AuthUser> loadCurrentUser() async {
    final response = await _authenticatedGet('/api/auth/me');
    return AuthUser.fromJson(_decodeObject(response.body));
  }

  Future<SubscriptionStatus> fetchSubscriptionStatus() async {
    final response = await _authenticatedGet('/api/me/subscription-status');
    return SubscriptionStatus.fromJson(_decodeObject(response.body));
  }

  Future<LessonAccessDecision> fetchLessonAccessDecision() async {
    final response = await _authenticatedGet('/api/me/lesson-access');
    return LessonAccessDecision.fromJson(_decodeObject(response.body));
  }

  Future<UserSettings> fetchUserSettings() async {
    final response = await _authenticatedGet('/api/me/settings');
    return UserSettings.fromJson(_decodeObject(response.body));
  }

  Future<UserSettings> updateUserSettings(UserSettings settings) async {
    final response =
        await _authenticatedPut('/api/me/settings', body: settings.toJson());
    return UserSettings.fromJson(_decodeObject(response.body));
  }

  Future<String> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/password-reset/request',
        body: PasswordResetRequest(email: email).toJson(),
      );
      if (_isSuccess(response.statusCode)) {
        return _passwordMessage(
          response.body,
          fallback:
              'Password reset instructions were sent if this email is registered.',
        );
      }
      throw ApiException(_passwordResetRequestFailureMessage(response));
    } on ApiException catch (error) {
      throw ApiException(_safePasswordResetRequestExceptionMessage(error));
    } catch (_) {
      throw const ApiException('Could not request password reset. Please try again.');
    }
  }

  Future<String> confirmPasswordReset(String token, String newPassword) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/password-reset/confirm',
        body: PasswordResetConfirmRequest(token: token, newPassword: newPassword)
            .toJson(),
      );
      if (_isSuccess(response.statusCode)) {
        return _passwordMessage(response.body, fallback: 'Password updated.');
      }
      throw ApiException(_passwordResetConfirmFailureMessage(response));
    } on ApiException catch (error) {
      throw ApiException(_safePasswordResetConfirmExceptionMessage(error));
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.');
    }
  }

  Future<String> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    try {
      final response = await _authenticatedPost(
        '/api/auth/password/change',
        body: ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmNewPassword: confirmNewPassword,
        ).toJson(),
        failureMessageForResponse: _changePasswordFailureMessage,
      );
      return _passwordMessage(response.body, fallback: 'Password updated.');
    } on ApiException catch (error) {
      throw ApiException(_safeChangePasswordExceptionMessage(error));
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.');
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _apiClient.post('/api/auth/revoke',
            body:
                RevokeRefreshTokenRequest(refreshToken: refreshToken).toJson());
      } catch (_) {
        // Local session is still cleared when the revoke call cannot complete.
      }
    }
    await _storage.clear();
  }

  Future<AuthResponse> _authenticate(
      String path, Map<String, dynamic> body) async {
    final response = await _apiClient.post(path, body: body);
    if (!_isSuccess(response.statusCode)) {
      throw const ApiException('Email or password was not accepted.');
    }
    final auth = AuthResponse.fromJson(_decodeObject(response.body));
    await _storage.saveTokens(
        accessToken: auth.accessToken, refreshToken: auth.refreshToken);
    return auth;
  }

  Future<ApiResponse> _authenticatedGet(String path) async {
    return _authenticatedSend(
      path,
      (token) => _apiClient.get(path, accessToken: token),
    );
  }

  Future<ApiResponse> _authenticatedPost(
    String path, {
    required Map<String, dynamic> body,
    String Function(ApiResponse response)? failureMessageForResponse,
  }) async {
    return _authenticatedSend(
      path,
      (token) => _apiClient.post(path, body: body, accessToken: token),
      failureMessageForResponse: failureMessageForResponse,
    );
  }

  Future<ApiResponse> _authenticatedPut(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _authenticatedSend(
      path,
      (token) => _apiClient.put(path, body: body, accessToken: token),
    );
  }

  Future<ApiResponse> _authenticatedSend(
    String path,
    Future<ApiResponse> Function(String accessToken) send, {
    String Function(ApiResponse response)? failureMessageForResponse,
  }) async {
    final accessToken = await _storage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ApiException('Please sign in again.');
    }

    var response = await send(accessToken);
    if (response.statusCode == 401) {
      final refreshed = await _refreshSession();
      if (!refreshed) {
        await _storage.clear();
        throw const ApiException('Please sign in again.');
      }
      final newAccessToken = await _storage.readAccessToken();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _storage.clear();
        throw const ApiException('Please sign in again.');
      }
      response = await send(newAccessToken);
    }

    if (!_isSuccess(response.statusCode)) {
      throw ApiException(failureMessageForResponse?.call(response) ??
          'Unable to load account details right now.');
    }
    return response;
  }

  Future<bool> _refreshSession() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _apiClient.post('/api/auth/refresh',
          body: RefreshTokenRequest(refreshToken: refreshToken).toJson());
      if (!_isSuccess(response.statusCode)) return false;
      final auth = AuthResponse.fromJson(_decodeObject(response.body));
      await _storage.saveTokens(
          accessToken: auth.accessToken, refreshToken: auth.refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }


  static String _passwordMessage(String body, {required String fallback}) {
    try {
      final parsed = PasswordOperationResponse.fromJson(_decodeObject(body));
      return parsed.message.isEmpty ? fallback : parsed.message;
    } catch (_) {
      return fallback;
    }
  }

  static String _passwordResetRequestFailureMessage(ApiResponse response) {
    final body = response.body.toLowerCase();
    if (response.statusCode == 429) {
      return 'Too many password reset requests. Please wait before trying again.';
    }
    if (body.contains('delivery') || body.contains('email') && body.contains('configured')) {
      return 'Password reset email delivery is not configured. Please contact support.';
    }
    return 'Could not request password reset. Please try again.';
  }

  static String _passwordResetConfirmFailureMessage(ApiResponse response) {
    if (response.statusCode == 429) {
      return 'Too many password reset requests. Please wait before trying again.';
    }
    if (response.statusCode == 400 || response.statusCode == 404) {
      return 'Password reset code is invalid or expired.';
    }
    return 'Something went wrong. Please try again.';
  }

  static String _changePasswordFailureMessage(ApiResponse response) {
    final body = response.body.toLowerCase();
    if (response.statusCode == 400 || response.statusCode == 401) {
      if (body.contains('current') || body.contains('incorrect')) {
        return 'Current password is incorrect.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  static String _safePasswordResetRequestExceptionMessage(ApiException error) {
    const safe = {
      'Password reset email delivery is not configured. Please contact support.',
      'Too many password reset requests. Please wait before trying again.',
      'Could not request password reset. Please try again.',
    };
    return safe.contains(error.message)
        ? error.message
        : 'Could not request password reset. Please try again.';
  }

  static String _safePasswordResetConfirmExceptionMessage(ApiException error) {
    const safe = {
      'Password reset code is invalid or expired.',
      'Too many password reset requests. Please wait before trying again.',
      'Something went wrong. Please try again.',
    };
    return safe.contains(error.message)
        ? error.message
        : 'Something went wrong. Please try again.';
  }

  static String _safeChangePasswordExceptionMessage(ApiException error) {
    const safe = {
      'Please sign in to change your password.',
      'Current password is incorrect.',
      'Something went wrong. Please try again.',
    };
    if (error.message == 'Please sign in again.') {
      return 'Please sign in to change your password.';
    }
    return safe.contains(error.message)
        ? error.message
        : 'Something went wrong. Please try again.';
  }

  static bool _isSuccess(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  static Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('The service returned an unexpected response.');
    }
    return decoded;
  }
}
