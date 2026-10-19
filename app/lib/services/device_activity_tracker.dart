import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/device_registration.dart';
import 'device_metadata.dart';

/// One instance at application scope. Operational metadata is independent of
/// optional analytics. Failed attempts are throttled, with no retry loop.
class DeviceActivityTracker {
  DeviceActivityTracker({
    required ValueListenable<String?> authenticatedUser,
    required DeviceMetadata metadata,
    required Future<void> Function(String, DeviceRegistrationRequest) register,
    DateTime Function()? now,
    Timer Function(Duration, void Function(Timer))? periodicTimer,
  })  : _user = authenticatedUser,
        _metadata = metadata,
        _register = register,
        _now = now ?? DateTime.now,
        _periodicTimer = periodicTimer ?? Timer.periodic {
    _user.addListener(_sessionChanged);
  }
  static const refreshInterval = Duration(minutes: 15);
  static const minimumInterval = Duration(minutes: 1);
  final ValueListenable<String?> _user;
  final DeviceMetadata _metadata;
  final Future<void> Function(String, DeviceRegistrationRequest) _register;
  final DateTime Function() _now;
  final Timer Function(Duration, void Function(Timer)) _periodicTimer;
  Timer? _timer;
  bool _foreground = false;
  bool _disposed = false;
  bool _inFlight = false;
  String? _lastUser;
  DateTime? _lastAttempt;
  int _generation = 0;

  bool get isForeground => _foreground && !_disposed;

  void setForeground(bool foreground) {
    if (_disposed || _foreground == foreground) return;
    _foreground = foreground;
    _restart();
  }

  void _sessionChanged() {
    _generation++;
    _lastAttempt = null;
    _lastUser = null;
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _timer = null;
    if (!_foreground || _user.value == null || _disposed) return;
    unawaited(refresh());
    _timer = _periodicTimer(refreshInterval, (_) => unawaited(refresh()));
  }

  Future<void> refresh() async {
    final user = _user.value;
    if (_disposed || !_foreground || user == null || _inFlight) return;
    final now = _now();
    if (_lastUser == user &&
        _lastAttempt != null &&
        now.difference(_lastAttempt!) < minimumInterval) {
      return;
    }
    final generation = _generation;
    _inFlight = true;
    _lastUser = user;
    _lastAttempt = now;
    try {
      final request =
          await _metadata.read().timeout(const Duration(seconds: 5));
      if (_disposed ||
          !_foreground ||
          generation != _generation ||
          _user.value != user) {
        return;
      }
      await _register(user, request);
    } catch (_) {
      // Never changes authentication, lessons, billing or navigation.
    } finally {
      _inFlight = false;
      // An account switch during a request schedules the new account once.
      if (!_disposed &&
          _foreground &&
          _user.value != null &&
          generation != _generation) {
        unawaited(refresh());
      }
    }
  }

  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    _user.removeListener(_sessionChanged);
  }
}
