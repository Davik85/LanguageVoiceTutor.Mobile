import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:language_voice_tutor_mobile/models/device_registration.dart';
import 'package:language_voice_tutor_mobile/services/device_activity_tracker.dart';
import 'package:language_voice_tutor_mobile/services/device_metadata.dart';
import '../support/tracking_fakes.dart';

class _ManualTimer implements Timer {
  _ManualTimer(this.callback);
  final void Function(Timer) callback;
  @override
  bool isActive = true;
  @override
  int tick = 0;
  @override
  void cancel() {
    isActive = false;
  }

  void fire() {
    if (isActive) {
      tick++;
      callback(this);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ValueNotifier<String?> user;
  late FakeDeviceMetadata metadata;
  late List<String> calls;
  late DateTime now;
  late List<_ManualTimer> timers;
  late DeviceActivityTracker tracker;
  setUp(() {
    user = ValueNotifier(null);
    metadata = FakeDeviceMetadata();
    calls = [];
    now = DateTime.utc(2026, 10, 18);
    timers = [];
    tracker = DeviceActivityTracker(
        authenticatedUser: user,
        metadata: metadata,
        register: (user, request) async {
          calls.add(user);
        },
        now: () => now,
        periodicTimer: (duration, callback) {
          expect(duration, const Duration(minutes: 15));
          final timer = _ManualTimer(callback);
          timers.add(timer);
          return timer;
        });
  });
  tearDown(() {
    tracker.dispose();
    user.dispose();
  });

  test(
      'foreground resume and fifteen-minute timer update; background and logout cancel',
      () async {
    tracker.setForeground(true);
    expect(calls, isEmpty);
    expect(timers, isEmpty);
    user.value = 'a';
    await flushTracking();
    expect(calls, ['a']);
    now = now.add(const Duration(minutes: 15));
    timers.last.fire();
    await flushTracking();
    expect(calls, ['a', 'a']);
    tracker.setForeground(false);
    expect(timers.last.isActive, isFalse);
    now = now.add(const Duration(minutes: 15));
    timers.last.fire();
    await flushTracking();
    expect(calls.length, 2);
    tracker.setForeground(true);
    await flushTracking();
    expect(calls.length, 3);
    user.value = null;
    expect(timers.last.isActive, isFalse);
    now = now.add(const Duration(minutes: 15));
    timers.last.fire();
    await flushTracking();
    expect(calls.length, 3);
  });
  test('duplicate lifecycle signals and rapid resumes coalesce with one timer',
      () async {
    user.value = 'a';
    tracker.setForeground(true);
    await flushTracking();
    tracker.setForeground(true);
    tracker.setForeground(false);
    tracker.setForeground(true);
    await flushTracking();
    expect(calls, ['a']);
    expect(timers.where((t) => t.isActive).length, 1);
  });
  test(
      'parallel requests prevented, account switch during metadata schedules new account',
      () async {
    metadata.delayed = Completer<DeviceRegistrationRequest>();
    user.value = 'a';
    tracker.setForeground(true);
    await tracker.refresh();
    await tracker.refresh();
    user.value = 'b';
    metadata.delayed!.complete(const DeviceRegistrationRequest(
        deviceName: 'Example [id]', appVersion: '1+1'));
    await flushTracking();
    expect(calls, ['b']);
    expect(timers.where((t) => t.isActive).length, 1);
  });
  test('logout while metadata pending never sends request', () async {
    metadata.delayed = Completer<DeviceRegistrationRequest>();
    user.value = 'a';
    tracker.setForeground(true);
    user.value = null;
    metadata.delayed!.complete(const DeviceRegistrationRequest(
        deviceName: 'Example [id]', appVersion: '1'));
    await flushTracking();
    expect(calls, isEmpty);
  });
  test('metadata failures stay isolated and next interval can recover',
      () async {
    metadata.fail = true;
    user.value = 'a';
    tracker.setForeground(true);
    await flushTracking();
    expect(calls, isEmpty);
    expect(user.value, 'a');
    metadata.fail = false;
    now = now.add(const Duration(minutes: 15));
    timers.last.fire();
    await flushTracking();
    expect(calls, ['a']);
  });
  testWidgets('real timer fires at fifteen minutes, never during background',
      (tester) async {
    tracker.dispose();
    tracker = DeviceActivityTracker(
        authenticatedUser: user,
        metadata: metadata,
        register: (user, request) async {
          calls.add(user);
        },
        now: () => now);
    user.value = 'a';
    tracker.setForeground(true);
    await tester.pump();
    expect(calls.length, 1);
    now = now.add(const Duration(minutes: 14));
    await tester.pump(const Duration(minutes: 14));
    expect(calls.length, 1);
    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(calls.length, 2);
    tracker.setForeground(false);
    now = now.add(const Duration(hours: 1));
    await tester.pump(const Duration(hours: 1));
    expect(calls.length, 2);
  });

  const channel =
      MethodChannel('com.languagevoicetutor.mobile/device_metadata');
  test(
      'metadata uses installed package version, stable identity and distinct same-model installations',
      () async {
    var installation = '00000000-0000-4000-8000-000000000001';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getDeviceName');
      return 'Example Model [$installation]';
    });
    final provider = AndroidDeviceMetadata(
        packageInfo: () async => PackageInfo(
            appName: 'Orralen',
            packageName: 'com.languagevoicetutor.mobile',
            version: '7.8.9',
            buildNumber: '123'));
    final first = await provider.read();
    final second = await AndroidDeviceMetadata(
        packageInfo: () async => PackageInfo(
            appName: 'Orralen',
            packageName: 'p',
            version: '7.8.9',
            buildNumber: '124')).read();
    expect(first.deviceName, second.deviceName);
    expect(first.appVersion, '7.8.9+123');
    expect(second.appVersion, '7.8.9+124');
    installation = '00000000-0000-4000-8000-000000000002';
    expect((await provider.read()).deviceName, isNot(first.deviceName));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test(
      'optional package metadata failure uses stable fallback and bounds version',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (_) async =>
                'Example Model [00000000-0000-4000-8000-000000000001]');
    final provider = AndroidDeviceMetadata(
        packageInfo: () async => throw StateError('unavailable'));
    expect((await provider.read()).appVersion, 'Unknown');
    final longVersion = AndroidDeviceMetadata(
        packageInfo: () async => PackageInfo(
            appName: 'Orralen',
            packageName: 'p',
            version: 'x' * 100,
            buildNumber: '1'));
    expect((await longVersion.read()).appVersion.length, 64);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test(
      'missing identity fails safely rather than sharing a model-only backend row',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    await expectLater(AndroidDeviceMetadata().read(), throwsFormatException);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
