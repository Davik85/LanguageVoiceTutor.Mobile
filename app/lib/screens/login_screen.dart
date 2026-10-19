import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../l10n/app_localizations_context.dart';
import '../l10n/device_language_defaults.dart';
import '../models/user_display_name.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import '../theme/app_visuals.dart';
import '../widgets/password_recovery_form.dart';
import '../widgets/registration_legal_notice.dart';
import '../services/legal_document_launcher.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    AuthService? authService,
    LegalDocumentLauncher? legalDocumentLauncher,
    DeviceLanguageDefaults? deviceLanguageDefaults,
    ValueChanged<String>? onInterfaceLanguageLoaded,
  })  : _authService = authService,
        _legalDocumentLauncher = legalDocumentLauncher,
        _deviceLanguageDefaults = deviceLanguageDefaults ??
            const DeviceLanguageDefaults(
              interfaceLanguageId: 'en',
              nativeLanguageId: 'en',
            ),
        _onInterfaceLanguageLoaded = onInterfaceLanguageLoaded;

  static const String routeName = '/login';
  final AuthService? _authService;
  final LegalDocumentLauncher? _legalDocumentLauncher;
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
  bool _analyticsAccepted = false;
  bool _analyticsSaveFailed = false;
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
    if (_isSubmitting) return;
    final validForm = _formKey.currentState!.validate();
    if (!validForm) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      if (register) {
        // Consent must be persisted and applied before AuthService can log sign_up.
        // Optional analytics failures must never prevent account creation.
        var saved = false;
        try {
          saved =
              await _authService.analytics.chooseConsent(_analyticsAccepted);
        } catch (_) {
          // AnalyticsService fails closed; keep authentication independent.
        }
        if (!mounted) return;
        setState(() => _analyticsSaveFailed = !saved);
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

  Future<void> _openLegalDocument(Uri document) async {
    var opened = false;
    try {
      opened = await (widget._legalDocumentLauncher ??
              const AndroidLegalDocumentLauncher())
          .open(document);
    } catch (_) {
      // Browser availability must not change authentication or consent state.
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.legalDocumentOpenFailed),
      ));
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
    return AppVisuals.screenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const _LoginHero(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.authWelcomeMessage,
                      key: const Key('login-welcome-message'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppVisuals.textBlue,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration:
                          InputDecoration(labelText: context.l10n.email),
                      validator: (value) =>
                          value == null || !value.contains('@')
                              ? context.l10n.invalidEmail
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration:
                          InputDecoration(labelText: context.l10n.password),
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
                        validator: (value) => isValidUserDisplayName(value)
                            ? null
                            : context.l10n.displayNameLettersOnly,
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                    SizedBox(height: _isRegistering ? 12 : 24),
                    if (_isRegistering) ...[
                      Row(
                        key: const Key('registration-analytics-choice'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            key: const Key('registration-analytics-checkbox'),
                            value: _analyticsAccepted,
                            semanticLabel:
                                context.l10n.registrationAnalyticsConsent,
                            onChanged: _isSubmitting
                                ? null
                                : (value) => setState(() {
                                      _analyticsAccepted = value ?? false;
                                      _analyticsSaveFailed = false;
                                    }),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    excludeFromSemantics: true,
                                    onTap: _isSubmitting
                                        ? null
                                        : () => setState(() {
                                              _analyticsAccepted =
                                                  !_analyticsAccepted;
                                              _analyticsSaveFailed = false;
                                            }),
                                    child: ExcludeSemantics(
                                      child: Text(
                                          context.l10n.registrationAnalyticsConsent,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                  ),
                                  TextButton(
                                    key: const Key(
                                        'registration-analytics-privacy-link'),
                                    onPressed: () => _openLegalDocument(
                                        LegalDocuments.privacy),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                    child: Text(context.l10n.privacyPolicy),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_analyticsSaveFailed)
                        Semantics(
                          liveRegion: true,
                          child: Text(context.l10n.analyticsSaveFailed,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                      const SizedBox(height: 8),
                    ],
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
                    if (_isRegistering) ...[
                      const SizedBox(height: 8),
                      RegistrationLegalNotice(
                          onOpenDocument: _openLegalDocument),
                    ],
                    if (!_isRegistering) ...[
                      TextButton(
                        key: const Key('login-forgot-password'),
                        onPressed: _isSubmitting
                            ? null
                            : () =>
                                setState(() => _showPasswordRecovery = true),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
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
                                _analyticsAccepted = false;
                                _analyticsSaveFailed = false;
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
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: ShaderMask(
        key: const Key('login-hero-fade'),
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.72, 1],
        ).createShader(bounds),
        child: Image.asset(
          'assets/brand/login_screen.webp',
          key: const Key('login-hero-image'),
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
