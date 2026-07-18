import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/auth_models.dart';
import '../models/lesson_access_decision.dart';
import '../models/lesson_start_selection.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import 'choose_topic_screen.dart';
import 'lesson_history_screen.dart';
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
  bool _isLoadingLessonSettings = false;
  String? _lessonStartError;

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

  Future<void> _startLesson() async {
    if (_isLoadingLessonSettings) return;
    setState(() {
      _isLoadingLessonSettings = true;
      _lessonStartError = null;
    });

    try {
      final settings = await _authService.fetchUserSettings();
      if (!mounted) return;
      final selectedLevel = lessonLevelFor(settings.currentLevel);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChooseTopicScreen(
            selectedLevel: selectedLevel,
            authService: _authService,
          ),
        ),
      );
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
      setState(() => _lessonStartError =
          'Unable to load your learning settings right now. Please try again.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _lessonStartError =
          'Unable to load your learning settings right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoadingLessonSettings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          const _HomeTitle(),
          const SizedBox(height: 12),
          Text(
            'Practice real conversations by text and voice.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a topic and situation, then start a guided lesson.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isLoadingLessonSettings ? null : _startLesson,
            icon: const Icon(Icons.school),
            label: Text(
              _isLoadingLessonSettings ? 'Loading settings...' : 'Start lesson',
            ),
          ),
          if (_lessonStartError != null) ...[
            const SizedBox(height: 8),
            Text(_lessonStartError!),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('home-lesson-history'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonHistoryScreen(authService: _authService),
              ),
            ),
            icon: const Icon(Icons.history),
            label: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lesson history'),
                Text('Review your recent lessons'),
              ],
            ),
          ),
          const SizedBox(height: 20),
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

  static const _languageColor = Color(0xFF173A63);
  static const _voiceColor = Color(0xFF128776);
  static const _tutorColor = Color(0xFFD6633C);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.06,
          letterSpacing: 0,
        );

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
          child: Semantics(
            label: AppConfig.appName,
            header: true,
            child: ExcludeSemantics(
              child: Text.rich(
                TextSpan(
                  style: titleStyle,
                  children: const [
                    TextSpan(
                      text: 'Language',
                      style: TextStyle(color: _languageColor),
                    ),
                    TextSpan(
                      text: ' Voice',
                      style: TextStyle(color: _voiceColor),
                    ),
                    TextSpan(
                      text: ' Tutor',
                      style: TextStyle(color: _tutorColor),
                    ),
                  ],
                ),
                key: const Key('home-branded-title'),
                softWrap: true,
              ),
            ),
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

  bool get _hasPremiumAccess => lessonAccess?.premiumActive ?? false;

  bool get _hasTrialAccess => lessonAccess?.trialActive ?? false;

  bool get _hasPaidOrTrialAccess => _hasPremiumAccess || _hasTrialAccess;

  String get _planLabel {
    if (_hasPremiumAccess) return 'Premium plan';
    if (_hasTrialAccess) return 'Premium trial';
    return 'Free plan';
  }

  String get _accessSummaryLabel {
    if (_hasPremiumAccess) return 'Unlimited lessons';
    if (_hasTrialAccess) return 'Unlimited lessons during trial';

    final remaining = lessonAccess?.freeLessonRemainingToday ?? 1;
    final lesson = remaining == 1 ? 'lesson' : 'lessons';
    return '$remaining free $lesson remaining today';
  }

  String? get _accessStatusLabel {
    if (_hasPremiumAccess) return 'Premium access is active';
    if (_hasTrialAccess) return 'Trial access is active';
    return null;
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your account',
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
            Text(_accessSummaryLabel),
            if (_accessStatusLabel != null) ...[
              const SizedBox(height: 4),
              Text(_accessStatusLabel!),
            ],
            if (isChecking) ...[
              const SizedBox(height: 8),
              const Text('Refreshing your lesson status...'),
            ] else if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!),
            ] else if (lessonAccess != null && !_hasPaidOrTrialAccess) ...[
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
              child: const Text('Refresh status'),
            ),
          ],
        ),
      ),
    );
  }
}
