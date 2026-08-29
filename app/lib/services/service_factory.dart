import '../api/api_client.dart';
import '../config/app_config.dart';
import 'auth_service.dart';
import 'premium_purchase_adapter.dart';
import 'premium_purchase_coordinator.dart';
import 'session_storage.dart';

AuthService createAuthService() => AuthService(
      apiClient: HttpApiClient(),
      storage: SecureSessionStorage(),
    );

PremiumPurchaseCoordinator createPremiumPurchaseCoordinator({
  required AuthService authService,
  PremiumPurchaseAdapter? purchaseAdapter,
}) =>
    PremiumPurchaseCoordinator(
      authService: authService,
      purchaseAdapter: purchaseAdapter ?? GooglePlayPremiumPurchaseAdapter(),
      productIds: {AppConfig.googlePlayPremiumProductId},
      basePlanId: AppConfig.googlePlayPremiumBasePlanId,
    );
