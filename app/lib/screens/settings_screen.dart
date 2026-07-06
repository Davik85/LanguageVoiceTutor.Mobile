import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/auth_models.dart';
import '../models/subscription_status.dart';
import '../services/auth_service.dart';
import '../services/backend_health_service.dart';
import '../services/service_factory.dart';
import 'login_screen.dart';

enum BackendConnectionState { notChecked, checking, connected, unavailable }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, BackendHealthService? healthService, AuthService? authService})
      : _healthService = healthService,
        _authService = authService;

  static const String routeName = '/settings';

  final BackendHealthService? _healthService;
  final AuthService? _authService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final BackendHealthService _healthService;
  late final AuthService _authService;
  BackendConnectionState _connectionState = BackendConnectionState.notChecked;
  AuthUser? _user;
  SubscriptionStatus? _subscription;
  String? _accountError;

  @override
  void initState() {
    super.initState();
    _healthService = widget._healthService ?? BackendHealthService(apiClient: HttpApiClient());
    _authService = widget._authService ?? createAuthService();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final user = await _authService.loadCurrentUser();
      final subscription = await _authService.fetchSubscriptionStatus();
      if (!mounted) return;
      setState(() { _user = user; _subscription = subscription; _accountError = null; });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Please sign in again.') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (_) => false,
        );
        return;
      }
      setState(() => _accountError = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _accountError = 'Unable to load account details right now.');
    }
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

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Backend connection', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_connectionLabel),
            const SizedBox(height: 8),
            Text(_connectionMessage),
            const SizedBox(height: 12),
            FilledButton(onPressed: _connectionState == BackendConnectionState.checking ? null : _checkBackendConnection, child: const Text('Check connection')),
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Account', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_user == null && _accountError == null) const Text('Loading account...') else if (_user != null) ...[
              Text(_user!.displayName?.isNotEmpty == true ? _user!.displayName! : 'No display name'),
              Text(_user!.email),
            ] else Text(_accountError!),
          ]))),
          const SizedBox(height: 12),
          SubscriptionStatusCard(subscription: _subscription, error: _accountError),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: _logout, child: const Text('Logout')),
          const SizedBox(height: 12),
          const Text('Auth tokens are stored securely and are never shown here.'),
        ],
      ),
    );
  }

  String get _connectionLabel => switch (_connectionState) { BackendConnectionState.notChecked => 'Not checked', BackendConnectionState.checking => 'Checking...', BackendConnectionState.connected => 'Connected', BackendConnectionState.unavailable => 'Unavailable' };
  String get _connectionMessage => switch (_connectionState) { BackendConnectionState.notChecked => 'Tap the button to confirm the app can reach the Language Voice Tutor service.', BackendConnectionState.checking => 'Checking the service now.', BackendConnectionState.connected => 'The app can reach the Language Voice Tutor service.', BackendConnectionState.unavailable => 'The service is unavailable right now. Please try again later.' };
}

class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({super.key, required this.subscription, this.error});

  final SubscriptionStatus? subscription;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Subscription', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (subscription == null && error == null) const Text('Loading subscription...') else if (subscription != null) ...[
        Text(subscription!.displayLabel),
        Text(subscription!.planName ?? subscription!.currentTariffName ?? 'No paid plan'),
        Text('Free lessons remaining today: ${subscription!.freeLessonRemainingToday}'),
      ] else Text(error!),
    ])));
  }
}
