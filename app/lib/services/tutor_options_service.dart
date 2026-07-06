import 'dart:convert';

import '../api/api_client.dart';
import '../models/tutor_options.dart';

class TutorOptionsService {
  const TutorOptionsService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<TutorOptions> fetchTutorOptions() async {
    final response = await _apiClient.get('/api/tutor-options');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('Unable to load practice options right now.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('The service returned an unexpected response.');
      }
      return TutorOptions.fromJson(decoded);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('The service returned an unexpected response.');
    }
  }
}
