import '../api/api_client.dart';
import '../config/app_config.dart';
import 'auth_service.dart';
import 'premium_purchase_adapter.dart';
import 'premium_purchase_coordinator.dart';
import 'session_storage.dart';
import 'restore_credentials_platform.dart';
import 'restore_credentials_service.dart';
import 'restore_credentials_state.dart';

AuthService createAuthService() {
  final apiClient = HttpApiClient();
  final storage = SecureSessionStorage();
  return AuthService(
    apiClient: apiClient,
    storage: storage,
    restoreCredentialsService: RestoreCredentialsService(
      apiClient: apiClient,
      sessionStorage: storage,
      platform: MethodChannelRestoreCredentialsPlatform(),
      state: SecureRestoreCredentialsState(),
    ),
  );
}

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
