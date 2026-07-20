import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/models/audio_speech.dart';
import 'package:language_voice_tutor_mobile/models/audio_transcription.dart';
import 'package:language_voice_tutor_mobile/models/feedback_report.dart';
import 'package:language_voice_tutor_mobile/models/language_options.dart';
import 'package:language_voice_tutor_mobile/models/lesson_chat.dart';
import 'package:language_voice_tutor_mobile/models/lesson_runtime.dart';
import 'package:language_voice_tutor_mobile/models/lesson_session.dart';
import 'package:language_voice_tutor_mobile/models/translation.dart';
import 'package:language_voice_tutor_mobile/models/user_settings.dart';
import 'package:language_voice_tutor_mobile/models/voice_scenario_resolution.dart';
import 'package:language_voice_tutor_mobile/services/auth_service.dart';
import 'package:language_voice_tutor_mobile/services/session_storage.dart';

class FakeApiClient implements ApiClient {
  final calls = <String>[];
  final tokens = <String?>[];
  final bodies = <Map<String, dynamic>?>[];
  final responses = <String, List<ApiResponse>>{};
  final errors = <String, List<Object>>{};
  Future<ApiResponse>? delayedRefreshResponse;

  @override
  Future<ApiResponse> get(String path, {String? accessToken}) async {
    calls.add('GET $path');
    tokens.add(accessToken);
    bodies.add(null);
    final queued = responses[path];
    final errorsForPath = errors[path];
    if (errorsForPath != null && errorsForPath.isNotEmpty) {
      throw errorsForPath.removeAt(0);
    }
    if (queued != null && queued.isNotEmpty) return queued.removeAt(0);
    return const ApiResponse(statusCode: 200, body: '{}');
  }

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    calls.add('POST $path');
    tokens.add(accessToken);
    bodies.add(body);
    if (path == '/api/auth/refresh' && delayedRefreshResponse != null) {
      return delayedRefreshResponse!;
    }
    final queued = responses[path];
    final errorsForPath = errors[path];
    if (errorsForPath != null && errorsForPath.isNotEmpty) {
      throw errorsForPath.removeAt(0);
    }
    if (queued != null && queued.isNotEmpty) return queued.removeAt(0);
    return const ApiResponse(
      statusCode: 200,
      body:
          '{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-06T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-06T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}',
    );
  }

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    calls.add('PUT $path');
    tokens.add(accessToken);
    bodies.add(body);
    final queued = responses[path];
    final errorsForPath = errors[path];
    if (errorsForPath != null && errorsForPath.isNotEmpty) {
      throw errorsForPath.removeAt(0);
    }
    if (queued != null && queued.isNotEmpty) return queued.removeAt(0);
    return const ApiResponse(statusCode: 200, body: '{}');
  }
}

class MemoryStorage implements SessionStorage {
  String? access = 'access';
  String? refresh = 'refresh';

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }
}

class StaleResponseStorage extends MemoryStorage {
  var _accessReads = 0;

  @override
  Future<String?> readAccessToken() async {
    _accessReads++;
    return _accessReads == 1 ? 'old-access' : 'new-access';
  }
}

class FakeAudioApiClient extends FakeApiClient
    implements BinaryApiClient, MultipartApiClient {
  final binaryResponses = <String, List<BinaryApiResponse>>{};
  final multipartResponses = <String, List<MultipartApiResponse>>{};

  @override
  Future<BinaryApiResponse> postBinary(String path,
      {required Map<String, dynamic> body, String? accessToken}) async {
    calls.add('BINARY $path');
    tokens.add(accessToken);
    bodies.add(body);
    return binaryResponses[path]!.removeAt(0);
  }

  @override
  Future<MultipartApiResponse> postMultipartWav(String path,
      {required Map<String, String> fields,
      required MultipartWavFile file,
      String? accessToken}) async {
    calls.add('MULTIPART $path');
    tokens.add(accessToken);
    bodies.add(null);
    return multipartResponses[path]!.removeAt(0);
  }
}

const lessonSessionReadyBody =
    '{"lessonSessionId":"session-1","lessonContentId":"everyday_english_introductions","studyLanguage":"Spanish"}';

const introStartRequest = StartLessonSessionRequest(
  lessonContentId: 'everyday_english_introductions',
  studyLanguage: 'Spanish',
  topicId: '1',
  topicTitle: 'Daily Life',
  subtopicId: '101',
  subtopicTitle: 'Introductions',
  level: 'A1 Beginner',
  selectedContextId: null,
  selectedContextTitle: null,
  modeUsed: 'text',
);

const voiceScenarioRequest = VoiceScenarioResolutionRequest(
  studyLanguage: 'English',
  learnerLevel: 'A2',
  topicId: 'travel',
  subtopicId: 'hotel',
  runtimeScenarioId: 'travel_hotel',
  runtimeVersion: 7,
  recognizedText: 'private transcript text',
  candidates: [
    VoiceScenarioCandidateRequest(
      id: 'hotel_front_desk',
      title: 'Private scenario title',
      description: 'Private prompt and conversation history',
    ),
  ],
);

Map<String, dynamic> runtimeScenarioJson() => {
      'id': 'everyday_english_introductions',
      'metadata': {
        'topic': 'Daily Life',
        'subtopic': 'Introductions',
        'lessonType': 'guided_roleplay',
      },
      'lessonSetup': {
        'setupMessage': 'Today we will practice introductions.',
      },
      'learningGoal': {
        'goal':
            'The user can introduce themselves and ask simple personal questions.',
      },
      'situation': {
        'description':
            'The user meets someone for the first time in a simple everyday situation.',
      },
      'targetLanguage': {
        'keyPhrases': ['Hi.', 'My name is...'],
        'grammarFocus': ['verb "to be": I am / I\'m'],
      },
      'levelProfiles': {
        'A1 Beginner': {
          'difficultyNotes': 'Very simple English.',
          'tutorLanguageStyle': 'Use very short, clear questions.',
          'expectedUserResponse': 'One short introduction sentence.',
          'feedbackStrictness': 'Keep feedback very short.',
          'hintStrategy': 'Give a full model starter when needed.',
          'correctionPriority': 'Clear name and place sentences first.',
          'conversationDepth': 'Stay very shallow.',
          'exampleGoodAnswer': 'My name is Ana.',
          'exampleStretchAnswer':
              'My name is Ana. I\'m from Brazil. Nice to meet you.',
          'addedKeyPhrases': ['Nice to meet you.'],
          'addedUsefulConstructions': ['Use My name is...'],
          'addedGrammarFocus': ['basic questions'],
          'softWrapUpAfterUserTurn': 10,
          'finalMessageAtUserTurn': 15,
        },
      },
      'conversationFlow': {
        'opening': 'Hi! What is your name?',
        'firstUserTask': 'Say your name.',
        'guidedPracticeFollowUpQuestions': ['Where are you from?'],
        'variationOrComplication': '',
        'correctionMoment': '',
        'wrapUpMessage': 'Nice work today.',
        'finalMessage': 'Great job. See you next time.',
        'wrapUpIntent': 'Wrap up the introduction.',
        'finalMessageIntent': 'End the lesson cleanly.',
      },
      'roleplayBeats': [
        {'id': 'beat-1', 'intent': 'Tutor greets the learner.'},
      ],
      'reciprocalQuestionHandling': {
        'ifUserAsksTutorName': 'My name is Alex.',
        'ifUserAsksSimplePersonalQuestion': 'I live nearby.',
        'mustNotIgnoreUserQuestion': true,
        'mustNotRefuseScenarioCompatibleQuestions': true,
      },
      'expectedScenarioProgression': [
        'Greet the learner.',
        'Exchange names.',
      ],
      'aiTutorPromptInstructions': [
        'Keep tutor messages short and suitable for voice output.',
      ],
      'promptTemplates': {
        'opening': 'Keep the greeting simple.',
      },
      'hintRules': {'exampleHint': 'Try: My name is Ana.'},
      'runtimeContent': {
        'effectiveRuntimeSource': 'cms_published_snapshot',
        'contentPackSlug': 'static-json-v1',
        'versionNumber': 7,
        'snapshotHash': 'hash-123',
        'fallbackUsed': false,
        'scenarioKey': 'everyday_english_introductions',
        'resolvedLevelId': 'A1 Beginner',
        'softWrapUpAfterUserTurn': 10,
        'finalMessageAtUserTurn': 15,
        'lessonPhase': 'active_roleplay',
        'hasWrapUpStarted': false,
      },
    };

LessonChatRequest sampleChatRequest() => LessonChatRequest.fromScenario(
      scenario: LessonRuntimeScenario.fromJson(runtimeScenarioJson()),
      levelProfile: LessonRuntimeScenario.fromJson(runtimeScenarioJson())
          .levelProfileFor('A1 Beginner'),
      selectedLevel: 'A1 Beginner',
      topicTitle: 'Daily Life',
      subtopicTitle: 'Introductions',
      userMessage: 'Hello, my name is Sam.',
      lastBotMessage: '',
      nativeLanguageName: 'English',
      targetLanguageId: 'es',
      targetLanguageName: 'Spanish',
      targetLanguageNativeName: 'Spanish',
      targetLanguageCode: 'es',
      userDisplayName: '',
      learnerTurnCount: 1,
      recentMessages: const [
        LessonRecentConversationMessage(
          sender: 'User',
          text: 'Hello, my name is Sam.',
        ),
      ],
      backendSessionId: 'session-1',
    );

const translationRequest = TranslationRequest(
  text: 'Hello, how are you?',
  targetLanguage: 'Spanish',
  sourceLanguageId: 'en',
  sourceLanguageName: 'English',
  sourceLanguageNativeName: 'English',
  sourceLanguageCode: 'en',
  backendSessionId: 'session-1',
);

const userSettingsRequest = UserSettings(
  nativeLanguage: 'tr',
  studyLanguage: 'en',
  explanationLanguage: 'ru',
  speechVoice: 'coral',
  speechSpeed: 1.1,
  conversationModeEnabled: true,
  selectedTutorId: 'lana',
  currentLevel: 'A1',
);

const userSettingsResponseBody =
    '{"nativeLanguage":"tr","studyLanguage":"en","explanationLanguage":"ru","speechVoice":"coral","speechSpeed":1.1,"conversationModeEnabled":true,"selectedTutorId":"lana","currentLevel":"A1"}';

void main() {
  test('study language values are converted to backend-compatible names', () {
    expect(LanguageOptions.backendStudyLanguageNameFor('es'), 'Spanish');
    expect(LanguageOptions.backendStudyLanguageNameFor(null), 'English');
    expect(LanguageOptions.backendNativeLanguageNameFor('en'), 'English');
  });

  test('start lesson session request serializes backend fields only', () {
    expect(introStartRequest.toJson(), {
      'lessonContentId': 'everyday_english_introductions',
      'studyLanguage': 'Spanish',
      'topicId': '1',
      'topicTitle': 'Daily Life',
      'subtopicId': '101',
      'subtopicTitle': 'Introductions',
      'level': 'A1 Beginner',
      'selectedContextId': null,
      'selectedContextTitle': null,
      'modeUsed': 'text',
    });
  });

  test(
      'discovers no active lesson session from the authenticated production list',
      () async {
    final api = FakeApiClient()
      ..responses['/api/me/lesson-sessions'] = [
        const ApiResponse(statusCode: 200, body: '{"items":[]}'),
      ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .discoverActiveLessonSession();

    expect(result.status, ActiveLessonSessionDiscoveryStatus.success);
    expect(result.session, isNull);
    expect(api.calls, ['GET /api/me/lesson-sessions']);
    expect(api.tokens, ['access']);
    expect(api.calls.single, isNot(contains('/api/dev')));
  });

  test(
      'discovers the single active lesson session and rejects multiple active sessions',
      () async {
    const finished =
        '{"id":"11111111-1111-1111-1111-111111111111","status":"Finished","startedAt":"2026-07-20T10:00:00Z"}';
    const active =
        '{"id":"33333333-3333-3333-3333-333333333333","status":"Active","startedAt":"2026-07-20T11:00:00Z"}';
    final api = FakeApiClient()
      ..responses['/api/me/lesson-sessions'] = [
        const ApiResponse(
            statusCode: 200, body: '{"items":[$finished,$active]}'),
        const ApiResponse(statusCode: 200, body: '{"items":[$active,$active]}'),
      ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final one = await service.discoverActiveLessonSession();
    expect(one.status, ActiveLessonSessionDiscoveryStatus.success);
    expect(one.session?.sessionId, '33333333-3333-3333-3333-333333333333');

    final multiple = await service.discoverActiveLessonSession();
    expect(multiple.status, ActiveLessonSessionDiscoveryStatus.inconsistent);
    expect(multiple.session, isNull);
  });

  test(
      'active lesson discovery refreshes after 401 and safely handles failures',
      () async {
    const activeBody =
        '{"items":[{"id":"33333333-3333-3333-3333-333333333333","status":"Active","startedAt":"2026-07-20T11:00:00Z"}]}';
    final refreshApi = FakeApiClient()
      ..responses['/api/me/lesson-sessions'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(statusCode: 200, body: activeBody),
      ];
    final refreshed = await AuthService(
      apiClient: refreshApi,
      storage: MemoryStorage(),
    ).discoverActiveLessonSession();
    expect(refreshed.session, isNotNull);
    expect(refreshApi.calls, [
      'GET /api/me/lesson-sessions',
      'POST /api/auth/refresh',
      'GET /api/me/lesson-sessions',
    ]);

    final invalidRefreshApi = FakeApiClient()
      ..responses['/api/me/lesson-sessions'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
      ]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
      ];
    final invalidStorage = MemoryStorage();
    final invalid = await AuthService(
      apiClient: invalidRefreshApi,
      storage: invalidStorage,
    ).discoverActiveLessonSession();
    expect(invalid.status, ActiveLessonSessionDiscoveryStatus.authRequired);
    expect(invalidStorage.access, isNull);
    expect(invalidStorage.refresh, isNull);

    final unavailableApi = FakeApiClient()
      ..responses['/api/me/lesson-sessions'] = [
        const ApiResponse(statusCode: 503, body: '{}'),
      ];
    final unavailableStorage = MemoryStorage();
    final unavailable = await AuthService(
      apiClient: unavailableApi,
      storage: unavailableStorage,
    ).discoverActiveLessonSession();
    expect(unavailable.status, ActiveLessonSessionDiscoveryStatus.unavailable);
    expect(unavailableStorage.access, 'access');
    expect(unavailableStorage.refresh, 'refresh');

    final networkApi = FakeApiClient()
      ..errors['/api/me/lesson-sessions'] = [
        const ApiException(
          'Unable to reach the service.',
          category: ApiFailureCategory.network,
        ),
      ];
    final networkStorage = MemoryStorage();
    final network = await AuthService(
      apiClient: networkApi,
      storage: networkStorage,
    ).discoverActiveLessonSession();
    expect(network.status, ActiveLessonSessionDiscoveryStatus.unavailable);
    expect(networkStorage.access, 'access');
    expect(networkStorage.refresh, 'refresh');

    final malformedApi = FakeApiClient()
      ..responses['/api/me/lesson-sessions'] = [
        const ApiResponse(
            statusCode: 200,
            body:
                '{"items":[{"id":"bad","status":"Active","startedAt":"2026-07-20T11:00:00Z"}]}'),
      ];
    expect(
      (await AuthService(apiClient: malformedApi, storage: MemoryStorage())
              .discoverActiveLessonSession())
          .status,
      ActiveLessonSessionDiscoveryStatus.failed,
    );
  });

  test('voice scenario diagnostics preserve exact non-2xx HTTP status',
      () async {
    final api = FakeApiClient()
      ..responses[
          '/api/me/lesson-sessions/session-1/voice-scenario-resolution'] = [
        const ApiResponse(
          statusCode: 422,
          body: '{"code":"scenario_contract_rejected"}',
        ),
      ];

    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .resolveVoiceScenario(
      sessionId: 'session-1',
      request: voiceScenarioRequest,
    );

    expect(result.isSuccess, isFalse);
    expect(result.diagnostic.httpStatusCode, 422);
    expect(result.diagnostic.failureStage, 'http_response');
    expect(result.diagnostic.backendSafeCode, 'scenario_contract_rejected');
  });

  test('voice scenario diagnostics distinguish authentication from transport',
      () async {
    const path = '/api/me/lesson-sessions/session-1/voice-scenario-resolution';
    final initial401Api = FakeApiClient()
      ..responses[path] = [const ApiResponse(statusCode: 401, body: '{}')]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
      ];
    final initial401 = await AuthService(
      apiClient: initial401Api,
      storage: MemoryStorage(),
    ).resolveVoiceScenario(
      sessionId: 'session-1',
      request: voiceScenarioRequest,
    );
    expect(initial401.diagnostic.httpStatusCode, isNull);
    expect(initial401.diagnostic.refreshRetry, isFalse);
    expect(initial401.diagnostic.failureStage, 'authentication_required');

    final retry401Api = FakeApiClient()
      ..responses[path] = [
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(statusCode: 401, body: '{}'),
      ];
    final retry401 = await AuthService(
      apiClient: retry401Api,
      storage: MemoryStorage(),
    ).resolveVoiceScenario(
      sessionId: 'session-1',
      request: voiceScenarioRequest,
    );
    expect(retry401.diagnostic.httpStatusCode, isNull);
    expect(retry401.diagnostic.refreshRetry, isFalse);
    expect(retry401.diagnostic.failureStage, 'authentication_required');
  });

  test('voice scenario diagnostics classify malformed JSON as response_json',
      () async {
    final api = FakeApiClient()
      ..responses[
          '/api/me/lesson-sessions/session-1/voice-scenario-resolution'] = [
        const ApiResponse(statusCode: 200, body: 'not json'),
      ];

    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .resolveVoiceScenario(
      sessionId: 'session-1',
      request: voiceScenarioRequest,
    );

    expect(result.isSuccess, isFalse);
    expect(result.diagnostic.failureStage, 'response_json');
    expect(result.diagnostic.responseParsed, isFalse);
  });

  test(
      'voice scenario diagnostics classify missing required fields as response_contract',
      () async {
    final api = FakeApiClient()
      ..responses[
          '/api/me/lesson-sessions/session-1/voice-scenario-resolution'] = [
        const ApiResponse(
          statusCode: 200,
          body: '{"decision":"published_context"}',
        ),
      ];

    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .resolveVoiceScenario(
      sessionId: 'session-1',
      request: voiceScenarioRequest,
    );

    expect(result.isSuccess, isFalse);
    expect(result.diagnostic.failureStage, 'response_contract');
    expect(result.diagnostic.responseParsed, isTrue);
    expect(result.diagnostic.decisionPresent, isTrue);
  });

  test('valid voice scenario semantic response is successful', () async {
    final api = FakeApiClient()
      ..responses[
          '/api/me/lesson-sessions/session-1/voice-scenario-resolution'] = [
        const ApiResponse(
          statusCode: 200,
          body:
              '{"decision":"published_context","matchedContextId":"hotel_front_desk","confidence":0.92,"candidateContextIds":[],"normalizedFreeContext":null,"clarificationText":null}',
        ),
      ];

    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .resolveVoiceScenario(
      sessionId: 'session-1',
      request: voiceScenarioRequest,
    );

    expect(result.isSuccess, isTrue);
    expect(result.response?.decision,
        VoiceScenarioSemanticDecision.publishedContext);
    expect(result.diagnostic.failureStage, 'success');
    expect(result.diagnostic.matchedIdPresent, isTrue);
    expect(result.diagnostic.candidateCount, 1);
  });

  test('voice scenario diagnostic fields contain metadata only', () async {
    const path = '/api/me/lesson-sessions/session-1/voice-scenario-resolution';
    final storage = MemoryStorage()..access = 'private-bearer-token';
    final api = FakeApiClient()
      ..responses[path] = [
        const ApiResponse(
          statusCode: 500,
          body:
              '{"detail":"private raw response body with prompt and history","secret":"private-api-key"}',
        ),
      ];

    final result = await AuthService(apiClient: api, storage: storage)
        .resolveVoiceScenario(
      sessionId: 'session-1',
      request: voiceScenarioRequest,
    );
    final fields = result.diagnostic.toFields().toString();

    for (final sensitiveValue in [
      voiceScenarioRequest.recognizedText,
      voiceScenarioRequest.candidates.single.title,
      'private-bearer-token',
      'Private prompt',
      'conversation history',
      'private raw response body',
      'private-api-key',
    ]) {
      expect(fields, isNot(contains(sensitiveValue)));
    }
    expect(result.diagnostic.backendSafeCode, isNull);
  });

  test('settings update sends the complete backend-compatible payload',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/settings'] = [
      const ApiResponse(statusCode: 200, body: userSettingsResponseBody),
    ];

    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .updateUserSettings(userSettingsRequest);

    expect(result.status, UserSettingsUpdateStatus.success);
    expect(result.settings?.nativeLanguage, 'tr');
    expect(api.calls, ['PUT /api/me/settings']);
    expect(api.bodies.single, {
      'nativeLanguage': 'tr',
      'studyLanguage': 'English',
      'explanationLanguage': 'ru',
      'speechVoice': 'coral',
      'speechSpeed': 1.1,
      'conversationModeEnabled': true,
      'selectedTutorId': 'lana',
      'currentLevel': 'A1',
    });
  });

  test('settings update preserves a safe nonblank 400 error', () async {
    final api = FakeApiClient();
    api.responses['/api/me/settings'] = [
      const ApiResponse(
          statusCode: 400, body: '{"error":"Unsupported native language."}'),
    ];

    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .updateUserSettings(userSettingsRequest);

    expect(result.status, UserSettingsUpdateStatus.validationFailure);
    expect(result.message, 'Unsupported native language.');
  });

  test('settings update keeps malformed or blank 400 errors generic', () async {
    for (final body in ['{}', '{"error":"  "}', 'not json']) {
      final api = FakeApiClient();
      api.responses['/api/me/settings'] = [
        ApiResponse(statusCode: 400, body: body)
      ];
      final result = await AuthService(apiClient: api, storage: MemoryStorage())
          .updateUserSettings(userSettingsRequest);
      expect(result.status, UserSettingsUpdateStatus.ordinaryFailure);
      expect(result.message, 'Unable to save settings right now.');
    }
  });

  test('settings update maps 503 to a temporary service result', () async {
    final api = FakeApiClient();
    api.responses['/api/me/settings'] = [
      const ApiResponse(statusCode: 503, body: '{"error":"storage details"}'),
    ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .updateUserSettings(userSettingsRequest);
    expect(result.status, UserSettingsUpdateStatus.serviceUnavailable);
    expect(result.message,
        'Settings are temporarily unavailable. Please try again.');
    expect(result.message, isNot(contains('storage details')));
  });

  test('settings update refreshes once after 401 and returns confirmed data',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/settings'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: userSettingsResponseBody),
    ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .updateUserSettings(userSettingsRequest);
    expect(result.status, UserSettingsUpdateStatus.success);
    expect(api.calls, [
      'PUT /api/me/settings',
      'POST /api/auth/refresh',
      'PUT /api/me/settings',
    ]);
  });

  test('settings update returns authentication required when refresh fails',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/settings'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    api.responses['/api/auth/refresh'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .updateUserSettings(userSettingsRequest);
    expect(result.status, UserSettingsUpdateStatus.authenticationRequired);
  });

  test(
      'settings update keeps malformed success, network, and unknown failures safe',
      () async {
    final malformedApi = FakeApiClient()
      ..responses['/api/me/settings'] = [
        const ApiResponse(statusCode: 200, body: 'not json'),
      ];
    final malformed =
        await AuthService(apiClient: malformedApi, storage: MemoryStorage())
            .updateUserSettings(userSettingsRequest);
    expect(malformed.status, UserSettingsUpdateStatus.ordinaryFailure);

    final networkApi = FakeApiClient()
      ..errors['/api/me/settings'] = [
        const SocketException('private network detail')
      ];
    final network =
        await AuthService(apiClient: networkApi, storage: MemoryStorage())
            .updateUserSettings(userSettingsRequest);
    expect(network.status, UserSettingsUpdateStatus.ordinaryFailure);
    expect(network.message, isNot(contains('private network detail')));

    final unexpectedApi = FakeApiClient()
      ..responses['/api/me/settings'] = [
        const ApiResponse(
            statusCode: 418, body: '{"error":"technical detail"}'),
      ];
    final unexpected =
        await AuthService(apiClient: unexpectedApi, storage: MemoryStorage())
            .updateUserSettings(userSettingsRequest);
    expect(unexpected.status, UserSettingsUpdateStatus.ordinaryFailure);
    expect(unexpected.message, isNot(contains('technical detail')));
  });

  test('runtime scenario request uses GET lesson content endpoint', () async {
    final api = FakeApiClient();
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    api.responses[
        '/api/me/lesson-content/scenarios/everyday_english_introductions'] = [
      const ApiResponse(
        statusCode: 200,
        body:
            '{"id":"everyday_english_introductions","metadata":{"topic":"Daily Life","subtopic":"Introductions","lessonType":"guided_roleplay"},"lessonSetup":{"setupMessage":"Today we will practice introductions."},"learningGoal":{"goal":"The user can introduce themselves."},"situation":{"description":"Meet someone for the first time."},"targetLanguage":{"keyPhrases":["Hi."],"grammarFocus":["basic questions"]},"levelProfiles":{"A1 Beginner":{"difficultyNotes":"Simple","tutorLanguageStyle":"Short","expectedUserResponse":"One sentence","feedbackStrictness":"Short","hintStrategy":"Starter","correctionPriority":"Name","conversationDepth":"Shallow","exampleGoodAnswer":"Hi","exampleStretchAnswer":"Hi, I am Sam","addedKeyPhrases":["Hi"],"addedUsefulConstructions":["I am"],"addedGrammarFocus":["to be"],"softWrapUpAfterUserTurn":10,"finalMessageAtUserTurn":15}},"conversationFlow":{"opening":"Hi","firstUserTask":"Introduce yourself","guidedPracticeFollowUpQuestions":["Where are you from?"],"variationOrComplication":"","correctionMoment":"","wrapUpMessage":"Nice work","finalMessage":"See you","wrapUpIntent":"Wrap up","finalMessageIntent":"Finish"},"roleplayBeats":[{"id":"beat-1","intent":"Tutor greets learner"}],"reciprocalQuestionHandling":{"ifUserAsksTutorName":"I am Alex","ifUserAsksSimplePersonalQuestion":"I live nearby","mustNotIgnoreUserQuestion":true,"mustNotRefuseScenarioCompatibleQuestions":true},"expectedScenarioProgression":["Greet learner"],"aiTutorPromptInstructions":["Keep it short"],"promptTemplates":{"opening":"Keep the greeting simple."},"runtimeContent":{"effectiveRuntimeSource":"cms_published_snapshot","contentPackSlug":"static-json-v1","versionNumber":7,"snapshotHash":"hash-123","fallbackUsed":false,"scenarioKey":"everyday_english_introductions","resolvedLevelId":"A1 Beginner","softWrapUpAfterUserTurn":10,"finalMessageAtUserTurn":15,"lessonPhase":"active_roleplay","hasWrapUpStarted":false}}',
      ),
    ];

    final scenario = await service.fetchLessonRuntimeScenario(
      scenarioKey: 'everyday_english_introductions',
    );

    expect(
      api.calls,
      contains(
          'GET /api/me/lesson-content/scenarios/everyday_english_introductions'),
    );
    expect(scenario.id, 'everyday_english_introductions');
    expect(scenario.metadata.subtopic, 'Introductions');
    expect(
        scenario.runtimeContent.scenarioKey, 'everyday_english_introductions');
  });

  test('runtime scenario request refreshes and retries after 401', () async {
    final api = FakeApiClient();
    api.responses[
        '/api/me/lesson-content/scenarios/everyday_english_introductions'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(
        statusCode: 200,
        body:
            '{"id":"everyday_english_introductions","metadata":{"topic":"Daily Life","subtopic":"Introductions","lessonType":"guided_roleplay"},"lessonSetup":{"setupMessage":"Today we will practice introductions."},"learningGoal":{"goal":"The user can introduce themselves."},"situation":{"description":"Meet someone for the first time."},"targetLanguage":{"keyPhrases":[],"grammarFocus":[]},"levelProfiles":{},"conversationFlow":{"opening":"","firstUserTask":"","guidedPracticeFollowUpQuestions":[],"variationOrComplication":"","correctionMoment":"","wrapUpMessage":"","finalMessage":"","wrapUpIntent":"","finalMessageIntent":""},"roleplayBeats":[],"reciprocalQuestionHandling":{"ifUserAsksTutorName":"","ifUserAsksSimplePersonalQuestion":"","mustNotIgnoreUserQuestion":false,"mustNotRefuseScenarioCompatibleQuestions":false},"expectedScenarioProgression":[],"aiTutorPromptInstructions":[],"promptTemplates":{},"runtimeContent":{"effectiveRuntimeSource":"","contentPackSlug":"","versionNumber":1,"snapshotHash":"","fallbackUsed":false,"scenarioKey":"everyday_english_introductions","resolvedLevelId":"","softWrapUpAfterUserTurn":0,"finalMessageAtUserTurn":0,"lessonPhase":"","hasWrapUpStarted":false}}',
      ),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    await service.fetchLessonRuntimeScenario(
      scenarioKey: 'everyday_english_introductions',
    );

    expect(
      api.calls,
      containsAllInOrder([
        'GET /api/me/lesson-content/scenarios/everyday_english_introductions',
        'POST /api/auth/refresh',
        'GET /api/me/lesson-content/scenarios/everyday_english_introductions',
      ]),
    );
  });

  test('lesson chat request serializes to backend reply shape', () {
    final request = sampleChatRequest();
    final json = request.toJson();

    expect(json['userMessage'], 'Hello, my name is Sam.');
    expect(json['backendSessionId'], 'session-1');
    expect(json['runtimeContentScenarioKey'], 'everyday_english_introductions');
    expect(json['selectedLevel'], 'A1 Beginner');
    expect(json['topicTitle'], 'Daily Life');
    expect(json['subtopicTitle'], 'Introductions');
    expect(json['recentMessages'], [
      {'sender': 'User', 'text': 'Hello, my name is Sam.'},
    ]);
  });

  test('lesson chat reply sends desktop-compatible endpoint and parses reply',
      () async {
    final api = FakeApiClient();
    api.responses['/api/lesson-chat/reply'] = [
      const ApiResponse(
        statusCode: 200,
        body:
            '{"botReply":"Hi Sam! Nice to meet you. Where are you from?","isLessonComplete":false}',
      ),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.sendLessonChatReply(
      request: sampleChatRequest(),
    );

    expect(result.status, LessonChatReplyStatus.success);
    expect(result.reply?.botReply,
        'Hi Sam! Nice to meet you. Where are you from?');
    expect(api.calls, contains('POST /api/lesson-chat/reply'));
    expect(api.calls,
        isNot(contains('POST /api/me/lesson-sessions/session-1/reply')));
    expect(
      api.bodies.last?['runtimeContentScenarioKey'],
      'everyday_english_introductions',
    );
  });

  test('lesson chat reply refreshes and retries after 401', () async {
    final api = FakeApiClient();
    api.responses['/api/lesson-chat/reply'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(
        statusCode: 200,
        body: '{"botReply":"Hola","isLessonComplete":false}',
      ),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.sendLessonChatReply(
      request: sampleChatRequest(),
    );

    expect(result.status, LessonChatReplyStatus.success);
    expect(
      api.calls,
      containsAllInOrder([
        'POST /api/lesson-chat/reply',
        'POST /api/auth/refresh',
        'POST /api/lesson-chat/reply',
      ]),
    );
  });

  test('lesson chat reply rejects blank text locally', () async {
    final api = FakeApiClient();
    final service = AuthService(apiClient: api, storage: MemoryStorage());
    final request = LessonChatRequest.fromScenario(
      scenario: LessonRuntimeScenario.fromJson(runtimeScenarioJson()),
      levelProfile: LessonRuntimeScenario.fromJson(runtimeScenarioJson())
          .levelProfileFor('A1 Beginner'),
      selectedLevel: 'A1 Beginner',
      topicTitle: 'Daily Life',
      subtopicTitle: 'Introductions',
      userMessage: '   ',
      lastBotMessage: '',
      nativeLanguageName: 'English',
      targetLanguageId: 'es',
      targetLanguageName: 'Spanish',
      targetLanguageNativeName: 'Spanish',
      targetLanguageCode: 'es',
      userDisplayName: '',
      learnerTurnCount: 1,
      recentMessages: const [],
      backendSessionId: 'session-1',
    );

    final result = await service.sendLessonChatReply(request: request);

    expect(result.status, LessonChatReplyStatus.validation);
    expect(api.calls, isEmpty);
  });

  test('lesson chat hint sends the existing request JSON and parses hintText',
      () async {
    final api = FakeApiClient();
    api.responses['/api/lesson-chat/hint'] = [
      const ApiResponse(statusCode: 200, body: '{"hintText":"Try hello."}'),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final request = sampleChatRequest();
    final result = await service.requestLessonChatHint(request: request);

    expect(result.status, LessonChatHintStatus.success);
    expect(result.hint?.hintText, 'Try hello.');
    expect(api.calls, contains('POST /api/lesson-chat/hint'));
    expect(api.bodies.last, request.toJson());
    expect(api.calls.join(' '), isNot(contains('/api/dev')));
    expect(api.calls.join(' '), isNot(contains('/reply')));
  });

  test('lesson chat hint rejects blank, missing, and malformed responses',
      () async {
    for (final body in ['{"hintText":"  "}', '{}', 'not json']) {
      final api = FakeApiClient();
      api.responses['/api/lesson-chat/hint'] = [
        ApiResponse(statusCode: 200, body: body),
      ];
      final result = await AuthService(apiClient: api, storage: MemoryStorage())
          .requestLessonChatHint(request: sampleChatRequest());
      expect(result.status, LessonChatHintStatus.failed);
    }
  });

  test('lesson chat hint maps learner-safe failures, including 429', () async {
    final cases = <ApiResponse, LessonChatHintStatus>{
      const ApiResponse(statusCode: 400, body: '{}'):
          LessonChatHintStatus.failed,
      const ApiResponse(statusCode: 429, body: '{}'):
          LessonChatHintStatus.limited,
      const ApiResponse(statusCode: 409, body: '{"code":"lesson_ended"}'):
          LessonChatHintStatus.conflict,
      const ApiResponse(statusCode: 500, body: '{}'):
          LessonChatHintStatus.unavailable,
    };
    for (final entry in cases.entries) {
      final api = FakeApiClient();
      api.responses['/api/lesson-chat/hint'] = [entry.key];
      final result = await AuthService(apiClient: api, storage: MemoryStorage())
          .requestLessonChatHint(request: sampleChatRequest());
      expect(result.status, entry.value);
      if (entry.key.statusCode == 429) {
        expect(result.message,
            'Hint is temporarily unavailable. Please try again shortly.');
      }
    }
  });

  test('lesson chat hint refreshes once and keeps auth failure distinct',
      () async {
    final api = FakeApiClient();
    api.responses['/api/lesson-chat/hint'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: '{"hintText":"Try hello."}'),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());
    expect(
        (await service.requestLessonChatHint(request: sampleChatRequest()))
            .status,
        LessonChatHintStatus.success);
    expect(
        api.calls,
        containsAllInOrder([
          'POST /api/lesson-chat/hint',
          'POST /api/auth/refresh',
          'POST /api/lesson-chat/hint',
        ]));

    final failedRefreshApi = FakeApiClient();
    failedRefreshApi.responses['/api/lesson-chat/hint'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    failedRefreshApi.responses['/api/auth/refresh'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    final failed = await AuthService(
      apiClient: failedRefreshApi,
      storage: MemoryStorage(),
    ).requestLessonChatHint(request: sampleChatRequest());
    expect(failed.status, LessonChatHintStatus.authRequired);
  });

  test('message persistence uses session messages endpoint', () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions/session-1/messages'] = [
      const ApiResponse(
        statusCode: 200,
        body: '{"id":"11111111-1111-4111-8111-111111111111"}',
      ),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final persistedId = await service.persistLessonSessionMessage(
      sessionId: 'session-1',
      request: const CreateLessonSessionMessageRequest(
        role: 'user',
        text: 'Hello',
        source: 'typed',
        turnNumber: 1,
        isValidLessonTurn: true,
        studyLanguage: 'Spanish',
      ),
    );

    expect(
      api.calls,
      contains('POST /api/me/lesson-sessions/session-1/messages'),
    );
    expect(persistedId, '11111111-1111-4111-8111-111111111111');
    expect(api.calls.join(' '), isNot(contains('openai')));
  });

  test('feedback posts the existing full request contract and parses sections',
      () async {
    final api = FakeApiClient();
    api.responses['/api/lesson-chat/feedback'] = [
      const ApiResponse(
          statusCode: 200,
          body:
              '{"shortText":"Good work.","correctedVersion":"","grammarTip":"","vocabularyTip":"word","cultureTip":"","naturalVersion":"More natural."}'),
    ];
    final request = LessonChatRequest.fromScenario(
      scenario: LessonRuntimeScenario.fromJson(runtimeScenarioJson()),
      levelProfile: LessonRuntimeScenario.fromJson(runtimeScenarioJson())
          .levelProfileFor('A1 Beginner'),
      selectedLevel: 'A1 Beginner',
      topicTitle: 'Daily Life',
      subtopicTitle: 'Introductions',
      userMessage: 'Hello, my name is Sam.',
      lastBotMessage: 'Hello!',
      nativeLanguageName: 'English',
      targetLanguageId: 'es',
      targetLanguageName: 'Spanish',
      targetLanguageNativeName: 'Spanish',
      targetLanguageCode: 'es',
      userDisplayName: '',
      learnerTurnCount: 1,
      recentMessages: const [],
      backendSessionId: 'session-1',
      sourceMessageId: 42,
      sourcePersistedMessageId: '11111111-1111-4111-8111-111111111111',
      sourceMessageKind: 'user',
    );
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .requestLessonFeedback(request: request);
    expect(result.status, LessonFeedbackStatus.success);
    expect(result.feedback?.shortText, 'Good work.');
    expect(result.feedback?.vocabularyTip, 'word');
    expect(api.calls, ['POST /api/lesson-chat/feedback']);
    expect(api.bodies.single, request.toJson());
    expect(api.bodies.single!['sourceMessageId'], 42);
    expect(api.bodies.single!['sourcePersistedMessageId'],
        '11111111-1111-4111-8111-111111111111');
    expect(api.bodies.single!['backendSessionId'], 'session-1');
    expect(api.bodies.single!['sourceMessageKind'], 'user');
    expect(api.calls.single, isNot(contains('/api/dev')));
  });

  test('feedback keeps malformed responses and HTTP failures learner-safe',
      () async {
    for (final body in ['{}', '{"shortText":"  "}', 'not json']) {
      final api = FakeApiClient()
        ..responses['/api/lesson-chat/feedback'] = [
          ApiResponse(statusCode: 200, body: body)
        ];
      expect(
          (await AuthService(apiClient: api, storage: MemoryStorage())
                  .requestLessonFeedback(request: sampleChatRequest()))
              .status,
          LessonFeedbackStatus.validation);
    }
    final statuses = <int, LessonFeedbackStatus>{
      400: LessonFeedbackStatus.validation,
      409: LessonFeedbackStatus.sessionEnded,
      429: LessonFeedbackStatus.temporarilyUnavailable,
      500: LessonFeedbackStatus.unavailable,
      502: LessonFeedbackStatus.unavailable
    };
    for (final entry in statuses.entries) {
      final api = FakeApiClient()
        ..responses['/api/lesson-chat/feedback'] = [
          ApiResponse(statusCode: entry.key, body: '{}')
        ];
      final request = LessonChatRequest.fromScenario(
          scenario: LessonRuntimeScenario.fromJson(runtimeScenarioJson()),
          levelProfile: LessonRuntimeScenario.fromJson(runtimeScenarioJson())
              .levelProfileFor('A1 Beginner'),
          selectedLevel: 'A1 Beginner',
          topicTitle: 'Daily Life',
          subtopicTitle: 'Introductions',
          userMessage: 'Hello',
          lastBotMessage: '',
          nativeLanguageName: 'English',
          targetLanguageId: 'es',
          targetLanguageName: 'Spanish',
          targetLanguageNativeName: 'Spanish',
          targetLanguageCode: 'es',
          userDisplayName: '',
          learnerTurnCount: 1,
          recentMessages: const [],
          backendSessionId: 'session-1',
          sourceMessageId: 1,
          sourcePersistedMessageId: '11111111-1111-4111-8111-111111111111',
          sourceMessageKind: 'user');
      expect(
          (await AuthService(apiClient: api, storage: MemoryStorage())
                  .requestLessonFeedback(request: request))
              .status,
          entry.value);
    }
  });

  test('abandon uses the authenticated production endpoint with no body',
      () async {
    final api = FakeApiClient();
    api.responses['/api/lesson-sessions/session-1/abandon'] = [
      const ApiResponse(
        statusCode: 200,
        body: '{"id":"session-1","status":"abandoned"}',
      ),
    ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .abandonLessonSession(sessionId: 'session-1');

    expect(result.status, LessonSessionAbandonStatus.abandoned);
    expect(api.calls, ['POST /api/lesson-sessions/session-1/abandon']);
    expect(api.bodies.single, isNull);
    expect(api.tokens.single, 'access');
    expect(api.calls.join(' '), isNot(contains('/api/dev')));
    expect(api.calls.join(' '), isNot(contains('/active/abandon')));
  });

  test('abandon refreshes once after 401 and keeps failures safe', () async {
    final api = FakeApiClient();
    api.responses['/api/lesson-sessions/session-1/abandon'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: '{"status":"abandoned"}'),
    ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .abandonLessonSession(sessionId: 'session-1');
    expect(result.status, LessonSessionAbandonStatus.abandoned);
    expect(
        api.calls,
        containsAllInOrder([
          'POST /api/lesson-sessions/session-1/abandon',
          'POST /api/auth/refresh',
          'POST /api/lesson-sessions/session-1/abandon',
        ]));

    final authFailureApi = FakeApiClient();
    authFailureApi.responses['/api/lesson-sessions/session-1/abandon'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    authFailureApi.responses['/api/auth/refresh'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    expect(
      (await AuthService(apiClient: authFailureApi, storage: MemoryStorage())
              .abandonLessonSession(sessionId: 'session-1'))
          .status,
      LessonSessionAbandonStatus.authRequired,
    );

    final failureApi = FakeApiClient();
    failureApi.responses['/api/lesson-sessions/session-1/abandon'] = [
      const ApiResponse(statusCode: 503, body: '{}'),
    ];
    expect(
      (await AuthService(apiClient: failureApi, storage: MemoryStorage())
              .abandonLessonSession(sessionId: 'session-1'))
          .status,
      LessonSessionAbandonStatus.unavailable,
    );
  });

  test('finish uses authenticated production PUT then reads ready summary',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions/session-1/finish'] = [
      const ApiResponse(statusCode: 200, body: '{"status":"finished"}'),
    ];
    api.responses['/api/me/lesson-sessions/session-1/summary'] = [
      const ApiResponse(
          statusCode: 200,
          body:
              '{"status":"ready","level":"A1","topicTitle":"Daily Life","summary":"Good work.","strengths":["Greeting"],"improvements":null,"vocabulary":[],"grammar":[],"nextSteps":["Practice again"]}'),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final result = await service.finishLessonSession(
        sessionId: 'session-1', validTurnCount: 2);

    expect(result.status, LessonCompletionStatus.summaryReady);
    expect(result.summary?.summary, 'Good work.');
    expect(
        api.calls,
        containsAllInOrder([
          'PUT /api/me/lesson-sessions/session-1/finish',
          'GET /api/me/lesson-sessions/session-1/summary',
        ]));
    expect(api.bodies.first, {'validTurnCount': 2});
    expect(api.tokens.first, 'access');
    expect(api.calls.join(' '), isNot(contains('/api/dev')));
    expect(api.calls.join(' '), isNot(contains('/reply')));
  });

  test('finish refreshes once after 401 and accepts unavailable summary',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions/session-1/finish'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: '{}'),
    ];
    api.responses['/api/me/lesson-sessions/session-1/summary'] = [
      const ApiResponse(statusCode: 200, body: '{"status":"unavailable"}'),
    ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .finishLessonSession(sessionId: 'session-1', validTurnCount: 0);
    expect(result.status, LessonCompletionStatus.summaryUnavailable);
    expect(
        api.calls,
        containsAllInOrder([
          'PUT /api/me/lesson-sessions/session-1/finish',
          'POST /api/auth/refresh',
          'PUT /api/me/lesson-sessions/session-1/finish',
          'GET /api/me/lesson-sessions/session-1/summary',
        ]));
  });

  test('summary maps only exact ready and unavailable statuses as completed',
      () async {
    final api = FakeApiClient();
    final service = AuthService(apiClient: api, storage: MemoryStorage());
    api.responses['/api/me/lesson-sessions/session-1/summary'] = [
      const ApiResponse(statusCode: 200, body: '{"status":"ready"}'),
      const ApiResponse(statusCode: 200, body: '{"status":"unavailable"}'),
      const ApiResponse(statusCode: 200, body: '{"status":"pending"}'),
      const ApiResponse(statusCode: 200, body: '{}'),
      const ApiResponse(statusCode: 200, body: 'not-json'),
    ];
    expect((await service.loadLessonSummary(sessionId: 'session-1')).status,
        LessonCompletionStatus.summaryReady);
    expect((await service.loadLessonSummary(sessionId: 'session-1')).status,
        LessonCompletionStatus.summaryUnavailable);
    for (var i = 0; i < 3; i++) {
      expect((await service.loadLessonSummary(sessionId: 'session-1')).status,
          LessonCompletionStatus.summaryLoadError);
    }
  });

  test('summary HTTP and transport failures are retryable load errors',
      () async {
    final api = FakeApiClient();
    final service = AuthService(apiClient: api, storage: MemoryStorage());
    api.responses['/api/me/lesson-sessions/session-1/summary'] = [
      const ApiResponse(statusCode: 404, body: '{}'),
      const ApiResponse(statusCode: 409, body: '{}'),
      const ApiResponse(statusCode: 500, body: '{}'),
    ];
    for (var i = 0; i < 3; i++) {
      expect((await service.loadLessonSummary(sessionId: 'session-1')).status,
          LessonCompletionStatus.summaryLoadError);
    }
    api.errors['/api/me/lesson-sessions/session-1/summary'] = [
      const ApiException('The service took too long to respond.'),
      const ApiException('Unable to reach the service.'),
    ];
    for (var i = 0; i < 2; i++) {
      expect((await service.loadLessonSummary(sessionId: 'session-1')).status,
          LessonCompletionStatus.summaryLoadError);
    }
  });

  test('summary refreshes after 401 and requires sign-in after failed refresh',
      () async {
    final api = FakeApiClient();
    api.responses['/api/me/lesson-sessions/session-1/summary'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: '{"status":"ready"}'),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());
    expect((await service.loadLessonSummary(sessionId: 'session-1')).status,
        LessonCompletionStatus.summaryReady);
    expect(api.calls, contains('POST /api/auth/refresh'));

    final failedRefreshApi = FakeApiClient();
    failedRefreshApi.responses['/api/me/lesson-sessions/session-1/summary'] = [
      const ApiResponse(statusCode: 401, body: '{}')
    ];
    failedRefreshApi.responses['/api/auth/refresh'] = [
      const ApiResponse(statusCode: 401, body: '{}')
    ];
    expect(
        (await AuthService(
                    apiClient: failedRefreshApi, storage: MemoryStorage())
                .loadLessonSummary(sessionId: 'session-1'))
            .status,
        LessonCompletionStatus.authRequired);
  });

  test('translation posts the exact backend contract and parses translatedText',
      () async {
    final api = FakeApiClient();
    api.responses['/api/translate'] = [
      const ApiResponse(statusCode: 200, body: '{"translatedText":"Hola"}'),
    ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .requestTranslation(request: translationRequest);

    expect(result.status, TranslationStatus.success);
    expect(result.translation?.translatedText, 'Hola');
    expect(api.calls, ['POST /api/translate']);
    expect(api.bodies.single, translationRequest.toJson());
    expect(api.bodies.single!.keys, {
      'text',
      'targetLanguage',
      'sourceLanguageId',
      'sourceLanguageName',
      'sourceLanguageNativeName',
      'sourceLanguageCode',
      'backendSessionId',
    });
    expect(api.bodies.single!['targetLanguage'], 'Spanish');
    expect(api.bodies.single!['sourceLanguageId'], 'en');
    expect(api.bodies.single!['sourceLanguageName'], 'English');
    expect(api.bodies.single!['backendSessionId'], 'session-1');
    expect(api.calls.join(' '), isNot(contains('/api/dev')));
  });

  test('translation accepts source-equivalent text and rejects invalid bodies',
      () async {
    final api = FakeApiClient();
    api.responses['/api/translate'] = [
      const ApiResponse(
          statusCode: 200, body: '{"translatedText":"Hello, how are you?"}'),
      const ApiResponse(statusCode: 200, body: '{}'),
      const ApiResponse(statusCode: 200, body: '{"translatedText":"   "}'),
      const ApiResponse(statusCode: 200, body: 'not json'),
    ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());
    expect(
        (await service.requestTranslation(request: translationRequest)).status,
        TranslationStatus.success);
    for (var i = 0; i < 3; i++) {
      expect(
        (await service.requestTranslation(request: translationRequest)).status,
        TranslationStatus.failed,
      );
    }
  });

  test('translation maps safe failures and retries once after 401', () async {
    final cases = <ApiResponse, TranslationStatus>{
      const ApiResponse(statusCode: 400, body: '{}'):
          TranslationStatus.validation,
      const ApiResponse(statusCode: 409, body: '{}'):
          TranslationStatus.sessionEnded,
      const ApiResponse(statusCode: 429, body: '{}'):
          TranslationStatus.temporarilyUnavailable,
      const ApiResponse(statusCode: 500, body: '{}'):
          TranslationStatus.unavailable,
    };
    for (final entry in cases.entries) {
      final api = FakeApiClient();
      api.responses['/api/translate'] = [entry.key];
      expect(
        (await AuthService(apiClient: api, storage: MemoryStorage())
                .requestTranslation(request: translationRequest))
            .status,
        entry.value,
      );
    }

    final api = FakeApiClient();
    api.responses['/api/translate'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: '{"translatedText":"Hola"}'),
    ];
    expect(
      (await AuthService(apiClient: api, storage: MemoryStorage())
              .requestTranslation(request: translationRequest))
          .status,
      TranslationStatus.success,
    );
    expect(api.calls, [
      'POST /api/translate',
      'POST /api/auth/refresh',
      'POST /api/translate',
    ]);

    final failedRefresh = FakeApiClient();
    failedRefresh.responses['/api/translate'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    failedRefresh.responses['/api/auth/refresh'] = [
      const ApiResponse(statusCode: 401, body: '{}'),
    ];
    expect(
      (await AuthService(apiClient: failedRefresh, storage: MemoryStorage())
              .requestTranslation(request: translationRequest))
          .status,
      TranslationStatus.authRequired,
    );
  });

  test('concurrent 401 requests share one refresh and retry with new access',
      () async {
    final refresh = Completer<ApiResponse>();
    final api = FakeApiClient()
      ..responses['/api/translate'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(statusCode: 200, body: '{"translatedText":"Hola"}'),
        const ApiResponse(statusCode: 200, body: '{"translatedText":"Hola"}'),
      ]
      ..delayedRefreshResponse = refresh.future;
    final service = AuthService(apiClient: api, storage: MemoryStorage());

    final first = service.requestTranslation(request: translationRequest);
    await Future<void>.delayed(Duration.zero);
    final second = service.requestTranslation(request: translationRequest);
    await Future<void>.delayed(Duration.zero);
    refresh.complete(const ApiResponse(
      statusCode: 200,
      body:
          '{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-06T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-06T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}',
    ));

    expect((await first).status, TranslationStatus.success);
    expect((await second).status, TranslationStatus.success);
    expect(api.calls.where((call) => call == 'POST /api/auth/refresh'),
        hasLength(1));
    final translationTokens = <String?>[];
    for (var i = 0; i < api.calls.length; i++) {
      if (api.calls[i] == 'POST /api/translate') {
        translationTokens.add(api.tokens[i]);
      }
    }
    expect(translationTokens, ['access', 'access', 'new-access', 'new-access']);
  });

  test('stale 401 retries newer stored access without refreshing', () async {
    final api = FakeApiClient()
      ..responses['/api/translate'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
        const ApiResponse(statusCode: 200, body: '{"translatedText":"Hola"}'),
      ];
    final result = await AuthService(
      apiClient: api,
      storage: StaleResponseStorage(),
    ).requestTranslation(request: translationRequest);

    expect(result.status, TranslationStatus.success);
    expect(api.calls, ['POST /api/translate', 'POST /api/translate']);
    expect(api.tokens, ['old-access', 'new-access']);
  });

  test('binary and multipart requests share the single-flight refresh',
      () async {
    final refresh = Completer<ApiResponse>();
    final api = FakeAudioApiClient()
      ..delayedRefreshResponse = refresh.future
      ..binaryResponses['/api/audio/speech'] = [
        BinaryApiResponse(
            statusCode: 401, bodyBytes: Uint8List(0), headers: {}),
        BinaryApiResponse(
            statusCode: 200,
            bodyBytes: Uint8List.fromList([1]),
            headers: const {'content-type': 'audio/wav'}),
      ]
      ..multipartResponses['/api/audio/transcribe'] = [
        const MultipartApiResponse(statusCode: 401, body: '{}', headers: {}),
        const MultipartApiResponse(
            statusCode: 200, body: '{"text":"Hello"}', headers: {}),
      ];
    final service = AuthService(apiClient: api, storage: MemoryStorage());
    final speech = service.requestTutorSpeech(
        request: const AudioSpeechRequest(
            text: 'Hi',
            speechVoice: 'coral',
            speechSpeed: 1,
            targetLanguageId: 'en',
            targetLanguageName: 'English',
            targetLanguageNativeName: 'English',
            targetLanguageCode: 'en',
            backendSessionId: 'session-1'));
    await Future<void>.delayed(Duration.zero);
    final transcription = service.transcribeLearnerAudio(
        request: const AudioTranscriptionRequest(
            audioFilePath: 'recording.wav',
            targetLanguageId: 'en',
            targetLanguageName: 'English',
            targetLanguageNativeName: 'English',
            targetLanguageCode: 'en',
            lessonPhase: 'active',
            transcriptionContext: 'lesson',
            backendSessionId: 'session-1'));
    await Future<void>.delayed(Duration.zero);
    refresh.complete(const ApiResponse(
        statusCode: 200,
        body:
            '{"accessToken":"new-access","tokenType":"Bearer","expiresAtUtc":"2026-07-06T12:30:00Z","refreshToken":"new-refresh","refreshTokenExpiresAtUtc":"2026-08-06T12:00:00Z","user":{"userId":"u1","email":"user@example.com","displayName":"User","createdAt":"2026-07-01T12:00:00Z"}}'));

    expect((await speech).status, AudioSpeechStatus.success);
    expect((await transcription).status, AudioTranscriptionStatus.success);
    expect(api.calls.where((call) => call == 'POST /api/auth/refresh'),
        hasLength(1));
  });

  test(
      'transcription HTTP 500 stays service unavailable without clearing tokens',
      () async {
    final api = FakeAudioApiClient()
      ..multipartResponses['/api/audio/transcribe'] = [
        const MultipartApiResponse(statusCode: 500, body: '{}', headers: {}),
      ];
    final storage = MemoryStorage();
    final result = await AuthService(apiClient: api, storage: storage)
        .transcribeLearnerAudio(
            request: const AudioTranscriptionRequest(
                audioFilePath: 'recording.wav',
                targetLanguageId: 'en',
                targetLanguageName: 'English',
                targetLanguageNativeName: 'English',
                targetLanguageCode: 'en',
                lessonPhase: 'active',
                transcriptionContext: 'lesson',
                backendSessionId: 'session-1'));
    expect(result.status, AudioTranscriptionStatus.serviceUnavailable);
    expect(storage.access, 'access');
    expect(storage.refresh, 'refresh');
    expect(api.calls, ['MULTIPART /api/audio/transcribe']);
  });

  test('temporary refresh failures preserve stored tokens', () async {
    for (final refreshFailure in [
      const ApiResponse(statusCode: 500, body: '{}'),
      null,
    ]) {
      final api = FakeApiClient()
        ..responses['/api/translate'] = [
          const ApiResponse(statusCode: 401, body: '{}'),
        ];
      if (refreshFailure == null) {
        api.errors['/api/auth/refresh'] = [
          const ApiException('Unable to reach the service.',
              category: ApiFailureCategory.network),
        ];
      } else {
        api.responses['/api/auth/refresh'] = [refreshFailure];
      }
      final storage = MemoryStorage();
      final result = await AuthService(apiClient: api, storage: storage)
          .requestTranslation(request: translationRequest);

      expect(result.status, TranslationStatus.unavailable);
      expect(storage.access, 'access');
      expect(storage.refresh, 'refresh');
    }
  });

  test('invalid refresh token clears stored tokens', () async {
    final api = FakeApiClient()
      ..responses['/api/translate'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
      ]
      ..responses['/api/auth/refresh'] = [
        const ApiResponse(statusCode: 401, body: '{}'),
      ];
    final storage = MemoryStorage();
    final result = await AuthService(apiClient: api, storage: storage)
        .requestTranslation(request: translationRequest);

    expect(result.status, TranslationStatus.authRequired);
    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
  });

  test('feedback report posts the exact authenticated backend contract',
      () async {
    final api = FakeApiClient()
      ..responses['/api/me/feedback-reports'] = [
        const ApiResponse(
            statusCode: 201, body: '{"reportId":"r1","status":"received"}'),
      ];
    final result = await AuthService(apiClient: api, storage: MemoryStorage())
        .submitFeedbackReport(const FeedbackReportRequest(
      category: FeedbackReportCategory.aiResponse,
      message: ' The reply was incorrect. ',
      reportedAiText: ' Example response ',
      clientPlatform: 'android',
      clientVersion: '0.1.0+1',
    ));
    expect(result.status, FeedbackReportSubmitStatus.success);
    expect(api.calls, ['POST /api/me/feedback-reports']);
    expect(api.tokens, ['access']);
    expect(api.bodies.single, {
      'category': 'ai_response',
      'message': 'The reply was incorrect.',
      'reportedAiText': 'Example response',
      'clientPlatform': 'android',
      'clientVersion': '0.1.0+1',
    });
  });
}
