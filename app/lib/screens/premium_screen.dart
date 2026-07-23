import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/subscription_status.dart';
import '../services/auth_service.dart';
import '../services/service_factory.dart';
import '../theme/app_visuals.dart';
import 'login_screen.dart';

enum PurchaseEntryResult { completed, cancelled, failed, unavailable }

typedef PurchaseEntryAction = Future<PurchaseEntryResult> Function();

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({
    super.key,
    AuthService? authService,
    this.purchaseAction,
    this.restoreAction,
  }) : _authService = authService;

  static const routeName = '/premium';
  final AuthService? _authService;
  final PurchaseEntryAction? purchaseAction;
  final PurchaseEntryAction? restoreAction;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  late final AuthService _authService;
  SubscriptionStatus? _status;
  String? _error;
  bool _loading = false;
  bool _refreshing = false;
  bool _runningAction = false;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (_loading || _refreshing) return;
    setState(() {
      if (refresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }
      _error = null;
    });
    try {
      final status = await _authService.fetchSubscriptionStatus();
      if (!mounted) return;
      setState(() => _status = status);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Please sign in again.') {
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.routeName, (_) => false);
        return;
      }
      setState(() => _error =
          'Premium status is temporarily unavailable. Please try again.');
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Premium status is temporarily unavailable. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  Future<void> _runAction({required bool restore}) async {
    if (_runningAction) return;
    final action = restore ? widget.restoreAction : widget.purchaseAction;
    if (action == null) {
      await _showUnavailable(restore: restore);
      return;
    }
    setState(() => _runningAction = true);
    try {
      final result = await action();
      if (!mounted) return;
      switch (result) {
        case PurchaseEntryResult.completed:
          await _load(refresh: true);
          if (mounted &&
              _status != null &&
              !_status!.premiumActive &&
              !_status!.trialActive) {
            setState(() => _error =
                'Purchase processing is not confirmed yet. Refresh your status again shortly.');
          }
        case PurchaseEntryResult.cancelled:
          break;
        case PurchaseEntryResult.failed:
          setState(() => _error =
              'Unable to complete that request right now. Please try again.');
        case PurchaseEntryResult.unavailable:
          await _showUnavailable(restore: restore);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Unable to complete that request right now. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _runningAction = false);
    }
  }

  Future<void> _showUnavailable({required bool restore}) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(restore
              ? 'Restore purchases is not available yet'
              : 'Google Play purchases are not available yet'),
          content: Text(restore
              ? 'Google Play restoration will be connected with the billing flow. Your current account status is still loaded from Language Voice Tutor.'
              : 'Purchases will be connected in the next step. This build cannot charge you or activate Premium.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );

  String _date(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatMediumDate(value.toLocal());

  String? get _tariff {
    final current = _status?.currentTariffName?.trim() ?? '';
    if (current.isNotEmpty) return current;
    final plan = _status?.planName?.trim() ?? '';
    return plan.isEmpty ? null : plan;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Premium')),
        body: AppVisuals.screenBackground(
          child: _loading && _status == null
              ? Center(
                  child: Semantics(
                      label: 'Loading Premium status',
                      child: const CircularProgressIndicator()))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_refreshing)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(),
                      ),
                    if (_error != null) ...[
                      Semantics(liveRegion: true, child: Text(_error!)),
                      const SizedBox(height: 8),
                    ],
                    if (_status == null)
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  'Premium status is temporarily unavailable.'),
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                  onPressed: () => _load(),
                                  child: const Text('Retry')),
                            ]),
                      ))
                    else ...[
                      _statusCard(context),
                      const SizedBox(height: 12),
                      _actions(),
                      const SizedBox(height: 12),
                      _benefitsCard(context),
                    ],
                  ],
                ),
        ),
      );

  Widget _statusCard(BuildContext context) {
    final status = _status!;
    final premium = status.premiumActive;
    final trial = !premium && status.trialActive;
    final title = premium
        ? 'Premium active'
        : trial
            ? 'Premium trial'
            : 'Free plan';
    return Semantics(
      label: 'Premium status: $title',
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (premium) ...[
            const Text('Practice without the daily free-lesson limit.'),
            if (status.premiumEndsAtUtc != null)
              Text('Premium ends ${_date(context, status.premiumEndsAtUtc!)}.'),
            if (_tariff != null) Text(_tariff!),
          ] else if (trial) ...[
            const Text('Your Premium trial is active.'),
            if (status.trialEndsAtUtc != null)
              Text('Trial ends ${_date(context, status.trialEndsAtUtc!)}.'),
          ] else ...[
            if (status.enforcementEnabled)
              Text(
                  '${status.freeLessonRemainingToday} free ${status.freeLessonRemainingToday == 1 ? 'lesson' : 'lessons'} remaining today.'),
            const Text('Premium removes the daily lesson limit.'),
          ],
          const SizedBox(height: 12),
          const Text(
              'Premium access is linked to your Language Voice Tutor account.'),
          const SizedBox(height: 4),
          const Text(
              'Your confirmed Premium status is shared across supported Language Voice Tutor clients.'),
        ]),
      )),
    );
  }

  Widget _benefitsCard(BuildContext context) => Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Premium benefits',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('• Practice without the daily free-lesson cap'),
          const Text('• Use the same Premium access across supported devices'),
          const Text(
              '• Keep your account, progress, history, and learning settings together'),
        ]),
      ));

  Widget _actions() {
    final active = _status!.premiumActive;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!active) ...[
        FilledButton(
          onPressed: _runningAction ? null : () => _runAction(restore: false),
          child: Text(_runningAction ? 'Please wait...' : 'Get Premium'),
        ),
        TextButton(
          onPressed: _runningAction ? null : () => _runAction(restore: true),
          child: const Text('Restore purchases'),
        ),
      ] else
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
              'Billing changes must be handled through the provider where Premium was purchased.'),
        ),
      OutlinedButton(
        onPressed:
            _refreshing || _runningAction ? null : () => _load(refresh: true),
        child: const Text('Refresh status'),
      ),
    ]);
  }
}
