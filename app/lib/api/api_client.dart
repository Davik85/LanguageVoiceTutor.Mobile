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

class MultipartApiResponse {
  const MultipartApiResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

class MultipartWavFile {
  const MultipartWavFile({required this.path, required this.fieldName});

  final String path;
  final String fieldName;
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

/// Kept separate so existing JSON and binary fakes do not acquire a new API.
abstract class MultipartApiClient {
  Future<MultipartApiResponse> postMultipartWav(
    String path, {
    required Map<String, String> fields,
    required MultipartWavFile file,
    String? accessToken,
  });
}

enum ApiFailureCategory { timeout, network, cancellation, transport, unknown }

class ApiException implements Exception {
  const ApiException(this.message,
      {this.category = ApiFailureCategory.unknown});

  final String message;
  final ApiFailureCategory category;

  @override
  String toString() => message;
}

class HttpApiClient implements ApiClient, BinaryApiClient, MultipartApiClient {
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
      throw const ApiException('The service took too long to respond.',
          category: ApiFailureCategory.timeout);
    } on SocketException {
      throw const ApiException('Unable to reach the service.',
          category: ApiFailureCategory.network);
    } on FormatException {
      throw const ApiException('The service returned an unexpected response.',
          category: ApiFailureCategory.transport);
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.',
          category: ApiFailureCategory.unknown);
    }
  }

  @override
  Future<MultipartApiResponse> postMultipartWav(
    String path, {
    required Map<String, String> fields,
    required MultipartWavFile file,
    String? accessToken,
  }) async {
    try {
      final input = File(file.path);
      if (!file.path.toLowerCase().endsWith('.wav') || !await input.exists()) {
        throw const ApiException('Recording file is unavailable.');
      }
      final requestUri = _baseUri.resolve(
        path.startsWith('/') ? path.substring(1) : path,
      );
      final request =
          await _httpClient.openUrl('POST', requestUri).timeout(_timeout);
      final boundary =
          'languagevoicetutor-${DateTime.now().microsecondsSinceEpoch}';
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }
      request.headers.contentType = ContentType(
        'multipart',
        'form-data',
        parameters: {'boundary': boundary},
      );
      for (final entry in fields.entries) {
        request.write('--$boundary\r\n');
        request.write(
            'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n');
        request.write('${entry.value}\r\n');
      }
      final fileName = input.uri.pathSegments.last;
      request.write('--$boundary\r\n');
      request.write(
          'Content-Disposition: form-data; name="${file.fieldName}"; filename="$fileName"\r\n');
      request.write('Content-Type: audio/wav\r\n\r\n');
      await request.addStream(input.openRead()).timeout(_timeout);
      request.write('\r\n--$boundary--\r\n');
      final response = await request.close().timeout(_timeout);
      final body =
          await response.transform(utf8.decoder).join().timeout(_timeout);
      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name.toLowerCase()] = values.join(',');
      });
      return MultipartApiResponse(
        statusCode: response.statusCode,
        body: body,
        headers: headers,
      );
    } on TimeoutException {
      throw const ApiException('The service took too long to respond.',
          category: ApiFailureCategory.timeout);
    } on SocketException {
      throw const ApiException('Unable to reach the service.',
          category: ApiFailureCategory.network);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.',
          category: ApiFailureCategory.transport);
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
      throw const ApiException('The service took too long to respond.',
          category: ApiFailureCategory.timeout);
    } on SocketException {
      throw const ApiException('Unable to reach the service.',
          category: ApiFailureCategory.network);
    } on FormatException {
      throw const ApiException('The service returned an unexpected response.',
          category: ApiFailureCategory.transport);
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.',
          category: ApiFailureCategory.unknown);
    }
  }
}
