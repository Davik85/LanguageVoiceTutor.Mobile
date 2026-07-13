class VoiceScenarioCandidateRequest {
  const VoiceScenarioCandidateRequest({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
      };
}

class VoiceScenarioResolutionRequest {
  const VoiceScenarioResolutionRequest({
    required this.studyLanguage,
    required this.learnerLevel,
    required this.topicId,
    required this.subtopicId,
    required this.runtimeScenarioId,
    required this.runtimeVersion,
    required this.recognizedText,
    required this.candidates,
  });

  final String studyLanguage;
  final String learnerLevel;
  final String topicId;
  final String subtopicId;
  final String runtimeScenarioId;
  final int? runtimeVersion;
  final String recognizedText;
  final List<VoiceScenarioCandidateRequest> candidates;

  Map<String, dynamic> toJson() => {
        'studyLanguage': studyLanguage,
        'learnerLevel': learnerLevel,
        'topicId': topicId,
        'subtopicId': subtopicId,
        'runtimeScenarioId': runtimeScenarioId,
        'runtimeVersion': runtimeVersion,
        'recognizedText': recognizedText,
        'isInitialScenarioSelectionTurn': true,
        'candidates':
            candidates.map((candidate) => candidate.toJson()).toList(),
      };
}

enum VoiceScenarioSemanticDecision {
  publishedContext,
  freeContext,
  clarify,
  unsafe,
}

class VoiceScenarioSemanticResponse {
  const VoiceScenarioSemanticResponse({
    required this.decision,
    required this.confidence,
    this.matchedContextId,
    this.candidateContextIds = const [],
    this.normalizedFreeContext,
    this.clarificationText,
  });

  final VoiceScenarioSemanticDecision decision;
  final String? matchedContextId;
  final double confidence;
  final List<String> candidateContextIds;
  final String? normalizedFreeContext;
  final String? clarificationText;

  factory VoiceScenarioSemanticResponse.fromJson(Map<String, dynamic> json) {
    const requiredFields = {
      'decision',
      'matchedContextId',
      'confidence',
      'candidateContextIds',
      'normalizedFreeContext',
      'clarificationText',
    };
    if (!requiredFields.every(json.containsKey) ||
        json['decision'] is! String ||
        (json['matchedContextId'] != null &&
            json['matchedContextId'] is! String) ||
        json['confidence'] is! num ||
        json['candidateContextIds'] is! List ||
        !(json['candidateContextIds'] as List)
            .every((item) => item is String) ||
        (json['normalizedFreeContext'] != null &&
            json['normalizedFreeContext'] is! String) ||
        (json['clarificationText'] != null &&
            json['clarificationText'] is! String)) {
      throw const FormatException('Invalid voice scenario response contract.');
    }
    final decision = switch (json['decision']) {
      'published_context' => VoiceScenarioSemanticDecision.publishedContext,
      'free_context' => VoiceScenarioSemanticDecision.freeContext,
      'clarify' => VoiceScenarioSemanticDecision.clarify,
      'unsafe' => VoiceScenarioSemanticDecision.unsafe,
      _ => throw const FormatException('Invalid voice scenario decision.'),
    };
    return VoiceScenarioSemanticResponse(
      decision: decision,
      matchedContextId: json['matchedContextId'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      candidateContextIds: (json['candidateContextIds'] as List)
          .cast<String>()
          .toList(growable: false),
      normalizedFreeContext: json['normalizedFreeContext'] as String?,
      clarificationText: json['clarificationText'] as String?,
    );
  }
}

class VoiceScenarioResolutionDiagnostic {
  const VoiceScenarioResolutionDiagnostic({
    required this.requestAttempted,
    required this.httpStatusCode,
    required this.refreshRetry,
    required this.failureStage,
    required this.responseParsed,
    required this.backendSafeCode,
    required this.decisionPresent,
    required this.matchedIdPresent,
    required this.normalizedFreeContextPresent,
    required this.candidateCount,
  });

  final bool requestAttempted;
  final int? httpStatusCode;
  final bool refreshRetry;
  final String failureStage;
  final bool responseParsed;
  final String? backendSafeCode;
  final bool decisionPresent;
  final bool matchedIdPresent;
  final bool normalizedFreeContextPresent;
  final int candidateCount;

  Map<String, Object?> toFields() => {
        'requestAttempted': requestAttempted,
        'httpStatusCode': httpStatusCode,
        'refreshRetry': refreshRetry,
        'failureStage': failureStage,
        'responseParsed': responseParsed,
        'backendSafeCode': backendSafeCode,
        'decisionPresent': decisionPresent,
        'matchedIdPresent': matchedIdPresent,
        'normalizedFreeContextPresent': normalizedFreeContextPresent,
        'candidateCount': candidateCount,
      };
}

class VoiceScenarioSemanticResult {
  const VoiceScenarioSemanticResult._({
    this.response,
    this.message,
    required this.diagnostic,
  });

  final VoiceScenarioSemanticResponse? response;
  final String? message;
  final VoiceScenarioResolutionDiagnostic diagnostic;
  bool get isSuccess => response != null;

  factory VoiceScenarioSemanticResult.success(
    VoiceScenarioSemanticResponse response, {
    VoiceScenarioResolutionDiagnostic? diagnostic,
  }) =>
      VoiceScenarioSemanticResult._(
        response: response,
        diagnostic: diagnostic ??
            const VoiceScenarioResolutionDiagnostic(
              requestAttempted: true,
              httpStatusCode: 200,
              refreshRetry: false,
              failureStage: 'success',
              responseParsed: true,
              backendSafeCode: null,
              decisionPresent: true,
              matchedIdPresent: false,
              normalizedFreeContextPresent: false,
              candidateCount: 0,
            ),
      );

  factory VoiceScenarioSemanticResult.failed([
    String? message,
    VoiceScenarioResolutionDiagnostic? diagnostic,
  ]) =>
      VoiceScenarioSemanticResult._(
        message: message ??
            'Scenario matching is temporarily unavailable. Review or edit the recognized text.',
        diagnostic: diagnostic ??
            const VoiceScenarioResolutionDiagnostic(
              requestAttempted: false,
              httpStatusCode: null,
              refreshRetry: false,
              failureStage: 'request_not_started',
              responseParsed: false,
              backendSafeCode: null,
              decisionPresent: false,
              matchedIdPresent: false,
              normalizedFreeContextPresent: false,
              candidateCount: 0,
            ),
      );
}
