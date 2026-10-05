import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';

class _Headers implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  set contentType(ContentType? value) {}
  @override
  void forEach(void Function(String name, List<String> values) action) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response([Stream<List<int>>? body]) : _body = body ?? Stream.value([1, 2]);
  final Stream<List<int>> _body;
  @override
  int get statusCode => 200;
  @override
  HttpHeaders get headers => _Headers();
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _body.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Request implements HttpClientRequest {
  final response = Completer<HttpClientResponse>();
  @override
  HttpHeaders get headers => _Headers();
  @override
  void write(Object? object) {}
  @override
  Future<void> addStream(Stream<List<int>> stream) async {}
  @override
  Future<HttpClientResponse> close() => response.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Client implements HttpClient {
  final request = _Request();
  int opens = 0;
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    opens++;
    return request;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'speech survives the former 10-second cutoff and succeeds at 18.404 seconds',
    (tester) async {
      final http = _Client();
      final client = HttpApiClient(httpClient: http);
      BinaryApiResponse? result;
      Object? failure;
      final operation =
          client.postBinary('/api/audio/speech', body: {}).then<void>(
        (value) {
          result = value;
        },
        onError: (Object error) {
          failure = error;
        },
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 18404));
      expect(failure, isNull);
      expect(result, isNull);
      http.request.response.complete(_Response());
      await tester.pump();
      await operation;
      expect(result?.bodyBytes, [1, 2]);
      expect(http.opens, 1);
    },
  );

  testWidgets('speech expires at 25 seconds without retrying', (tester) async {
    final http = _Client();
    final client = HttpApiClient(httpClient: http);
    Object? failure;
    final operation =
        client.postBinary('api/audio/speech', body: {}).then<Object?>(
      (value) => value,
      onError: (Object error) {
        failure = error;
        return null;
      },
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 24999));
    expect(failure, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    await operation;
    expect(
      failure,
      isA<ApiException>().having(
        (error) => error.category,
        'category',
        ApiFailureCategory.timeout,
      ),
    );
    expect(http.opens, 1);
    http.request.response.complete(_Response());
    await tester.pump();
  });

  testWidgets(
    'speech response headers and WAV body share the same 25-second budget',
    (tester) async {
      final http = _Client();
      final client = HttpApiClient(httpClient: http);
      final body = StreamController<List<int>>();
      Object? failure;
      final operation =
          client.postBinary('/api/audio/speech', body: {}).then<Object?>(
        (value) => value,
        onError: (Object error) {
          failure = error;
          return null;
        },
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 18));
      http.request.response.complete(_Response(body.stream));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(failure, isNull);
      await tester.pump(const Duration(seconds: 1));
      await operation;
      expect(
        failure,
        isA<ApiException>().having(
          (error) => error.category,
          'category',
          ApiFailureCategory.timeout,
        ),
      );
      await body.close();
      await tester.pump();
    },
  );

  for (final method in ['GET', 'POST', 'PUT', 'binary']) {
    testWidgets('$method retains the default 10-second timeout', (
      tester,
    ) async {
      final http = _Client();
      final client = HttpApiClient(httpClient: http);
      Object? failure;
      final Future<Object> response = switch (method) {
        'GET' => client.get('/api/me'),
        'POST' => client.post('/api/lesson/reply', body: {}),
        'PUT' => client.put('/api/me/settings', body: {}),
        _ => client.postBinary('/api/other-binary', body: {}),
      };
      final operation = response.then<Object?>(
        (value) => value,
        onError: (Object error) {
          failure = error;
          return null;
        },
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 9999));
      expect(failure, isNull);
      await tester.pump(const Duration(milliseconds: 1));
      await operation;
      expect(
        failure,
        isA<ApiException>().having(
          (error) => error.category,
          'category',
          ApiFailureCategory.timeout,
        ),
      );
      http.request.response.complete(_Response());
      await tester.pump();
    });
  }

  testWidgets(
    'learner multipart transcription retains its 10-second response timeout',
    (tester) async {
      final http = _Client();
      final client = HttpApiClient(httpClient: http);
      late File file;
      await tester.runAsync(() async {
        file = File(
          '${Directory.systemTemp.path}${Platform.pathSeparator}tts-timeout-transcription-test.wav',
        );
        await file.writeAsBytes([1, 2]);
      });
      Object? failure;
      late Future<Object?> operation;
      operation = client
          .postMultipartWav(
        '/api/audio/transcribe',
        fields: {},
        file: MultipartWavFile(path: file.path, fieldName: 'file'),
      )
          .then<Object?>(
        (value) => value,
        onError: (Object error) {
          failure = error;
          return null;
        },
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      await operation;
      expect(
        failure,
        isA<ApiException>().having(
          (error) => error.category,
          'category',
          ApiFailureCategory.timeout,
        ),
      );
      http.request.response.complete(_Response());
      await tester.pump();
      await tester.runAsync(() => file.delete());
    },
  );
}
