import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/premium_purchase.dart';
import 'package:language_voice_tutor_mobile/models/google_play_purchase_verification.dart';
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
  _CoordinatorAuth(this.verification)
      : super(apiClient: _Api(), storage: _Storage());
  final Future<GooglePlayPurchaseVerificationResponse> Function(String)
      verification;
  int verificationCalls = 0;

  @override
  Future<GooglePlayPurchaseVerificationResponse> verifyGooglePlayPurchase(
      String token) {
    verificationCalls++;
    return verification(token);
  }
}

class _EventAdapter implements PremiumPurchaseAdapter {
  _EventAdapter()
      : events = StreamController<PremiumPurchaseEvent>.broadcast(
          onListen: () {},
        );
  final StreamController<PremiumPurchaseEvent> events;
  int initializeCalls = 0;
  int subscriptions = 0;
  int disposeCalls = 0;
  @override
  Stream<PremiumPurchaseEvent> get purchaseEvents {
    subscriptions++;
    return events.stream;
  }

  @override
  Future<void> initialize() async => initializeCalls++;
  @override
  Future<bool> get isAvailable async => true;
  @override
  Future<PremiumProductLoadResult> loadSubscriptionProducts(
          Set<String> productIds) async =>
      const PremiumProductLoadResult(products: []);
  @override
  Future<bool> launchSubscriptionOffer(PremiumStoreProduct product,
          {String? obfuscatedAccountId}) async =>
      false;
  @override
  Future<void> restorePurchases({String? obfuscatedAccountId}) async {}
  @override
  Future<void> dispose() async {
    disposeCalls++;
    await events.close();
  }
}

void main() {
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
}
