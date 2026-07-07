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
    try {
      await _authService.loadCurrentUser();
      if (!mounted) return;
      await precacheImage(const AssetImage(AppConfig.logoAsset), context);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          AppConfig.logoAsset,
          key: const Key('splash-app-logo'),
          semanticLabel: AppConfig.logoSemanticLabel,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
