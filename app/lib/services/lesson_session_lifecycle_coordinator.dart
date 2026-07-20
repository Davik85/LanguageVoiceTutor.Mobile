import 'dart:async';

import '../models/lesson_session.dart';
import 'auth_service.dart';

/// Keeps the existing backend-owned active-session lease alive while a Mobile
/// lesson is open. The backend remains authoritative for expiry and status.
class LessonSessionLifecycleCoordinator {
  LessonSessionLifecycleCoordinator({
    required AuthService authService,
    Duration? heartbeatInterval,
  })  : _authService = authService,
        _heartbeatInterval = heartbeatInterval ??
            LessonSessionLifecycleCoordinator.heartbeatInterval;

  static const heartbeatInterval = Duration(seconds: 30);

  final AuthService _authService;
  final Duration _heartbeatInterval;
  Timer? _heartbeatTimer;
  String? _sessionId;
  bool _heartbeatInFlight = false;
  Future<LessonSessionAbandonResult>? _abandonOperation;

  void start(String sessionId) {
    if (_sessionId != null || !_isGuid(sessionId)) return;
    _sessionId = sessionId;
    unawaited(_sendHeartbeat());
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      unawaited(_sendHeartbeat());
    });
  }

  Future<void> stop() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _sessionId = null;
  }

  Future<LessonSessionAbandonResult> abandon() {
    final existing = _abandonOperation;
    if (existing != null) return existing;
    final sessionId = _sessionId;
    if (sessionId == null) {
      return Future.value(LessonSessionAbandonResult.failed());
    }
    _abandonOperation = _abandon(sessionId);
    return _abandonOperation!;
  }

  Future<LessonSessionAbandonResult> _abandon(String sessionId) async {
    await stop();
    return _authService.abandonLessonSession(sessionId: sessionId);
  }

  Future<void> _sendHeartbeat() async {
    final sessionId = _sessionId;
    if (sessionId == null || _heartbeatInFlight || _abandonOperation != null) {
      return;
    }
    _heartbeatInFlight = true;
    try {
      final result =
          await _authService.heartbeatLessonSession(sessionId: sessionId);
      if (result.isTerminal ||
          result.status == LessonSessionHeartbeatStatus.authRequired) {
        await stop();
      }
    } finally {
      _heartbeatInFlight = false;
    }
  }

  static bool _isGuid(String value) => RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(value.trim());
}
