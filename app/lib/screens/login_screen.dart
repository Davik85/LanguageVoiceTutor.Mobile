import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../l10n/app_localizations_context.dart';
import '../l10n/device_language_defaults.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import '../widgets/password_recovery_form.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    AuthService? authService,
    DeviceLanguageDefaults? deviceLanguageDefaults,
    ValueChanged<String>? onInterfaceLanguageLoaded,
  })  : _authService = authService,
        _deviceLanguageDefaults = deviceLanguageDefaults ??
            const DeviceLanguageDefaults(
              interfaceLanguageId: 'en',
              nativeLanguageId: 'en',
            ),
        _onInterfaceLanguageLoaded = onInterfaceLanguageLoaded;

  static const String routeName = '/login';
  final AuthService? _authService;
  final DeviceLanguageDefaults _deviceLanguageDefaults;
  final ValueChanged<String>? _onInterfaceLanguageLoaded;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  late final AuthService _authService;
  bool _isRegistering = false;
  bool _showPasswordRecovery = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool register}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      if (register) {
        await _authService.register(_emailController.text.trim(),
            _passwordController.text, _displayNameController.text.trim());
        await _initializeNewAccountLanguages();
      } else {
        await _authService.login(
            _emailController.text.trim(), _passwordController.text);
        await _loadExistingAccountLanguage();
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to sign in right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _loadExistingAccountLanguage() async {
    try {
      final settings = await _authService.fetchUserSettings();
      widget._onInterfaceLanguageLoaded?.call(settings.explanationLanguage);
    } catch (_) {
      // Authentication succeeded; retain the device-derived interface language.
    }
  }

  Future<void> _initializeNewAccountLanguages() async {
    try {
      final current = await _authService.fetchUserSettings();
      final result = await _authService.updateUserSettings(
        current.copyWith(
          nativeLanguage: widget._deviceLanguageDefaults.nativeLanguageId,
          explanationLanguage:
              widget._deviceLanguageDefaults.interfaceLanguageId,
        ),
      );
      if (result.isSuccess && result.settings != null) {
        widget._onInterfaceLanguageLoaded
            ?.call(result.settings!.explanationLanguage);
      }
    } catch (_) {
      // Registration succeeded; do not retry or make it appear to have failed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _isRegistering ? context.l10n.register : context.l10n.login)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(context.l10n.signInToApp,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: context.l10n.email),
              validator: (value) => value == null || !value.contains('@')
                  ? context.l10n.invalidEmail
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(labelText: context.l10n.password),
              validator: (value) => value == null || value.length < 6
                  ? context.l10n.enterPassword
                  : null,
            ),
            if (_isRegistering) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                    labelText: context.l10n.displayNameOptional),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _submit(register: _isRegistering),
              child: Text(_isSubmitting
                  ? context.l10n.pleaseWait
                  : (_isRegistering
                      ? context.l10n.register
                      : context.l10n.login)),
            ),
            if (!_isRegistering) ...[
              TextButton(
                key: const Key('login-forgot-password'),
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _showPasswordRecovery = true),
                child: Text(context.l10n.forgotPassword),
              ),
              if (_showPasswordRecovery) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.passwordRecovery,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        PasswordRecoveryForm(
                          authService: _authService,
                          initialEmail: _emailController.text,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
            TextButton(
              key: const Key('login-mode-switch'),
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() {
                        _isRegistering = !_isRegistering;
                        _showPasswordRecovery = false;
                        _error = null;
                      }),
              child: Text(_isRegistering
                  ? context.l10n.alreadyHaveAccount
                  : context.l10n.createAccount),
            ),
          ],
        ),
      ),
    );
  }
}
