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
    Future<ApiResponse> Function(String accessToken) send,
  ) async {
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
      throw const ApiException('Unable to load account details right now.');
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
