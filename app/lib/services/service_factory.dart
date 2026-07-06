import '../api/api_client.dart';
import 'auth_service.dart';
import 'session_storage.dart';

AuthService createAuthService() => AuthService(
      apiClient: HttpApiClient(),
      storage: SecureSessionStorage(),
    );
