import '../models/lesson_runtime.dart';
import '../models/study_language_definition.dart';

/// Deterministic tutor-facing lesson text ported from Desktop.
///
/// English CMS/runtime text remains semantic source material. Stable CMS IDs,
/// canonical English titles, and runtime scenario keys are never translated.
abstract final class LocalizedLessonTextService {
  static String buildSetupMessage({
    required LessonRuntimeScenario scenario,
    required StudyLanguageDefinition studyLanguage,
  }) {
    final language = _resolve(studyLanguage);
    if (_isEnglish(language)) return _buildEnglishSetupMessage(scenario);

    final subtopic = adaptShortScenarioText(
      scenario.metadata.subtopic,
      language,
    );
    final goal = _adaptGoal(scenario, language);
    final choices = scenario.controlledVariation.contextVariants
        .take(3)
        .map((variant) => localizedScenarioTitle(variant, language))
        .toList(growable: false);
    final choiceBlock = choices.isEmpty
        ? _localizeChooseSimpleSituation(language, subtopic)
        : choices.indexed
            .map((entry) => '${entry.$1 + 1}. ${entry.$2}')
            .join('\n');

    return switch (language.id) {
      'fr' => 'Aujourd’hui, nous allons pratiquer : $subtopic.\n\n'
          'Objectif : $goal\n\nChoisis une situation :\n$choiceBlock\n\n'
          'Ou propose ta propre situation sur ce thème.',
      'de' => 'Heute üben wir: $subtopic.\n\nZiel: $goal\n\n'
          'Wähle eine Situation:\n$choiceBlock\n\n'
          'Oder schlage eine eigene passende Situation vor.',
      'pt' => 'Hoje vamos praticar: $subtopic.\n\nObjetivo: $goal\n\n'
          'Escolha uma situação:\n$choiceBlock\n\n'
          'Ou sugira sua própria situação sobre este tema.',
      'es' => 'Hoy vamos a practicar: $subtopic.\n\nObjetivo: $goal\n\n'
          'Elige una situación:\n$choiceBlock\n\n'
          'O propone tu propia situación sobre este tema.',
      'it' => 'Oggi pratichiamo: $subtopic.\n\nObiettivo: $goal\n\n'
          'Scegli una situazione:\n$choiceBlock\n\n'
          'Oppure proponi una tua situazione su questo tema.',
      _ => _buildEnglishSetupMessage(scenario),
    };
  }

  static String localizedScenarioTitle(
    LessonRuntimeContextVariant variant,
    StudyLanguageDefinition studyLanguage,
  ) =>
      adaptShortScenarioText(variant.title, studyLanguage);

  static String buildContextConfirmationLine({
    required LessonRuntimeContextVariant variant,
    required StudyLanguageDefinition studyLanguage,
    required String englishFallback,
  }) {
    final language = _resolve(studyLanguage);
    if (_isEnglish(language)) return englishFallback.trim();
    final title = localizedScenarioTitle(variant, language);
    return switch (language.id) {
      'fr' => 'Très bien ! Imaginons cette situation : $title.',
      'de' => 'Sehr gut! Stellen wir uns diese Situation vor: $title.',
      'pt' => 'Muito bem! Vamos imaginar esta situação: $title.',
      'es' => 'Muy bien. Imaginemos esta situación: $title.',
      'it' => 'Molto bene! Immaginiamo questa situazione: $title.',
      _ => englishFallback.trim(),
    };
  }

  static String buildContextOpeningLine({
    required String englishOpeningLine,
    required LessonRuntimeScenario scenario,
    required StudyLanguageDefinition studyLanguage,
  }) {
    final language = _resolve(studyLanguage);
    if (_isEnglish(language)) return englishOpeningLine.trim();
    if (_isIntroductionsLesson(scenario)) {
      return switch (language.id) {
        'fr' => 'Bonjour ! Ravi de te rencontrer. Comment tu t’appelles ?',
        'de' => 'Hallo! Schön, dich kennenzulernen. Wie heißt du?',
        'pt' => 'Olá! Prazer em conhecer você. Como você se chama?',
        'es' => '¡Hola! Encantado de conocerte. ¿Cómo te llamas?',
        'it' => 'Ciao! Piacere di conoscerti. Come ti chiami?',
        _ => englishOpeningLine.trim(),
      };
    }
    return switch (language.id) {
      'fr' => 'Commençons simplement. Que veux-tu dire en premier ?',
      'de' => 'Fangen wir einfach an. Was möchtest du zuerst sagen?',
      'pt' => 'Vamos começar de forma simples. O que você quer dizer primeiro?',
      'es' => 'Empecemos de forma sencilla. ¿Qué quieres decir primero?',
      'it' => 'Cominciamo in modo semplice. Che cosa vuoi dire per prima cosa?',
      _ => englishOpeningLine.trim(),
    };
  }

  static String buildSetupContextHint({
    required LessonRuntimeScenario scenario,
    required StudyLanguageDefinition studyLanguage,
  }) {
    final language = _resolve(studyLanguage);
    final titles = scenario.controlledVariation.contextVariants
        .take(3)
        .map((variant) => '"${localizedScenarioTitle(variant, language)}"')
        .toList(growable: false);
    final subtopic = adaptShortScenarioText(
      scenario.metadata.subtopic,
      language,
    ).toLowerCase();
    if (_isEnglish(language)) {
      return titles.isEmpty
          ? 'Choose a simple situation about $subtopic.'
          : 'You can choose: ${titles.join(', ')}.';
    }
    return switch (language.id) {
      'fr' => titles.isEmpty
          ? 'Choisis une situation simple sur $subtopic.'
          : 'Tu peux choisir : ${titles.join(', ')}.',
      'de' => titles.isEmpty
          ? 'Wähle eine einfache Situation zu $subtopic.'
          : 'Du kannst wählen: ${titles.join(', ')}.',
      'pt' => titles.isEmpty
          ? 'Escolha uma situação simples sobre $subtopic.'
          : 'Você pode escolher: ${titles.join(', ')}.',
      'es' => titles.isEmpty
          ? 'Elige una situación sencilla sobre $subtopic.'
          : 'Puedes elegir: ${titles.join(', ')}.',
      'it' => titles.isEmpty
          ? 'Scegli una situazione semplice su $subtopic.'
          : 'Puoi scegliere: ${titles.join(', ')}.',
      _ => titles.isEmpty
          ? 'Choose a simple situation about $subtopic.'
          : 'You can choose: ${titles.join(', ')}.',
    };
  }

  static String buildExampleHint(
    String englishHint,
    StudyLanguageDefinition studyLanguage,
  ) {
    final language = _resolve(studyLanguage);
    if (_isEnglish(language)) return englishHint.trim();
    return switch (language.id) {
      'fr' => 'Essaie une phrase simple en français, par exemple : '
          'Je m’appelle [ton nom].',
      'de' => 'Versuche einen einfachen Satz auf Deutsch, zum Beispiel: '
          'Ich heiße [dein Name].',
      'pt' => 'Tente uma frase simples em português, por exemplo: '
          'Eu me chamo [seu nome].',
      'es' => 'Prueba una frase sencilla en español, por ejemplo: '
          'Me llamo [tu nombre].',
      'it' => 'Prova una frase semplice in italiano, per esempio: '
          'Mi chiamo [il tuo nome].',
      _ => englishHint.trim(),
    };
  }

  static String buildNeutralLessonReadyFallback(
    StudyLanguageDefinition studyLanguage,
  ) {
    final language = _resolve(studyLanguage);
    return switch (language.id) {
      'fr' => 'Ta leçon est prête.',
      'de' => 'Deine Lektion ist bereit.',
      'pt' => 'Sua lição está pronta.',
      'es' => 'Tu lección está lista.',
      'it' => 'La tua lezione è pronta.',
      _ => 'Your lesson is ready.',
    };
  }

  static String buildFinalLessonMessage(
    String englishFinalMessage,
    StudyLanguageDefinition studyLanguage,
  ) {
    final language = _resolve(studyLanguage);
    if (_isEnglish(language)) return englishFinalMessage;
    return switch (language.id) {
      'fr' => 'Très bien travaillé. La leçon est terminée : ouvre le résumé '
          'pour revoir tes points forts et les prochaines étapes.',
      'de' => 'Sehr gut gemacht. Die Lektion ist beendet: Öffne die '
          'Zusammenfassung, um deine Stärken und nächsten Schritte zu sehen.',
      'pt' => 'Muito bom trabalho. A lição terminou: abra o resumo para '
          'revisar seus pontos fortes e os próximos passos.',
      'es' => 'Muy buen trabajo. La lección ha terminado: abre el resumen '
          'para revisar tus puntos fuertes y los próximos pasos.',
      'it' => 'Ottimo lavoro. La lezione è finita: apri il riepilogo per '
          'rivedere i tuoi punti forti e i prossimi passi.',
      _ => englishFinalMessage,
    };
  }

  static String adaptShortScenarioText(
    String value,
    StudyLanguageDefinition studyLanguage,
  ) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '';
    final language = _resolve(studyLanguage);
    if (_isEnglish(language)) return normalized;
    final key = normalized.toLowerCase();
    const mappings = <String, Map<String, String>>{
      'fr': {
        'introductions': 'les présentations',
        'meeting a new neighbor': 'Rencontrer un nouveau voisin',
        'first day at a language school':
            'Premier jour dans une école de langue',
        'meeting someone at a hobby club':
            'Rencontrer quelqu’un dans un club de loisirs',
        'meeting a colleague in the break room':
            'Rencontrer un collègue dans la salle de pause',
        'joining an online english meeting': 'Rejoindre une réunion en ligne',
      },
      'de': {
        'introductions': 'Vorstellungen',
        'meeting a new neighbor': 'Einen neuen Nachbarn treffen',
        'first day at a language school': 'Erster Tag in einer Sprachschule',
        'meeting someone at a hobby club':
            'Jemanden in einem Hobbyclub treffen',
      },
      'pt': {
        'introductions': 'apresentações',
        'meeting a new neighbor': 'Conhecer um novo vizinho',
        'first day at a language school':
            'Primeiro dia em uma escola de idiomas',
        'meeting someone at a hobby club':
            'Conhecer alguém em um clube de hobby',
      },
      'es': {
        'introductions': 'presentaciones',
        'meeting a new neighbor': 'Conocer a un nuevo vecino',
        'first day at a language school':
            'Primer día en una escuela de idiomas',
        'meeting someone at a hobby club':
            'Conocer a alguien en un club de aficiones',
      },
      'it': {
        'introductions': 'presentazioni',
        'meeting a new neighbor': 'Conoscere un nuovo vicino',
        'first day at a language school':
            'Primo giorno in una scuola di lingue',
        'meeting someone at a hobby club':
            'Conoscere qualcuno in un club di hobby',
      },
    };
    return mappings[language.id]?[key] ?? normalized;
  }

  static String _buildEnglishSetupMessage(LessonRuntimeScenario scenario) {
    final parts = <String>[];
    final openingLine = scenario.conversationFlow.opening.trim().isNotEmpty
        ? scenario.conversationFlow.opening.trim()
        : scenario.lessonSetup.setupMessage.trim();
    final goal = scenario.learningGoal.goal.trim();
    if (openingLine.isNotEmpty) parts.add(openingLine);
    if (goal.isNotEmpty) parts.add('Goal: $goal');
    final choices = scenario.controlledVariation.contextVariants
        .take(3)
        .map((variant) => variant.title.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (choices.isNotEmpty) {
      parts.add([
        'Choose a situation:',
        ...choices.indexed.map((entry) => '${entry.$1 + 1}. ${entry.$2}'),
      ].join('\n'));
    }
    final subtopic = scenario.metadata.subtopic.trim();
    if (subtopic.isNotEmpty) {
      parts.add(
          'Or suggest your own situation about ${subtopic.toLowerCase()}.');
    }
    return parts.isEmpty ? 'Your lesson is ready.' : parts.join('\n\n');
  }

  static String _adaptGoal(
    LessonRuntimeScenario scenario,
    StudyLanguageDefinition language,
  ) {
    if (_isIntroductionsLesson(scenario)) {
      return switch (language.id) {
        'fr' => 'tu vas apprendre à dire ton nom, d’où tu viens et à poser '
            'des questions simples.',
        'de' => 'du lernst, deinen Namen zu sagen, woher du kommst, und '
            'einfache Fragen zu stellen.',
        'pt' => 'você vai aprender a dizer seu nome, de onde você é, e '
            'fazer perguntas simples.',
        'es' => 'aprenderás a decir tu nombre, de dónde eres y a hacer '
            'preguntas sencillas.',
        'it' => 'imparerai a dire il tuo nome, da dove vieni e a fare '
            'domande semplici.',
        _ => scenario.learningGoal.goal,
      };
    }
    final goal = scenario.learningGoal.goal.trim().isEmpty
        ? scenario.metadata.subtopic
        : scenario.learningGoal.goal;
    return switch (language.id) {
      'fr' => 'pratiquer cette situation en ${language.tutorInstructionName} : '
          '$goal.',
      'de' => 'diese Situation auf ${language.tutorInstructionName} üben: '
          '$goal.',
      'pt' => 'praticar esta situação em ${language.tutorInstructionName}: '
          '$goal.',
      'es' => 'practicar esta situación en ${language.tutorInstructionName}: '
          '$goal.',
      'it' =>
        'praticare questa situazione in ${language.tutorInstructionName}: '
            '$goal.',
      _ => goal,
    };
  }

  static String _localizeChooseSimpleSituation(
    StudyLanguageDefinition language,
    String subtopic,
  ) =>
      switch (language.id) {
        'fr' => 'Choisis une situation simple sur $subtopic.',
        'de' => 'Wähle eine einfache Situation zu $subtopic.',
        'pt' => 'Escolha uma situação simples sobre $subtopic.',
        'es' => 'Elige una situación sencilla sobre $subtopic.',
        'it' => 'Scegli una situazione semplice su $subtopic.',
        _ => 'Choose a simple situation about $subtopic.',
      };

  static bool _isIntroductionsLesson(LessonRuntimeScenario scenario) =>
      scenario.metadata.subtopic.trim().toLowerCase() == 'introductions' ||
      scenario.id.trim().toLowerCase() == 'everyday_english_introductions';

  static StudyLanguageDefinition _resolve(
    StudyLanguageDefinition studyLanguage,
  ) =>
      StudyLanguageDefinitions.resolve(studyLanguage.id);

  static bool _isEnglish(StudyLanguageDefinition language) =>
      language.id == 'en';
}
