import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/device_registration.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/http_audio_diagnostics.dart';

import '../support/tracking_fakes.dart';

Uint8List _chunk(String id, Uint8List body) {
  final result = Uint8List(8 + body.length + (body.length & 1));
  result.setRange(0, 4, id.codeUnits);
  ByteData.sublistView(result).setUint32(4, body.length, Endian.little);
  result.setRange(8, 8 + body.length, body);
  return result;
}

Uint8List _wav(List<double> seconds,
    {int bits = 16,
    int channels = 1,
    int format = 1,
    bool dataFirst = false,
    bool quarterWindows = false,
    int? frameCount}) {
  const rate = 8; // Tiny synthetic fixtures: eight frames per second.
  final framesPerStep = quarterWindows ? 2 : rate;
  final frames = frameCount ?? seconds.length * framesPerStep;
  final width = bits ~/ 8;
  final fmt = ByteData(16)
    ..setUint16(0, format, Endian.little)
    ..setUint16(2, channels, Endian.little)
    ..setUint32(4, rate, Endian.little)
    ..setUint32(8, rate * channels * width, Endian.little)
    ..setUint16(12, channels * width, Endian.little)
    ..setUint16(14, bits, Endian.little);
  final pcm = ByteData(frames * channels * width);
  for (var frame = 0; frame < frames; frame++) {
    final value = (seconds[frame ~/ framesPerStep] *
            (1 << (bits - 1)) *
            (frame.isEven ? 1 : -1))
        .round();
    for (var channel = 0; channel < channels; channel++) {
      final offset = (frame * channels + channel) * width;
      switch (bits) {
        case 8:
          pcm.setUint8(offset, value + 128);
        case 16:
          pcm.setInt16(offset, value, Endian.little);
        case 24:
          for (var b = 0; b < 3; b++) {
            pcm.setUint8(offset + b, (value >> (8 * b)) & 255);
          }
        case 32:
          pcm.setInt32(offset, value, Endian.little);
      }
    }
  }
  final chunks = [
    _chunk('JUNK', Uint8List.fromList([1, 2, 3])), // Odd chunk + padding.
    if (dataFirst) _chunk('data', pcm.buffer.asUint8List()),
    _chunk('fmt ', fmt.buffer.asUint8List()),
    if (!dataFirst) _chunk('data', pcm.buffer.asUint8List()),
  ];
  final header = Uint8List(12);
  header.setRange(0, 4, 'RIFF'.codeUnits);
  header.setRange(8, 12, 'WAVE'.codeUnits);
  ByteData.sublistView(header).setUint32(
      4, 4 + chunks.fold<int>(0, (sum, c) => sum + c.length), Endian.little);
  final builder = BytesBuilder()..add(header);
  for (final chunk in chunks) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}

class _Headers implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  set contentType(ContentType? value) {}
  @override
  void forEach(void Function(String, List<String>) action) =>
      action('content-type', ['audio/wav']);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response(this.statusCode, this.body);
  @override
  final int statusCode;
  final Stream<List<int>> body;
  @override
  HttpHeaders get headers => _Headers();
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      body.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Request implements HttpClientRequest {
  _Request(this.send, {this.onWrite});
  final Future<HttpClientResponse> Function() send;
  final void Function(Object?)? onWrite;
  @override
  HttpHeaders get headers => _Headers();
  @override
  void write(Object? object) => onWrite?.call(object);
  @override
  Future<HttpClientResponse> close() => send();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Http implements HttpClient {
  _Http(this.send, {this.onWrite});
  final Future<HttpClientResponse> Function() send;
  final void Function(Object?)? onWrite;
  int closes = 0;
  @override
  Future<HttpClientRequest> openUrl(String method, Uri uri) async =>
      _Request(() {
        closes++;
        return send();
      }, onWrite: onWrite);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<String> lines;
  late DebugPrintCallback original;
  setUp(() {
    lines = [];
    original = debugPrint;
    debugPrint = (line, {wrapWidth}) {
      if (line != null) lines.add(line);
    };
  });
  tearDown(() => debugPrint = original);

  String measure(Uint8List bytes) {
    ReceivedTutorWavDiagnostics(enabled: true, output: lines.add)
        .record(bytes, status: 200);
    return lines.single;
  }

  for (final bits in [8, 16, 24, 32]) {
    test('active $bits-bit stereo PCM, odd chunks and nonstandard data offset',
        () {
      final bytes =
          _wav([0.25, 0.25], bits: bits, channels: 2, dataFirst: true);
      final before = Uint8List.fromList(bytes);
      final line = measure(bytes);
      expect(line, contains('analysis=pcm rate=8 channels=2 bits=$bits'));
      expect(
          line,
          contains(
              'durationMs=2000 windowMs=250 lastWindowMs=250 windows=8 activity=active'));
      expect(line, contains('levelsDbRmsPeak=[0:-12/-12,1:-12/-12,'));
      expect(line, contains('lowWindows=0 lowMs=[]'));
      expect(line, contains('tailMs=0 tailAfterActive=false'));
      expect(bytes, orderedEquals(before));
    });
  }
  test('three seconds active then six seconds near-silent tail', () {
    final line = measure(_wav([0.25, 0.25, 0.25, 0, 0, 0, 0, 0, 0]));
    expect(line, contains('activity=partial_near_silence'));
    expect(line, contains('quietMs=[3000-9000]'));
    expect(line, contains('tailMs=6000 tailAfterActive=true'));
    expect(
        line, matches(RegExp(r'utc=\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z')));
  });
  test('all-zero unsigned PCM differs from a tail following activity', () {
    final line = measure(_wav([0, 0, 0], bits: 8));
    expect(line, contains('activity=all_zero'));
    expect(line, contains('tailMs=3000 tailAfterActive=false'));
  });
  test('nonzero low-level signal is measured as entirely near-silent', () {
    expect(measure(_wav([0.0005, 0.0005, 0.0005])),
        contains('activity=all_near_silent'));
  });
  test('a short quiet end is not called a sustained tail', () {
    final line = measure(_wav([0.25, 0]));
    expect(line, contains('quietMs=[]'));
    expect(line, contains('tailMs=0'));
  });
  test('truncated RIFF and forged chunk boundaries are invalid', () {
    final wav = _wav([0.25]);
    expect(measure(Uint8List.sublistView(wav, 0, wav.length - 1)),
        contains('analysis=invalid reason=riff_size'));
    lines.clear();
    ByteData.sublistView(wav).setUint32(16, 0xffffffff, Endian.little);
    expect(measure(wav), contains('analysis=invalid reason=chunk_bounds'));
    lines.clear();
    expect(measure(Uint8List(4)), contains('analysis=invalid reason=header'));
  });
  test('float encoding is unsupported and never treated as integer PCM', () {
    expect(measure(_wav([0.25], format: 3)),
        contains('analysis=unsupported reason=encoding'));
  });
  test('scan and output have explicit bounds', () {
    final line = measure(_wav(List.filled(40, 0.25)));
    expect(line, contains('windows=160'));
    expect(line, contains('levelsOmitted=144'));
    expect(line.length, lessThan(1200));
    lines.clear();
    expect(measure(_wav(List.filled(121, 0))),
        contains('analysis=unsupported reason=scan_limit'));
  });
  test('flag defaults off; explicit disable and logger failures are isolated',
      () {
    final wav = _wav([0.25]);
    ReceivedTutorWavDiagnostics().record(wav, status: 200);
    const requested = bool.fromEnvironment('LVT_DIAG_AUDIO_TRACE');
    expect(lines.length, !kReleaseMode && requested ? 1 : 0);
    lines.clear();
    ReceivedTutorWavDiagnostics(enabled: false, output: lines.add)
        .record(wav, status: 200);
    expect(lines, isEmpty);
    expect(
        () => ReceivedTutorWavDiagnostics(
                enabled: true,
                output: (_) => throw StateError('private logger failure'))
            .record(wav, status: 200),
        returnsNormally);
  });
  test('completed HTTP speech bytes are measured once and delivered unchanged',
      () async {
    final wav = _wav([0.25, 0, 0, 0]);
    final stream = StreamController<List<int>>();
    final http = _Http(() async => _Response(200, stream.stream));
    final operation = HttpApiClient(httpClient: http)
        .postBinary('/api/audio/speech', body: {'text': 'private speech'});
    await Future<void>.delayed(Duration.zero);
    stream.add(wav.sublist(0, 12));
    await Future<void>.delayed(Duration.zero);
    expect(lines.where((s) => s.startsWith('[TutorWavReceived]')), isEmpty);
    stream.add(wav.sublist(12));
    await stream.close();
    final result = await operation;
    expect(result.bodyBytes, orderedEquals(wav));
    final waves = lines.where((s) => s.startsWith('[TutorWavReceived]'));
    expect(waves.length, ReceivedTutorWavDiagnostics.configuredEnabled ? 1 : 0);
    if (waves.isNotEmpty) {
      expect(waves.single, contains('tailMs=3000 tailAfterActive=true'));
      expect(lines.join(), isNot(contains('private')));
    }
  });
  test(
      'malformed audio and failed diagnostic output cannot break HTTP delivery',
      () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    debugPrint = (_, {wrapWidth}) => throw StateError('private logger failure');
    final http = _Http(() async => _Response(200, Stream.value(bytes)));
    final result = await HttpApiClient(httpClient: http)
        .postBinary('/api/audio/speech', body: {});
    expect(result.bodyBytes, orderedEquals(bytes));
    final registration =
        await HttpApiClient(httpClient: http).post('/api/me/devices', body: {});
    expect(registration.statusCode, 200);
  });
  test('real registration retries have distinct attempts and body completion',
      () async {
    final body = StreamController<List<int>>();
    final http = _Http(() async => _Response(401, body.stream));
    final operation = HttpApiClient(httpClient: http).post('/api/me/devices',
        body: {'deviceName': 'private device'}, accessToken: 'private token');
    await Future<void>.delayed(Duration.zero);
    expect(lines.single, contains('event=dispatch'));
    expect(http.closes, 1);
    body.add([123, 125]);
    await body.close();
    expect((await operation).statusCode, 401);
    final second = HttpApiClient(
        httpClient:
            _Http(() async => _Response(200, Stream.value([123, 125]))));
    await second.post('/api/me/devices', body: {});
    expect(lines.length, 4);
    expect(lines[1], contains('event=complete'));
    expect(lines[1], contains('status=401'));
    expect(lines[3], contains('status=200'));
    final ids = lines.map((s) => RegExp(r'attempt=(\d+)').firstMatch(s)![1]);
    expect(ids.toSet().length, 2);
    for (final line in lines) {
      expect(
          line, matches(RegExp(r'utc=\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z')));
      expect(line, matches(RegExp(r'elapsedMs=\d+')));
      expect(line, isNot(contains('private')));
    }
  });
  test('authentication recovery produces two actual anonymous HTTP attempts',
      () async {
    const disabled =
        bool.fromEnvironment('LVT_DIAG_DISABLE_DEVICE_REGISTRATION');
    var count = 0;
    final authJson = TrackingApi().authBody;
    final http = _Http(() async {
      final step = count++;
      return _Response(step == 1 ? 401 : 200,
          Stream.value((step == 0 || step == 2 ? authJson : '{}').codeUnits));
    });
    final auth = AuthService(
        apiClient: HttpApiClient(httpClient: http), storage: TrackingStorage());
    await auth.loadCurrentUser();
    await auth.registerDevice(
        'user-1',
        const DeviceRegistrationRequest(
            deviceName: 'private device', appVersion: 'private version'));
    final attempts =
        lines.where((s) => s.startsWith('[DeviceRegistrationHTTP]'));
    expect(http.closes, disabled ? 1 : 4);
    expect(attempts.length, disabled ? 0 : 4);
    if (!disabled) {
      final logs = attempts.toList();
      expect(logs[1], contains('status=401'));
      expect(logs[3], contains('status=200'));
      expect(
          logs
              .map((s) => RegExp(r'attempt=(\d+)').firstMatch(s)![1])
              .toSet()
              .length,
          2);
    }
  });
  test('empty PCM, bad frame alignment and missing odd padding are invalid',
      () {
    expect(
        measure(_wav([])), contains('analysis=invalid reason=pcm_alignment'));
    lines.clear();
    final badAlign = _wav([0.25]);
    // JUNK is 12 bytes; fmt starts at 24 and its body at 32.
    ByteData.sublistView(badAlign).setUint16(44, 3, Endian.little);
    expect(
        measure(badAlign), contains('analysis=invalid reason=pcm_alignment'));
    lines.clear();
    final odd = _wav([0.25], bits: 8);
    // Last data payload is truncated but RIFF length updated to remain coherent.
    final missing = Uint8List.sublistView(odd, 0, odd.length - 1);
    final view = ByteData.sublistView(missing);
    view.setUint32(4, missing.length - 8, Endian.little);
    view.setUint32(52, 7, Endian.little);
    expect(measure(missing), contains('analysis=invalid reason=chunk_bounds'));
  });
  test('failed registration dispatch has only a sanitized category', () async {
    final http = _Http(() async => throw const SocketException('private host'));
    await expectLater(HttpApiClient(httpClient: http).post('/api/me/devices'),
        throwsA(isA<ApiException>()));
    expect(lines.length, 2);
    expect(lines.last, contains('failure=network'));
    expect(lines.join(), isNot(contains('private')));
  });
  test('suppressed or rejected registration never logs a dispatch', () async {
    const disabled =
        bool.fromEnvironment('LVT_DIAG_DISABLE_DEVICE_REGISTRATION');
    final http = _Http(() async => _Response(200, Stream.value([123, 125])));
    final auth = AuthService(
        apiClient: HttpApiClient(httpClient: http), storage: TrackingStorage());
    await auth.registerDevice(
        'unknown',
        const DeviceRegistrationRequest(
            deviceName: 'private device', appVersion: 'private version'));
    expect(http.closes, 0);
    expect(
        lines, ['[DeviceRegistration] ${disabled ? 'suppressed' : 'enabled'}']);
  });

  for (final quarters in [1, 2, 3]) {
    test('${quarters * 250} ms low gap is separate from near-silence', () {
      final samples = List.filled(20, 0.25);
      for (var i = 5; i < 5 + quarters; i++) {
        samples[i] = 0.0015;
      }
      final line = measure(_wav(samples, quarterWindows: true));
      expect(line, contains('activity=active quietWindows=0'));
      expect(line, contains('lowMs=[1250-${1250 + 250 * quarters}:middle]'));
      expect(line, contains('longestLowMs=${250 * quarters}'));
      expect(line, contains('lowMiddle=true lowNearEnd=false'));
    });
  }
  test('low tail and entirely silent signal report positions and longest run',
      () {
    final line =
        measure(_wav([0.25, 0.25, 0.0015, 0.0015], quarterWindows: true));
    expect(line, contains('lowMs=[500-1000:tail]'));
    expect(line, contains('lowMiddle=false lowNearEnd=true'));
    expect(
        line, contains('longestLowMs=500 longestLowAt=500-1000 lowTailMs=500'));
    lines.clear();
    final silence = measure(_wav([0, 0, 0]));
    expect(silence, contains('activity=all_zero'));
    expect(silence, contains('lowMs=[0-3000:whole]'));
    expect(silence, contains('longestLowMs=3000'));
  });
  test(
      'unrounded RMS threshold classifies PCM values on either side of -50 dBFS',
      () {
    final line = measure(
        _wav([0.25, 103 / 32768, 104 / 32768, 0.25], quarterWindows: true));
    expect(line, contains('quietWindows=0'));
    expect(line, contains('lowWindows=1 lowMs=[250-500:near_end]'));
    expect(
        line,
        contains(
            '1:-50/-50,2:-50/-50')); // Rounded levels alone cannot classify.
  });
  test('partial final window uses actual frames and duration', () {
    final line = measure(_wav([0.25, 0.25, 0.25, 0.0015, 0.0015],
        quarterWindows: true, frameCount: 9));
    expect(line,
        contains('durationMs=1125 windowMs=250 lastWindowMs=125 windows=5'));
    expect(line, contains('lowMs=[750-1125:tail]'));
    expect(line, contains('longestLowMs=375'));
  });
  test('bounded interval output still measures a later longest low run', () {
    final samples = [
      for (var i = 0; i < 14; i++) i.isEven ? 0.25 : 0.0015,
      ...List.filled(4, 0.25),
      ...List.filled(8, 0.0015)
    ];
    final line = measure(_wav(samples, quarterWindows: true));
    expect(line, contains('lowIntervalsOmitted=2'));
    expect(line, contains('longestLowMs=2000 longestLowAt=4500-6500'));
    expect(line, contains('lowTailMs=2000'));
    expect(line.length, lessThan(1500));
  });
  test(
      'concurrent HTTP responses retain metadata, bytes and playback correlation',
      () async {
    const enabled = ReceivedTutorWavDiagnostics.configuredEnabled;
    final responses = [
      Completer<HttpClientResponse>(),
      Completer<HttpClientResponse>()
    ];
    var sent = 0;
    final payloads = <String>[];
    final http = _Http(() => responses[sent++].future,
        onWrite: (v) => payloads.add(v as String));
    final client = HttpApiClient(httpClient: http);
    const aText = 'AЯ😀'; // Four UTF-16 units; seven UTF-8 bytes.
    const bText = 'short';
    final a = client.postBinary('/api/audio/speech', body: {'text': aText});
    final b = client.postBinary('/api/audio/speech', body: {'text': bText});
    await Future<void>.delayed(Duration.zero);
    expect(payloads.map((s) => jsonDecode(s)['text']), [aText, bText]);
    final starts = lines.where((s) => s.contains('event=request ')).toList();
    expect(starts.length, enabled ? 2 : 0);
    String id(String line) => RegExp(r'\brequest=(\d+)').firstMatch(line)![1]!;
    if (enabled) {
      expect(starts[0], contains('textUtf16=4 utf8Bytes=7'));
      expect(starts[1], contains('textUtf16=5 utf8Bytes=5'));
      expect(id(starts[0]), isNot(id(starts[1])));
    }
    final bWav = _wav([0.25, 0.25]);
    responses[1].complete(_Response(200, Stream.value(bWav)));
    final bResult = await b;
    final aWav = _wav([0.25]);
    responses[0].complete(_Response(200, Stream.value(aWav)));
    final aResult = await a;
    expect(aResult.bodyBytes, orderedEquals(aWav));
    expect(bResult.bodyBytes, orderedEquals(bWav));
    final before = Uint8List.fromList(aResult.bodyBytes);
    TutorSpeechTrace.prepared(aResult.bodyBytes, '/private/a.wav');
    TutorSpeechTrace.prepared(bResult.bodyBytes, '/private/b.wav');
    final playback = TutorSpeechTrace.beforePlayback('/private/a.wav');
    playback?.started();
    playback?.completed('completed');
    if (enabled) {
      final waves =
          lines.where((s) => s.startsWith('[TutorWavReceived]')).toList();
      expect(id(waves[0]), id(starts[1]));
      expect(waves[0], contains('durationMs=2000'));
      expect(id(waves[1]), id(starts[0]));
      expect(waves[1], contains('durationMs=1000'));
      final prepared =
          lines.where((s) => s.contains('event=prepared ')).toList();
      expect(id(prepared[0]), id(starts[0]));
      expect(id(prepared[1]), id(starts[1]));
      expect(
          prepared.every(
              (s) => s.contains('matchesHttp=true diskReadback=unavailable')),
          isTrue);
      final play =
          lines.where((s) => s.startsWith('[TutorSpeechPlayback]')).toList();
      expect(play.length, 3);
      expect(play.every((s) => id(s) == id(starts[0])), isTrue);
      expect(
          play.first, contains('rawBytes=unavailable fileContent=unverified'));
      expect(play.last, contains('event=result status=completed'));
      final fingerprints =
          lines.where((s) => s.contains('fpSample4096=')).toList();
      final fp = RegExp(r'fpSample4096=([a-f0-9]{8})');
      expect(fp.firstMatch(fingerprints[1])![1],
          fp.firstMatch(fingerprints[2])![1]);
    } else {
      expect(lines, isEmpty);
    }
    expect(aResult.bodyBytes, orderedEquals(before));
    expect(lines.join(), isNot(contains('private')));
    expect(lines.join(), isNot(contains(aText)));
    expect(lines.join(), isNot(contains(bText)));
  });
  test('fingerprint detects a sampled byte change without altering the buffer',
      () async {
    final wav = _wav([0.25]);
    final result = await HttpApiClient(
            httpClient: _Http(() async => _Response(200, Stream.value(wav))))
        .postBinary('/api/audio/speech', body: {'text': 'x'});
    result.bodyBytes[0] ^=
        1; // Synthetic corruption injected by this test only.
    final before = Uint8List.fromList(result.bodyBytes);
    TutorSpeechTrace.prepared(result.bodyBytes, '/private/changed.wav');
    expect(result.bodyBytes, orderedEquals(before));
    if (ReceivedTutorWavDiagnostics.configuredEnabled) {
      expect(
          lines.last, contains('matchesHttp=false diskReadback=unavailable'));
    } else {
      expect(lines, isEmpty);
    }
  });
  test('unavailable checkpoints and cached replays are safe and anonymous',
      () async {
    TutorSpeechTrace.prepared(null, '/private/unknown.wav');
    final unknown = TutorSpeechTrace.beforePlayback('/private/unknown.wav');
    unknown?.started();
    unknown?.completed('completed');
    if (ReceivedTutorWavDiagnostics.configuredEnabled) {
      expect(lines.first,
          contains('request=unavailable event=prepared integrity=unavailable'));
      expect(lines[1], contains('request=unavailable'));
      expect(lines.join(), isNot(contains('private')));
    } else {
      expect(lines, isEmpty);
    }
    lines.clear();
    final wav = _wav([0.25]);
    final response = await HttpApiClient(
            httpClient: _Http(() async => _Response(200, Stream.value(wav))))
        .postBinary('/api/audio/speech', body: {'text': 'synthetic replay'});
    TutorSpeechTrace.prepared(response.bodyBytes, '/private/cached.wav');
    final first = TutorSpeechTrace.beforePlayback('/private/cached.wav');
    first?.started();
    first?.completed('completed');
    final second = TutorSpeechTrace.beforePlayback('/private/cached.wav',
        sourceBytes: response.bodyBytes);
    second?.started();
    second?.completed('completed');
    if (ReceivedTutorWavDiagnostics.configuredEnabled) {
      final handoffs =
          lines.where((s) => s.contains('event=handoff ')).toList();
      expect(handoffs.length, 2);
      expect(
          handoffs[0], contains('rawBytes=unavailable fileContent=unverified'));
      expect(handoffs[1], contains('rawBytes=available source=write_buffer'));
      expect(handoffs[1], contains('matchesHttp=true fileContent=unverified'));
      String field(String line, String key) =>
          RegExp('$key=([0-9]+)').firstMatch(line)![1]!;
      expect(field(handoffs[0], 'request'), field(handoffs[1], 'request'));
      expect(field(handoffs[0], 'playback'),
          isNot(field(handoffs[1], 'playback')));
      expect(lines.join(), isNot(contains('private')));
    } else {
      expect(lines, isEmpty);
    }
    expect(response.bodyBytes, orderedEquals(wav));
    debugPrint = (_, {wrapWidth}) => throw StateError('private');
    expect(() => TutorSpeechTrace.prepared(null, '/private/unknown.wav'),
        returnsNormally);
    expect(
        () =>
            TutorSpeechTrace.beforePlayback('/private/unknown.wav')?.started(),
        returnsNormally);
  });
  test('UTF-8 counting handles surrogate replacement and skips excessive text',
      () {
    for (final text in ['é', '\uD800', '\uDC00', '\uD800x', '😀', '']) {
      lines.clear();
      TutorSpeechTrace.start(text);
      if (ReceivedTutorWavDiagnostics.configuredEnabled) {
        expect(lines.single, contains('utf8Bytes=${utf8.encode(text).length}'));
      } else {
        expect(lines, isEmpty);
      }
    }
    lines.clear();
    TutorSpeechTrace.start('x' * 65537);
    if (ReceivedTutorWavDiagnostics.configuredEnabled) {
      expect(lines.single, contains('textUtf16=65537 utf8Bytes=unavailable'));
    }
  });
}
