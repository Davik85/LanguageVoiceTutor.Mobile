import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/tutor_options.dart';
import 'package:language_voice_tutor_mobile/services/tutor_options_service.dart';

class RecordingApiClient implements ApiClient {
  RecordingApiClient(this.response);

  final ApiResponse response;
  String? requestedPath;
  String? accessToken;

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    requestedPath = path;
    this.accessToken = accessToken;
    return response;
  }

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async =>
      const ApiResponse(statusCode: 500, body: '{}');

  @override
  Future<ApiResponse> post(String path,
          {Map<String, dynamic>? body, String? accessToken}) async =>
      const ApiResponse(statusCode: 500, body: '{}');
}

void main() {
  test('tutor options response parsing supports top-level array', () {
    final options = TutorOptions.fromJsonList([
      {
        'tutorId': 'lana',
        'displayName': 'Lana',
        'isActive': true,
        'extra': 'ignored',
      },
      {
        'tutorId': 'nelli',
        'displayName': 'Nelli',
        'isActive': true,
      },
      {
        'tutorId': 'david',
        'displayName': 'David',
        'isActive': false,
      },
    ]);

    expect(options.tutors, hasLength(3));
    expect(options.activeTutors.map((tutor) => tutor.displayName), [
      'Lana',
      'Nelli',
    ]);
    expect(options.hasActiveTutors, isTrue);
  });

  test('tutor options response parsing supports empty top-level array', () {
    final options = TutorOptions.fromJsonList([]);

    expect(options.tutors, isEmpty);
    expect(options.activeTutors, isEmpty);
    expect(options.hasActiveTutors, isFalse);
  });

  test('service calls public tutor options endpoint without auth token',
      () async {
    final apiClient = RecordingApiClient(const ApiResponse(
      statusCode: 200,
      body: '[{"tutorId":"lana","displayName":"Lana","isActive":true}]',
    ));

    final options =
        await TutorOptionsService(apiClient: apiClient).fetchTutorOptions();

    expect(apiClient.requestedPath, '/api/tutor-options');
    expect(apiClient.accessToken, isNull);
    expect(options.activeTutors.single.displayName, 'Lana');
  });

  test('service returns sanitized failure on non-success', () async {
    final service = TutorOptionsService(
      apiClient: RecordingApiClient(
        const ApiResponse(statusCode: 500, body: '{"internal":"details"}'),
      ),
    );

    expect(
      service.fetchTutorOptions(),
      throwsA(isA<ApiException>().having(
        (error) => error.message,
        'message',
        'Unable to load practice options right now.',
      )),
    );
  });
}
