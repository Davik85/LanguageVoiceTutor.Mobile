import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class RestoreCredentialsState {
  Future<String?> readSyncedUserId();
  Future<void> setSyncedUserId(String userId);
  Future<void> clearSyncedUserId();
  Future<bool> isAutomaticRestoreSuppressed();
  Future<void> setAutomaticRestoreSuppressed(bool suppressed);
}

class SecureRestoreCredentialsState implements RestoreCredentialsState {
  SecureRestoreCredentialsState({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _syncedUserIdKey = 'lvt_restore_credential_synced_user_id';
  static const _suppressedKey = 'lvt_restore_credential_suppressed';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readSyncedUserId() => _storage.read(key: _syncedUserIdKey);
  @override
  Future<void> setSyncedUserId(String userId) =>
      _storage.write(key: _syncedUserIdKey, value: userId);
  @override
  Future<void> clearSyncedUserId() => _storage.delete(key: _syncedUserIdKey);
  @override
  Future<bool> isAutomaticRestoreSuppressed() async =>
      (await _storage.read(key: _suppressedKey)) == 'true';
  @override
  Future<void> setAutomaticRestoreSuppressed(bool suppressed) =>
      _storage.write(key: _suppressedKey, value: suppressed ? 'true' : 'false');
}
