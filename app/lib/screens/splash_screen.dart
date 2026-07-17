import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, AuthService? authService})
      : _authService = authService;

  static const String routeName = '/';
  final AuthService? _authService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthService _authService;
  bool _startedLoading = false;
  bool _temporaryFailure = false;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_startedLoading) return;
    _startedLoading = true;
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => _temporaryFailure = false);
    final result = await _authService.checkSession();
    switch (result) {
      case SessionCheckResult.authenticated:
        if (!mounted) return;
        await precacheImage(const AssetImage(AppConfig.logoAsset), context);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      case SessionCheckResult.authenticationRequired:
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      case SessionCheckResult.temporaryFailure:
        if (!mounted) return;
        setState(() => _temporaryFailure = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppConfig.logoAsset,
              key: const Key('splash-app-logo'),
              semanticLabel: AppConfig.logoSemanticLabel,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            if (_temporaryFailure) ...[
              const SizedBox(height: 24),
              const Text('Unable to check your session. Please try again.'),
              const SizedBox(height: 12),
              ElevatedButton(
                key: const Key('splash-retry-button'),
                onPressed: _loadSession,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
