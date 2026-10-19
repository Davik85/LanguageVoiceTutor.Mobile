class DeviceRegistrationRequest {
  const DeviceRegistrationRequest(
      {required this.deviceName, required this.appVersion});
  final String deviceName;
  final String appVersion;
  Map<String, dynamic> toJson() => {
        'platform': 'Android',
        'deviceName': deviceName,
        'appVersion': appVersion,
      };
}

class DeviceRegistrationResponse {
  const DeviceRegistrationResponse(
      {required this.registered,
      required this.lastSeenAt,
      required this.trackingScope});
  final bool registered;
  final DateTime lastSeenAt;
  final String trackingScope;
  factory DeviceRegistrationResponse.fromJson(Map<String, dynamic> json) {
    if (json['registered'] is! bool ||
        json['lastSeenAt'] is! String ||
        json['trackingScope'] is! String) {
      throw const FormatException('Invalid device response.');
    }
    return DeviceRegistrationResponse(
        registered: json['registered'] as bool,
        lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
        trackingScope: json['trackingScope'] as String);
  }
}
