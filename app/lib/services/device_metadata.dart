import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/device_registration.dart';

abstract class DeviceMetadata {
  Future<DeviceRegistrationRequest> read();
}

class AndroidDeviceMetadata implements DeviceMetadata {
  AndroidDeviceMetadata(
      {MethodChannel? channel, Future<PackageInfo> Function()? packageInfo})
      : _channel = channel ??
            const MethodChannel(
                'com.languagevoicetutor.mobile/device_metadata'),
        _packageInfo = packageInfo ?? PackageInfo.fromPlatform;
  final MethodChannel _channel;
  final Future<PackageInfo> Function() _packageInfo;

  @override
  Future<DeviceRegistrationRequest> read() async {
    // Native noBackupFilesDir stores the complete stable name, including a
    // random installation UUID. Failure skips tracking rather than merging rows.
    final name = await _channel.invokeMethod<String>('getDeviceName');
    if (name == null || name.trim().isEmpty || name.length > 128) {
      throw const FormatException('Device identity unavailable.');
    }
    var version = 'Unknown';
    try {
      final info = await _packageInfo();
      if (info.version.trim().isNotEmpty) {
        version = info.buildNumber.trim().isEmpty
            ? info.version.trim()
            : '${info.version.trim()}+${info.buildNumber.trim()}';
      }
    } catch (_) {}
    if (version.length > 64) version = version.substring(0, 64);
    return DeviceRegistrationRequest(deviceName: name, appVersion: version);
  }
}
