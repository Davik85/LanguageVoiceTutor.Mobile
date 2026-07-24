import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/subscription_status.dart';
import '../l10n/app_localizations_context.dart';
import '../services/auth_service.dart';
import '../services/premium_purchase_adapter.dart';
import '../services/service_factory.dart';
import '../theme/app_visuals.dart';
import 'login_screen.dart';

enum PurchaseEntryResult { completed, cancelled, failed, unavailable }

typedef PurchaseEntryAction = Future<PurchaseEntryResult> Function();

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({
    super.key,
    AuthService? authService,
    PremiumPurchaseAdapter? purchaseAdapter,
    this.purchaseAction,
    this.restoreAction,
  })  : _authService = authService,
        _purchaseAdapter = purchaseAdapter;

  static const routeName = '/premium';
  final AuthService? _authService;
  final PremiumPurchaseAdapter? _purchaseAdapter;
  @Deprecated('Use purchaseAdapter in new code.')
  final PurchaseEntryAction? purchaseAction;
  @Deprecated('Use purchaseAdapter in new code.')
  final PurchaseEntryAction? restoreAction;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  late final AuthService _authService;
  late final PremiumPurchaseAdapter _purchaseAdapter;
  SubscriptionStatus? _status;
  String? _error;
  bool _loading = false;
  bool _refreshing = false;
  bool _runningAction = false;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _purchaseAdapter =
        widget._purchaseAdapter ?? const UnavailablePremiumPurchaseAdapter();
    _purchaseAdapter.initialize();
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
      setState(() => _error = context.l10n.premiumStatusTemporarilyUnavailable);
    } catch (_) {
      if (mounted) {
        setState(
            () => _error = context.l10n.premiumStatusTemporarilyUnavailable);
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
    final legacyAction = restore ? widget.restoreAction : widget.purchaseAction;
    if (legacyAction != null) {
      setState(() => _runningAction = true);
      try {
        final result = await legacyAction();
        if (result == PurchaseEntryResult.completed) {
          await _load(refresh: true);
          if (mounted &&
              _status != null &&
              !_status!.premiumActive &&
              !_status!.trialActive) {
            setState(() => _error = context.l10n.purchasePendingConfirmation);
          }
        } else if (result == PurchaseEntryResult.failed && mounted) {
          setState(() => _error = context.l10n.purchaseActionFailed);
        } else if (result == PurchaseEntryResult.unavailable) {
          await _showUnavailable(restore: restore);
        }
      } finally {
        if (mounted) setState(() => _runningAction = false);
      }
      return;
    }
    if (!await _purchaseAdapter.isAvailable) {
      await _showUnavailable(restore: restore);
      return;
    }
    setState(() => _runningAction = true);
    try {
      if (restore) {
        await _purchaseAdapter.restorePurchases();
        return;
      }
      // Production has no configured catalog, so it can never launch a store flow.
      final catalog = await _purchaseAdapter.loadSubscriptionProducts(const {});
      if (catalog.products.isEmpty) {
        await _showUnavailable(restore: false);
        return;
      }
      final result =
          await _purchaseAdapter.launchSubscriptionOffer(catalog.products.first)
              ? PurchaseEntryResult.completed
              : PurchaseEntryResult.failed;
      if (!mounted) return;
      switch (result) {
        case PurchaseEntryResult.completed:
          await _load(refresh: true);
          if (mounted &&
              _status != null &&
              !_status!.premiumActive &&
              !_status!.trialActive) {
            setState(() => _error = context.l10n.purchasePendingConfirmation);
          }
        case PurchaseEntryResult.cancelled:
          break;
        case PurchaseEntryResult.failed:
          setState(() => _error = context.l10n.purchaseActionFailed);
        case PurchaseEntryResult.unavailable:
          await _showUnavailable(restore: restore);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.purchaseActionFailed);
      }
    } finally {
      if (mounted) setState(() => _runningAction = false);
    }
  }

  Future<void> _showUnavailable({required bool restore}) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(restore
              ? context.l10n.restorePurchasesUnavailableTitle
              : context.l10n.googlePlayPurchasesUnavailableTitle),
          content: Text(restore
              ? context.l10n.restorePurchasesUnavailableDescription
              : context.l10n.googlePlayPurchasesUnavailableDescription),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.premiumOk))
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
        appBar: AppBar(title: Text(context.l10n.premium)),
        body: AppVisuals.screenBackground(
          child: _loading && _status == null
              ? Center(
                  child: Semantics(
                      label: context.l10n.premiumStatusLoadingSemantics,
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
                              Text(context
                                  .l10n.premiumStatusTemporarilyUnavailable),
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                  onPressed: () => _load(),
                                  child: Text(context.l10n.retry)),
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
        ? context.l10n.premiumActive
        : trial
            ? context.l10n.premiumTrial
            : context.l10n.freePlan;
    return Semantics(
      label: context.l10n.premiumStatusSemantics(title),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (premium) ...[
            Text(context.l10n.premiumActiveDescription),
            if (status.premiumEndsAtUtc != null)
              Text(context.l10n
                  .premiumEndsOn(_date(context, status.premiumEndsAtUtc!))),
            if (_tariff != null) Text(_tariff!),
          ] else if (trial) ...[
            Text(context.l10n.premiumTrialActiveDescription),
            if (status.trialEndsAtUtc != null)
              Text(context.l10n
                  .premiumTrialEndsOn(_date(context, status.trialEndsAtUtc!))),
          ] else ...[
            if (status.enforcementEnabled)
              Text(context.l10n
                  .freeLessonsRemainingToday(status.freeLessonRemainingToday)),
            Text(context.l10n.premiumRemovesDailyLimit),
          ],
          const SizedBox(height: 12),
          Text(context.l10n.premiumAccountLinked),
          const SizedBox(height: 4),
          Text(context.l10n.premiumSharedAcrossClients),
        ]),
      )),
    );
  }

  Widget _benefitsCard(BuildContext context) => Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l10n.premiumBenefits,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(context.l10n.premiumBenefitDailyLimit),
          Text(context.l10n.premiumBenefitAcrossDevices),
          Text(context.l10n.premiumBenefitAccountData),
        ]),
      ));

  Widget _actions() {
    final active = _status!.premiumActive;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!active) ...[
        FilledButton(
          onPressed: _runningAction ? null : () => _runAction(restore: false),
          child: Text(_runningAction
              ? context.l10n.pleaseWait
              : context.l10n.getPremium),
        ),
        TextButton(
          onPressed: _runningAction ? null : () => _runAction(restore: true),
          child: Text(context.l10n.restorePurchases),
        ),
      ] else
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(context.l10n.billingProviderExplanation),
        ),
      OutlinedButton(
        onPressed:
            _refreshing || _runningAction ? null : () => _load(refresh: true),
        child: Text(context.l10n.refreshPremiumStatus),
      ),
    ]);
  }
}
