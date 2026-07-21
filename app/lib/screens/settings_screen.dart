import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/auth_models.dart';
import '../models/feedback_report.dart';
import '../models/language_option.dart';
import '../models/language_options.dart';
import '../models/lesson_start_selection.dart';
import '../models/subscription_status.dart';
import '../models/tutor_options.dart';
import '../models/user_settings.dart';
import '../services/auth_service.dart';
import '../services/backend_health_service.dart';
import '../services/service_factory.dart';
import '../services/tutor_options_service.dart';
import '../theme/app_visuals.dart';
import 'achievements_screen.dart';
import 'login_screen.dart';
import 'lesson_history_screen.dart';
import 'progress_screen.dart';

enum BackendConnectionState { notChecked, checking, connected, unavailable }

enum _SettingsSection { profile, lessons, app }

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
  static const _voices = ['alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer'];

  late final BackendHealthService _healthService;
  late final AuthService _authService;
  late final TutorOptionsService _tutorOptionsService;
  BackendConnectionState _connectionState = BackendConnectionState.notChecked;
  AuthUser? _user;
  SubscriptionStatus? _subscription;
  UserSettings? _settings;
  UserSettings? _confirmedSettings;
  TutorOptions? _tutorOptions;
  String? _tutorOptionsError;
  String? _accountError;
  String? _settingsError;
  bool _isSaving = false;
  final _resetEmailController = TextEditingController();
  final _resetCodeController = TextEditingController();
  final _resetNewPasswordController = TextEditingController();
  final _resetConfirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _changeNewPasswordController = TextEditingController();
  final _changeConfirmPasswordController = TextEditingController();
  String? _resetRequestMessage;
  String? _resetConfirmMessage;
  String? _changePasswordMessage;
  bool _isRequestingReset = false;
  bool _isConfirmingReset = false;
  bool _isChangingPassword = false;
  final _feedbackMessageController = TextEditingController();
  final _reportedAiTextController = TextEditingController();
  FeedbackReportCategory _feedbackCategory = FeedbackReportCategory.suggestion;
  bool _isSubmittingFeedback = false;
  String? _feedbackMessage;
  _SettingsSection _section = _SettingsSection.profile;

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

  @override
  void dispose() {
    _resetEmailController.dispose();
    _resetCodeController.dispose();
    _resetNewPasswordController.dispose();
    _resetConfirmPasswordController.dispose();
    _currentPasswordController.dispose();
    _changeNewPasswordController.dispose();
    _changeConfirmPasswordController.dispose();
    _feedbackMessageController.dispose();
    _reportedAiTextController.dispose();
    super.dispose();
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
      final settings = await _authService.fetchUserSettings();
      TutorOptions? tutorOptions;
      String? tutorOptionsError;
      try {
        tutorOptions = await _tutorOptionsService.fetchTutorOptions();
      } catch (_) {
        tutorOptionsError =
            'Tutor choices are unavailable right now. You can still review and save your other settings.';
      }
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _confirmedSettings = settings;
        _tutorOptions = tutorOptions;
        _tutorOptionsError = tutorOptionsError;
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
      final result = await _authService.updateUserSettings(
        _settingsWithSupportedTutor(settings),
      );
      if (!mounted) return;
      if (result.isSuccess && result.settings != null) {
        final saved = result.settings!;
        setState(() {
          _settings = saved;
          _confirmedSettings = saved;
          _settingsError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved.')),
        );
        return;
      }
      setState(() => _settings = _confirmedSettings);
      if (result.status == UserSettingsUpdateStatus.authenticationRequired) {
        return _goToLogin();
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _settings = _confirmedSettings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save settings right now.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _submitFeedback() async {
    final message = _feedbackMessageController.text.trim();
    if (message.isEmpty) {
      setState(() => _feedbackMessage = 'Please enter a description.');
      return;
    }
    setState(() {
      _isSubmittingFeedback = true;
      _feedbackMessage = null;
    });
    final result = await _authService.submitFeedbackReport(
        FeedbackReportRequest(
            category: _feedbackCategory,
            message: message,
            reportedAiText:
                _feedbackCategory == FeedbackReportCategory.aiResponse
                    ? _reportedAiTextController.text.trim()
                    : null,
            clientPlatform: 'android',
            clientVersion: '0.1.0+1'));
    if (!mounted) {
      return;
    }
    if (result.status == FeedbackReportSubmitStatus.authenticationRequired) {
      return _goToLogin();
    }
    setState(() {
      _isSubmittingFeedback = false;
      _feedbackMessage = result.message;
      if (result.status == FeedbackReportSubmitStatus.success) {
        _feedbackMessageController.clear();
        _reportedAiTextController.clear();
      }
    });
  }

  Future<void> _requestPasswordReset() async {
    if (_resetEmailController.text.trim().isEmpty) {
      setState(() => _resetRequestMessage = 'Email is required.');
      return;
    }
    setState(() {
      _isRequestingReset = true;
      _resetRequestMessage = null;
    });
    try {
      final message = await _authService
          .requestPasswordReset(_resetEmailController.text.trim());
      if (!mounted) return;
      setState(() => _resetRequestMessage = message);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _resetRequestMessage = error.message);
    } finally {
      if (mounted) setState(() => _isRequestingReset = false);
    }
  }

  Future<void> _confirmPasswordReset() async {
    if (_resetCodeController.text.trim().isEmpty ||
        _resetNewPasswordController.text.isEmpty) {
      setState(() =>
          _resetConfirmMessage = 'Reset code and new password are required.');
      return;
    }
    if (_resetNewPasswordController.text !=
        _resetConfirmPasswordController.text) {
      setState(() =>
          _resetConfirmMessage = 'New password and confirmation must match.');
      return;
    }
    setState(() {
      _isConfirmingReset = true;
      _resetConfirmMessage = null;
    });
    try {
      final message = await _authService.confirmPasswordReset(
        _resetCodeController.text.trim(),
        _resetNewPasswordController.text,
      );
      if (!mounted) return;
      setState(() => _resetConfirmMessage = message);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _resetConfirmMessage = error.message);
    } finally {
      if (mounted) setState(() => _isConfirmingReset = false);
    }
  }

  Future<void> _changePassword() async {
    if (_user == null) {
      setState(() =>
          _changePasswordMessage = 'Please sign in to change your password.');
      return;
    }
    if (_currentPasswordController.text.isEmpty) {
      setState(() => _changePasswordMessage = 'Current password is required.');
      return;
    }
    if (_changeNewPasswordController.text !=
        _changeConfirmPasswordController.text) {
      setState(() =>
          _changePasswordMessage = 'New password and confirmation must match.');
      return;
    }
    setState(() {
      _isChangingPassword = true;
      _changePasswordMessage = null;
    });
    try {
      final message = await _authService.changePassword(
        _currentPasswordController.text,
        _changeNewPasswordController.text,
        _changeConfirmPasswordController.text,
      );
      if (!mounted) return;
      setState(() => _changePasswordMessage = message);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _changePasswordMessage = error.message);
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
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

  UserSettings _settingsWithSupportedTutor(UserSettings settings) {
    final activeTutors = _tutorOptions?.activeTutors ?? const <TutorOption>[];
    if (activeTutors.isEmpty) return settings;
    final supportedIds = activeTutors.map((t) => t.tutorId).toSet();
    if (supportedIds.contains(settings.selectedTutorId)) return settings;
    return settings.copyWith(selectedTutorId: activeTutors.first.tutorId);
  }

  void _updateSettings(UserSettings settings) =>
      setState(() => _settings = settings);

  Future<void> _openLessonHistory() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonHistoryScreen(authService: _authService),
        ),
      );

  Future<void> _openProgress() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProgressScreen(authService: _authService),
        ),
      );

  Future<void> _openAchievements() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AchievementsScreen(authService: _authService),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AppVisuals.screenBackground(
        child: switch (_section) {
          _SettingsSection.profile => _profileContent(),
          _SettingsSection.lessons => _lessonsContent(),
          _SettingsSection.app => _appContent(),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _section.index,
        onDestinationSelected: (index) =>
            setState(() => _section = _SettingsSection.values[index]),
        destinations: const [
          NavigationDestination(
            key: Key('settings-profile-tab'),
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            key: Key('settings-lessons-tab'),
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Lessons',
          ),
          NavigationDestination(
            key: Key('settings-app-tab'),
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'App',
          ),
        ],
      ),
    );
  }

  Widget _profileContent() => ListView(
        key: const Key('settings-profile-content'),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
            tutorOptionsError: _tutorOptionsError,
            error: _settingsError,
            studyLanguageOptions: LanguageOptions.studyLanguages,
            nativeLanguageOptions: LanguageOptions.nativeLanguages,
            interfaceLanguageOptions: LanguageOptions.interfaceLanguages,
            voices: _voices,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: 12),
          _AudioCard(settings: _settings, onChanged: _updateSettings),
          const SizedBox(height: 12),
          _SettingsActionButton(
            onPressed: _settings == null || _isSaving ? null : _saveSettings,
            label: _isSaving ? 'Saving...' : 'Save settings',
          ),
        ],
      );

  Widget _lessonsContent() => ListView(
        key: const Key('settings-lessons-content'),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Text('Lessons', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              ListTile(
                key: const Key('settings-lesson-history'),
                leading: const Icon(Icons.history),
                title: const Text('Lesson history'),
                onTap: _openLessonHistory,
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settings-progress'),
                leading: const Icon(Icons.insights),
                title: const Text('Progress'),
                onTap: _openProgress,
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('settings-rewards'),
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Rewards'),
              subtitle: const Text('View all badges and learning rewards.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openAchievements,
            ),
          ),
        ],
      );

  Widget _appContent() => ListView(
        key: const Key('settings-app-content'),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _PasswordRecoveryCard(
            resetEmailController: _resetEmailController,
            resetCodeController: _resetCodeController,
            resetNewPasswordController: _resetNewPasswordController,
            resetConfirmPasswordController: _resetConfirmPasswordController,
            currentPasswordController: _currentPasswordController,
            changeNewPasswordController: _changeNewPasswordController,
            changeConfirmPasswordController: _changeConfirmPasswordController,
            resetRequestMessage: _resetRequestMessage,
            resetConfirmMessage: _resetConfirmMessage,
            changePasswordMessage: _changePasswordMessage,
            requestingReset: _isRequestingReset,
            confirmingReset: _isConfirmingReset,
            changingPassword: _isChangingPassword,
            onRequestReset: _requestPasswordReset,
            onConfirmReset: _confirmPasswordReset,
            onChangePassword: _changePassword,
          ),
          const SizedBox(height: 12),
          _FeedbackReportCard(
            category: _feedbackCategory,
            messageController: _feedbackMessageController,
            aiTextController: _reportedAiTextController,
            submitting: _isSubmittingFeedback,
            message: _feedbackMessage,
            onCategoryChanged: (value) => setState(() {
              _feedbackCategory = value;
              _feedbackMessage = null;
            }),
            onSubmit: _submitFeedback,
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Privacy & voice'),
                  SizedBox(height: 6),
                  Text(
                    'Voice responses are sent securely to Language Voice Tutor for transcription. You can choose text input instead of voice.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _ComingSoonCard(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications & contact',
            subtitle:
                'Notification preferences and support details are coming soon.',
          ),
          const SizedBox(height: 12),
          _DiagnosticsCard(
            connectionLabel: _connectionLabel,
            connectionMessage: _connectionMessage,
            checking: _connectionState == BackendConnectionState.checking,
            onCheck: _checkBackendConnection,
          ),
        ],
      );

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

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      );
}

class _SettingsActionButton extends StatelessWidget {
  const _SettingsActionButton({required this.onPressed, required this.label});
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppVisuals.actionButtonGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4439679A),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            onPressed: onPressed,
            child: Text(label),
          ),
        ),
      );
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

class _PasswordRecoveryCard extends StatelessWidget {
  const _PasswordRecoveryCard({
    required this.resetEmailController,
    required this.resetCodeController,
    required this.resetNewPasswordController,
    required this.resetConfirmPasswordController,
    required this.currentPasswordController,
    required this.changeNewPasswordController,
    required this.changeConfirmPasswordController,
    required this.resetRequestMessage,
    required this.resetConfirmMessage,
    required this.changePasswordMessage,
    required this.requestingReset,
    required this.confirmingReset,
    required this.changingPassword,
    required this.onRequestReset,
    required this.onConfirmReset,
    required this.onChangePassword,
  });

  final TextEditingController resetEmailController;
  final TextEditingController resetCodeController;
  final TextEditingController resetNewPasswordController;
  final TextEditingController resetConfirmPasswordController;
  final TextEditingController currentPasswordController;
  final TextEditingController changeNewPasswordController;
  final TextEditingController changeConfirmPasswordController;
  final String? resetRequestMessage;
  final String? resetConfirmMessage;
  final String? changePasswordMessage;
  final bool requestingReset;
  final bool confirmingReset;
  final bool changingPassword;
  final VoidCallback onRequestReset;
  final VoidCallback onConfirmReset;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => Card(
          child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text('Password & recovery',
                  style: Theme.of(context).textTheme.titleMedium),
              children: [
            TextField(
              controller: resetEmailController,
              decoration: const InputDecoration(labelText: 'Account email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: requestingReset ? null : onRequestReset,
                child: Text(requestingReset
                    ? 'Sending reset instructions...'
                    : 'Forgot password'),
              ),
            ),
            if (resetRequestMessage != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(resetRequestMessage!),
              ),
            ],
            const Divider(height: 28),
            TextField(
              controller: resetCodeController,
              decoration: const InputDecoration(labelText: 'Reset code'),
            ),
            TextField(
              controller: resetNewPasswordController,
              decoration: const InputDecoration(labelText: 'New password'),
              obscureText: true,
            ),
            TextField(
              controller: resetConfirmPasswordController,
              decoration:
                  const InputDecoration(labelText: 'Confirm new password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: confirmingReset ? null : onConfirmReset,
                child: Text(confirmingReset
                    ? 'Updating password...'
                    : 'Reset password'),
              ),
            ),
            if (resetConfirmMessage != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(resetConfirmMessage!),
              ),
            ],
            const Divider(height: 28),
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current password'),
              obscureText: true,
            ),
            TextField(
              controller: changeNewPasswordController,
              decoration:
                  const InputDecoration(labelText: 'New account password'),
              obscureText: true,
            ),
            TextField(
              controller: changeConfirmPasswordController,
              decoration: const InputDecoration(
                  labelText: 'Confirm new account password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: changingPassword ? null : onChangePassword,
                child: Text(changingPassword
                    ? 'Changing password...'
                    : 'Change password'),
              ),
            ),
            if (changePasswordMessage != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(changePasswordMessage!),
              ),
            ],
          ]));
}

class _LearningCard extends StatelessWidget {
  const _LearningCard(
      {required this.settings,
      required this.tutorOptions,
      required this.tutorOptionsError,
      required this.error,
      required this.studyLanguageOptions,
      required this.nativeLanguageOptions,
      required this.interfaceLanguageOptions,
      required this.voices,
      required this.onChanged});
  final UserSettings? settings;
  final TutorOptions? tutorOptions;
  final String? tutorOptionsError;
  final String? error;
  final List<LanguageOption> studyLanguageOptions;
  final List<LanguageOption> nativeLanguageOptions;
  final List<LanguageOption> interfaceLanguageOptions;
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
              _LessonLevelDropdown(
                  value: settings!.currentLevel,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(currentLevel: v))),
              const SizedBox(height: 10),
              _LanguageDropdown(
                  label: 'Study language',
                  value: settings!.studyLanguage,
                  options: studyLanguageOptions,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(studyLanguage: v))),
              const SizedBox(height: 10),
              _LanguageDropdown(
                  label: 'Native language',
                  value: settings!.nativeLanguage,
                  options: nativeLanguageOptions,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(nativeLanguage: v))),
              const SizedBox(height: 10),
              _LanguageDropdown(
                  label: 'Interface / explanation language',
                  value: settings!.explanationLanguage,
                  options: interfaceLanguageOptions,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(explanationLanguage: v))),
              const SizedBox(height: 10),
              _TutorDropdown(
                selectedTutorId: settings!.selectedTutorId,
                tutorOptions: tutorOptions,
                error: tutorOptionsError,
                onChanged: (v) =>
                    onChanged(settings!.copyWith(selectedTutorId: v)),
              ),
              const SizedBox(height: 10),
              _Dropdown(
                  label: 'Tutor voice',
                  value: settings!.speechVoice,
                  values: voices,
                  onChanged: (v) =>
                      onChanged(settings!.copyWith(speechVoice: v))),
            ],
          ])));
}

class _LessonLevelDropdown extends StatelessWidget {
  const _LessonLevelDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Current level'),
        initialValue: canonicalLessonLevel(value),
        items: lessonLevels
            .map((level) => DropdownMenuItem(
                  value: canonicalLessonLevel(level.id),
                  child: Text(level.label),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      );
}

class _TutorDropdown extends StatelessWidget {
  const _TutorDropdown({
    required this.selectedTutorId,
    required this.tutorOptions,
    required this.error,
    required this.onChanged,
  });

  final String selectedTutorId;
  final TutorOptions? tutorOptions;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tutors = tutorOptions?.activeTutors ?? const <TutorOption>[];
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(error!),
      );
    }
    if (tutorOptions == null) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('Loading tutors...'),
      );
    }
    if (tutors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('No tutors are available right now.'),
      );
    }

    final supportedIds = tutors.map((t) => t.tutorId).toSet();
    final value = supportedIds.contains(selectedTutorId)
        ? selectedTutorId
        : tutors.first.tutorId;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Selected tutor'),
      initialValue: value,
      items: tutors
          .map((t) => DropdownMenuItem(value: t.tutorId, child: Text(t.label)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
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

class _FeedbackReportCard extends StatelessWidget {
  const _FeedbackReportCard(
      {required this.category,
      required this.messageController,
      required this.aiTextController,
      required this.submitting,
      required this.message,
      required this.onCategoryChanged,
      required this.onSubmit});
  final FeedbackReportCategory category;
  final TextEditingController messageController;
  final TextEditingController aiTextController;
  final bool submitting;
  final String? message;
  final ValueChanged<FeedbackReportCategory> onCategoryChanged;
  final VoidCallback onSubmit;

  String get _descriptionLabel => switch (category) {
        FeedbackReportCategory.suggestion => 'Your suggestion',
        FeedbackReportCategory.appIssue => 'Describe the problem',
        FeedbackReportCategory.aiResponse =>
          'What was wrong with the AI response?',
      };

  @override
  Widget build(BuildContext context) => Card(
        child: ExpansionTile(
          key: const Key('feedback-reports-card'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text('Feedback & reports',
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: const Text('Send a suggestion or report a problem'),
          children: [
            DropdownButtonFormField<FeedbackReportCategory>(
              key: const Key('feedback-category'),
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Report type'),
              items: FeedbackReportCategory.values
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)))
                  .toList(),
              onChanged: submitting
                  ? null
                  : (value) {
                      if (value != null) onCategoryChanged(value);
                    },
            ),
            const SizedBox(height: 8),
            TextField(
                controller: messageController,
                enabled: !submitting,
                maxLines: 4,
                maxLength: 4000,
                decoration: InputDecoration(labelText: _descriptionLabel)),
            if (category == FeedbackReportCategory.aiResponse) ...[
              const SizedBox(height: 8),
              TextField(
                  controller: aiTextController,
                  enabled: !submitting,
                  maxLines: 4,
                  maxLength: 4000,
                  decoration: const InputDecoration(
                      labelText: 'Paste the AI response (optional)')),
            ],
            const SizedBox(height: 8),
            Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                    onPressed: submitting ? null : onSubmit,
                    child: Text(submitting ? 'Sending...' : 'Send'))),
            if (message != null) ...[
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: Text(message!))
            ],
          ],
        ),
      );
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
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 8),
              title: Text('Connection status',
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(connectionLabel),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(connectionMessage),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                      onPressed: checking ? null : onCheck,
                      child: const Text('Check connection')),
                ),
              ],
            ),
          ])));
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown(
      {required this.label,
      required this.value,
      required this.options,
      required this.onChanged});
  final String label;
  final String value;
  final List<LanguageOption> options;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final supportedIds = options.map((option) => option.id).toSet();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      initialValue: supportedIds.contains(value) ? value : null,
      items: options
          .map((option) =>
              DropdownMenuItem(value: option.id, child: Text(option.label)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
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
