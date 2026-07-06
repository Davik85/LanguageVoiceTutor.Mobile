import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, AuthService? authService}) : _authService = authService;

  static const String routeName = '/';
  final AuthService? _authService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthService _authService;
  String? _message;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      await _authService.loadCurrentUser();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Please sign in to continue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.record_voice_over, size: 72),
              const SizedBox(height: 16),
              Text(AppConfig.appName, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(_message ?? 'Checking your session...'),
              const SizedBox(height: 24),
              if (_message == null) const CircularProgressIndicator() else FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                child: const Text('Continue to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
