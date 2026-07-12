import 'package:permission_handler/permission_handler.dart';

enum LearnerMicrophonePermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

abstract class LearnerMicrophonePermissionService {
  Future<LearnerMicrophonePermissionStatus> check();
  Future<LearnerMicrophonePermissionStatus> request();
  Future<bool> openSettings();
}

class PermissionHandlerLearnerMicrophonePermissionService
    implements LearnerMicrophonePermissionService {
  @override
  Future<LearnerMicrophonePermissionStatus> check() async =>
      _map(await Permission.microphone.status);

  @override
  Future<LearnerMicrophonePermissionStatus> request() async =>
      _map(await Permission.microphone.request());

  @override
  Future<bool> openSettings() => openAppSettings();

  LearnerMicrophonePermissionStatus _map(PermissionStatus status) {
    if (status.isGranted) {
      return LearnerMicrophonePermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return LearnerMicrophonePermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) {
      return LearnerMicrophonePermissionStatus.restricted;
    }
    return LearnerMicrophonePermissionStatus.denied;
  }
}
