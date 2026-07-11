import 'dart:convert';

import '../api/api_client.dart';
import '../models/auth_models.dart';
import '../models/lesson_access_decision.dart';
import '../models/lesson_chat.dart';
import '../models/lesson_runtime.dart';
import '../models/lesson_session.dart';
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

  Future<LessonSessionStartResult> startLessonSession({
    required StartLessonSessionRequest request,
  }) async {
    try {
      final response = await _authenticatedPost(
        '/api/me/lesson-sessions',
        body: request.toJson(),
        failureMessageForResponse: _lessonSessionStartFailureMessage,
      );
      return LessonSessionStartResult.ready(
        LessonSessionResponse.fromJson(_decodeObject(response.body)),
      );
    } on ApiException catch (error) {
      return _safeLessonSessionStartResult(error);
    } catch (_) {
      return LessonSessionStartResult.failed();
    }
  }

  Future<LessonRuntimeScenario> fetchLessonRuntimeScenario({
    required String scenarioKey,
  }) async {
    final normalizedKey = scenarioKey.trim();
    if (normalizedKey.isEmpty) {
      throw const ApiException('Lesson content is unavailable right now.');
    }

    final response = await _authenticatedGet(
      '/api/me/lesson-content/scenarios/${Uri.encodeComponent(normalizedKey)}',
      failureMessageForResponse: _lessonRuntimeScenarioFailureMessage,
    );
    return LessonRuntimeScenario.fromJson(_decodeObject(response.body));
  }

  Future<LessonChatReplyResult> sendLessonChatReply({
    required LessonChatRequest request,
  }) async {
    if (request.userMessage.trim().isEmpty) {
      return LessonChatReplyResult.validation();
    }

    try {
      final response = await _authenticatedPost(
        '/api/lesson-chat/reply',
        body: request.toJson(),
        failureMessageForResponse: _lessonChatReplyFailureMessage,
      );
      return LessonChatReplyResult.success(
        LessonChatReplyResponse.fromJson(_decodeObject(response.body)),
      );
    } on ApiException catch (error) {
      return _safeLessonChatReplyResult(error);
    } catch (_) {
      return LessonChatReplyResult.failed();
    }
  }

  Future<LessonChatHintResult> requestLessonChatHint({
    required LessonChatRequest request,
  }) async {
    try {
      final response = await _authenticatedPost(
        '/api/lesson-chat/hint',
        body: request.toJson(),
        failureMessageForResponse: _lessonChatHintFailureMessage,
      );
      return LessonChatHintResult.success(
        LessonChatHintResponse.fromJson(_decodeObject(response.body)),
      );
    } on ApiException catch (error) {
      return _safeLessonChatHintResult(error);
    } catch (_) {
      return LessonChatHintResult.failed();
    }
  }

  Future<void> persistLessonSessionMessage({
    required String sessionId,
    required CreateLessonSessionMessageRequest request,
  }) async {
    await _authenticatedPost(
      '/api/me/lesson-sessions/$sessionId/messages',
      body: request.toJson(),
      failureMessageForResponse: _lessonSessionMessageFailureMessage,
    );
  }

  Future<LessonSessionAbandonResult> abandonLessonSession({
    required String sessionId,
  }) async {
    final normalizedId = sessionId.trim();
    if (normalizedId.isEmpty) return LessonSessionAbandonResult.failed();
    try {
      final response = await _authenticatedPostWithoutBody(
        '/api/lesson-sessions/$normalizedId/abandon',
        failureMessageForResponse: _lessonAbandonFailureMessage,
      );
      _decodeObject(response.body);
      return LessonSessionAbandonResult.abandoned();
    } on ApiException catch (error) {
      return _safeLessonSessionAbandonResult(error);
    } catch (_) {
      return LessonSessionAbandonResult.failed();
    }
  }

  Future<LessonCompletionResult> finishLessonSession({
    required String sessionId,
    required int validTurnCount,
  }) async {
    final normalizedId = sessionId.trim();
    if (normalizedId.isEmpty || validTurnCount < 0) {
      return LessonCompletionResult.failed();
    }
    try {
      await _authenticatedPut(
        '/api/me/lesson-sessions/$normalizedId/finish',
        body:
            FinishLessonSessionRequest(validTurnCount: validTurnCount).toJson(),
        failureMessageForResponse: _lessonFinishFailureMessage,
      );
      final summaryResult = await loadLessonSummary(sessionId: normalizedId);
      return summaryResult;
    } on ApiException catch (error) {
      return _safeLessonCompletionResult(error);
    } catch (_) {
      return LessonCompletionResult.failed();
    }
  }

  Future<LessonCompletionResult> loadLessonSummary({
    required String sessionId,
  }) async {
    final normalizedId = sessionId.trim();
    if (normalizedId.isEmpty) return LessonCompletionResult.failed();
    try {
      final response = await _authenticatedGet(
        '/api/me/lesson-sessions/$normalizedId/summary',
        failureMessageForResponse: _lessonSummaryFailureMessage,
      );
      final summary =
          LessonSummaryResponse.fromJson(_decodeObject(response.body));
      if (summary.isReady) return LessonCompletionResult.summaryReady(summary);
      if (summary.isUnavailable) {
        return LessonCompletionResult.summaryUnavailable();
      }
      return LessonCompletionResult.summaryLoadError();
    } on ApiException catch (error) {
      return _safeLessonSummaryResult(error);
    } catch (_) {
      return LessonCompletionResult.summaryLoadError();
    }
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
      throw const ApiException(
          'Could not request password reset. Please try again.');
    }
  }

  Future<String> confirmPasswordReset(String token, String newPassword) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/password-reset/confirm',
        body:
            PasswordResetConfirmRequest(token: token, newPassword: newPassword)
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

  Future<ApiResponse> _authenticatedGet(
    String path, {
    String Function(ApiResponse response)? failureMessageForResponse,
  }) async {
    return _authenticatedSend(
      path,
      (token) => _apiClient.get(path, accessToken: token),
      failureMessageForResponse: failureMessageForResponse,
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

  Future<ApiResponse> _authenticatedPostWithoutBody(
    String path, {
    String Function(ApiResponse response)? failureMessageForResponse,
  }) async {
    return _authenticatedSend(
      path,
      (token) => _apiClient.post(path, accessToken: token),
      failureMessageForResponse: failureMessageForResponse,
    );
  }

  Future<ApiResponse> _authenticatedPut(
    String path, {
    required Map<String, dynamic> body,
    String Function(ApiResponse response)? failureMessageForResponse,
  }) async {
    return _authenticatedSend(
      path,
      (token) => _apiClient.put(path, body: body, accessToken: token),
      failureMessageForResponse: failureMessageForResponse,
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
    if (body.contains('delivery') ||
        body.contains('email') && body.contains('configured')) {
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

  static String _lessonSessionStartFailureMessage(ApiResponse response) {
    if (response.statusCode == 401) {
      return 'Please sign in again to start a lesson.';
    }
    if (response.statusCode >= 500) {
      return 'Could not start the lesson. Please check your connection and try again.';
    }

    final code = _lessonSessionErrorCode(response.body);
    if (code == 'lesson_access_denied') {
      return 'You have used today\'s free lesson. Please try again tomorrow or upgrade.';
    }
    if (code == 'active_lesson_exists') {
      return 'You already have an active lesson. Finish or leave it before starting a new one.';
    }
    return 'Could not start the lesson. Please try again.';
  }

  static String _lessonRuntimeScenarioFailureMessage(ApiResponse response) {
    if (response.statusCode == 401) {
      return 'Please sign in again to continue the lesson.';
    }
    if (response.statusCode == 404) {
      return 'Lesson content is unavailable right now.';
    }
    if (response.statusCode >= 500) {
      return 'Could not load lesson content. Please check your connection and try again.';
    }
    return 'Could not load lesson content. Please try again.';
  }

  static String _lessonChatReplyFailureMessage(ApiResponse response) {
    if (response.statusCode == 400) {
      return 'Please enter a message.';
    }
    if (response.statusCode == 401) {
      return 'Please sign in again to continue the lesson.';
    }
    if (response.statusCode == 404) {
      return 'This lesson session is no longer available.';
    }
    if (response.statusCode == 429) {
      return 'You have used today\'s free lesson. Please try again tomorrow or upgrade.';
    }
    if (response.statusCode >= 500) {
      return 'Could not send the message. Please check your connection and try again.';
    }

    final code = _lessonSessionErrorCode(response.body);
    if (code == 'lesson_ended' ||
        code == 'lesson_session_ended' ||
        code == 'session_conflict') {
      return 'This lesson has already ended.';
    }
    if (response.statusCode == 409) {
      return 'This lesson has already ended.';
    }
    return 'Could not send the message. Please try again.';
  }

  static String _lessonChatHintFailureMessage(ApiResponse response) {
    if (response.statusCode == 401) {
      return 'Please sign in again to continue the lesson.';
    }
    if (response.statusCode == 404) {
      return 'This lesson session is no longer available.';
    }
    if (response.statusCode == 429) {
      return 'Hint is temporarily unavailable. Please try again shortly.';
    }
    final code = _lessonSessionErrorCode(response.body);
    if (code == 'lesson_ended' ||
        code == 'lesson_session_ended' ||
        code == 'session_conflict' ||
        response.statusCode == 409) {
      return 'This lesson has already ended.';
    }
    if (response.statusCode >= 500) {
      return 'Could not get a hint. Please check your connection and try again.';
    }
    return 'Could not get a hint. Please try again.';
  }

  static String _lessonSessionMessageFailureMessage(ApiResponse response) {
    if (response.statusCode == 401) {
      return 'Please sign in again to continue the lesson.';
    }
    if (response.statusCode == 404 || response.statusCode == 409) {
      return 'This lesson session is no longer available.';
    }
    if (response.statusCode >= 500) {
      return 'Could not save the message right now.';
    }
    return 'Could not save the message right now.';
  }

  static String _lessonFinishFailureMessage(ApiResponse response) {
    if (response.statusCode == 401) {
      return 'Please sign in again to finish the lesson.';
    }
    if (response.statusCode == 404 || response.statusCode == 403) {
      return 'This lesson session is no longer available.';
    }
    if (response.statusCode >= 500) {
      return 'Could not finish the lesson. Please check your connection and try again.';
    }
    return 'Could not finish the lesson. Please check your connection and try again.';
  }

  static String _lessonAbandonFailureMessage(ApiResponse response) {
    if (response.statusCode == 401) {
      return 'Please sign in again to continue the lesson.';
    }
    if (response.statusCode >= 500) {
      return 'Could not leave the lesson. Please check your connection and try again.';
    }
    return 'Could not leave the lesson. Please try again.';
  }

  static String _lessonSummaryFailureMessage(ApiResponse response) {
    if (response.statusCode == 401) {
      return 'Please sign in again to finish the lesson.';
    }
    if (response.statusCode == 404 || response.statusCode == 403) {
      return 'This lesson session is no longer available.';
    }
    if (response.statusCode >= 500) {
      return 'The summary is unavailable right now.';
    }
    return 'The summary is unavailable right now.';
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

  static LessonSessionStartResult _safeLessonSessionStartResult(
      ApiException error) {
    if (error.message == 'Please sign in again.' ||
        error.message == 'Please sign in again to start a lesson.') {
      return LessonSessionStartResult.authRequired();
    }
    if (error.message ==
        'You have used today\'s free lesson. Please try again tomorrow or upgrade.') {
      return LessonSessionStartResult.blocked();
    }
    if (error.message ==
        'You already have an active lesson. Finish or leave it before starting a new one.') {
      return LessonSessionStartResult.conflict();
    }
    if (error.message ==
            'Could not start the lesson. Please check your connection and try again.' ||
        error.message == 'The service took too long to respond.' ||
        error.message == 'Unable to reach the service.') {
      return LessonSessionStartResult.unavailable();
    }
    return LessonSessionStartResult.failed();
  }

  static LessonSessionAbandonResult _safeLessonSessionAbandonResult(
    ApiException error,
  ) {
    if (error.message == 'Please sign in again.' ||
        error.message == 'Please sign in again to continue the lesson.') {
      return LessonSessionAbandonResult.authRequired();
    }
    if (error.message ==
            'Could not leave the lesson. Please check your connection and try again.' ||
        error.message == 'The service took too long to respond.' ||
        error.message == 'Unable to reach the service.') {
      return LessonSessionAbandonResult.unavailable();
    }
    return LessonSessionAbandonResult.failed();
  }

  static LessonChatReplyResult _safeLessonChatReplyResult(ApiException error) {
    if (error.message == 'Please enter a message.') {
      return LessonChatReplyResult.validation();
    }
    if (error.message == 'Please sign in again.' ||
        error.message == 'Please sign in again to continue the lesson.') {
      return LessonChatReplyResult.authRequired();
    }
    if (error.message == 'This lesson session is no longer available.') {
      return LessonChatReplyResult.notFound();
    }
    if (error.message == 'This lesson has already ended.') {
      return LessonChatReplyResult.conflict();
    }
    if (error.message ==
        'You have used today\'s free lesson. Please try again tomorrow or upgrade.') {
      return LessonChatReplyResult.limited();
    }
    if (error.message ==
            'Could not send the message. Please check your connection and try again.' ||
        error.message == 'The service took too long to respond.' ||
        error.message == 'Unable to reach the service.') {
      return LessonChatReplyResult.unavailable();
    }
    return LessonChatReplyResult.failed();
  }

  static LessonChatHintResult _safeLessonChatHintResult(ApiException error) {
    if (error.message == 'Please sign in again.' ||
        error.message == 'Please sign in again to continue the lesson.') {
      return LessonChatHintResult.authRequired();
    }
    if (error.message == 'This lesson session is no longer available.') {
      return LessonChatHintResult.notFound();
    }
    if (error.message == 'This lesson has already ended.') {
      return LessonChatHintResult.conflict();
    }
    if (error.message ==
        'Hint is temporarily unavailable. Please try again shortly.') {
      return LessonChatHintResult.limited();
    }
    if (error.message ==
            'Could not get a hint. Please check your connection and try again.' ||
        error.message == 'The service took too long to respond.' ||
        error.message == 'Unable to reach the service.') {
      return LessonChatHintResult.unavailable();
    }
    return LessonChatHintResult.failed();
  }

  static LessonCompletionResult _safeLessonCompletionResult(
      ApiException error) {
    if (error.message == 'Please sign in again.' ||
        error.message == 'Please sign in again to finish the lesson.') {
      return LessonCompletionResult.authRequired();
    }
    if (error.message == 'This lesson session is no longer available.') {
      return LessonCompletionResult.notFound();
    }
    if (error.message ==
            'Could not finish the lesson. Please check your connection and try again.' ||
        error.message == 'The summary is unavailable right now.' ||
        error.message == 'The service took too long to respond.' ||
        error.message == 'Unable to reach the service.') {
      return LessonCompletionResult.unavailable();
    }
    return LessonCompletionResult.failed();
  }

  static LessonCompletionResult _safeLessonSummaryResult(ApiException error) {
    if (error.message == 'Please sign in again.' ||
        error.message == 'Please sign in again to finish the lesson.') {
      return LessonCompletionResult.authRequired();
    }
    // Only a successful response with status == "unavailable" is allowed to
    // enter the completed-safe unavailable state. HTTP and transport failures
    // remain retryable summary-load errors without exposing server details.
    return LessonCompletionResult.summaryLoadError();
  }

  static String _lessonSessionErrorCode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return '';
      return _jsonString(decoded, 'code',
          fallback: _jsonString(decoded, 'errorCode',
              fallback: _jsonString(decoded, 'error')));
    } catch (_) {
      return '';
    }
  }

  static String _jsonString(Map<String, dynamic> json, String key,
      {String fallback = ''}) {
    final value = json[key];
    return value is String ? value : fallback;
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
