import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/auth_models.dart';
import '../models/lesson_access_decision.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import 'choose_level_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    AuthService? authService,
  }) : _authService = authService;

  static const String routeName = '/home';
  final AuthService? _authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  AuthUser? _currentUser;
  bool _isLoadingAccount = true;
  LessonAccessDecision? _lessonAccess;
  bool _isCheckingLessonAccess = false;
  String? _lessonAccessError;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final user = await _authService.loadCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _isLoadingAccount = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentUser = null;
        _isLoadingAccount = false;
      });
    }
  }

  Future<void> _checkLessonAccess() async {
    setState(() {
      _isCheckingLessonAccess = true;
      _lessonAccessError = null;
    });

    try {
      final lessonAccess = await _authService.fetchLessonAccessDecision();
      if (!mounted) return;
      setState(() => _lessonAccess = lessonAccess);
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
      setState(() => _lessonAccessError =
          'Unable to check lesson access right now. Please try again.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _lessonAccessError =
          'Unable to check lesson access right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isCheckingLessonAccess = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _HomeTitle(),
          const SizedBox(height: 12),
          Text(
            'Practice real conversations by text and voice.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your level, topic, and situation, then start a guided lesson.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChooseLevelScreen()),
            ),
            icon: const Icon(Icons.school),
            label: const Text('Start lesson'),
          ),
          const SizedBox(height: 16),
          AccountAccessCard(
            user: _currentUser,
            isLoadingAccount: _isLoadingAccount,
            lessonAccess: _lessonAccess,
            error: _lessonAccessError,
            isChecking: _isCheckingLessonAccess,
            onCheckLessonAccess: _checkLessonAccess,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            AppConfig.logoAsset,
            key: const Key('app-logo'),
            semanticLabel: AppConfig.logoSemanticLabel,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppConfig.appName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

class AccountAccessCard extends StatelessWidget {
  const AccountAccessCard({
    super.key,
    required this.user,
    required this.isLoadingAccount,
    required this.lessonAccess,
    required this.error,
    required this.isChecking,
    required this.onCheckLessonAccess,
  });

  final AuthUser? user;
  final bool isLoadingAccount;
  final LessonAccessDecision? lessonAccess;
  final String? error;
  final bool isChecking;
  final VoidCallback onCheckLessonAccess;

  String get _planLabel {
    if (lessonAccess == null) return 'Free plan';
    if (lessonAccess!.premiumActive) return 'Premium plan';
    if (lessonAccess!.trialActive) return 'Trial access';
    return 'Free plan';
  }

  String get _lessonRemainingLabel {
    final remaining = lessonAccess?.freeLessonRemainingToday ?? 1;
    final lesson = remaining == 1 ? 'lesson' : 'lessons';
    return '$remaining free $lesson remaining today';
  }

  String get _signedInLabel {
    final name = _accountName;
    return name == null ? 'Signed in' : 'Signed in as $name';
  }

  String? get _accountName {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email.trim() ?? '';
    if (email.isEmpty) return null;

    final atIndex = email.indexOf('@');
    final localPart = atIndex > 0 ? email.substring(0, atIndex) : email;
    return localPart.isEmpty ? null : localPart;
  }

  String get _email {
    final email = user?.email.trim() ?? '';
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account / access',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (isLoadingAccount)
              const Text('Checking your account...')
            else if (user != null) ...[
              Text(
                _signedInLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (_email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_email),
              ],
            ] else
              const Text(
                'Sign in to keep your settings and progress synced.',
              ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(_planLabel),
            const SizedBox(height: 4),
            Text(_lessonRemainingLabel),
            if (isChecking) ...[
              const SizedBox(height: 8),
              const Text('Checking lesson access...'),
            ] else if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!),
            ] else if (lessonAccess != null) ...[
              const SizedBox(height: 8),
              Text(lessonAccess!.canStartNewLesson
                  ? 'You can start a lesson'
                  : 'You cannot start a new lesson right now'),
              const SizedBox(height: 4),
              Text(lessonAccess!.displayReason),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: isChecking ? null : onCheckLessonAccess,
              child: const Text('Refresh access'),
            ),
          ],
        ),
      ),
    );
  }
}
