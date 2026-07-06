import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';

class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

abstract class ApiClient {
  Future<ApiResponse> get(String path);
}

class HttpApiClient implements ApiClient {
  HttpApiClient({
    String baseUrl = AppConfig.productionApiBaseUrl,
    Duration timeout = const Duration(seconds: 10),
    HttpClient? httpClient,
  })  : _baseUri = Uri.parse(baseUrl),
        _timeout = timeout,
        _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final Duration _timeout;
  final HttpClient _httpClient;

  @override
  Future<ApiResponse> get(String path) async {
    final requestUri = _baseUri.resolve(
      path.startsWith('/') ? path.substring(1) : path,
    );
    final request = await _httpClient.getUrl(requestUri).timeout(_timeout);
    final response = await request.close().timeout(_timeout);
    final body =
        await response.transform(utf8.decoder).join().timeout(_timeout);

    return ApiResponse(statusCode: response.statusCode, body: body);
  }
}
