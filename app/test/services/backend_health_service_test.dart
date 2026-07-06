import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/services/backend_health_service.dart';

class FakeApiClient implements ApiClient {
  FakeApiClient(this.response);

  final Future<ApiResponse> Function(String path) response;
  String? requestedPath;

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) {
    requestedPath = path;
    return response(path);
  }

  @override
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body, String? accessToken}) => throw UnimplementedError();
}

void main() {
  group('BackendHealthService', () {
    test('calls /health and parses a successful response', () async {
      final apiClient = FakeApiClient(
        (_) async => const ApiResponse(
          statusCode: 200,
          body:
              '{"status":"ok","environment":"production","checkedAtUtc":"2026-07-06T12:00:00Z"}',
        ),
      );
      final service = BackendHealthService(apiClient: apiClient);

      final status = await service.checkHealth();

      expect(apiClient.requestedPath, '/health');
      expect(status.status, 'ok');
      expect(status.environment, 'production');
    });

    test('throws for unsuccessful status responses', () {
      final service = BackendHealthService(
        apiClient: FakeApiClient(
          (_) async => const ApiResponse(statusCode: 503, body: '{}'),
        ),
      );

      expect(service.checkHealth(), throwsFormatException);
    });

    test('throws for invalid response bodies', () {
      final service = BackendHealthService(
        apiClient: FakeApiClient(
          (_) async => const ApiResponse(statusCode: 200, body: '[]'),
        ),
      );

      expect(service.checkHealth(), throwsFormatException);
    });
  });
}
