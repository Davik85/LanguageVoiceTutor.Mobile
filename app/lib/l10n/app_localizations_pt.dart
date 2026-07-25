// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Language Voice Tutor';

  @override
  String get settings => 'Definições';

  @override
  String get profile => 'Perfil';

  @override
  String get app => 'Aplicação';

  @override
  String get saveSettings => 'Guardar definições';

  @override
  String get saving => 'A guardar...';

  @override
  String get settingsSaved => 'Definições guardadas.';

  @override
  String get unableToSaveSettings =>
      'Não é possível guardar as definições neste momento.';

  @override
  String get learning => 'Aprendizagem';

  @override
  String get studyLanguage => 'Língua de estudo';

  @override
  String get nativeLanguage => 'Língua materna';

  @override
  String get interfaceLanguage => 'Língua da interface';

  @override
  String get interfaceExplanationLanguage =>
      'Língua da interface / das explicações';

  @override
  String get interfaceLanguageDescription =>
      'Altera apenas a língua da interface da aplicação.';

  @override
  String get currentLevel => 'Nível atual';

  @override
  String get selectedTutor => 'Tutor selecionado';

  @override
  String get loadingSettings => 'A carregar definições...';

  @override
  String get unableToLoadSettings =>
      'Não é possível carregar as definições neste momento.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get back => 'Voltar';

  @override
  String get login => 'Iniciar sessão';

  @override
  String get register => 'Registar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Palavra-passe';

  @override
  String get displayNameOptional => 'Nome de apresentação (opcional)';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get unableToCheckSession =>
      'Não é possível verificar a sessão. Tente novamente.';

  @override
  String get lessons => 'Lições';

  @override
  String get lessonHistory => 'Histórico de lições';

  @override
  String get progress => 'Progresso';

  @override
  String get rewards => 'Recompensas';

  @override
  String get viewAll => 'Ver tudo';

  @override
  String get achievements => 'Conquistas';

  @override
  String get account => 'Conta';

  @override
  String get logout => 'Terminar sessão';

  @override
  String get audio => 'Áudio';

  @override
  String get feedbackAndReports => 'Feedback e relatórios';

  @override
  String get cancel => 'Cancelar';

  @override
  String get submit => 'Submeter';

  @override
  String get send => 'Enviar';

  @override
  String get done => 'Concluído';

  @override
  String get openAndroidSettings => 'Abrir definições do Android';

  @override
  String get hint => 'Sugestão';

  @override
  String get finishLesson => 'Terminar lição';

  @override
  String get typeYourMessage => 'Escreva a sua mensagem';

  @override
  String get sending => 'A enviar...';

  @override
  String get languageNameEnglish => 'Inglês';

  @override
  String get languageNameRussian => 'Russo';

  @override
  String get languageNameSpanish => 'Espanhol';

  @override
  String get languageNameFrench => 'Francês';

  @override
  String get languageNameGerman => 'Alemão';

  @override
  String get signInToApp => 'Inicie sessão no Language Voice Tutor';

  @override
  String get pleaseWait => 'Aguarde...';

  @override
  String get alreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get invalidEmail => 'Introduza um endereço de e-mail válido.';

  @override
  String get enterPassword => 'Introduza a sua palavra-passe.';

  @override
  String get chooseTopic => 'Escolher tópico';

  @override
  String get chooseTopicTitle => 'Escolha um tópico';

  @override
  String get chooseTopicSubtitle =>
      'Escolha o tipo de conversa que pretende praticar.';

  @override
  String get chooseSituation => 'Escolher situação';

  @override
  String get chooseSituationTitle => 'Escolha uma situação';

  @override
  String get chooseSituationSubtitle =>
      'Pratique um momento específico deste tópico.';

  @override
  String get viewAllRewards =>
      'Veja todos os emblemas e recompensas de aprendizagem.';

  @override
  String get accountDeletion => 'Eliminação de conta';

  @override
  String get requestAccountDeletion => 'Solicitar eliminação da conta';

  @override
  String get loadingAccount => 'A carregar conta...';

  @override
  String get premiumAndSubscription => 'Premium e subscrição';

  @override
  String get currentPassword => 'Palavra-passe atual';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get submitting => 'A submeter...';

  @override
  String get loadingTutors => 'A carregar tutores...';

  @override
  String get noTutorsAvailable => 'Não há tutores disponíveis neste momento.';

  @override
  String get loadingAudioSettings => 'A carregar definições de áudio...';

  @override
  String get conversationModeEnabled => 'Modo de conversa ativado';

  @override
  String get sendSuggestionOrReport =>
      'Enviar uma sugestão ou comunicar um problema';

  @override
  String get reportType => 'Tipo de comunicação';

  @override
  String get pasteAiResponseOptional => 'Cole a resposta da IA (opcional)';

  @override
  String get lessonHistoryHeading => 'As suas lições concluídas recentemente';

  @override
  String get noCompletedLessons => 'Ainda não há lições concluídas';

  @override
  String get completedLessonsAppearHere =>
      'As lições concluídas aparecerão aqui.';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get lesson => 'Lição';

  @override
  String get level => 'Nível';

  @override
  String get completed => 'Concluída';

  @override
  String get finished => 'Terminada';

  @override
  String get lessonChat => 'Conversa da lição';

  @override
  String get conversation => 'Conversa';

  @override
  String turnCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interações',
      one: '1 interação',
    );
    return '$_temp0';
  }

  @override
  String get achievementsUnavailable => 'Ainda não há conquistas disponíveis.';

  @override
  String unlockedCount(num unlocked, num total) {
    return '$unlocked de $total desbloqueadas';
  }

  @override
  String learningLanguage(String language) {
    return 'A aprender $language';
  }

  @override
  String get streaks => 'Sequências';

  @override
  String get lessonMilestones => 'Marcos das lições';

  @override
  String get topics => 'Tópicos';

  @override
  String get situations => 'Situações';

  @override
  String get otherAchievements => 'Outras conquistas';

  @override
  String progressCount(num current, num total) {
    return '$current de $total';
  }

  @override
  String get startLesson => 'Iniciar lição';

  @override
  String get openSettings => 'Abrir definições';

  @override
  String get keepLearningRhythm => 'Mantenha o ritmo de aprendizagem';

  @override
  String get reminderPermissionExplanation =>
      'Language Voice Tutor pode enviar-lhe dois lembretes diários animadores para que a prática não se perca num dia atarefado. Pode alterar as horas ou desativar os lembretes nas Definições.';

  @override
  String get notNow => 'Agora não';

  @override
  String get allowReminders => 'Permitir lembretes';

  @override
  String get achievementsTemporarilyUnavailable =>
      'Conquistas temporariamente indisponíveis';

  @override
  String get achievementsEmpty => 'As suas conquistas aparecerão aqui.';

  @override
  String learningStreak(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count dias',
      one: 'Sequência de 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get learningStreakLoading => 'A carregar sequência de aprendizagem';

  @override
  String get learningStreakUnavailable =>
      'Sequência de aprendizagem indisponível';

  @override
  String get learnerFallbackName => 'Aprendente';

  @override
  String get premiumPlan => 'Plano Premium';

  @override
  String get premiumTrial => 'Período experimental Premium';

  @override
  String get freePlan => 'Plano gratuito';

  @override
  String signedInAs(String name) {
    return 'Sessão iniciada como $name';
  }

  @override
  String get premiumDetails => 'Detalhes Premium';

  @override
  String get explorePremium => 'Conheça o Premium';

  @override
  String freeLessonsAvailableToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições gratuitas disponíveis hoje',
      one: '1 lição gratuita disponível hoje',
    );
    return '$_temp0';
  }

  @override
  String get yourWeek => 'A sua semana';

  @override
  String lessonsLastSevenDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições nos últimos 7 dias',
      one: '1 lição nos últimos 7 dias',
    );
    return '$_temp0';
  }

  @override
  String get startStreakToday => 'Comece a sua sequência hoje';

  @override
  String get activityUnavailable =>
      'A atividade não está disponível neste momento.';

  @override
  String lessonsCompleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições concluídas',
      one: '1 lição concluída',
    );
    return '$_temp0';
  }

  @override
  String activityDaySemantics(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições concluídas',
      one: '1 lição concluída',
    );
    return '$date: $_temp0';
  }

  @override
  String get weekdayMon => 'Seg';

  @override
  String get weekdayTue => 'Ter';

  @override
  String get weekdayWed => 'Qua';

  @override
  String get weekdayThu => 'Qui';

  @override
  String get weekdayFri => 'Sex';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get remindersTemporarilyUnavailable =>
      'Os lembretes de prática estão temporariamente indisponíveis.';

  @override
  String get unableToUpdateReminders =>
      'Não é possível atualizar os lembretes neste momento. Tente novamente.';

  @override
  String get unableToLoadAccount =>
      'Não é possível carregar os detalhes da conta neste momento.';

  @override
  String get tutorChoicesUnavailable =>
      'As opções de tutor não estão disponíveis neste momento. Ainda pode rever e guardar as outras definições.';

  @override
  String get pleaseEnterDescription => 'Introduza uma descrição.';

  @override
  String get emailRequired => 'O e-mail é obrigatório.';

  @override
  String get resetCodePasswordRequired =>
      'O código de reposição e a nova palavra-passe são obrigatórios.';

  @override
  String get passwordsMustMatch =>
      'A nova palavra-passe e a confirmação têm de coincidir.';

  @override
  String get signInToChangePassword =>
      'Inicie sessão para alterar a sua palavra-passe.';

  @override
  String get currentPasswordRequired => 'A palavra-passe atual é obrigatória.';

  @override
  String get accountDeletionDescription =>
      'Envie um pedido para eliminar permanentemente a sua conta Language Voice Tutor e os seus dados pessoais.';

  @override
  String get accountDeletionNotice =>
      'Enviar este pedido não elimina a sua conta de imediato. O apoio irá analisá-lo e processá-lo, podendo pedir mais informações. A resposta será enviada para o endereço de e-mail associado à sua conta. A sua conta não é considerada eliminada apenas por ter enviado este pedido.';

  @override
  String get noDisplayName => 'Sem nome de apresentação';

  @override
  String get subscriptionUnavailable => 'Subscrição indisponível';

  @override
  String get noPaidPlan => 'Sem plano pago';

  @override
  String requestId(String id) {
    return 'ID do pedido: $id';
  }

  @override
  String statusValue(String status) {
    return 'Estado: $status';
  }

  @override
  String get passwordRecovery => 'Palavra-passe e recuperação';

  @override
  String get accountEmail => 'E-mail da conta';

  @override
  String get sendingResetInstructions => 'A enviar instruções de reposição...';

  @override
  String get forgotPassword => 'Esqueci-me da palavra-passe';

  @override
  String get resetCode => 'Código de reposição';

  @override
  String get newPassword => 'Nova palavra-passe';

  @override
  String get confirmNewPassword => 'Confirmar nova palavra-passe';

  @override
  String get updatingPassword => 'A atualizar a palavra-passe...';

  @override
  String get resetPassword => 'Repor palavra-passe';

  @override
  String get newAccountPassword => 'Nova palavra-passe da conta';

  @override
  String get confirmNewAccountPassword =>
      'Confirmar nova palavra-passe da conta';

  @override
  String get changingPassword => 'A alterar a palavra-passe...';

  @override
  String get changePassword => 'Alterar palavra-passe';

  @override
  String get tutorVoice => 'Voz do tutor';

  @override
  String speechSpeed(String speed) {
    return 'Velocidade da fala: ${speed}x';
  }

  @override
  String get feedbackSuggestion => 'Sugestão';

  @override
  String get feedbackAppProblem => 'Problema na aplicação';

  @override
  String get feedbackAiResponse => 'Resposta da IA';

  @override
  String get yourSuggestion => 'A sua sugestão';

  @override
  String get describeProblem => 'Descreva o problema';

  @override
  String get aiResponseProblem => 'O que estava errado na resposta da IA?';

  @override
  String get practiceReminders => 'Lembretes de prática';

  @override
  String get localRemindersDescription =>
      'Estes lembretes são locais neste dispositivo.';

  @override
  String get dailyPracticeReminders => 'Lembretes diários de prática';

  @override
  String get morningReminder => 'Lembrete matinal';

  @override
  String get eveningReminder => 'Lembrete noturno';

  @override
  String get notificationsAllowed => 'Notificações permitidas';

  @override
  String get notificationStatusUnavailable =>
      'Estado das notificações indisponível';

  @override
  String get notificationsBlocked =>
      'As notificações estão bloqueadas pelo Android.';

  @override
  String get allowNotifications => 'Permitir notificações';

  @override
  String get feedbackReceived => 'Obrigado. A sua mensagem foi recebida.';

  @override
  String get feedbackValidationFailure =>
      'Verifique a sua mensagem e tente novamente.';

  @override
  String get feedbackUnavailable =>
      'O feedback está temporariamente indisponível. Tente novamente.';

  @override
  String get deletionRequestAlreadyExists =>
      'Já existe um pedido ativo de eliminação da conta.';

  @override
  String get deletionRequestSubmitted =>
      'O seu pedido de eliminação da conta foi enviado para processamento pelo apoio.';

  @override
  String get incorrectCurrentPassword =>
      'A sua palavra-passe atual está incorreta.';

  @override
  String get unableToReachService =>
      'Não é possível contactar o serviço. Tente novamente.';

  @override
  String get unexpectedServiceResponse =>
      'O serviço devolveu uma resposta inesperada. Tente novamente.';

  @override
  String get unableToSubmitRequest =>
      'Não é possível submeter o seu pedido neste momento. Tente novamente.';

  @override
  String get unableToLoadLearningSettings =>
      'Não é possível carregar as suas definições de aprendizagem neste momento. Tente novamente.';

  @override
  String get settingsTemporarilyUnavailable =>
      'As definições estão temporariamente indisponíveis. Tente novamente.';

  @override
  String selectedLevelContext(String level) {
    return 'Nível: $level';
  }

  @override
  String selectedLevelTopicContext(String level, String topic) {
    return 'Nível: $level / Tópico: $topic';
  }

  @override
  String topicCardSemantics(String label, String description) {
    return '$label. $description';
  }

  @override
  String situationCardSemantics(String label, String description) {
    return '$label. $description';
  }

  @override
  String openTopicTooltip(String topic) {
    return 'Abrir $topic';
  }

  @override
  String openSituationTooltip(String situation) {
    return 'Abrir $situation';
  }

  @override
  String get noSituationsAvailable =>
      'Não há situações disponíveis para este tópico.';

  @override
  String get levelA1Label => 'A1 Iniciante';

  @override
  String get levelA1Description =>
      'Desenvolva cumprimentos simples, expresse necessidades e dê respostas curtas do dia a dia.';

  @override
  String get levelA2Label => 'A2 Elementar';

  @override
  String get levelA2Description =>
      'Lide com conversas de rotina usando palavras e frases familiares.';

  @override
  String get levelB1Label => 'B1 Intermédio';

  @override
  String get levelB1Description =>
      'Pratique interações mais longas, opiniões e resolução de problemas do dia a dia.';

  @override
  String get levelB2Label => 'B2 Intermédio avançado';

  @override
  String get levelB2Description =>
      'Aperfeiçoe conversas com nuances e detalhes mais naturais.';

  @override
  String get topicDailyLifeLabel => 'Vida diária';

  @override
  String get topicDailyLifeDescription =>
      'Conversas informais, apresentações e situações do dia a dia.';

  @override
  String get topicTravelLabel => 'Viagens';

  @override
  String get topicTravelDescription =>
      'Aeroportos, hotéis, direções e transportes.';

  @override
  String get topicWorkBusinessLabel => 'Trabalho e negócios';

  @override
  String get topicWorkBusinessDescription =>
      'Reuniões, e-mails, chamadas e conversas no trabalho.';

  @override
  String get topicJobInterviewLabel => 'Entrevista de emprego';

  @override
  String get topicJobInterviewDescription =>
      'Pratique perguntas e respostas comuns de entrevistas.';

  @override
  String get topicRestaurantCafeLabel => 'Restaurante e café';

  @override
  String get topicRestaurantCafeDescription =>
      'Pedir comida, reservar mesas e fazer pedidos educados.';

  @override
  String get topicFreeConversationLabel => 'Conversa livre';

  @override
  String get topicFreeConversationDescription =>
      'Prática aberta moldada pelo que pretende dizer.';

  @override
  String get situationIntroductionsLabel => 'Apresentações';

  @override
  String get situationIntroductionsDescription =>
      'Apresente-se e faça perguntas pessoais básicas.';

  @override
  String get situationSmallTalkNeighborLabel => 'Falar com um vizinho';

  @override
  String get situationSmallTalkNeighborDescription =>
      'Tenha uma conversa curta e amigável perto de casa.';

  @override
  String get situationAskingForHelpLabel => 'Pedir ajuda';

  @override
  String get situationAskingForHelpDescription =>
      'Peça ajuda numa situação simples do dia a dia.';

  @override
  String get situationMakingPlansLabel => 'Fazer planos';

  @override
  String get situationMakingPlansDescription =>
      'Planeie uma atividade e combine a hora e o local.';

  @override
  String get situationTalkingAboutDayLabel => 'Falar sobre o seu dia';

  @override
  String get situationTalkingAboutDayDescription =>
      'Descreva o seu dia e a rotina diária.';

  @override
  String get situationAirportCheckInLabel => 'Check-in no aeroporto';

  @override
  String get situationAirportCheckInDescription =>
      'Faça o check-in para um voo e confirme os detalhes da viagem.';

  @override
  String get situationHotelCheckInLabel => 'Check-in no hotel';

  @override
  String get situationHotelCheckInDescription =>
      'Faça o check-in num hotel e coloque perguntas comuns.';

  @override
  String get situationAskingForDirectionsLabel => 'Pedir direções';

  @override
  String get situationAskingForDirectionsDescription =>
      'Peça e compreenda direções numa cidade nova.';

  @override
  String get situationOrderingTransportLabel => 'Pedir transporte';

  @override
  String get situationOrderingTransportDescription =>
      'Organize um táxi ou transporte partilhado até ao destino.';

  @override
  String get situationLostLuggageLabel => 'Bagagem perdida';

  @override
  String get situationLostLuggageDescription =>
      'Comunique bagagem perdida e explique a sua situação.';

  @override
  String get situationFirstMeetingLabel => 'Primeira reunião';

  @override
  String get situationFirstMeetingDescription =>
      'Apresente-se numa nova reunião de trabalho.';

  @override
  String get situationDailyStandupLabel => 'Reunião diária';

  @override
  String get situationDailyStandupDescription =>
      'Dê uma breve atualização sobre as suas tarefas.';

  @override
  String get situationClientPhoneCallLabel => 'Chamada com um cliente';

  @override
  String get situationClientPhoneCallDescription =>
      'Conduza uma chamada profissional clara e educada.';

  @override
  String get situationAskingForClarificationLabel => 'Pedir esclarecimentos';

  @override
  String get situationAskingForClarificationDescription =>
      'Faça perguntas complementares para confirmar os requisitos.';

  @override
  String get situationDiscussingDeadlinesLabel => 'Discutir prazos';

  @override
  String get situationDiscussingDeadlinesDescription =>
      'Fale sobre prazos e expectativas de entrega.';

  @override
  String get situationTellMeAboutYourselfLabel => 'Fale-me de si';

  @override
  String get situationTellMeAboutYourselfDescription =>
      'Faça uma breve apresentação pessoal adequada a uma entrevista.';

  @override
  String get situationWorkExperienceLabel => 'Experiência profissional';

  @override
  String get situationWorkExperienceDescription =>
      'Descreva trabalho anterior, responsabilidades e um resultado.';

  @override
  String get situationStrengthsWeaknessesLabel => 'Pontos fortes e fracos';

  @override
  String get situationStrengthsWeaknessesDescription =>
      'Fale profissionalmente sobre um ponto forte e uma área a melhorar.';

  @override
  String get situationWhyThisJobLabel => 'Porque quer este emprego?';

  @override
  String get situationWhyThisJobDescription =>
      'Explique a sua motivação e relacione a função com as suas competências.';

  @override
  String get situationQuestionsAtEndLabel => 'Fazer perguntas no final';

  @override
  String get situationQuestionsAtEndDescription =>
      'Faça perguntas educadas e úteis antes de a entrevista terminar.';

  @override
  String get situationBookingTableLabel => 'Reservar uma mesa';

  @override
  String get situationBookingTableDescription =>
      'Ligue ou fale com alguém para reservar uma mesa.';

  @override
  String get situationOrderingFoodLabel => 'Pedir comida';

  @override
  String get situationOrderingFoodDescription =>
      'Peça uma refeição e faça perguntas simples sobre o menu.';

  @override
  String get situationAskingIngredientsLabel => 'Perguntar sobre ingredientes';

  @override
  String get situationAskingIngredientsDescription =>
      'Pergunte sobre alergias e ingredientes dos pratos.';

  @override
  String get situationWrongOrderLabel => 'Lidar com um pedido errado';

  @override
  String get situationWrongOrderDescription =>
      'Explique educadamente um problema com o seu pedido.';

  @override
  String get situationPayingBillLabel => 'Pagar a conta';

  @override
  String get situationPayingBillDescription =>
      'Peça a conta e conclua o pagamento.';

  @override
  String get situationOpenConversationLabel => 'Conversa aberta';

  @override
  String get situationOpenConversationDescription =>
      'Pratique qualquer tema com seguimento flexível.';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatusLoadingSemantics => 'A carregar estado Premium';

  @override
  String get premiumStatusTemporarilyUnavailable =>
      'O estado Premium está temporariamente indisponível. Tente novamente.';

  @override
  String premiumStatusSemantics(String status) {
    return 'Estado Premium: $status';
  }

  @override
  String get premiumActive => 'Premium ativo';

  @override
  String get premiumActiveDescription =>
      'Pratique sem o limite diário de lições gratuitas.';

  @override
  String premiumEndsOn(String date) {
    return 'O Premium termina a $date.';
  }

  @override
  String get premiumTrialActiveDescription =>
      'O seu período experimental Premium está ativo.';

  @override
  String premiumTrialEndsOn(String date) {
    return 'O período experimental termina a $date.';
  }

  @override
  String freeLessonsRemainingToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restam $count lições gratuitas hoje.',
      one: 'Resta 1 lição gratuita hoje.',
      zero: 'Não restam lições gratuitas hoje.',
    );
    return '$_temp0';
  }

  @override
  String get premiumRemovesDailyLimit =>
      'O Premium elimina o limite diário de lições.';

  @override
  String get premiumAccountLinked =>
      'O acesso Premium está associado à sua conta Language Voice Tutor.';

  @override
  String get premiumSharedAcrossClients =>
      'O seu estado Premium confirmado é partilhado entre clientes Language Voice Tutor compatíveis.';

  @override
  String get premiumBenefits => 'Vantagens Premium';

  @override
  String get premiumBenefitDailyLimit =>
      '• Pratique sem o limite diário de lições gratuitas';

  @override
  String get premiumBenefitAcrossDevices =>
      '• Use o mesmo acesso Premium em dispositivos compatíveis';

  @override
  String get premiumBenefitAccountData =>
      '• Mantenha a conta, o progresso, o histórico e as definições de aprendizagem juntos';

  @override
  String get getPremium => 'Obter Premium';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get refreshPremiumStatus => 'Atualizar estado';

  @override
  String get billingProviderExplanation =>
      'As alterações de faturação devem ser tratadas pelo fornecedor onde o Premium foi adquirido.';

  @override
  String get googlePlayPurchasesUnavailableTitle =>
      'As compras Google Play ainda não estão disponíveis';

  @override
  String get restorePurchasesUnavailableTitle =>
      'Restaurar compras ainda não está disponível';

  @override
  String get googlePlayPurchasesUnavailableDescription =>
      'As compras serão associadas no passo seguinte. Esta versão não pode cobrar-lhe nem ativar o Premium.';

  @override
  String get restorePurchasesUnavailableDescription =>
      'O restauro Google Play será associado ao fluxo de faturação. O estado atual da sua conta continua a ser carregado do Language Voice Tutor.';

  @override
  String get purchasePendingConfirmation =>
      'O processamento da compra ainda não está confirmado. Atualize novamente o estado dentro de instantes.';

  @override
  String get purchaseActionFailed =>
      'Não é possível concluir esse pedido neste momento. Tente novamente.';

  @override
  String get premiumOk => 'OK';

  @override
  String get leaveLessonTitle => 'Sair da lição?';

  @override
  String get leaveLessonDescription =>
      'Sair termina esta lição inacabada sem criar um resumo.';

  @override
  String get stay => 'Ficar';

  @override
  String get leaveLesson => 'Sair da lição';

  @override
  String get finishLessonTitle => 'Terminar lição?';

  @override
  String get finishLessonDescription => 'Terminar esta lição e ver o resumo?';

  @override
  String get continueLesson => 'Continuar lição';

  @override
  String get gettingHint => 'A obter sugestão...';

  @override
  String get dismissHint => 'Dispensar sugestão';

  @override
  String get finishingLesson => 'A terminar lição...';

  @override
  String get finishLessonAuthRequired =>
      'Inicie sessão novamente para terminar a lição.';

  @override
  String get finishLessonSessionUnavailable =>
      'Esta sessão de lição já não está disponível.';

  @override
  String get finishLessonFailed =>
      'Não foi possível terminar a lição. Verifique a ligação e tente novamente.';

  @override
  String get lessonFeedback => 'Feedback';

  @override
  String get loadingLessonFeedback => 'A carregar feedback...';

  @override
  String get showLessonFeedback => 'Mostrar feedback';

  @override
  String get hideLessonFeedback => 'Ocultar feedback';

  @override
  String get retryLessonFeedback => 'Tentar feedback novamente';

  @override
  String get feedbackNotReady =>
      'O feedback ainda não está pronto. Tente novamente.';

  @override
  String get feedbackQuickSummary => 'Resumo rápido';

  @override
  String get feedbackCorrectedVersion => 'Versão corrigida';

  @override
  String get feedbackGrammarTip => 'Sugestão gramatical';

  @override
  String get feedbackVocabularyTip => 'Sugestão de vocabulário';

  @override
  String get feedbackCultureTip => 'Sugestão cultural';

  @override
  String get feedbackNaturalVersion => 'Versão mais natural';

  @override
  String get lessonFeedbackAuthRequired =>
      'Inicie sessão novamente para continuar a lição.';

  @override
  String get lessonFeedbackSessionEnded => 'Esta lição já terminou.';

  @override
  String get lessonFeedbackNotAvailableForMessage =>
      'O feedback não está disponível para esta mensagem.';

  @override
  String get lessonFeedbackFailed =>
      'Não foi possível obter feedback. Tente novamente.';

  @override
  String get lessonStartBlocked =>
      'Já usou a lição gratuita de hoje. Tente novamente amanhã ou atualize para Premium.';

  @override
  String get lessonStartConflict =>
      'Já tem uma lição ativa. Termine-a ou saia antes de iniciar outra.';

  @override
  String get lessonStartAuthRequired =>
      'Inicie sessão novamente para começar uma lição.';

  @override
  String get lessonStartUnavailable =>
      'Não foi possível iniciar a lição. Verifique a ligação e tente novamente.';

  @override
  String get lessonStartFailed =>
      'Não foi possível iniciar a lição. Tente novamente.';

  @override
  String get lessonSummary => 'Resumo da lição';

  @override
  String get lessonCompleted => 'Lição concluída';

  @override
  String get summaryWhatWentWell => 'O que correu bem';

  @override
  String get summaryStrengths => 'Pontos fortes';

  @override
  String get summaryImprovements => 'Melhorias';

  @override
  String get summaryVocabulary => 'Vocabulário';

  @override
  String get summaryGrammar => 'Gramática';

  @override
  String get summaryNextSteps => 'Próximos passos';

  @override
  String get retrySummary => 'Tentar resumo novamente';

  @override
  String get summaryUnavailableMessage =>
      'A lição foi guardada, mas não foi possível criar um resumo para esta lição.';

  @override
  String get summaryAuthRequiredMessage =>
      'Inicie sessão novamente para carregar o resumo da lição.';

  @override
  String get summaryLoadErrorMessage =>
      'A lição foi guardada, mas não é possível carregar o resumo neste momento.';

  @override
  String get startRecording => 'Iniciar gravação';

  @override
  String get stopRecording => 'Parar gravação';

  @override
  String get progressCompletedLessons => 'Lições concluídas';

  @override
  String get progressAllTime => 'Desde sempre';

  @override
  String get progressLast7Days => 'Últimos 7 dias';

  @override
  String get progressLast30Days => 'Últimos 30 dias';

  @override
  String get progressCurrentStreak => 'Sequência atual';

  @override
  String get progressLongestStreak => 'Sequência mais longa';

  @override
  String get progressRecentActivity => 'Atividade recente';

  @override
  String get progressLastCompletedLesson => 'Última lição concluída';

  @override
  String get progressLessonsByLanguage => 'Lições por língua';

  @override
  String get progressLessonsByLevel => 'Lições por nível';

  @override
  String get progressEmptyTitle => 'O seu progresso aparecerá aqui';

  @override
  String get progressEmptyDescription =>
      'As lições concluídas aparecerão aqui depois de terminar uma lição.';

  @override
  String get progressUnavailable =>
      'O progresso está temporariamente indisponível. Tente novamente.';

  @override
  String get progressLoadFailed =>
      'Não foi possível carregar o progresso. Tente novamente.';

  @override
  String progressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
      zero: '0 dias',
    );
    return '$_temp0';
  }

  @override
  String get achievementsLoadFailed =>
      'Não foi possível carregar as conquistas. Tente novamente.';

  @override
  String achievementUnlockedSemantics(String title) {
    return 'Conquista desbloqueada: $title';
  }

  @override
  String achievementLockedSemantics(String title, num current, num target) {
    return 'Conquista bloqueada: $title. Progresso: $current de $target.';
  }

  @override
  String closeAchievementPreview(String title) {
    return 'Fechar pré-visualização da conquista $title';
  }

  @override
  String get closeAllAchievementPreviews =>
      'Fechar todas as pré-visualizações de conquistas';

  @override
  String get achievementTitleStreak7 => 'Sequência de 7 dias';

  @override
  String get achievementTitleStreak30 => 'Sequência de 30 dias';

  @override
  String get achievementTitleStreak60 => 'Sequência de 60 dias';

  @override
  String get achievementTitleStreak100 => 'Sequência de 100 dias';

  @override
  String get achievementTitleStreak365 => 'Sequência de 365 dias';

  @override
  String get achievementTitleLessons1 => 'Primeiro passo';

  @override
  String get achievementTitleLessons5 => 'A começar';

  @override
  String get achievementTitleLessons10 => '10 lições concluídas';

  @override
  String get achievementTitleLessons25 => 'Aprendente persistente';

  @override
  String get achievementTitleLessons50 => '50 lições concluídas';

  @override
  String get achievementTitleLessons100 => 'Clube dos 100';

  @override
  String get achievementTitleDailyLifeIntroductions => 'Primeiro olá';

  @override
  String get achievementTitleDailyLifeNeighborChat => 'Conversa com um vizinho';

  @override
  String get achievementTitleDailyLifeHelpfulHand => 'Mão amiga';

  @override
  String get achievementTitleDailyLifePlanMaker => 'Criador de planos';

  @override
  String get achievementTitleDailyLifeDayTeller => 'Contador do dia';

  @override
  String get achievementTitleDailyLifeEverydayHero => 'Herói do dia a dia';

  @override
  String get achievementTitleTravelAirportExpert =>
      'Especialista em aeroportos';

  @override
  String get achievementTitleTravelHonoredGuest => 'Hóspede de honra';

  @override
  String get achievementTitleTravelCityNavigator => 'Navegador urbano';

  @override
  String get achievementTitleTravelRideReady => 'Pronto para a viagem';

  @override
  String get achievementTitleTravelBaggageFinder => 'Caçador de bagagem';

  @override
  String get achievementTitleTravelTraveler => 'Viajante';

  @override
  String get achievementTitleWorkMeetingReady => 'Pronto para reuniões';

  @override
  String get achievementTitleWorkStandupStar => 'Estrela da reunião diária';

  @override
  String get achievementTitleWorkClientCaller =>
      'Especialista em chamadas com clientes';

  @override
  String get achievementTitleWorkClearCommunicator => 'Comunicador claro';

  @override
  String get achievementTitleWorkDeadlineDriver => 'Mestre dos prazos';

  @override
  String get achievementTitleWorkBusinessReady => 'Pronto para negócios';

  @override
  String get achievementTitleInterviewStrongIntroduction =>
      'Apresentação forte';

  @override
  String get achievementTitleInterviewCareerStory => 'História profissional';

  @override
  String get achievementTitleInterviewSelfAwareCandidate =>
      'Candidato consciente';

  @override
  String get achievementTitleInterviewRightFit => 'Escolha certa';

  @override
  String get achievementTitleInterviewCuriousCandidate => 'Candidato curioso';

  @override
  String get achievementTitleInterviewReady => 'Pronto para entrevista';

  @override
  String get achievementTitleRestaurantTableBooker => 'Reservador de mesas';

  @override
  String get achievementTitleRestaurantMenuExpert => 'Especialista em menu';

  @override
  String get achievementTitleRestaurantIngredientGuide =>
      'Guia de ingredientes';

  @override
  String get achievementTitleRestaurantOrderFixer => 'Corretor de pedidos';

  @override
  String get achievementTitleRestaurantBillSettled => 'Conta paga';

  @override
  String get achievementTitleRestaurantDiningPro =>
      'Profissional de restauração';

  @override
  String get autoSendMessage => 'Auto-send message';

  @override
  String get autoPlayTutorVoice => 'Auto-play tutor voice';

  @override
  String get voiceRecognitionUnclear =>
      'Não consegui reconhecer isso claramente. Tente novamente.';

  @override
  String get microphoneBlockedOpenSettings =>
      'O acesso ao microfone está bloqueado. Abra as definições do Android para o ativar.';

  @override
  String get microphonePermissionDeniedRetry =>
      'O acesso ao microfone não foi concedido. Toque no microfone para tentar novamente.';

  @override
  String get recordingStartFailedCheckMicrophone =>
      'Não foi possível iniciar a gravação. Verifique o microfone.';

  @override
  String get recordingStartFailed =>
      'Não foi possível iniciar a gravação. Tente novamente.';

  @override
  String get recordingTooShort => 'Grave uma resposta um pouco mais longa.';

  @override
  String get recordingStopFailed =>
      'Não foi possível parar a gravação. Tente novamente.';

  @override
  String get recordingProcessingFailed =>
      'Não foi possível processar essa gravação. Tente novamente.';

  @override
  String get recordingAuthRequired =>
      'Inicie sessão novamente para usar a gravação.';

  @override
  String get transcriptionTemporarilyUnavailable =>
      'A transcrição está temporariamente indisponível. Tente novamente dentro de instantes.';

  @override
  String get transcriptionTimedOut =>
      'A transcrição demorou demasiado tempo. Tente novamente.';

  @override
  String get transcriptionConnectionFailed =>
      'A ligação falhou durante a transcrição. Tente novamente.';

  @override
  String get transcriptionFailed =>
      'Não foi possível transcrever essa gravação. Tente novamente.';

  @override
  String get voiceTemporarilyUnavailable =>
      'A voz está temporariamente indisponível. Tente novamente dentro de instantes.';

  @override
  String get voicePlaybackFailed =>
      'Não foi possível reproduzir a voz. Tente novamente.';

  @override
  String get voicePlaybackTimedOut =>
      'A reprodução de voz demorou demasiado tempo. Tente novamente.';

  @override
  String get voicePlaybackStopped =>
      'A reprodução de voz parou. Pode gravar novamente.';

  @override
  String get replaceTypedTextTitle => 'Substituir texto escrito?';

  @override
  String get replaceTypedTextDescription =>
      'Utilizar a gravação transcrita em vez do rascunho escrito?';

  @override
  String get keepTypedText => 'Manter texto escrito';

  @override
  String get replaceTypedText => 'Substituir texto escrito';

  @override
  String get transcribingRecording => 'A transcrever gravação...';

  @override
  String get retryLessonContent => 'Tentar conteúdo da lição novamente';

  @override
  String get translation => 'Tradução';

  @override
  String get playVoice => 'Reproduzir voz';

  @override
  String get openConversationMode => 'Abrir modo de conversa';

  @override
  String get conversationPaused => 'Conversa em pausa. Pode gravar novamente.';

  @override
  String get tutorReplyTimedOut =>
      'O tutor demorou demasiado tempo a responder. Tente novamente.';

  @override
  String get conversationSendFailed =>
      'Não foi possível enviar essa resposta. Tente gravar novamente.';

  @override
  String get openAndroidSettingsFailed =>
      'Não foi possível abrir as definições do Android. Tente novamente.';

  @override
  String get conversationReady => 'A sua conversa está pronta.';

  @override
  String get tutorAvatarSemantics => 'Avatar do tutor';

  @override
  String get lessonContentLoadFailed =>
      'Não foi possível carregar o conteúdo da lição. Tente novamente.';

  @override
  String get lessonHistoryDetails => 'Detalhes da lição';

  @override
  String get historySummary => 'Resumo';

  @override
  String get noHistoryConversation =>
      'Não há conversa disponível para esta lição.';

  @override
  String get noHistorySummary => 'Não há resumo da lição disponível.';

  @override
  String get overallSummary => 'Resumo geral';

  @override
  String get historyTutor => 'Professor';

  @override
  String get historyYou => 'Você';

  @override
  String get feedbackCorrectedText => 'Texto corrigido';

  @override
  String get feedbackExplanation => 'Explicação';

  @override
  String get feedbackPraise => 'Elogio';

  @override
  String get lessonUnavailable => 'Essa lição não está disponível.';

  @override
  String get lessonNoLongerAvailable => 'Esta lição já não está disponível.';

  @override
  String get lessonHistoryUnavailable =>
      'O histórico de lições está temporariamente indisponível. Tente novamente.';

  @override
  String get lessonDetailLoadFailed =>
      'Não foi possível carregar os detalhes da lição. Tente novamente.';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appTitle => 'Language Voice Tutor';

  @override
  String get settings => 'Definições';

  @override
  String get profile => 'Perfil';

  @override
  String get app => 'Aplicação';

  @override
  String get saveSettings => 'Guardar definições';

  @override
  String get saving => 'A guardar...';

  @override
  String get settingsSaved => 'Definições guardadas.';

  @override
  String get unableToSaveSettings =>
      'Não é possível guardar as definições neste momento.';

  @override
  String get learning => 'Aprendizagem';

  @override
  String get studyLanguage => 'Língua de estudo';

  @override
  String get nativeLanguage => 'Língua materna';

  @override
  String get interfaceLanguage => 'Língua da interface';

  @override
  String get interfaceExplanationLanguage =>
      'Língua da interface / das explicações';

  @override
  String get interfaceLanguageDescription =>
      'Altera apenas a língua da interface da aplicação.';

  @override
  String get currentLevel => 'Nível atual';

  @override
  String get selectedTutor => 'Tutor selecionado';

  @override
  String get loadingSettings => 'A carregar definições...';

  @override
  String get unableToLoadSettings =>
      'Não é possível carregar as definições neste momento.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get back => 'Voltar';

  @override
  String get login => 'Iniciar sessão';

  @override
  String get register => 'Registar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Palavra-passe';

  @override
  String get displayNameOptional => 'Nome de apresentação (opcional)';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get unableToCheckSession =>
      'Não é possível verificar a sessão. Tente novamente.';

  @override
  String get lessons => 'Lições';

  @override
  String get lessonHistory => 'Histórico de lições';

  @override
  String get progress => 'Progresso';

  @override
  String get rewards => 'Recompensas';

  @override
  String get viewAll => 'Ver tudo';

  @override
  String get achievements => 'Conquistas';

  @override
  String get account => 'Conta';

  @override
  String get logout => 'Terminar sessão';

  @override
  String get audio => 'Áudio';

  @override
  String get feedbackAndReports => 'Feedback e relatórios';

  @override
  String get cancel => 'Cancelar';

  @override
  String get submit => 'Submeter';

  @override
  String get send => 'Enviar';

  @override
  String get done => 'Concluído';

  @override
  String get openAndroidSettings => 'Abrir definições do Android';

  @override
  String get hint => 'Sugestão';

  @override
  String get finishLesson => 'Terminar lição';

  @override
  String get typeYourMessage => 'Escreva a sua mensagem';

  @override
  String get sending => 'A enviar...';

  @override
  String get languageNameEnglish => 'Inglês';

  @override
  String get languageNameRussian => 'Russo';

  @override
  String get languageNameSpanish => 'Espanhol';

  @override
  String get languageNameFrench => 'Francês';

  @override
  String get languageNameGerman => 'Alemão';

  @override
  String get signInToApp => 'Inicie sessão no Language Voice Tutor';

  @override
  String get pleaseWait => 'Aguarde...';

  @override
  String get alreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get invalidEmail => 'Introduza um endereço de e-mail válido.';

  @override
  String get enterPassword => 'Introduza a sua palavra-passe.';

  @override
  String get chooseTopic => 'Escolher tópico';

  @override
  String get chooseTopicTitle => 'Escolha um tópico';

  @override
  String get chooseTopicSubtitle =>
      'Escolha o tipo de conversa que pretende praticar.';

  @override
  String get chooseSituation => 'Escolher situação';

  @override
  String get chooseSituationTitle => 'Escolha uma situação';

  @override
  String get chooseSituationSubtitle =>
      'Pratique um momento específico deste tópico.';

  @override
  String get viewAllRewards =>
      'Veja todos os emblemas e recompensas de aprendizagem.';

  @override
  String get accountDeletion => 'Eliminação de conta';

  @override
  String get requestAccountDeletion => 'Solicitar eliminação da conta';

  @override
  String get loadingAccount => 'A carregar conta...';

  @override
  String get premiumAndSubscription => 'Premium e subscrição';

  @override
  String get currentPassword => 'Palavra-passe atual';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get submitting => 'A submeter...';

  @override
  String get loadingTutors => 'A carregar tutores...';

  @override
  String get noTutorsAvailable => 'Não há tutores disponíveis neste momento.';

  @override
  String get loadingAudioSettings => 'A carregar definições de áudio...';

  @override
  String get conversationModeEnabled => 'Modo de conversa ativado';

  @override
  String get sendSuggestionOrReport =>
      'Enviar uma sugestão ou comunicar um problema';

  @override
  String get reportType => 'Tipo de comunicação';

  @override
  String get pasteAiResponseOptional => 'Cole a resposta da IA (opcional)';

  @override
  String get lessonHistoryHeading => 'As suas lições concluídas recentemente';

  @override
  String get noCompletedLessons => 'Ainda não há lições concluídas';

  @override
  String get completedLessonsAppearHere =>
      'As lições concluídas aparecerão aqui.';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get lesson => 'Lição';

  @override
  String get level => 'Nível';

  @override
  String get completed => 'Concluída';

  @override
  String get finished => 'Terminada';

  @override
  String get lessonChat => 'Conversa da lição';

  @override
  String get conversation => 'Conversa';

  @override
  String turnCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interações',
      one: '1 interação',
    );
    return '$_temp0';
  }

  @override
  String get achievementsUnavailable => 'Ainda não há conquistas disponíveis.';

  @override
  String unlockedCount(num unlocked, num total) {
    return '$unlocked de $total desbloqueadas';
  }

  @override
  String learningLanguage(String language) {
    return 'A aprender $language';
  }

  @override
  String get streaks => 'Sequências';

  @override
  String get lessonMilestones => 'Marcos das lições';

  @override
  String get topics => 'Tópicos';

  @override
  String get situations => 'Situações';

  @override
  String get otherAchievements => 'Outras conquistas';

  @override
  String progressCount(num current, num total) {
    return '$current de $total';
  }

  @override
  String get startLesson => 'Iniciar lição';

  @override
  String get openSettings => 'Abrir definições';

  @override
  String get keepLearningRhythm => 'Mantenha o ritmo de aprendizagem';

  @override
  String get reminderPermissionExplanation =>
      'Language Voice Tutor pode enviar-lhe dois lembretes diários animadores para que a prática não se perca num dia atarefado. Pode alterar as horas ou desativar os lembretes nas Definições.';

  @override
  String get notNow => 'Agora não';

  @override
  String get allowReminders => 'Permitir lembretes';

  @override
  String get achievementsTemporarilyUnavailable =>
      'Conquistas temporariamente indisponíveis';

  @override
  String get achievementsEmpty => 'As suas conquistas aparecerão aqui.';

  @override
  String learningStreak(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count dias',
      one: 'Sequência de 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get learningStreakLoading => 'A carregar sequência de aprendizagem';

  @override
  String get learningStreakUnavailable =>
      'Sequência de aprendizagem indisponível';

  @override
  String get learnerFallbackName => 'Aprendente';

  @override
  String get premiumPlan => 'Plano Premium';

  @override
  String get premiumTrial => 'Período experimental Premium';

  @override
  String get freePlan => 'Plano gratuito';

  @override
  String signedInAs(String name) {
    return 'Sessão iniciada como $name';
  }

  @override
  String get premiumDetails => 'Detalhes Premium';

  @override
  String get explorePremium => 'Conheça o Premium';

  @override
  String freeLessonsAvailableToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições gratuitas disponíveis hoje',
      one: '1 lição gratuita disponível hoje',
    );
    return '$_temp0';
  }

  @override
  String get yourWeek => 'A sua semana';

  @override
  String lessonsLastSevenDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições nos últimos 7 dias',
      one: '1 lição nos últimos 7 dias',
    );
    return '$_temp0';
  }

  @override
  String get startStreakToday => 'Comece a sua sequência hoje';

  @override
  String get activityUnavailable =>
      'A atividade não está disponível neste momento.';

  @override
  String lessonsCompleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições concluídas',
      one: '1 lição concluída',
    );
    return '$_temp0';
  }

  @override
  String activityDaySemantics(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lições concluídas',
      one: '1 lição concluída',
    );
    return '$date: $_temp0';
  }

  @override
  String get weekdayMon => 'Seg';

  @override
  String get weekdayTue => 'Ter';

  @override
  String get weekdayWed => 'Qua';

  @override
  String get weekdayThu => 'Qui';

  @override
  String get weekdayFri => 'Sex';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get remindersTemporarilyUnavailable =>
      'Os lembretes de prática estão temporariamente indisponíveis.';

  @override
  String get unableToUpdateReminders =>
      'Não é possível atualizar os lembretes neste momento. Tente novamente.';

  @override
  String get unableToLoadAccount =>
      'Não é possível carregar os detalhes da conta neste momento.';

  @override
  String get tutorChoicesUnavailable =>
      'As opções de tutor não estão disponíveis neste momento. Ainda pode rever e guardar as outras definições.';

  @override
  String get pleaseEnterDescription => 'Introduza uma descrição.';

  @override
  String get emailRequired => 'O e-mail é obrigatório.';

  @override
  String get resetCodePasswordRequired =>
      'O código de reposição e a nova palavra-passe são obrigatórios.';

  @override
  String get passwordsMustMatch =>
      'A nova palavra-passe e a confirmação têm de coincidir.';

  @override
  String get signInToChangePassword =>
      'Inicie sessão para alterar a sua palavra-passe.';

  @override
  String get currentPasswordRequired => 'A palavra-passe atual é obrigatória.';

  @override
  String get accountDeletionDescription =>
      'Envie um pedido para eliminar permanentemente a sua conta Language Voice Tutor e os seus dados pessoais.';

  @override
  String get accountDeletionNotice =>
      'Enviar este pedido não elimina a sua conta de imediato. O apoio irá analisá-lo e processá-lo, podendo pedir mais informações. A resposta será enviada para o endereço de e-mail associado à sua conta. A sua conta não é considerada eliminada apenas por ter enviado este pedido.';

  @override
  String get noDisplayName => 'Sem nome de apresentação';

  @override
  String get subscriptionUnavailable => 'Subscrição indisponível';

  @override
  String get noPaidPlan => 'Sem plano pago';

  @override
  String requestId(String id) {
    return 'ID do pedido: $id';
  }

  @override
  String statusValue(String status) {
    return 'Estado: $status';
  }

  @override
  String get passwordRecovery => 'Palavra-passe e recuperação';

  @override
  String get accountEmail => 'E-mail da conta';

  @override
  String get sendingResetInstructions => 'A enviar instruções de reposição...';

  @override
  String get forgotPassword => 'Esqueci-me da palavra-passe';

  @override
  String get resetCode => 'Código de reposição';

  @override
  String get newPassword => 'Nova palavra-passe';

  @override
  String get confirmNewPassword => 'Confirmar nova palavra-passe';

  @override
  String get updatingPassword => 'A atualizar a palavra-passe...';

  @override
  String get resetPassword => 'Repor palavra-passe';

  @override
  String get newAccountPassword => 'Nova palavra-passe da conta';

  @override
  String get confirmNewAccountPassword =>
      'Confirmar nova palavra-passe da conta';

  @override
  String get changingPassword => 'A alterar a palavra-passe...';

  @override
  String get changePassword => 'Alterar palavra-passe';

  @override
  String get tutorVoice => 'Voz do tutor';

  @override
  String speechSpeed(String speed) {
    return 'Velocidade da fala: ${speed}x';
  }

  @override
  String get feedbackSuggestion => 'Sugestão';

  @override
  String get feedbackAppProblem => 'Problema na aplicação';

  @override
  String get feedbackAiResponse => 'Resposta da IA';

  @override
  String get yourSuggestion => 'A sua sugestão';

  @override
  String get describeProblem => 'Descreva o problema';

  @override
  String get aiResponseProblem => 'O que estava errado na resposta da IA?';

  @override
  String get practiceReminders => 'Lembretes de prática';

  @override
  String get localRemindersDescription =>
      'Estes lembretes são locais neste dispositivo.';

  @override
  String get dailyPracticeReminders => 'Lembretes diários de prática';

  @override
  String get morningReminder => 'Lembrete matinal';

  @override
  String get eveningReminder => 'Lembrete noturno';

  @override
  String get notificationsAllowed => 'Notificações permitidas';

  @override
  String get notificationStatusUnavailable =>
      'Estado das notificações indisponível';

  @override
  String get notificationsBlocked =>
      'As notificações estão bloqueadas pelo Android.';

  @override
  String get allowNotifications => 'Permitir notificações';

  @override
  String get feedbackReceived => 'Obrigado. A sua mensagem foi recebida.';

  @override
  String get feedbackValidationFailure =>
      'Verifique a sua mensagem e tente novamente.';

  @override
  String get feedbackUnavailable =>
      'O feedback está temporariamente indisponível. Tente novamente.';

  @override
  String get deletionRequestAlreadyExists =>
      'Já existe um pedido ativo de eliminação da conta.';

  @override
  String get deletionRequestSubmitted =>
      'O seu pedido de eliminação da conta foi enviado para processamento pelo apoio.';

  @override
  String get incorrectCurrentPassword =>
      'A sua palavra-passe atual está incorreta.';

  @override
  String get unableToReachService =>
      'Não é possível contactar o serviço. Tente novamente.';

  @override
  String get unexpectedServiceResponse =>
      'O serviço devolveu uma resposta inesperada. Tente novamente.';

  @override
  String get unableToSubmitRequest =>
      'Não é possível submeter o seu pedido neste momento. Tente novamente.';

  @override
  String get unableToLoadLearningSettings =>
      'Não é possível carregar as suas definições de aprendizagem neste momento. Tente novamente.';

  @override
  String get settingsTemporarilyUnavailable =>
      'As definições estão temporariamente indisponíveis. Tente novamente.';

  @override
  String selectedLevelContext(String level) {
    return 'Nível: $level';
  }

  @override
  String selectedLevelTopicContext(String level, String topic) {
    return 'Nível: $level / Tópico: $topic';
  }

  @override
  String topicCardSemantics(String label, String description) {
    return '$label. $description';
  }

  @override
  String situationCardSemantics(String label, String description) {
    return '$label. $description';
  }

  @override
  String openTopicTooltip(String topic) {
    return 'Abrir $topic';
  }

  @override
  String openSituationTooltip(String situation) {
    return 'Abrir $situation';
  }

  @override
  String get noSituationsAvailable =>
      'Não há situações disponíveis para este tópico.';

  @override
  String get levelA1Label => 'A1 Iniciante';

  @override
  String get levelA1Description =>
      'Desenvolva cumprimentos simples, expresse necessidades e dê respostas curtas do dia a dia.';

  @override
  String get levelA2Label => 'A2 Elementar';

  @override
  String get levelA2Description =>
      'Lide com conversas de rotina usando palavras e frases familiares.';

  @override
  String get levelB1Label => 'B1 Intermédio';

  @override
  String get levelB1Description =>
      'Pratique interações mais longas, opiniões e resolução de problemas do dia a dia.';

  @override
  String get levelB2Label => 'B2 Intermédio avançado';

  @override
  String get levelB2Description =>
      'Aperfeiçoe conversas com nuances e detalhes mais naturais.';

  @override
  String get topicDailyLifeLabel => 'Vida diária';

  @override
  String get topicDailyLifeDescription =>
      'Conversas informais, apresentações e situações do dia a dia.';

  @override
  String get topicTravelLabel => 'Viagens';

  @override
  String get topicTravelDescription =>
      'Aeroportos, hotéis, direções e transportes.';

  @override
  String get topicWorkBusinessLabel => 'Trabalho e negócios';

  @override
  String get topicWorkBusinessDescription =>
      'Reuniões, e-mails, chamadas e conversas no trabalho.';

  @override
  String get topicJobInterviewLabel => 'Entrevista de emprego';

  @override
  String get topicJobInterviewDescription =>
      'Pratique perguntas e respostas comuns de entrevistas.';

  @override
  String get topicRestaurantCafeLabel => 'Restaurante e café';

  @override
  String get topicRestaurantCafeDescription =>
      'Pedir comida, reservar mesas e fazer pedidos educados.';

  @override
  String get topicFreeConversationLabel => 'Conversa livre';

  @override
  String get topicFreeConversationDescription =>
      'Prática aberta moldada pelo que pretende dizer.';

  @override
  String get situationIntroductionsLabel => 'Apresentações';

  @override
  String get situationIntroductionsDescription =>
      'Apresente-se e faça perguntas pessoais básicas.';

  @override
  String get situationSmallTalkNeighborLabel => 'Falar com um vizinho';

  @override
  String get situationSmallTalkNeighborDescription =>
      'Tenha uma conversa curta e amigável perto de casa.';

  @override
  String get situationAskingForHelpLabel => 'Pedir ajuda';

  @override
  String get situationAskingForHelpDescription =>
      'Peça ajuda numa situação simples do dia a dia.';

  @override
  String get situationMakingPlansLabel => 'Fazer planos';

  @override
  String get situationMakingPlansDescription =>
      'Planeie uma atividade e combine a hora e o local.';

  @override
  String get situationTalkingAboutDayLabel => 'Falar sobre o seu dia';

  @override
  String get situationTalkingAboutDayDescription =>
      'Descreva o seu dia e a rotina diária.';

  @override
  String get situationAirportCheckInLabel => 'Check-in no aeroporto';

  @override
  String get situationAirportCheckInDescription =>
      'Faça o check-in para um voo e confirme os detalhes da viagem.';

  @override
  String get situationHotelCheckInLabel => 'Check-in no hotel';

  @override
  String get situationHotelCheckInDescription =>
      'Faça o check-in num hotel e coloque perguntas comuns.';

  @override
  String get situationAskingForDirectionsLabel => 'Pedir direções';

  @override
  String get situationAskingForDirectionsDescription =>
      'Peça e compreenda direções numa cidade nova.';

  @override
  String get situationOrderingTransportLabel => 'Pedir transporte';

  @override
  String get situationOrderingTransportDescription =>
      'Organize um táxi ou transporte partilhado até ao destino.';

  @override
  String get situationLostLuggageLabel => 'Bagagem perdida';

  @override
  String get situationLostLuggageDescription =>
      'Comunique bagagem perdida e explique a sua situação.';

  @override
  String get situationFirstMeetingLabel => 'Primeira reunião';

  @override
  String get situationFirstMeetingDescription =>
      'Apresente-se numa nova reunião de trabalho.';

  @override
  String get situationDailyStandupLabel => 'Reunião diária';

  @override
  String get situationDailyStandupDescription =>
      'Dê uma breve atualização sobre as suas tarefas.';

  @override
  String get situationClientPhoneCallLabel => 'Chamada com um cliente';

  @override
  String get situationClientPhoneCallDescription =>
      'Conduza uma chamada profissional clara e educada.';

  @override
  String get situationAskingForClarificationLabel => 'Pedir esclarecimentos';

  @override
  String get situationAskingForClarificationDescription =>
      'Faça perguntas complementares para confirmar os requisitos.';

  @override
  String get situationDiscussingDeadlinesLabel => 'Discutir prazos';

  @override
  String get situationDiscussingDeadlinesDescription =>
      'Fale sobre prazos e expectativas de entrega.';

  @override
  String get situationTellMeAboutYourselfLabel => 'Fale-me de si';

  @override
  String get situationTellMeAboutYourselfDescription =>
      'Faça uma breve apresentação pessoal adequada a uma entrevista.';

  @override
  String get situationWorkExperienceLabel => 'Experiência profissional';

  @override
  String get situationWorkExperienceDescription =>
      'Descreva trabalho anterior, responsabilidades e um resultado.';

  @override
  String get situationStrengthsWeaknessesLabel => 'Pontos fortes e fracos';

  @override
  String get situationStrengthsWeaknessesDescription =>
      'Fale profissionalmente sobre um ponto forte e uma área a melhorar.';

  @override
  String get situationWhyThisJobLabel => 'Porque quer este emprego?';

  @override
  String get situationWhyThisJobDescription =>
      'Explique a sua motivação e relacione a função com as suas competências.';

  @override
  String get situationQuestionsAtEndLabel => 'Fazer perguntas no final';

  @override
  String get situationQuestionsAtEndDescription =>
      'Faça perguntas educadas e úteis antes de a entrevista terminar.';

  @override
  String get situationBookingTableLabel => 'Reservar uma mesa';

  @override
  String get situationBookingTableDescription =>
      'Ligue ou fale com alguém para reservar uma mesa.';

  @override
  String get situationOrderingFoodLabel => 'Pedir comida';

  @override
  String get situationOrderingFoodDescription =>
      'Peça uma refeição e faça perguntas simples sobre o menu.';

  @override
  String get situationAskingIngredientsLabel => 'Perguntar sobre ingredientes';

  @override
  String get situationAskingIngredientsDescription =>
      'Pergunte sobre alergias e ingredientes dos pratos.';

  @override
  String get situationWrongOrderLabel => 'Lidar com um pedido errado';

  @override
  String get situationWrongOrderDescription =>
      'Explique educadamente um problema com o seu pedido.';

  @override
  String get situationPayingBillLabel => 'Pagar a conta';

  @override
  String get situationPayingBillDescription =>
      'Peça a conta e conclua o pagamento.';

  @override
  String get situationOpenConversationLabel => 'Conversa aberta';

  @override
  String get situationOpenConversationDescription =>
      'Pratique qualquer tema com seguimento flexível.';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatusLoadingSemantics => 'A carregar estado Premium';

  @override
  String get premiumStatusTemporarilyUnavailable =>
      'O estado Premium está temporariamente indisponível. Tente novamente.';

  @override
  String premiumStatusSemantics(String status) {
    return 'Estado Premium: $status';
  }

  @override
  String get premiumActive => 'Premium ativo';

  @override
  String get premiumActiveDescription =>
      'Pratique sem o limite diário de lições gratuitas.';

  @override
  String premiumEndsOn(String date) {
    return 'O Premium termina a $date.';
  }

  @override
  String get premiumTrialActiveDescription =>
      'O seu período experimental Premium está ativo.';

  @override
  String premiumTrialEndsOn(String date) {
    return 'O período experimental termina a $date.';
  }

  @override
  String freeLessonsRemainingToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restam $count lições gratuitas hoje.',
      one: 'Resta 1 lição gratuita hoje.',
      zero: 'Não restam lições gratuitas hoje.',
    );
    return '$_temp0';
  }

  @override
  String get premiumRemovesDailyLimit =>
      'O Premium elimina o limite diário de lições.';

  @override
  String get premiumAccountLinked =>
      'O acesso Premium está associado à sua conta Language Voice Tutor.';

  @override
  String get premiumSharedAcrossClients =>
      'O seu estado Premium confirmado é partilhado entre clientes Language Voice Tutor compatíveis.';

  @override
  String get premiumBenefits => 'Vantagens Premium';

  @override
  String get premiumBenefitDailyLimit =>
      '• Pratique sem o limite diário de lições gratuitas';

  @override
  String get premiumBenefitAcrossDevices =>
      '• Use o mesmo acesso Premium em dispositivos compatíveis';

  @override
  String get premiumBenefitAccountData =>
      '• Mantenha a conta, o progresso, o histórico e as definições de aprendizagem juntos';

  @override
  String get getPremium => 'Obter Premium';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get refreshPremiumStatus => 'Atualizar estado';

  @override
  String get billingProviderExplanation =>
      'As alterações de faturação devem ser tratadas pelo fornecedor onde o Premium foi adquirido.';

  @override
  String get googlePlayPurchasesUnavailableTitle =>
      'As compras Google Play ainda não estão disponíveis';

  @override
  String get restorePurchasesUnavailableTitle =>
      'Restaurar compras ainda não está disponível';

  @override
  String get googlePlayPurchasesUnavailableDescription =>
      'As compras serão associadas no passo seguinte. Esta versão não pode cobrar-lhe nem ativar o Premium.';

  @override
  String get restorePurchasesUnavailableDescription =>
      'O restauro Google Play será associado ao fluxo de faturação. O estado atual da sua conta continua a ser carregado do Language Voice Tutor.';

  @override
  String get purchasePendingConfirmation =>
      'O processamento da compra ainda não está confirmado. Atualize novamente o estado dentro de instantes.';

  @override
  String get purchaseActionFailed =>
      'Não é possível concluir esse pedido neste momento. Tente novamente.';

  @override
  String get premiumOk => 'OK';

  @override
  String get leaveLessonTitle => 'Sair da lição?';

  @override
  String get leaveLessonDescription =>
      'Sair termina esta lição inacabada sem criar um resumo.';

  @override
  String get stay => 'Ficar';

  @override
  String get leaveLesson => 'Sair da lição';

  @override
  String get finishLessonTitle => 'Terminar lição?';

  @override
  String get finishLessonDescription => 'Terminar esta lição e ver o resumo?';

  @override
  String get continueLesson => 'Continuar lição';

  @override
  String get gettingHint => 'A obter sugestão...';

  @override
  String get dismissHint => 'Dispensar sugestão';

  @override
  String get finishingLesson => 'A terminar lição...';

  @override
  String get finishLessonAuthRequired =>
      'Inicie sessão novamente para terminar a lição.';

  @override
  String get finishLessonSessionUnavailable =>
      'Esta sessão de lição já não está disponível.';

  @override
  String get finishLessonFailed =>
      'Não foi possível terminar a lição. Verifique a ligação e tente novamente.';

  @override
  String get lessonFeedback => 'Feedback';

  @override
  String get loadingLessonFeedback => 'A carregar feedback...';

  @override
  String get showLessonFeedback => 'Mostrar feedback';

  @override
  String get hideLessonFeedback => 'Ocultar feedback';

  @override
  String get retryLessonFeedback => 'Tentar feedback novamente';

  @override
  String get feedbackNotReady =>
      'O feedback ainda não está pronto. Tente novamente.';

  @override
  String get feedbackQuickSummary => 'Resumo rápido';

  @override
  String get feedbackCorrectedVersion => 'Versão corrigida';

  @override
  String get feedbackGrammarTip => 'Sugestão gramatical';

  @override
  String get feedbackVocabularyTip => 'Sugestão de vocabulário';

  @override
  String get feedbackCultureTip => 'Sugestão cultural';

  @override
  String get feedbackNaturalVersion => 'Versão mais natural';

  @override
  String get lessonFeedbackAuthRequired =>
      'Inicie sessão novamente para continuar a lição.';

  @override
  String get lessonFeedbackSessionEnded => 'Esta lição já terminou.';

  @override
  String get lessonFeedbackNotAvailableForMessage =>
      'O feedback não está disponível para esta mensagem.';

  @override
  String get lessonFeedbackFailed =>
      'Não foi possível obter feedback. Tente novamente.';

  @override
  String get lessonStartBlocked =>
      'Já usou a lição gratuita de hoje. Tente novamente amanhã ou atualize para Premium.';

  @override
  String get lessonStartConflict =>
      'Já tem uma lição ativa. Termine-a ou saia antes de iniciar outra.';

  @override
  String get lessonStartAuthRequired =>
      'Inicie sessão novamente para começar uma lição.';

  @override
  String get lessonStartUnavailable =>
      'Não foi possível iniciar a lição. Verifique a ligação e tente novamente.';

  @override
  String get lessonStartFailed =>
      'Não foi possível iniciar a lição. Tente novamente.';

  @override
  String get lessonSummary => 'Resumo da lição';

  @override
  String get lessonCompleted => 'Lição concluída';

  @override
  String get summaryWhatWentWell => 'O que correu bem';

  @override
  String get summaryStrengths => 'Pontos fortes';

  @override
  String get summaryImprovements => 'Melhorias';

  @override
  String get summaryVocabulary => 'Vocabulário';

  @override
  String get summaryGrammar => 'Gramática';

  @override
  String get summaryNextSteps => 'Próximos passos';

  @override
  String get retrySummary => 'Tentar resumo novamente';

  @override
  String get summaryUnavailableMessage =>
      'A lição foi guardada, mas não foi possível criar um resumo para esta lição.';

  @override
  String get summaryAuthRequiredMessage =>
      'Inicie sessão novamente para carregar o resumo da lição.';

  @override
  String get summaryLoadErrorMessage =>
      'A lição foi guardada, mas não é possível carregar o resumo neste momento.';

  @override
  String get startRecording => 'Iniciar gravação';

  @override
  String get stopRecording => 'Parar gravação';

  @override
  String get progressCompletedLessons => 'Lições concluídas';

  @override
  String get progressAllTime => 'Desde sempre';

  @override
  String get progressLast7Days => 'Últimos 7 dias';

  @override
  String get progressLast30Days => 'Últimos 30 dias';

  @override
  String get progressCurrentStreak => 'Sequência atual';

  @override
  String get progressLongestStreak => 'Sequência mais longa';

  @override
  String get progressRecentActivity => 'Atividade recente';

  @override
  String get progressLastCompletedLesson => 'Última lição concluída';

  @override
  String get progressLessonsByLanguage => 'Lições por língua';

  @override
  String get progressLessonsByLevel => 'Lições por nível';

  @override
  String get progressEmptyTitle => 'O seu progresso aparecerá aqui';

  @override
  String get progressEmptyDescription =>
      'As lições concluídas aparecerão aqui depois de terminar uma lição.';

  @override
  String get progressUnavailable =>
      'O progresso está temporariamente indisponível. Tente novamente.';

  @override
  String get progressLoadFailed =>
      'Não foi possível carregar o progresso. Tente novamente.';

  @override
  String progressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
      zero: '0 dias',
    );
    return '$_temp0';
  }

  @override
  String get achievementsLoadFailed =>
      'Não foi possível carregar as conquistas. Tente novamente.';

  @override
  String achievementUnlockedSemantics(String title) {
    return 'Conquista desbloqueada: $title';
  }

  @override
  String achievementLockedSemantics(String title, num current, num target) {
    return 'Conquista bloqueada: $title. Progresso: $current de $target.';
  }

  @override
  String closeAchievementPreview(String title) {
    return 'Fechar pré-visualização da conquista $title';
  }

  @override
  String get closeAllAchievementPreviews =>
      'Fechar todas as pré-visualizações de conquistas';

  @override
  String get achievementTitleStreak7 => 'Sequência de 7 dias';

  @override
  String get achievementTitleStreak30 => 'Sequência de 30 dias';

  @override
  String get achievementTitleStreak60 => 'Sequência de 60 dias';

  @override
  String get achievementTitleStreak100 => 'Sequência de 100 dias';

  @override
  String get achievementTitleStreak365 => 'Sequência de 365 dias';

  @override
  String get achievementTitleLessons1 => 'Primeiro passo';

  @override
  String get achievementTitleLessons5 => 'A começar';

  @override
  String get achievementTitleLessons10 => '10 lições concluídas';

  @override
  String get achievementTitleLessons25 => 'Aprendente persistente';

  @override
  String get achievementTitleLessons50 => '50 lições concluídas';

  @override
  String get achievementTitleLessons100 => 'Clube dos 100';

  @override
  String get achievementTitleDailyLifeIntroductions => 'Primeiro olá';

  @override
  String get achievementTitleDailyLifeNeighborChat => 'Conversa com um vizinho';

  @override
  String get achievementTitleDailyLifeHelpfulHand => 'Mão amiga';

  @override
  String get achievementTitleDailyLifePlanMaker => 'Criador de planos';

  @override
  String get achievementTitleDailyLifeDayTeller => 'Contador do dia';

  @override
  String get achievementTitleDailyLifeEverydayHero => 'Herói do dia a dia';

  @override
  String get achievementTitleTravelAirportExpert =>
      'Especialista em aeroportos';

  @override
  String get achievementTitleTravelHonoredGuest => 'Hóspede de honra';

  @override
  String get achievementTitleTravelCityNavigator => 'Navegador urbano';

  @override
  String get achievementTitleTravelRideReady => 'Pronto para a viagem';

  @override
  String get achievementTitleTravelBaggageFinder => 'Caçador de bagagem';

  @override
  String get achievementTitleTravelTraveler => 'Viajante';

  @override
  String get achievementTitleWorkMeetingReady => 'Pronto para reuniões';

  @override
  String get achievementTitleWorkStandupStar => 'Estrela da reunião diária';

  @override
  String get achievementTitleWorkClientCaller =>
      'Especialista em chamadas com clientes';

  @override
  String get achievementTitleWorkClearCommunicator => 'Comunicador claro';

  @override
  String get achievementTitleWorkDeadlineDriver => 'Mestre dos prazos';

  @override
  String get achievementTitleWorkBusinessReady => 'Pronto para negócios';

  @override
  String get achievementTitleInterviewStrongIntroduction =>
      'Apresentação forte';

  @override
  String get achievementTitleInterviewCareerStory => 'História profissional';

  @override
  String get achievementTitleInterviewSelfAwareCandidate =>
      'Candidato consciente';

  @override
  String get achievementTitleInterviewRightFit => 'Escolha certa';

  @override
  String get achievementTitleInterviewCuriousCandidate => 'Candidato curioso';

  @override
  String get achievementTitleInterviewReady => 'Pronto para entrevista';

  @override
  String get achievementTitleRestaurantTableBooker => 'Reservador de mesas';

  @override
  String get achievementTitleRestaurantMenuExpert => 'Especialista em menu';

  @override
  String get achievementTitleRestaurantIngredientGuide =>
      'Guia de ingredientes';

  @override
  String get achievementTitleRestaurantOrderFixer => 'Corretor de pedidos';

  @override
  String get achievementTitleRestaurantBillSettled => 'Conta paga';

  @override
  String get achievementTitleRestaurantDiningPro =>
      'Profissional de restauração';

  @override
  String get autoSendMessage => 'Auto-send message';

  @override
  String get autoPlayTutorVoice => 'Auto-play tutor voice';

  @override
  String get voiceRecognitionUnclear =>
      'Não consegui reconhecer isso claramente. Tente novamente.';

  @override
  String get microphoneBlockedOpenSettings =>
      'O acesso ao microfone está bloqueado. Abra as definições do Android para o ativar.';

  @override
  String get microphonePermissionDeniedRetry =>
      'O acesso ao microfone não foi concedido. Toque no microfone para tentar novamente.';

  @override
  String get recordingStartFailedCheckMicrophone =>
      'Não foi possível iniciar a gravação. Verifique o microfone.';

  @override
  String get recordingStartFailed =>
      'Não foi possível iniciar a gravação. Tente novamente.';

  @override
  String get recordingTooShort => 'Grave uma resposta um pouco mais longa.';

  @override
  String get recordingStopFailed =>
      'Não foi possível parar a gravação. Tente novamente.';

  @override
  String get recordingProcessingFailed =>
      'Não foi possível processar essa gravação. Tente novamente.';

  @override
  String get recordingAuthRequired =>
      'Inicie sessão novamente para usar a gravação.';

  @override
  String get transcriptionTemporarilyUnavailable =>
      'A transcrição está temporariamente indisponível. Tente novamente dentro de instantes.';

  @override
  String get transcriptionTimedOut =>
      'A transcrição demorou demasiado tempo. Tente novamente.';

  @override
  String get transcriptionConnectionFailed =>
      'A ligação falhou durante a transcrição. Tente novamente.';

  @override
  String get transcriptionFailed =>
      'Não foi possível transcrever essa gravação. Tente novamente.';

  @override
  String get voiceTemporarilyUnavailable =>
      'A voz está temporariamente indisponível. Tente novamente dentro de instantes.';

  @override
  String get voicePlaybackFailed =>
      'Não foi possível reproduzir a voz. Tente novamente.';

  @override
  String get voicePlaybackTimedOut =>
      'A reprodução de voz demorou demasiado tempo. Tente novamente.';

  @override
  String get voicePlaybackStopped =>
      'A reprodução de voz parou. Pode gravar novamente.';

  @override
  String get replaceTypedTextTitle => 'Substituir texto escrito?';

  @override
  String get replaceTypedTextDescription =>
      'Utilizar a gravação transcrita em vez do rascunho escrito?';

  @override
  String get keepTypedText => 'Manter texto escrito';

  @override
  String get replaceTypedText => 'Substituir texto escrito';

  @override
  String get transcribingRecording => 'A transcrever gravação...';

  @override
  String get retryLessonContent => 'Tentar conteúdo da lição novamente';

  @override
  String get translation => 'Tradução';

  @override
  String get playVoice => 'Reproduzir voz';

  @override
  String get openConversationMode => 'Abrir modo de conversa';

  @override
  String get conversationPaused => 'Conversa em pausa. Pode gravar novamente.';

  @override
  String get tutorReplyTimedOut =>
      'O tutor demorou demasiado tempo a responder. Tente novamente.';

  @override
  String get conversationSendFailed =>
      'Não foi possível enviar essa resposta. Tente gravar novamente.';

  @override
  String get openAndroidSettingsFailed =>
      'Não foi possível abrir as definições do Android. Tente novamente.';

  @override
  String get conversationReady => 'A sua conversa está pronta.';

  @override
  String get tutorAvatarSemantics => 'Avatar do tutor';

  @override
  String get lessonContentLoadFailed =>
      'Não foi possível carregar o conteúdo da lição. Tente novamente.';

  @override
  String get lessonHistoryDetails => 'Detalhes da lição';

  @override
  String get historySummary => 'Resumo';

  @override
  String get noHistoryConversation =>
      'Não há conversa disponível para esta lição.';

  @override
  String get noHistorySummary => 'Não há resumo da lição disponível.';

  @override
  String get overallSummary => 'Resumo geral';

  @override
  String get historyTutor => 'Professor';

  @override
  String get historyYou => 'Você';

  @override
  String get feedbackCorrectedText => 'Texto corrigido';

  @override
  String get feedbackExplanation => 'Explicação';

  @override
  String get feedbackPraise => 'Elogio';

  @override
  String get lessonUnavailable => 'Essa lição não está disponível.';

  @override
  String get lessonNoLongerAvailable => 'Esta lição já não está disponível.';

  @override
  String get lessonHistoryUnavailable =>
      'O histórico de lições está temporariamente indisponível. Tente novamente.';

  @override
  String get lessonDetailLoadFailed =>
      'Não foi possível carregar os detalhes da lição. Tente novamente.';
}
