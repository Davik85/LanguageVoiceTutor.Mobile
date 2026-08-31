import 'dart:convert';

import '../api/api_client.dart';
import '../models/auth_models.dart';
import 'restore_credentials_platform.dart';
import 'restore_credentials_state.dart';
import 'session_storage.dart';

enum RestoreAuthenticationResult { restored, unavailable, noCredential, failed }

class RestoreCredentialsService {
  RestoreCredentialsService({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
    required RestoreCredentialsPlatform platform,
    required RestoreCredentialsState state,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage,
        _platform = platform,
        _state = state;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;
  final RestoreCredentialsPlatform _platform;
  final RestoreCredentialsState _state;

  Future<void> onManualAuthenticationSucceeded(AuthResponse auth) async {
    await _state.setAutomaticRestoreSuppressed(false);
    await syncForAuthenticatedUser(auth.user, auth.accessToken);
  }

  Future<void> syncForAuthenticatedUser(
      AuthUser user, String accessToken) async {
    if (user.userId.isEmpty ||
        accessToken.isEmpty ||
        await _state.readSyncedUserId() == user.userId) {
      return;
    }
    try {
      final options = await _apiClient.post(
        '/api/auth/restore-credentials/registration/options',
        accessToken: accessToken,
      );
      if (options.statusCode != 200) {
        return;
      }
      final ceremony = _ceremony(options.body);
      if (ceremony == null) {
        return;
      }
      final native = await _platform.createRestoreCredential(
          jsonEncode(ceremony.options), true);
      if (!native.isSuccess || native.responseJson == null) return;
      final credential = _jsonObject(native.responseJson!);
      if (credential == null) return;
      final verified = await _apiClient.post(
        '/api/auth/restore-credentials/registration/verify',
        accessToken: accessToken,
        body: {'ceremonyId': ceremony.id, 'credential': credential},
      );
      if (verified.statusCode == 204) {
        await _state.setSyncedUserId(user.userId);
      }
    } catch (_) {
      // Restore setup is strictly best effort after ordinary authentication.
    }
  }

  Future<RestoreAuthenticationResult> tryAutomaticRestore() async {
    if (await _state.isAutomaticRestoreSuppressed()) {
      return RestoreAuthenticationResult.noCredential;
    }
    try {
      final options = await _apiClient
          .post('/api/auth/restore-credentials/assertion/options');
      if (options.statusCode == 503) {
        return RestoreAuthenticationResult.unavailable;
      }
      if (options.statusCode != 200) return RestoreAuthenticationResult.failed;
      final ceremony = _ceremony(options.body);
      if (ceremony == null) return RestoreAuthenticationResult.failed;
      final native =
          await _platform.getRestoreCredential(jsonEncode(ceremony.options));
      if (!native.isSuccess || native.responseJson == null) {
        return native.status == RestoreCredentialPlatformStatus.noCredential ||
                native.status == RestoreCredentialPlatformStatus.unsupported ||
                native.status == RestoreCredentialPlatformStatus.unavailable
            ? RestoreAuthenticationResult.noCredential
            : RestoreAuthenticationResult.failed;
      }
      final credential = _jsonObject(native.responseJson!);
      if (credential == null) return RestoreAuthenticationResult.failed;
      final verified = await _apiClient.post(
        '/api/auth/restore-credentials/assertion/verify',
        body: {'ceremonyId': ceremony.id, 'credential': credential},
      );
      if (verified.statusCode != 200) {
        return RestoreAuthenticationResult.noCredential;
      }
      final auth =
          AuthResponse.fromJson(_jsonObject(verified.body) ?? const {});
      if (auth.accessToken.isEmpty ||
          auth.refreshToken.isEmpty ||
          auth.user.userId.isEmpty) {
        return RestoreAuthenticationResult.failed;
      }
      await _sessionStorage.saveTokens(
          accessToken: auth.accessToken, refreshToken: auth.refreshToken);
      await syncForAuthenticatedUser(auth.user, auth.accessToken);
      return RestoreAuthenticationResult.restored;
    } catch (_) {
      return RestoreAuthenticationResult.failed;
    }
  }

  Future<void> prepareForExplicitLogout() async {
    await _state.setAutomaticRestoreSuppressed(true);
    await _state.clearSyncedUserId();
    try {
      await _platform.clearRestoreCredential();
    } catch (_) {
      // Suppression remains in place even if native clearing is unavailable.
    }
  }

  _Ceremony? _ceremony(String body) {
    final json = _jsonObject(body);
    final id = json?['ceremonyId'];
    final options = json?['options'];
    return id is String && id.isNotEmpty && options is Map<String, dynamic>
        ? _Ceremony(id, options)
        : null;
  }
}

class _Ceremony {
  const _Ceremony(this.id, this.options);
  final String id;
  final Map<String, dynamic> options;
}

Map<String, dynamic>? _jsonObject(String source) {
  try {
    final value = jsonDecode(source);
    return value is Map<String, dynamic> ? value : null;
  } catch (_) {
    return null;
  }
}
