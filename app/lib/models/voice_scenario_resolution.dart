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
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      candidateContextIds: (json['candidateContextIds'] as List? ?? const [])
          .whereType<String>()
          .take(2)
          .toList(growable: false),
      normalizedFreeContext: json['normalizedFreeContext'] as String?,
      clarificationText: json['clarificationText'] as String?,
    );
  }
}

class VoiceScenarioSemanticResult {
  const VoiceScenarioSemanticResult._({this.response, this.message});

  final VoiceScenarioSemanticResponse? response;
  final String? message;
  bool get isSuccess => response != null;

  factory VoiceScenarioSemanticResult.success(
          VoiceScenarioSemanticResponse response) =>
      VoiceScenarioSemanticResult._(response: response);

  factory VoiceScenarioSemanticResult.failed([String? message]) =>
      VoiceScenarioSemanticResult._(
        message: message ??
            'Scenario matching is temporarily unavailable. Review or edit the recognized text.',
      );
}
