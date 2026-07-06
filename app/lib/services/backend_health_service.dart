import 'dart:convert';

import '../api/api_client.dart';
import '../models/backend_health_status.dart';

class BackendHealthService {
  const BackendHealthService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<BackendHealthStatus> checkHealth() async {
    final response = await _apiClient.get('/health');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const FormatException('Health endpoint returned an unsuccessful status.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Health endpoint returned an invalid response.');
    }

    return BackendHealthStatus.fromJson(decoded);
  }
}
