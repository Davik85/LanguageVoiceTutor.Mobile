import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/google_play_purchase_verification.dart';
import '../models/premium_purchase.dart';
import '../models/subscription_status.dart';
import 'auth_service.dart';
import 'premium_purchase_adapter.dart';

enum PremiumPurchaseCoordinatorState {
  idle,
  unavailable,
  loadingCatalog,
  ready,
  blocked,
  launching,
  restoring,
  pending,
  processing,
  completed,
  cancelled,
  failed,
}

class PremiumPurchaseCoordinatorResult {
  const PremiumPurchaseCoordinatorResult({
    required this.state,
    this.verification,
    this.subscriptionStatus,
  });

  final PremiumPurchaseCoordinatorState state;
  final GooglePlayPurchaseVerificationResponse? verification;
  final SubscriptionStatus? subscriptionStatus;
  bool get shouldRefreshStatus =>
      verification?.subscriptionStatusRefreshRecommended ?? false;
}

class PremiumPurchaseCoordinator extends ChangeNotifier {
  PremiumPurchaseCoordinator({
    required AuthService authService,
    required PremiumPurchaseAdapter purchaseAdapter,
    Set<String> productIds = const {},
    String basePlanId = '',
  })  : _authService = authService,
        _purchaseAdapter = purchaseAdapter,
        _productIds = Set.unmodifiable(productIds),
        _basePlanId = basePlanId;

  final AuthService _authService;
  final PremiumPurchaseAdapter _purchaseAdapter;
  final Set<String> _productIds;
  final String _basePlanId;
  final Set<String> _processingTokens = <String>{};
  StreamSubscription<PremiumPurchaseEvent>? _events;
  PremiumPurchaseCoordinatorState _state = PremiumPurchaseCoordinatorState.idle;
  PremiumProductLoadResult _catalog = const PremiumProductLoadResult();
  PremiumPurchaseCoordinatorResult? _lastResult;
  PremiumStoreProduct? _selectedProduct;
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _disposed = false;
  bool _closed = false;

  PremiumPurchaseCoordinatorState get state => _state;
  PremiumProductLoadResult get catalog => _catalog;
  PremiumPurchaseCoordinatorResult? get lastResult => _lastResult;
  bool get isAvailable => _state != PremiumPurchaseCoordinatorState.unavailable;

  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    _initialized = true;
    // Listen first so a synchronous store event cannot be missed.
    _events = _purchaseAdapter.purchaseEvents.listen(_handlePurchaseEvent,
        onError: (_, __) => _setState(PremiumPurchaseCoordinatorState.failed));
    try {
      await _purchaseAdapter.initialize();
      _storeAvailable = await _purchaseAdapter.isAvailable;
    } catch (_) {
      _storeAvailable = false;
    }
    if (!_storeAvailable) {
      _setState(PremiumPurchaseCoordinatorState.unavailable);
      return;
    }
    if (_productIds.isEmpty) {
      _setState(PremiumPurchaseCoordinatorState.unavailable);
      return;
    }
    _setState(PremiumPurchaseCoordinatorState.loadingCatalog);
    try {
      _catalog = await _purchaseAdapter.loadSubscriptionProducts(_productIds);
    } catch (_) {
      _catalog = const PremiumProductLoadResult(
          failure: PremiumPurchaseFailure.storeError);
    }
    final matches = _catalog.products
        .where((product) =>
            _productIds.contains(product.productId) &&
            product.basePlanId == _basePlanId &&
            product.offerId == null &&
            (product.offerToken?.trim().isNotEmpty ?? false))
        .toList();
    _selectedProduct = matches.length == 1 ? matches.single : null;
    _setState(_selectedProduct == null || _catalog.failure != null
        ? PremiumPurchaseCoordinatorState.unavailable
        : PremiumPurchaseCoordinatorState.ready);
  }

  Future<PremiumPurchaseCoordinatorResult> startPurchase() async {
    if (!_initialized) await initialize();
    if (_state == PremiumPurchaseCoordinatorState.unavailable ||
        _selectedProduct == null) {
      return _result(PremiumPurchaseCoordinatorState.unavailable);
    }
    final identity = await _purchaseIdentity();
    if (identity == null) {
      return _setResult(PremiumPurchaseCoordinatorState.failed);
    }
    SubscriptionStatus status;
    try {
      status = await _authService.fetchSubscriptionStatus();
    } catch (_) {
      return _setResult(PremiumPurchaseCoordinatorState.failed);
    }
    if (status.userId.trim() != identity.userId ||
        !status.hasFreshGooglePlayPurchaseGate()) {
      return _setResult(PremiumPurchaseCoordinatorState.blocked);
    }
    _setState(PremiumPurchaseCoordinatorState.launching);
    final launched = await _purchaseAdapter.launchSubscriptionOffer(
        _selectedProduct!,
        obfuscatedAccountId: identity.obfuscatedAccountId);
    if (!launched) _setState(PremiumPurchaseCoordinatorState.failed);
    return _result(launched
        ? PremiumPurchaseCoordinatorState.launching
        : PremiumPurchaseCoordinatorState.failed);
  }

  Future<PremiumPurchaseCoordinatorResult> restorePurchases() async {
    if (!_initialized) await initialize();
    if (!_storeAvailable) {
      return _result(PremiumPurchaseCoordinatorState.unavailable);
    }
    final identity = await _purchaseIdentity();
    if (identity == null) {
      return _result(PremiumPurchaseCoordinatorState.failed);
    }
    _setState(PremiumPurchaseCoordinatorState.restoring);
    try {
      await _purchaseAdapter.restorePurchases(
          obfuscatedAccountId: identity.obfuscatedAccountId);
      return _result(PremiumPurchaseCoordinatorState.restoring);
    } catch (_) {
      _setState(PremiumPurchaseCoordinatorState.failed);
      return _result(PremiumPurchaseCoordinatorState.failed);
    }
  }

  Future<({String userId, String obfuscatedAccountId})?>
      _purchaseIdentity() async {
    try {
      final userId = (await _authService.loadCurrentUser()).userId.trim();
      if (!_isValidUserId(userId)) return null;
      return (
        userId: userId,
        obfuscatedAccountId: sha256.convert(utf8.encode(userId)).toString()
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isValidUserId(String value) =>
      value.isNotEmpty &&
      value.length <= 256 &&
      !value.contains('@') &&
      !RegExp(r'\s').hasMatch(value);

  Future<void> _handlePurchaseEvent(PremiumPurchaseEvent event) async {
    switch (event.status) {
      case PremiumPurchaseEventStatus.pending:
        _setState(PremiumPurchaseCoordinatorState.pending);
        return;
      case PremiumPurchaseEventStatus.cancelled:
        _setState(PremiumPurchaseCoordinatorState.cancelled);
        return;
      case PremiumPurchaseEventStatus.failed:
        _setState(PremiumPurchaseCoordinatorState.failed);
        return;
      case PremiumPurchaseEventStatus.purchased:
      case PremiumPurchaseEventStatus.restored:
        break;
    }
    final token = event.purchaseToken;
    if (token == null ||
        token.trim().isEmpty ||
        !_processingTokens.add(token)) {
      return;
    }
    _setState(PremiumPurchaseCoordinatorState.processing);
    try {
      final verification = await _authService.verifyGooglePlayPurchase(token);
      SubscriptionStatus? status;
      if (verification.subscriptionStatusRefreshRecommended) {
        try {
          status = await _authService.fetchSubscriptionStatus();
        } catch (_) {}
      }
      final state = switch (verification.result) {
        GooglePlayPurchaseVerificationResult.verified =>
          PremiumPurchaseCoordinatorState.completed,
        GooglePlayPurchaseVerificationResult.acknowledgementPending ||
        GooglePlayPurchaseVerificationResult.pending =>
          PremiumPurchaseCoordinatorState.pending,
        _ => PremiumPurchaseCoordinatorState.failed,
      };
      _lastResult = PremiumPurchaseCoordinatorResult(
          state: state, verification: verification, subscriptionStatus: status);
      _setState(state);
    } catch (_) {
      _setState(PremiumPurchaseCoordinatorState.failed);
    } finally {
      _processingTokens.remove(token);
    }
  }

  PremiumPurchaseCoordinatorResult _result(
      PremiumPurchaseCoordinatorState state) {
    return PremiumPurchaseCoordinatorResult(state: state);
  }

  PremiumPurchaseCoordinatorResult _setResult(
      PremiumPurchaseCoordinatorState state) {
    final result = PremiumPurchaseCoordinatorResult(state: state);
    _lastResult = result;
    _setState(state);
    return result;
  }

  void _setState(PremiumPurchaseCoordinatorState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _disposed = true;
    await _events?.cancel();
    await _purchaseAdapter.dispose();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
