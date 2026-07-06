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
  Future<ApiResponse> get(String path, {String? accessToken});
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  });
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  });
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
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
  Future<ApiResponse> get(String path, {String? accessToken}) =>
      _send('GET', path, accessToken: accessToken);

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) =>
      _send('POST', path, body: body, accessToken: accessToken);

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) =>
      _send('PUT', path, body: body, accessToken: accessToken);

  Future<ApiResponse> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    try {
      final requestUri = _baseUri.resolve(
        path.startsWith('/') ? path.substring(1) : path,
      );
      final request = await _httpClient.openUrl(method, requestUri).timeout(
            _timeout,
          );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(_timeout);
      final responseBody =
          await response.transform(utf8.decoder).join().timeout(_timeout);

      return ApiResponse(statusCode: response.statusCode, body: responseBody);
    } on TimeoutException {
      throw const ApiException('The service took too long to respond.');
    } on SocketException {
      throw const ApiException('Unable to reach the service.');
    } on FormatException {
      throw const ApiException('The service returned an unexpected response.');
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.');
    }
  }
}
