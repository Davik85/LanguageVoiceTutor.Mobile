import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../config/app_config.dart';
import '../services/backend_health_service.dart';

enum BackendConnectionState { notChecked, checking, connected, unavailable }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, BackendHealthService? healthService})
      : _healthService = healthService;

  static const String routeName = '/settings';

  final BackendHealthService? _healthService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final BackendHealthService _healthService;
  BackendConnectionState _connectionState = BackendConnectionState.notChecked;

  @override
  void initState() {
    super.initState();
    _healthService = widget._healthService ??
        BackendHealthService(apiClient: HttpApiClient());
  }

  Future<void> _checkBackendConnection() async {
    setState(() => _connectionState = BackendConnectionState.checking);

    try {
      await _healthService.checkHealth();
      if (!mounted) return;
      setState(() => _connectionState = BackendConnectionState.connected);
    } catch (_) {
      if (!mounted) return;
      setState(() => _connectionState = BackendConnectionState.unavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Placeholder settings screen'),
            const SizedBox(height: 12),
            const Text('App name: ${AppConfig.appName}'),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend connection',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_connectionLabel),
                    const SizedBox(height: 8),
                    Text(_connectionMessage),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _connectionState ==
                              BackendConnectionState.checking
                          ? null
                          : _checkBackendConnection,
                      child: const Text('Check connection'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No secrets, auth tokens, billing keys, or analytics are configured.',
            ),
          ],
        ),
      ),
    );
  }

  String get _connectionLabel {
    switch (_connectionState) {
      case BackendConnectionState.notChecked:
        return 'Not checked';
      case BackendConnectionState.checking:
        return 'Checking...';
      case BackendConnectionState.connected:
        return 'Connected';
      case BackendConnectionState.unavailable:
        return 'Unavailable';
    }
  }

  String get _connectionMessage {
    switch (_connectionState) {
      case BackendConnectionState.notChecked:
        return 'Tap the button to confirm the app can reach the Language Voice Tutor service.';
      case BackendConnectionState.checking:
        return 'Checking the service now.';
      case BackendConnectionState.connected:
        return 'The app can reach the Language Voice Tutor service.';
      case BackendConnectionState.unavailable:
        return 'The service is unavailable right now. Please try again later.';
    }
  }
}
