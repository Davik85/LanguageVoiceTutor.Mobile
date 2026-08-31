import 'package:flutter/services.dart';

enum RestoreCredentialPlatformStatus {
  success,
  unavailable,
  unsupported,
  noCredential,
  e2eeUnavailable,
  localOnly,
  invalid,
  failed,
}

class RestoreCredentialPlatformResult {
  const RestoreCredentialPlatformResult(this.status, {this.responseJson});

  final RestoreCredentialPlatformStatus status;
  final String? responseJson;

  bool get isSuccess =>
      status == RestoreCredentialPlatformStatus.success ||
      status == RestoreCredentialPlatformStatus.localOnly;
}

abstract class RestoreCredentialsPlatform {
  Future<RestoreCredentialPlatformResult> createRestoreCredential(
      String requestJson, bool isCloudBackupEnabled);
  Future<RestoreCredentialPlatformResult> getRestoreCredential(
      String requestJson);
  Future<RestoreCredentialPlatformResult> clearRestoreCredential();
}

class MethodChannelRestoreCredentialsPlatform
    implements RestoreCredentialsPlatform {
  MethodChannelRestoreCredentialsPlatform({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName =
      'com.languagevoicetutor.mobile/restore_credentials';
  final MethodChannel _channel;

  @override
  Future<RestoreCredentialPlatformResult> createRestoreCredential(
          String requestJson, bool isCloudBackupEnabled) =>
      _invoke('createRestoreCredential', {
        'requestJson': requestJson,
        'isCloudBackupEnabled': isCloudBackupEnabled,
      });

  @override
  Future<RestoreCredentialPlatformResult> getRestoreCredential(
          String requestJson) =>
      _invoke('getRestoreCredential', {'requestJson': requestJson});

  @override
  Future<RestoreCredentialPlatformResult> clearRestoreCredential() =>
      _invoke('clearRestoreCredential', const <String, Object?>{});

  Future<RestoreCredentialPlatformResult> _invoke(
      String method, Map<String, Object?> arguments) async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>(method, arguments);
      final category = result?['status'];
      RestoreCredentialPlatformStatus? status;
      for (final value in RestoreCredentialPlatformStatus.values) {
        if (value.name == category) {
          status = value;
          break;
        }
      }
      return RestoreCredentialPlatformResult(
          status ?? RestoreCredentialPlatformStatus.failed,
          responseJson: result?['responseJson'] as String?);
    } on PlatformException {
      return const RestoreCredentialPlatformResult(
          RestoreCredentialPlatformStatus.unavailable);
    } catch (_) {
      return const RestoreCredentialPlatformResult(
          RestoreCredentialPlatformStatus.failed);
    }
  }
}
