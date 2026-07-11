import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../config/app_config.dart';

class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class BinaryApiResponse {
  const BinaryApiResponse({
    required this.statusCode,
    required this.bodyBytes,
    required this.headers,
  });

  final int statusCode;
  final Uint8List bodyBytes;
  final Map<String, String> headers;

  String? header(String name) => headers[name.toLowerCase()];
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

/// Optional capability kept separate so existing JSON-only fakes remain valid.
abstract class BinaryApiClient {
  Future<BinaryApiResponse> postBinary(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
  });
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HttpApiClient implements ApiClient, BinaryApiClient {
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

  @override
  Future<BinaryApiResponse> postBinary(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    try {
      final requestUri = _baseUri.resolve(
        path.startsWith('/') ? path.substring(1) : path,
      );
      final request = await _httpClient.openUrl('POST', requestUri).timeout(
            _timeout,
          );
      request.headers.set(HttpHeaders.acceptHeader, 'audio/wav');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));

      final response = await request.close().timeout(_timeout);
      final bytes = await response.fold<List<int>>(
        <int>[],
        (all, chunk) => all..addAll(chunk),
      ).timeout(_timeout);
      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name.toLowerCase()] = values.join(',');
      });
      return BinaryApiResponse(
        statusCode: response.statusCode,
        bodyBytes: Uint8List.fromList(bytes),
        headers: headers,
      );
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
