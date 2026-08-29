import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/auth_models.dart';
import 'package:language_voice_tutor_mobile/models/premium_purchase.dart';
import 'package:language_voice_tutor_mobile/models/google_play_purchase_verification.dart';
import 'package:language_voice_tutor_mobile/models/subscription_status.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/premium_purchase_adapter.dart';
import 'package:language_voice_tutor_mobile/services/premium_purchase_coordinator.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class _Storage implements SessionStorage {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {}
}

class _Api implements ApiClient {
  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
  @override
  Future<ApiResponse> put(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
}

class _CoordinatorAuth extends AuthService {
  _CoordinatorAuth(this.verification, {this.subscriptionStatus, this.trace})
      : super(apiClient: _Api(), storage: _Storage());
  final Future<GooglePlayPurchaseVerificationResponse> Function(String)
      verification;
  final Future<SubscriptionStatus> Function()? subscriptionStatus;
  final List<String>? trace;
  int verificationCalls = 0;
  int subscriptionStatusCalls = 0;

  @override
  Future<AuthUser> loadCurrentUser() async => AuthUser(
        userId: 'backend-user',
        email: 'user@example.test',
        createdAt: DateTime.utc(2026, 8, 1),
      );

  @override
  Future<GooglePlayPurchaseVerificationResponse> verifyGooglePlayPurchase(
      String token) {
    verificationCalls++;
    return verification(token);
  }

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() {
    subscriptionStatusCalls++;
    trace?.add('backend-gate');
    final fetch = subscriptionStatus;
    if (fetch == null) throw StateError('Unexpected subscription refresh');
    return fetch();
  }
}

class _EventAdapter implements PremiumPurchaseAdapter {
  _EventAdapter({
    this.products = const [],
    this.launchResult = false,
    this.catalogResults,
    this.availabilityResults = const [true],
    this.trace,
  }) : events = StreamController<PremiumPurchaseEvent>.broadcast(
          onListen: () {},
        );
  final StreamController<PremiumPurchaseEvent> events;
  int initializeCalls = 0;
  int subscriptions = 0;
  int disposeCalls = 0;
  int launchCalls = 0;
  int restoreCalls = 0;
  int availabilityCalls = 0;
  int loadCalls = 0;
  Set<String>? loadedProductIds;
  PremiumStoreProduct? launchedProduct;
  final List<PremiumStoreProduct> products;
  final bool launchResult;
  final List<PremiumProductLoadResult>? catalogResults;
  final List<bool> availabilityResults;
  final List<String>? trace;
  @override
  Stream<PremiumPurchaseEvent> get purchaseEvents {
    subscriptions++;
    return events.stream;
  }

  @override
  Future<void> initialize() async => initializeCalls++;
  @override
  Future<bool> get isAvailable async {
    final index = availabilityCalls < availabilityResults.length
        ? availabilityCalls
        : availabilityResults.length - 1;
    availabilityCalls++;
    return availabilityResults[index];
  }

  @override
  Future<PremiumProductLoadResult> loadSubscriptionProducts(
      Set<String> productIds) async {
    trace?.add('catalog');
    loadedProductIds = productIds;
    final results = catalogResults;
    if (results != null) {
      final index = loadCalls < results.length ? loadCalls : results.length - 1;
      loadCalls++;
      return results[index];
    }
    loadCalls++;
    return PremiumProductLoadResult(products: products);
  }

  @override
  Future<bool> launchSubscriptionOffer(PremiumStoreProduct product,
      {String? obfuscatedAccountId}) async {
    launchCalls++;
    trace?.add('launch');
    launchedProduct = product;
    return launchResult;
  }

  @override
  Future<void> restorePurchases({String? obfuscatedAccountId}) async {
    restoreCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await events.close();
  }
}

SubscriptionStatus _subscriptionStatus({
  required bool premiumActive,
  String userId = 'backend-user',
  bool? purchaseAllowed,
  String? blockReasonCode,
  String? blockingProvider,
  DateTime? checkedAtUtc,
}) =>
    SubscriptionStatus(
      userId: userId,
      planId: premiumActive ? 'premium' : null,
      planName: premiumActive ? 'Premium' : null,
      premiumActive: premiumActive,
      trialActive: false,
      subscriptionStatus: premiumActive ? 'active' : null,
      billingProvider: premiumActive ? 'google_play' : null,
      freeLessonUsedToday: 0,
      freeLessonRemainingToday: premiumActive ? 0 : 1,
      checkedAtUtc: checkedAtUtc ?? DateTime.now().toUtc(),
      googlePlayPurchaseAllowed: purchaseAllowed,
      googlePlayPurchaseBlockReasonCode: blockReasonCode,
      googlePlayPurchaseBlockingProvider: blockingProvider,
      enforcementEnabled: true,
    );

const _product = PremiumStoreProduct(
  productId: 'configured',
  title: 'Premium',
  description: 'Monthly Premium',
  localizedPrice: r'$9.99',
  rawPrice: 9.99,
  currencyCode: 'USD',
  basePlanId: 'monthly',
  offerToken: 'monthly-offer-token',
);

void main() {
  test('fresh explicit backend allow is required immediately before launch',
      () async {
    final trace = <String>[];
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      trace: trace,
      subscriptionStatus: () async => _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'none',
      ),
    );
    final adapter = _EventAdapter(
        products: const [_product], launchResult: true, trace: trace);
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    final result = await coordinator.startPurchase();

    expect(auth.subscriptionStatusCalls, 1);
    expect(adapter.launchCalls, 1);
    expect(adapter.loadedProductIds, {'configured'});
    expect(adapter.launchedProduct, same(_product));
    expect(adapter.launchedProduct?.basePlanId, 'monthly');
    expect(adapter.launchedProduct?.offerToken, 'monthly-offer-token');
    expect(trace, ['catalog', 'catalog', 'backend-gate', 'launch']);
    expect(result.state, PremiumPurchaseCoordinatorState.launching);
    await coordinator.close();
  });

  test('fresh blocked backend status prevents a stale UI launch', () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: false,
        blockReasonCode: 'external_auto_renew_active',
        blockingProvider: 'paddle',
      ),
    );
    final adapter =
        _EventAdapter(products: const [_product], launchResult: true);
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    final result = await coordinator.startPurchase();

    expect(auth.subscriptionStatusCalls, 1);
    expect(adapter.launchCalls, 0);
    expect(result.state, PremiumPurchaseCoordinatorState.blocked);
    expect(result.subscriptionStatus, isNull);
    await coordinator.close();
  });

  test('fresh explicit allow for a different user never launches purchase',
      () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => _subscriptionStatus(
        userId: 'different-backend-user',
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'none',
      ),
    );
    final adapter =
        _EventAdapter(products: const [_product], launchResult: true);
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    final result = await coordinator.startPurchase();

    expect(auth.subscriptionStatusCalls, 1);
    expect(adapter.launchCalls, 0);
    expect(result.state, PremiumPurchaseCoordinatorState.blocked);
    await coordinator.close();
  });

  test('missing, stale, or incomplete allow gate never launches purchase',
      () async {
    final unsafeStatuses = [
      _subscriptionStatus(premiumActive: false),
      _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'none',
        checkedAtUtc: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
      ),
      _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'external_auto_renew_active',
      ),
    ];
    for (final unsafeStatus in unsafeStatuses) {
      final auth = _CoordinatorAuth(
        (_) async => throw StateError('verification is not expected'),
        subscriptionStatus: () async => unsafeStatus,
      );
      final adapter =
          _EventAdapter(products: const [_product], launchResult: true);
      final coordinator = PremiumPurchaseCoordinator(
        authService: auth,
        purchaseAdapter: adapter,
        productIds: {'configured'},
        basePlanId: 'monthly',
      );

      final result = await coordinator.startPurchase();

      expect(result.state, PremiumPurchaseCoordinatorState.blocked);
      expect(adapter.launchCalls, 0);
      await coordinator.close();
    }
  });

  test('status fetch failure prevents launch', () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => throw StateError('backend unavailable'),
    );
    final adapter =
        _EventAdapter(products: const [_product], launchResult: true);
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    final result = await coordinator.startPurchase();

    expect(result.state, PremiumPurchaseCoordinatorState.failed);
    expect(adapter.launchCalls, 0);
    await coordinator.close();
  });

  test('restore remains callable after a new purchase is blocked', () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => _subscriptionStatus(
        premiumActive: true,
        purchaseAllowed: false,
        blockReasonCode: 'external_auto_renew_active',
        blockingProvider: 'google_play',
      ),
    );
    final adapter =
        _EventAdapter(products: const [_product], launchResult: true);
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    expect((await coordinator.startPurchase()).state,
        PremiumPurchaseCoordinatorState.blocked);
    final restoreResult = await coordinator.restorePurchases();

    expect(adapter.launchCalls, 0);
    expect(adapter.restoreCalls, 1);
    expect(restoreResult.state, PremiumPurchaseCoordinatorState.restoring);
    await coordinator.close();
  });

  test('startup catalog failure is recovered by a fresh purchase query',
      () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'none',
      ),
    );
    final adapter = _EventAdapter(
      launchResult: true,
      catalogResults: const [
        PremiumProductLoadResult(failure: PremiumPurchaseFailure.storeError),
        PremiumProductLoadResult(products: [_product]),
      ],
    );
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    await coordinator.initialize();
    expect(coordinator.state, PremiumPurchaseCoordinatorState.unavailable);
    final result = await coordinator.startPurchase();

    expect(result.state, PremiumPurchaseCoordinatorState.launching);
    expect(adapter.loadCalls, 2);
    expect(auth.subscriptionStatusCalls, 1);
    expect(adapter.launchCalls, 1);
    expect(adapter.launchedProduct, same(_product));
    await coordinator.close();
  });

  test('purchase launches the fresh catalog entry instead of startup cache',
      () async {
    const startupProduct = PremiumStoreProduct(
      productId: 'configured',
      title: 'Premium',
      description: 'Monthly Premium',
      localizedPrice: r'$9.99',
      rawPrice: 9.99,
      currencyCode: 'USD',
      basePlanId: 'monthly',
      offerToken: 'startup-token',
    );
    const freshProduct = PremiumStoreProduct(
      productId: 'configured',
      title: 'Premium',
      description: 'Monthly Premium',
      localizedPrice: r'$9.99',
      rawPrice: 9.99,
      currencyCode: 'USD',
      basePlanId: 'monthly',
      offerToken: 'fresh-token',
    );
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'none',
      ),
    );
    final adapter = _EventAdapter(
      launchResult: true,
      catalogResults: const [
        PremiumProductLoadResult(products: [startupProduct]),
        PremiumProductLoadResult(products: [freshProduct]),
      ],
    );
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    await coordinator.initialize();
    final result = await coordinator.startPurchase();

    expect(result.state, PremiumPurchaseCoordinatorState.launching);
    expect(adapter.loadCalls, 2);
    expect(adapter.launchedProduct, same(freshProduct));
    expect(adapter.launchedProduct?.offerToken, 'fresh-token');
    await coordinator.close();
  });

  test('startup store unavailability is rechecked on purchase tap', () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'none',
      ),
    );
    final adapter = _EventAdapter(
      products: const [_product],
      launchResult: true,
      availabilityResults: const [false, true],
    );
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    await coordinator.initialize();
    expect(coordinator.state, PremiumPurchaseCoordinatorState.unavailable);
    final result = await coordinator.startPurchase();

    expect(result.state, PremiumPurchaseCoordinatorState.launching);
    expect(adapter.availabilityCalls, 2);
    expect(adapter.loadCalls, 1);
    expect(adapter.launchCalls, 1);
    await coordinator.close();
  });

  test('user catalog refresh retries once and then recovers', () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
      subscriptionStatus: () async => _subscriptionStatus(
        premiumActive: false,
        purchaseAllowed: true,
        blockReasonCode: 'none',
      ),
    );
    final adapter = _EventAdapter(
      launchResult: true,
      catalogResults: const [
        PremiumProductLoadResult(failure: PremiumPurchaseFailure.storeError),
        PremiumProductLoadResult(failure: PremiumPurchaseFailure.disconnected),
        PremiumProductLoadResult(products: [_product]),
      ],
    );
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    await coordinator.initialize();
    final result = await coordinator.startPurchase();

    expect(result.state, PremiumPurchaseCoordinatorState.launching);
    expect(adapter.loadCalls, 3);
    expect(adapter.launchCalls, 1);
    await coordinator.close();
  });

  test('missing or mismatched monthly catalog entry fails closed', () async {
    const wrongBasePlan = PremiumStoreProduct(
      productId: 'configured',
      title: 'Premium',
      description: 'Annual Premium',
      localizedPrice: r'$99.99',
      rawPrice: 99.99,
      currencyCode: 'USD',
      basePlanId: 'annual',
      offerToken: 'annual-offer-token',
    );
    const monthlyPromotion = PremiumStoreProduct(
      productId: 'configured',
      title: 'Premium',
      description: 'Monthly promotion',
      localizedPrice: r'$4.99',
      rawPrice: 4.99,
      currencyCode: 'USD',
      basePlanId: 'monthly',
      offerId: 'introductory',
      offerToken: 'introductory-offer-token',
    );
    const tokenlessMonthly = PremiumStoreProduct(
      productId: 'configured',
      title: 'Premium',
      description: 'Monthly Premium',
      localizedPrice: r'$9.99',
      rawPrice: 9.99,
      currencyCode: 'USD',
      basePlanId: 'monthly',
    );
    for (final products in const <List<PremiumStoreProduct>>[
      [],
      [wrongBasePlan],
      [monthlyPromotion],
      [tokenlessMonthly],
      [_product, _product],
    ]) {
      final auth = _CoordinatorAuth(
        (_) async => throw StateError('verification is not expected'),
        subscriptionStatus: () async => _subscriptionStatus(
          premiumActive: false,
          purchaseAllowed: true,
          blockReasonCode: 'none',
        ),
      );
      final adapter = _EventAdapter(products: products, launchResult: true);
      final coordinator = PremiumPurchaseCoordinator(
        authService: auth,
        purchaseAdapter: adapter,
        productIds: {'configured'},
        basePlanId: 'monthly',
      );

      final result = await coordinator.startPurchase();

      expect(result.state, PremiumPurchaseCoordinatorState.unavailable);
      expect(auth.subscriptionStatusCalls, 0);
      expect(adapter.launchCalls, 0);
      expect(adapter.loadCalls, 3);
      await coordinator.close();
    }
  });

  test('restore remains available when the monthly catalog entry is missing',
      () async {
    final auth = _CoordinatorAuth(
      (_) async => throw StateError('verification is not expected'),
    );
    final adapter = _EventAdapter();
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
      basePlanId: 'monthly',
    );

    expect((await coordinator.startPurchase()).state,
        PremiumPurchaseCoordinatorState.unavailable);
    final restoreResult = await coordinator.restorePurchases();

    expect(adapter.launchCalls, 0);
    expect(adapter.restoreCalls, 1);
    expect(restoreResult.state, PremiumPurchaseCoordinatorState.restoring);
    await coordinator.close();
  });

  test('unavailable production-safe adapter initializes without store work',
      () async {
    final coordinator = PremiumPurchaseCoordinator(
      authService: AuthService(apiClient: _Api(), storage: _Storage()),
      purchaseAdapter: const UnavailablePremiumPurchaseAdapter(),
    );
    await coordinator.initialize();
    expect(coordinator.state, PremiumPurchaseCoordinatorState.unavailable);
    await coordinator.close();
    coordinator.dispose();
  });

  test('purchase event model can be consumed without local entitlement', () {
    const event = PremiumPurchaseEvent(
      status: PremiumPurchaseEventStatus.pending,
      productId: 'product',
      requiresCompletion: false,
    );
    expect(event.status, PremiumPurchaseEventStatus.pending);
  });

  test('concurrent duplicate purchase events verify one in-flight token',
      () async {
    final pending = Completer<GooglePlayPurchaseVerificationResponse>();
    final auth = _CoordinatorAuth((_) => pending.future);
    final adapter = _EventAdapter();
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
    );
    await coordinator.initialize();
    const event = PremiumPurchaseEvent(
      status: PremiumPurchaseEventStatus.purchased,
      productId: 'configured',
      purchaseToken: 'transient-token',
      requiresCompletion: false,
    );
    adapter.events
      ..add(event)
      ..add(event);
    await Future<void>.delayed(Duration.zero);
    expect(auth.verificationCalls, 1);
    pending.complete(const GooglePlayPurchaseVerificationResponse(
      result: GooglePlayPurchaseVerificationResult.verified,
      subscriptionStatusRefreshRecommended: false,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(coordinator.state, PremiumPurchaseCoordinatorState.completed);
    await coordinator.close();
  });

  test('restored purchase follows the verified backend result', () async {
    final auth = _CoordinatorAuth(
        (_) async => const GooglePlayPurchaseVerificationResponse(
              result: GooglePlayPurchaseVerificationResult.verified,
              subscriptionStatusRefreshRecommended: false,
            ));
    final adapter = _EventAdapter();
    final coordinator = PremiumPurchaseCoordinator(
        authService: auth,
        purchaseAdapter: adapter,
        productIds: {'configured'});
    await coordinator.initialize();
    adapter.events.add(const PremiumPurchaseEvent(
        status: PremiumPurchaseEventStatus.restored,
        productId: 'configured',
        purchaseToken: 'token',
        requiresCompletion: false));
    await Future<void>.delayed(Duration.zero);
    expect(auth.verificationCalls, 1);
    expect(coordinator.state, PremiumPurchaseCoordinatorState.completed);
    await coordinator.close();
  });

  test('verified purchase refreshes and exposes backend Premium status once',
      () async {
    final backendStatus = _subscriptionStatus(premiumActive: true);
    final auth = _CoordinatorAuth(
      (_) async => const GooglePlayPurchaseVerificationResponse(
        result: GooglePlayPurchaseVerificationResult.verified,
        subscriptionStatusRefreshRecommended: true,
      ),
      subscriptionStatus: () async => backendStatus,
    );
    final adapter = _EventAdapter();
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
    );
    await coordinator.initialize();

    adapter.events.add(const PremiumPurchaseEvent(
      status: PremiumPurchaseEventStatus.purchased,
      productId: 'configured',
      purchaseToken: 'refresh-token',
      requiresCompletion: false,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(auth.verificationCalls, 1);
    expect(auth.subscriptionStatusCalls, 1);
    expect(coordinator.state, PremiumPurchaseCoordinatorState.completed);
    expect(coordinator.lastResult?.subscriptionStatus, same(backendStatus));
    expect(coordinator.lastResult?.subscriptionStatus?.premiumActive, isTrue);
    expect(coordinator.lastResult?.subscriptionStatus?.displayLabel, 'Premium');
    await coordinator.close();
  });

  test('verified purchase without refresh does not invent Premium status',
      () async {
    final auth = _CoordinatorAuth(
      (_) async => const GooglePlayPurchaseVerificationResponse(
        result: GooglePlayPurchaseVerificationResult.verified,
        subscriptionStatusRefreshRecommended: false,
      ),
    );
    final adapter = _EventAdapter();
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
    );
    await coordinator.initialize();

    adapter.events.add(const PremiumPurchaseEvent(
      status: PremiumPurchaseEventStatus.purchased,
      productId: 'configured',
      purchaseToken: 'no-refresh-token',
      requiresCompletion: false,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(auth.verificationCalls, 1);
    expect(auth.subscriptionStatusCalls, 0);
    expect(coordinator.state, PremiumPurchaseCoordinatorState.completed);
    expect(coordinator.lastResult?.subscriptionStatus, isNull);
    await coordinator.close();
  });

  test('verified purchase preserves backend non-Premium subscription status',
      () async {
    final backendStatus = _subscriptionStatus(premiumActive: false);
    final auth = _CoordinatorAuth(
      (_) async => const GooglePlayPurchaseVerificationResponse(
        result: GooglePlayPurchaseVerificationResult.verified,
        subscriptionStatusRefreshRecommended: true,
      ),
      subscriptionStatus: () async => backendStatus,
    );
    final adapter = _EventAdapter();
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
    );
    await coordinator.initialize();

    adapter.events.add(const PremiumPurchaseEvent(
      status: PremiumPurchaseEventStatus.purchased,
      productId: 'configured',
      purchaseToken: 'backend-free-token',
      requiresCompletion: false,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(auth.verificationCalls, 1);
    expect(auth.subscriptionStatusCalls, 1);
    expect(coordinator.state, PremiumPurchaseCoordinatorState.completed);
    expect(coordinator.lastResult?.subscriptionStatus, same(backendStatus));
    expect(coordinator.lastResult?.subscriptionStatus?.premiumActive, isFalse);
    expect(coordinator.lastResult?.subscriptionStatus?.displayLabel, 'Free');
    await coordinator.close();
  });

  test('verified purchase status refresh failure does not synthesize Premium',
      () async {
    final auth = _CoordinatorAuth(
      (_) async => const GooglePlayPurchaseVerificationResponse(
        result: GooglePlayPurchaseVerificationResult.verified,
        subscriptionStatusRefreshRecommended: true,
      ),
      subscriptionStatus: () async => throw StateError('backend unavailable'),
    );
    final adapter = _EventAdapter();
    final coordinator = PremiumPurchaseCoordinator(
      authService: auth,
      purchaseAdapter: adapter,
      productIds: {'configured'},
    );
    await coordinator.initialize();

    adapter.events.add(const PremiumPurchaseEvent(
      status: PremiumPurchaseEventStatus.purchased,
      productId: 'configured',
      purchaseToken: 'refresh-failure-token',
      requiresCompletion: false,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(auth.verificationCalls, 1);
    expect(auth.subscriptionStatusCalls, 1);
    expect(coordinator.state, PremiumPurchaseCoordinatorState.completed);
    expect(coordinator.lastResult?.subscriptionStatus, isNull);
    await coordinator.close();
  });

  test('acknowledgement pending and unsafe results remain fail-closed',
      () async {
    for (final result in GooglePlayPurchaseVerificationResult.values.where(
        (value) => value != GooglePlayPurchaseVerificationResult.verified)) {
      final auth =
          _CoordinatorAuth((_) async => GooglePlayPurchaseVerificationResponse(
                result: result,
                subscriptionStatusRefreshRecommended: false,
              ));
      final adapter = _EventAdapter();
      final coordinator = PremiumPurchaseCoordinator(
          authService: auth,
          purchaseAdapter: adapter,
          productIds: {'configured'});
      await coordinator.initialize();
      adapter.events.add(const PremiumPurchaseEvent(
          status: PremiumPurchaseEventStatus.purchased,
          productId: 'configured',
          purchaseToken: 'token',
          requiresCompletion: false));
      await Future<void>.delayed(Duration.zero);
      final expected = result == GooglePlayPurchaseVerificationResult.pending ||
              result ==
                  GooglePlayPurchaseVerificationResult.acknowledgementPending
          ? PremiumPurchaseCoordinatorState.pending
          : PremiumPurchaseCoordinatorState.failed;
      expect(coordinator.state, expected, reason: '$result must fail closed');
      await coordinator.close();
    }
  });
}
