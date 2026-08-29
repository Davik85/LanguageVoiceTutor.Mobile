import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../l10n/app_localizations_context.dart';
import '../services/auth_service.dart';

class PasswordRecoveryForm extends StatefulWidget {
  const PasswordRecoveryForm({
    super.key,
    required this.authService,
    this.initialEmail,
  });

  final AuthService authService;
  final String? initialEmail;

  @override
  State<PasswordRecoveryForm> createState() => _PasswordRecoveryFormState();
}

class _PasswordRecoveryFormState extends State<PasswordRecoveryForm> {
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _requestMessage;
  String? _confirmMessage;
  bool _requesting = false;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void didUpdateWidget(covariant PasswordRecoveryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_emailController.text.trim().isEmpty &&
        (widget.initialEmail?.trim().isNotEmpty ?? false)) {
      _emailController.text = widget.initialEmail!.trim();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _requestMessage = context.l10n.emailRequired);
      return;
    }
    setState(() {
      _requesting = true;
      _requestMessage = null;
    });
    try {
      final message = await widget.authService.requestPasswordReset(email);
      if (mounted) setState(() => _requestMessage = message);
    } on ApiException catch (error) {
      if (mounted) setState(() => _requestMessage = error.message);
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _confirmReset() async {
    if (_codeController.text.trim().isEmpty ||
        _newPasswordController.text.isEmpty) {
      setState(() => _confirmMessage = context.l10n.resetCodePasswordRequired);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _confirmMessage = context.l10n.passwordsMustMatch);
      return;
    }
    setState(() {
      _confirming = true;
      _confirmMessage = null;
    });
    try {
      final message = await widget.authService.confirmPasswordReset(
        _codeController.text.trim(),
        _newPasswordController.text,
      );
      if (mounted) setState(() => _confirmMessage = message);
    } on ApiException catch (error) {
      if (mounted) setState(() => _confirmMessage = error.message);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('password-recovery-email'),
            controller: _emailController,
            decoration: InputDecoration(labelText: context.l10n.accountEmail),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            key: const Key('password-recovery-request'),
            onPressed: _requesting ? null : _requestReset,
            child: Text(_requesting
                ? context.l10n.sendingResetInstructions
                : context.l10n.forgotPassword),
          ),
          if (_requestMessage != null) ...[
            const SizedBox(height: 8),
            Text(_requestMessage!),
          ],
          const Divider(height: 28),
          TextField(
            key: const Key('password-recovery-code'),
            controller: _codeController,
            decoration: InputDecoration(labelText: context.l10n.resetCode),
          ),
          TextField(
            key: const Key('password-recovery-new-password'),
            controller: _newPasswordController,
            decoration: InputDecoration(labelText: context.l10n.newPassword),
            obscureText: true,
          ),
          TextField(
            key: const Key('password-recovery-confirm-password'),
            controller: _confirmPasswordController,
            decoration:
                InputDecoration(labelText: context.l10n.confirmNewPassword),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            key: const Key('password-recovery-confirm'),
            onPressed: _confirming ? null : _confirmReset,
            child: Text(_confirming
                ? context.l10n.updatingPassword
                : context.l10n.resetPassword),
          ),
          if (_confirmMessage != null) ...[
            const SizedBox(height: 8),
            Text(_confirmMessage!),
          ],
        ],
      );
}
