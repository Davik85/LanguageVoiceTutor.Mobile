import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/auth_models.dart';
import '../models/subscription_status.dart';
import '../models/tutor_options.dart';
import '../models/user_settings.dart';
import '../services/auth_service.dart';
import '../services/backend_health_service.dart';
import '../services/service_factory.dart';
import '../services/tutor_options_service.dart';
import 'login_screen.dart';

enum BackendConnectionState { notChecked, checking, connected, unavailable }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    BackendHealthService? healthService,
    AuthService? authService,
    TutorOptionsService? tutorOptionsService,
  })  : _healthService = healthService,
        _authService = authService,
        _tutorOptionsService = tutorOptionsService;

  static const String routeName = '/settings';

  final BackendHealthService? _healthService;
  final AuthService? _authService;
  final TutorOptionsService? _tutorOptionsService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _studyLanguages = [
    'English',
    'French',
    'German',
    'Portuguese',
    'Spanish',
    'Italian',
  ];
  static const _interfaceLanguages = ['English', 'Spanish', 'French', 'German'];
  static const _voices = ['alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer'];

  late final BackendHealthService _healthService;
  late final AuthService _authService;
  late final TutorOptionsService _tutorOptionsService;
  BackendConnectionState _connectionState = BackendConnectionState.notChecked;
  AuthUser? _user;
  SubscriptionStatus? _subscription;
  UserSettings? _settings;
  TutorOptions? _tutorOptions;
  String? _accountError;
  String? _settingsError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _healthService = widget._healthService ??
        BackendHealthService(apiClient: HttpApiClient());
    _authService = widget._authService ?? createAuthService();
    _tutorOptionsService = widget._tutorOptionsService ??
        TutorOptionsService(apiClient: HttpApiClient());
    _loadAccount();
    _loadSettings();
  }

  Future<void> _loadAccount() async {
    try {
      final user = await _authService.loadCurrentUser();
      final subscription = await _authService.fetchSubscriptionStatus();
      if (!mounted) return;
      setState(() {
        _user = user;
        _subscription = subscription;
        _accountError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Please sign in again.') return _goToLogin();
      setState(
          () => _accountError = 'Unable to load account details right now.');
    } catch (_) {
      if (!mounted) return;
      setState(
          () => _accountError = 'Unable to load account details right now.');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final results = await Future.wait<dynamic>([
        _authService.fetchUserSettings(),
        _tutorOptionsService.fetchTutorOptions(),
      ]);
      if (!mounted) return;
      setState(() {
        _settings = results[0] as UserSettings;
        _tutorOptions = results[1] as TutorOptions;
        _settingsError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Please sign in again.') return _goToLogin();
      setState(() => _settingsError = 'Unable to load settings right now.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _settingsError = 'Unable to load settings right now.');
    }
  }

  Future<void> _saveSettings() async {
    final settings = _settings;
    if (settings == null) return;
    setState(() => _isSaving = true);
    try {
      final saved = await _authService.updateUserSettings(settings);
      if (!mounted) return;
      setState(() {
        _settings = saved;
        _settingsError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Please sign in again.') return _goToLogin();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save settings right now.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save settings right now.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
    _goToLogin();
  }

  void _goToLogin() => Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (_) => false,
      );

  void _updateSettings(UserSettings settings) =>
      setState(() => _settings = settings);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _AccountCard(
            user: _user,
            subscription: _subscription,
            error: _accountError,
            onLogout: _logout,
          ),
          const SizedBox(height: 12),
          _LearningCard(
            settings: _settings,
            tutorOptions: _tutorOptions,
            error: _settingsError,
            studyLanguages: _studyLanguages,
            interfaceLanguages: _interfaceLanguages,
            voices: _voices,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: 12),
          _AudioCard(settings: _settings, onChanged: _updateSettings),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _settings == null || _isSaving ? null : _saveSettings,
            child: Text(_isSaving ? 'Saving...' : 'Save settings'),
          ),
          const SizedBox(height: 12),
          _DiagnosticsCard(
            connectionLabel: _connectionLabel,
            connectionMessage: _connectionMessage,
            checking: _connectionState == BackendConnectionState.checking,
            onCheck: _checkBackendConnection,
          ),
          const SizedBox(height: 12),
          const Text(
              'Auth tokens are stored securely and are never shown here.'),
        ],
      ),
    );
  }

  String get _connectionLabel => switch (_connectionState) {
        BackendConnectionState.notChecked => 'Not checked',
        BackendConnectionState.checking => 'Checking...',
        BackendConnectionState.connected => 'Connected',
        BackendConnectionState.unavailable => 'Unavailable'
      };
  String get _connectionMessage => switch (_connectionState) {
        BackendConnectionState.notChecked =>
          'Tap the button to confirm the app can reach the Language Voice Tutor service.',
        BackendConnectionState.checking => 'Checking the service now.',
        BackendConnectionState.connected =>
          'The app can reach the Language Voice Tutor service.',
        BackendConnectionState.unavailable =>
          'The service is unavailable right now. Please try again later.'
      };
}

class _AccountCard extends StatelessWidget {
  const _AccountCard(
      {this.user, this.subscription, this.error, required this.onLogout});
  final AuthUser? user;
  final SubscriptionStatus? subscription;
  final String? error;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Account', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (user == null && error == null)
              const Text('Loading account...')
            else if (user != null) ...[
              Text(user!.displayName?.isNotEmpty == true
                  ? user!.displayName!
                  : 'No display name'),
              Text(user!.email),
              const SizedBox(height: 8),
              Text(subscription?.displayLabel ?? 'Subscription unavailable'),
              Text(subscription?.planName ??
                  subscription?.currentTariffName ??
                  'No paid plan'),
            ] else
              Text(error!),
            const SizedBox(height: 12),
            FilledButton.tonal(
                onPressed: onLogout, child: const Text('Logout')),
          ])));
}

class _LearningCard extends StatelessWidget {
  const _LearningCard(
      {required this.settings,
      required this.tutorOptions,
      required this.error,
      required this.studyLanguages,
      required this.interfaceLanguages,
      required this.voices,
      required this.onChanged});
  final UserSettings? settings;
  final TutorOptions? tutorOptions;
  final String? error;
  final List<String> studyLanguages;
  final List<String> interfaceLanguages;
  final List<String> voices;
  final ValueChanged<UserSettings> onChanged;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Learning', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (settings == null && error == null)
              const Text('Loading settings...')
            else if (settings == null)
              Text(error!)
            else ...[
              _Dropdown(
                  label: 'Study language',
                  value: settings!.studyLanguage,
                  values: studyLanguages,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(studyLanguage: v))),
              _Dropdown(
                  label: 'Native language',
                  value: settings!.nativeLanguage,
                  values: interfaceLanguages,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(nativeLanguage: v))),
              _Dropdown(
                  label: 'Interface / explanation language',
                  value: settings!.explanationLanguage,
                  values: interfaceLanguages,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(explanationLanguage: v))),
              const SizedBox(height: 8),
              Text('Tutor avatar / available tutors',
                  style: Theme.of(context).textTheme.labelLarge),
              Text(tutorOptions?.activeTutors.map((t) => t.label).join(', ') ??
                  'Loading tutors...'),
              const Text(
                  'Selected tutor persistence is not available in the current settings API yet.'),
              _Dropdown(
                  label: 'Tutor voice',
                  value: settings!.speechVoice,
                  values: voices,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(speechVoice: v))),
            ],
          ])));
}

class _AudioCard extends StatelessWidget {
  const _AudioCard({required this.settings, required this.onChanged});
  final UserSettings? settings;
  final ValueChanged<UserSettings> onChanged;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Audio', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (settings == null)
              const Text('Loading audio settings...')
            else ...[
              Text(
                  'Speech speed: ${settings!.speechSpeed.toStringAsFixed(1)}x'),
              Slider(
                  value: settings!.speechSpeed.clamp(0.5, 2.0),
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: settings!.speechSpeed.toStringAsFixed(1),
                  onChanged: (v) => onChanged(settings!.copyWith(
                      speechSpeed: double.parse(v.toStringAsFixed(1))))),
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Conversation mode enabled'),
                  value: settings!.conversationModeEnabled,
                  onChanged: (v) => onChanged(
                      settings!.copyWith(conversationModeEnabled: v))),
            ],
          ])));
}

class _DiagnosticsCard extends StatelessWidget {
  const _DiagnosticsCard(
      {required this.connectionLabel,
      required this.connectionMessage,
      required this.checking,
      required this.onCheck});
  final String connectionLabel;
  final String connectionMessage;
  final bool checking;
  final VoidCallback onCheck;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Backend diagnostics',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(connectionLabel),
            const SizedBox(height: 8),
            Text(connectionMessage),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: checking ? null : onCheck,
                child: const Text('Check connection')),
          ])));
}

class _Dropdown extends StatelessWidget {
  const _Dropdown(
      {required this.label,
      required this.value,
      required this.values,
      required this.onChanged});
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final items = {...values, if (value.isNotEmpty) value}.toList();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      initialValue: value.isEmpty ? null : value,
      items:
          items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
