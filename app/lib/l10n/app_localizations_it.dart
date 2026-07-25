// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Language Voice Tutor';

  @override
  String get settings => 'Impostazioni';

  @override
  String get profile => 'Profilo';

  @override
  String get app => 'Applicazione';

  @override
  String get saveSettings => 'Salva impostazioni';

  @override
  String get saving => 'Salvataggio...';

  @override
  String get settingsSaved => 'Impostazioni salvate.';

  @override
  String get unableToSaveSettings =>
      'Impossibile salvare le impostazioni al momento.';

  @override
  String get learning => 'Apprendimento';

  @override
  String get studyLanguage => 'Lingua di studio';

  @override
  String get nativeLanguage => 'Lingua madre';

  @override
  String get interfaceLanguage => 'Lingua dell\'interfaccia';

  @override
  String get interfaceExplanationLanguage =>
      'Lingua dell\'interfaccia / delle spiegazioni';

  @override
  String get interfaceLanguageDescription =>
      'Modifica solo la lingua dell\'interfaccia dell\'applicazione.';

  @override
  String get currentLevel => 'Livello attuale';

  @override
  String get selectedTutor => 'Tutor selezionato';

  @override
  String get loadingSettings => 'Caricamento impostazioni...';

  @override
  String get unableToLoadSettings =>
      'Impossibile caricare le impostazioni al momento.';

  @override
  String get retry => 'Riprova';

  @override
  String get back => 'Indietro';

  @override
  String get login => 'Accedi';

  @override
  String get register => 'Registrati';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Parola d\'accesso';

  @override
  String get displayNameOptional => 'Nome visualizzato (facoltativo)';

  @override
  String get signIn => 'Accedi';

  @override
  String get createAccount => 'Crea account';

  @override
  String get unableToCheckSession =>
      'Impossibile verificare la sessione. Riprova.';

  @override
  String get lessons => 'Lezioni';

  @override
  String get lessonHistory => 'Cronologia lezioni';

  @override
  String get progress => 'Progressi';

  @override
  String get rewards => 'Ricompense';

  @override
  String get viewAll => 'Vedi tutto';

  @override
  String get achievements => 'Obiettivi';

  @override
  String get account => 'Profilo utente';

  @override
  String get logout => 'Esci';

  @override
  String get audio => 'Audio';

  @override
  String get feedbackAndReports => 'Feedback e report';

  @override
  String get cancel => 'Annulla';

  @override
  String get submit => 'Invia';

  @override
  String get send => 'Invia';

  @override
  String get done => 'Fatto';

  @override
  String get openAndroidSettings => 'Apri le impostazioni di Android';

  @override
  String get hint => 'Suggerimento';

  @override
  String get finishLesson => 'Termina lezione';

  @override
  String get typeYourMessage => 'Scrivi il tuo messaggio';

  @override
  String get sending => 'Invio...';

  @override
  String get languageNameEnglish => 'Inglese';

  @override
  String get languageNameRussian => 'Russo';

  @override
  String get languageNameSpanish => 'Spagnolo';

  @override
  String get languageNameFrench => 'Francese';

  @override
  String get languageNameGerman => 'Tedesco';

  @override
  String get signInToApp => 'Accedi a Language Voice Tutor';

  @override
  String get pleaseWait => 'Attendi...';

  @override
  String get alreadyHaveAccount => 'Ho già un account';

  @override
  String get invalidEmail => 'Inserisci un indirizzo e-mail valido.';

  @override
  String get enterPassword => 'Inserisci la password.';

  @override
  String get chooseTopic => 'Scegli argomento';

  @override
  String get chooseTopicTitle => 'Scegli un argomento';

  @override
  String get chooseTopicSubtitle =>
      'Scegli il tipo di conversazione che vuoi esercitare.';

  @override
  String get chooseSituation => 'Scegli situazione';

  @override
  String get chooseSituationTitle => 'Scegli una situazione';

  @override
  String get chooseSituationSubtitle =>
      'Esercitati in un momento specifico di questo argomento.';

  @override
  String get viewAllRewards =>
      'Vedi tutti i badge e le ricompense di apprendimento.';

  @override
  String get accountDeletion => 'Eliminazione dell\'account';

  @override
  String get requestAccountDeletion => 'Richiedi l\'eliminazione dell\'account';

  @override
  String get loadingAccount => 'Caricamento account...';

  @override
  String get premiumAndSubscription => 'Premium e abbonamento';

  @override
  String get currentPassword => 'Parola d\'accesso attuale';

  @override
  String get reasonOptional => 'Motivo (facoltativo)';

  @override
  String get submitting => 'Invio...';

  @override
  String get loadingTutors => 'Caricamento tutor...';

  @override
  String get noTutorsAvailable => 'Nessun tutor disponibile al momento.';

  @override
  String get loadingAudioSettings => 'Caricamento impostazioni audio...';

  @override
  String get conversationModeEnabled => 'Modalità conversazione attivata';

  @override
  String get sendSuggestionOrReport =>
      'Invia un suggerimento o segnala un problema';

  @override
  String get reportType => 'Tipo di segnalazione';

  @override
  String get pasteAiResponseOptional =>
      'Incolla la risposta dell\'IA (facoltativo)';

  @override
  String get lessonHistoryHeading => 'Le lezioni completate di recente';

  @override
  String get noCompletedLessons => 'Nessuna lezione completata ancora';

  @override
  String get completedLessonsAppearHere =>
      'Le lezioni completate appariranno qui.';

  @override
  String get backToHome => 'Torna alla home';

  @override
  String get lesson => 'Lezione';

  @override
  String get level => 'Livello';

  @override
  String get completed => 'Completata';

  @override
  String get finished => 'Terminata';

  @override
  String get lessonChat => 'Chat della lezione';

  @override
  String get conversation => 'Conversazione';

  @override
  String turnCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count turni',
      one: '1 turno',
    );
    return '$_temp0';
  }

  @override
  String get achievementsUnavailable => 'Nessun obiettivo disponibile ancora.';

  @override
  String unlockedCount(num unlocked, num total) {
    return '$unlocked di $total sbloccati';
  }

  @override
  String learningLanguage(String language) {
    return 'Stai imparando $language';
  }

  @override
  String get streaks => 'Serie';

  @override
  String get lessonMilestones => 'Traguardi delle lezioni';

  @override
  String get topics => 'Argomenti';

  @override
  String get situations => 'Situazioni';

  @override
  String get otherAchievements => 'Altri obiettivi';

  @override
  String progressCount(num current, num total) {
    return '$current di $total';
  }

  @override
  String get startLesson => 'Inizia lezione';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get keepLearningRhythm => 'Mantieni il ritmo di apprendimento';

  @override
  String get reminderPermissionExplanation =>
      'Language Voice Tutor può inviarti due allegri promemoria giornalieri per evitare che la pratica si perda nelle giornate impegnate. Puoi modificare gli orari o disattivare i promemoria nelle Impostazioni.';

  @override
  String get notNow => 'Non ora';

  @override
  String get allowReminders => 'Consenti promemoria';

  @override
  String get achievementsTemporarilyUnavailable =>
      'Obiettivi temporaneamente non disponibili';

  @override
  String get achievementsEmpty => 'I tuoi obiettivi appariranno qui.';

  @override
  String learningStreak(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie di $count giorni',
      one: 'Serie di 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get learningStreakLoading => 'Caricamento serie di apprendimento';

  @override
  String get learningStreakUnavailable =>
      'Serie di apprendimento non disponibile';

  @override
  String get learnerFallbackName => 'Studente';

  @override
  String get premiumPlan => 'Piano Premium';

  @override
  String get premiumTrial => 'Prova Premium';

  @override
  String get freePlan => 'Piano gratuito';

  @override
  String signedInAs(String name) {
    return 'Accesso effettuato come $name';
  }

  @override
  String get premiumDetails => 'Dettagli Premium';

  @override
  String get explorePremium => 'Scopri Premium';

  @override
  String freeLessonsAvailableToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lezioni gratuite disponibili oggi',
      one: '1 lezione gratuita disponibile oggi',
    );
    return '$_temp0';
  }

  @override
  String get yourWeek => 'La tua settimana';

  @override
  String lessonsLastSevenDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lezioni negli ultimi 7 giorni',
      one: '1 lezione negli ultimi 7 giorni',
    );
    return '$_temp0';
  }

  @override
  String get startStreakToday => 'Inizia oggi la tua serie';

  @override
  String get activityUnavailable => 'Attività non disponibile al momento.';

  @override
  String lessonsCompleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lezioni completate',
      one: '1 lezione completata',
    );
    return '$_temp0';
  }

  @override
  String activityDaySemantics(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lezioni completate',
      one: '1 lezione completata',
    );
    return '$date: $_temp0';
  }

  @override
  String get weekdayMon => 'Lun';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mer';

  @override
  String get weekdayThu => 'Gio';

  @override
  String get weekdayFri => 'Ven';

  @override
  String get weekdaySat => 'Sab';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get remindersTemporarilyUnavailable =>
      'Promemoria per la pratica temporaneamente non disponibili.';

  @override
  String get unableToUpdateReminders =>
      'Impossibile aggiornare i promemoria al momento. Riprova.';

  @override
  String get unableToLoadAccount =>
      'Impossibile caricare i dettagli dell\'account al momento.';

  @override
  String get tutorChoicesUnavailable =>
      'Le opzioni del tutor non sono disponibili al momento. Puoi comunque rivedere e salvare le altre impostazioni.';

  @override
  String get pleaseEnterDescription => 'Inserisci una descrizione.';

  @override
  String get emailRequired => 'L\'e-mail è obbligatoria.';

  @override
  String get resetCodePasswordRequired =>
      'Il codice di reimpostazione e la nuova parola d\'accesso sono obbligatori.';

  @override
  String get passwordsMustMatch =>
      'La nuova parola d\'accesso e la conferma devono corrispondere.';

  @override
  String get signInToChangePassword =>
      'Accedi per cambiare la parola d\'accesso.';

  @override
  String get currentPasswordRequired =>
      'La parola d\'accesso attuale è obbligatoria.';

  @override
  String get accountDeletionDescription =>
      'Invia una richiesta per eliminare definitivamente il tuo account Language Voice Tutor e i dati personali.';

  @override
  String get accountDeletionNotice =>
      'L\'invio di questa richiesta non elimina subito il tuo account. L\'assistenza la esaminerà e la elaborerà e potrebbe chiederti ulteriori informazioni. La risposta sarà inviata all\'indirizzo e-mail associato al tuo account. Il tuo account non è considerato eliminato solo perché hai inviato questa richiesta.';

  @override
  String get noDisplayName => 'Nessun nome visualizzato';

  @override
  String get subscriptionUnavailable => 'Abbonamento non disponibile';

  @override
  String get noPaidPlan => 'Nessun piano a pagamento';

  @override
  String requestId(String id) {
    return 'ID richiesta: $id';
  }

  @override
  String statusValue(String status) {
    return 'Stato: $status';
  }

  @override
  String get passwordRecovery => 'Parola d\'accesso e recupero';

  @override
  String get accountEmail => 'E-mail dell\'account';

  @override
  String get sendingResetInstructions =>
      'Invio istruzioni di reimpostazione...';

  @override
  String get forgotPassword => 'Parola d\'accesso dimenticata';

  @override
  String get resetCode => 'Codice di reimpostazione';

  @override
  String get newPassword => 'Nuova parola d\'accesso';

  @override
  String get confirmNewPassword => 'Conferma la nuova parola d\'accesso';

  @override
  String get updatingPassword => 'Aggiornamento della parola d\'accesso...';

  @override
  String get resetPassword => 'Reimposta la parola d\'accesso';

  @override
  String get newAccountPassword => 'Nuova parola d\'accesso dell\'account';

  @override
  String get confirmNewAccountPassword =>
      'Conferma la nuova parola d\'accesso dell\'account';

  @override
  String get changingPassword => 'Modifica della parola d\'accesso...';

  @override
  String get changePassword => 'Cambia la parola d\'accesso';

  @override
  String get tutorVoice => 'Voce del tutor';

  @override
  String speechSpeed(String speed) {
    return 'Velocità vocale: ${speed}x';
  }

  @override
  String get feedbackSuggestion => 'Suggerimento';

  @override
  String get feedbackAppProblem => 'Problema dell\'app';

  @override
  String get feedbackAiResponse => 'Risposta dell\'IA';

  @override
  String get yourSuggestion => 'Il tuo suggerimento';

  @override
  String get describeProblem => 'Descrivi il problema';

  @override
  String get aiResponseProblem => 'Cosa non andava nella risposta dell\'IA?';

  @override
  String get practiceReminders => 'Promemoria per la pratica';

  @override
  String get localRemindersDescription =>
      'Questi promemoria sono locali al dispositivo.';

  @override
  String get dailyPracticeReminders => 'Promemoria giornalieri per la pratica';

  @override
  String get morningReminder => 'Promemoria mattutino';

  @override
  String get eveningReminder => 'Promemoria serale';

  @override
  String get notificationsAllowed => 'Notifiche consentite';

  @override
  String get notificationStatusUnavailable =>
      'Stato delle notifiche non disponibile';

  @override
  String get notificationsBlocked => 'Le notifiche sono bloccate da Android.';

  @override
  String get allowNotifications => 'Consenti notifiche';

  @override
  String get feedbackReceived => 'Grazie. Il tuo messaggio è stato ricevuto.';

  @override
  String get feedbackValidationFailure => 'Controlla il messaggio e riprova.';

  @override
  String get feedbackUnavailable =>
      'Il feedback non è disponibile temporaneamente. Riprova.';

  @override
  String get deletionRequestAlreadyExists =>
      'Esiste già una richiesta attiva di eliminazione dell\'account.';

  @override
  String get deletionRequestSubmitted =>
      'La richiesta di eliminazione dell\'account è stata inviata all\'assistenza per l\'elaborazione.';

  @override
  String get incorrectCurrentPassword =>
      'La tua parola d\'accesso attuale non è corretta.';

  @override
  String get unableToReachService =>
      'Impossibile raggiungere il servizio. Riprova.';

  @override
  String get unexpectedServiceResponse =>
      'Il servizio ha restituito una risposta imprevista. Riprova.';

  @override
  String get unableToSubmitRequest =>
      'Impossibile inviare la richiesta al momento. Riprova.';

  @override
  String get unableToLoadLearningSettings =>
      'Impossibile caricare le impostazioni di apprendimento al momento. Riprova.';

  @override
  String get settingsTemporarilyUnavailable =>
      'Le impostazioni non sono disponibili temporaneamente. Riprova.';

  @override
  String selectedLevelContext(String level) {
    return 'Livello: $level';
  }

  @override
  String selectedLevelTopicContext(String level, String topic) {
    return 'Livello: $level / Argomento: $topic';
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
    return 'Apri $topic';
  }

  @override
  String openSituationTooltip(String situation) {
    return 'Apri $situation';
  }

  @override
  String get noSituationsAvailable =>
      'Nessuna situazione disponibile per questo argomento.';

  @override
  String get levelA1Label => 'A1 Principiante';

  @override
  String get levelA1Description =>
      'Costruisci semplici saluti, esprimi bisogni e dai brevi risposte quotidiane.';

  @override
  String get levelA2Label => 'A2 Elementare';

  @override
  String get levelA2Description =>
      'Gestisci conversazioni abituali con parole e frasi familiari.';

  @override
  String get levelB1Label => 'B1 Intermedio';

  @override
  String get levelB1Description =>
      'Esercitati in scambi più lunghi, opinioni e soluzioni a problemi quotidiani.';

  @override
  String get levelB2Label => 'B2 Intermedio avanzato';

  @override
  String get levelB2Description =>
      'Affina conversazioni ricche di sfumature con dettagli più naturali.';

  @override
  String get topicDailyLifeLabel => 'Vita quotidiana';

  @override
  String get topicDailyLifeDescription =>
      'Conversazioni informali, presentazioni e situazioni quotidiane.';

  @override
  String get topicTravelLabel => 'Viaggi';

  @override
  String get topicTravelDescription =>
      'Aeroporti, hotel, indicazioni e trasporti.';

  @override
  String get topicWorkBusinessLabel => 'Lavoro e affari';

  @override
  String get topicWorkBusinessDescription =>
      'Riunioni, e-mail, chiamate e conversazioni sul lavoro.';

  @override
  String get topicJobInterviewLabel => 'Colloquio di lavoro';

  @override
  String get topicJobInterviewDescription =>
      'Esercitati con domande e risposte comuni dei colloqui.';

  @override
  String get topicRestaurantCafeLabel => 'Ristorante e bar';

  @override
  String get topicRestaurantCafeDescription =>
      'Ordinare cibo, prenotare tavoli e fare richieste cortesi.';

  @override
  String get topicFreeConversationLabel => 'Conversazione libera';

  @override
  String get topicFreeConversationDescription =>
      'Pratica libera basata su ciò che vuoi dire.';

  @override
  String get situationIntroductionsLabel => 'Presentazioni';

  @override
  String get situationIntroductionsDescription =>
      'Presentati e poni domande personali di base.';

  @override
  String get situationSmallTalkNeighborLabel => 'Parlare con un vicino';

  @override
  String get situationSmallTalkNeighborDescription =>
      'Fai una breve conversazione amichevole vicino a casa.';

  @override
  String get situationAskingForHelpLabel => 'Chiedere aiuto';

  @override
  String get situationAskingForHelpDescription =>
      'Chiedi aiuto in una semplice situazione quotidiana.';

  @override
  String get situationMakingPlansLabel => 'Fare programmi';

  @override
  String get situationMakingPlansDescription =>
      'Pianifica un\'attività e concorda ora e luogo.';

  @override
  String get situationTalkingAboutDayLabel => 'Parlare della propria giornata';

  @override
  String get situationTalkingAboutDayDescription =>
      'Descrivi la tua giornata e la routine quotidiana.';

  @override
  String get situationAirportCheckInLabel => 'Check-in in aeroporto';

  @override
  String get situationAirportCheckInDescription =>
      'Effettua il check-in per un volo e conferma i dettagli del viaggio.';

  @override
  String get situationHotelCheckInLabel => 'Check-in in hotel';

  @override
  String get situationHotelCheckInDescription =>
      'Effettua il check-in in hotel e fai domande comuni.';

  @override
  String get situationAskingForDirectionsLabel => 'Chiedere indicazioni';

  @override
  String get situationAskingForDirectionsDescription =>
      'Chiedi e comprendi le indicazioni in una nuova città.';

  @override
  String get situationOrderingTransportLabel => 'Prenotare un trasporto';

  @override
  String get situationOrderingTransportDescription =>
      'Organizza un taxi o un passaggio verso la tua destinazione.';

  @override
  String get situationLostLuggageLabel => 'Bagaglio smarrito';

  @override
  String get situationLostLuggageDescription =>
      'Segnala un bagaglio smarrito e spiega la tua situazione.';

  @override
  String get situationFirstMeetingLabel => 'Primo incontro';

  @override
  String get situationFirstMeetingDescription =>
      'Presentati in una nuova riunione di lavoro.';

  @override
  String get situationDailyStandupLabel => 'Riunione quotidiana';

  @override
  String get situationDailyStandupDescription =>
      'Fornisci un breve aggiornamento sulle tue attività.';

  @override
  String get situationClientPhoneCallLabel => 'Telefonata con un cliente';

  @override
  String get situationClientPhoneCallDescription =>
      'Gestisci una telefonata di lavoro cortese e chiara.';

  @override
  String get situationAskingForClarificationLabel => 'Chiedere chiarimenti';

  @override
  String get situationAskingForClarificationDescription =>
      'Poni domande di approfondimento per confermare i requisiti.';

  @override
  String get situationDiscussingDeadlinesLabel => 'Discutere le scadenze';

  @override
  String get situationDiscussingDeadlinesDescription =>
      'Parla di tempistiche e aspettative di consegna.';

  @override
  String get situationTellMeAboutYourselfLabel => 'Parlami di te';

  @override
  String get situationTellMeAboutYourselfDescription =>
      'Fai una breve presentazione personale adatta a un colloquio.';

  @override
  String get situationWorkExperienceLabel => 'Esperienza lavorativa';

  @override
  String get situationWorkExperienceDescription =>
      'Descrivi lavori precedenti, responsabilità e un risultato.';

  @override
  String get situationStrengthsWeaknessesLabel => 'Punti di forza e debolezza';

  @override
  String get situationStrengthsWeaknessesDescription =>
      'Parla in modo professionale di un punto di forza e di un\'area da migliorare.';

  @override
  String get situationWhyThisJobLabel => 'Perché vuoi questo lavoro?';

  @override
  String get situationWhyThisJobDescription =>
      'Spiega la tua motivazione e collega il ruolo alle tue competenze.';

  @override
  String get situationQuestionsAtEndLabel => 'Fare domande alla fine';

  @override
  String get situationQuestionsAtEndDescription =>
      'Poni domande cortesi e utili prima della fine del colloquio.';

  @override
  String get situationBookingTableLabel => 'Prenotare un tavolo';

  @override
  String get situationBookingTableDescription =>
      'Chiama o parla con qualcuno per prenotare un tavolo.';

  @override
  String get situationOrderingFoodLabel => 'Ordinare cibo';

  @override
  String get situationOrderingFoodDescription =>
      'Ordina un pasto e fai semplici domande sul menu.';

  @override
  String get situationAskingIngredientsLabel =>
      'Chiedere informazioni sugli ingredienti';

  @override
  String get situationAskingIngredientsDescription =>
      'Chiedi informazioni su allergie e ingredienti dei piatti.';

  @override
  String get situationWrongOrderLabel => 'Gestire un ordine sbagliato';

  @override
  String get situationWrongOrderDescription =>
      'Spiega con cortesia un problema con il tuo ordine.';

  @override
  String get situationPayingBillLabel => 'Pagare il conto';

  @override
  String get situationPayingBillDescription =>
      'Chiedi il conto e completa il pagamento.';

  @override
  String get situationOpenConversationLabel => 'Conversazione aperta';

  @override
  String get situationOpenConversationDescription =>
      'Esercitati su qualsiasi argomento con seguito flessibile.';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatusLoadingSemantics => 'Caricamento stato Premium';

  @override
  String get premiumStatusTemporarilyUnavailable =>
      'Lo stato Premium non è disponibile temporaneamente. Riprova.';

  @override
  String premiumStatusSemantics(String status) {
    return 'Stato Premium: $status';
  }

  @override
  String get premiumActive => 'Premium attivo';

  @override
  String get premiumActiveDescription =>
      'Esercitati senza il limite giornaliero di lezioni gratuite.';

  @override
  String premiumEndsOn(String date) {
    return 'Premium termina il $date.';
  }

  @override
  String get premiumTrialActiveDescription => 'La tua prova Premium è attiva.';

  @override
  String premiumTrialEndsOn(String date) {
    return 'La prova termina il $date.';
  }

  @override
  String freeLessonsRemainingToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lezioni gratuite disponibili oggi.',
      one: '1 lezione gratuita disponibile oggi.',
      zero: 'Nessuna lezione gratuita disponibile oggi.',
    );
    return '$_temp0';
  }

  @override
  String get premiumRemovesDailyLimit =>
      'Premium elimina il limite giornaliero delle lezioni.';

  @override
  String get premiumAccountLinked =>
      'L\'accesso Premium è collegato al tuo account Language Voice Tutor.';

  @override
  String get premiumSharedAcrossClients =>
      'Il tuo stato Premium confermato è condiviso tra i client Language Voice Tutor supportati.';

  @override
  String get premiumBenefits => 'Vantaggi Premium';

  @override
  String get premiumBenefitDailyLimit =>
      '• Esercitati senza il limite giornaliero di lezioni gratuite';

  @override
  String get premiumBenefitAcrossDevices =>
      '• Usa lo stesso accesso Premium sui dispositivi supportati';

  @override
  String get premiumBenefitAccountData =>
      '• Mantieni insieme account, progressi, cronologia e impostazioni di apprendimento';

  @override
  String get getPremium => 'Ottieni Premium';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get refreshPremiumStatus => 'Aggiorna stato';

  @override
  String get billingProviderExplanation =>
      'Le modifiche alla fatturazione devono essere gestite dal provider presso cui è stato acquistato Premium.';

  @override
  String get googlePlayPurchasesUnavailableTitle =>
      'Gli acquisti Google Play non sono ancora disponibili';

  @override
  String get restorePurchasesUnavailableTitle =>
      'Il ripristino acquisti non è ancora disponibile';

  @override
  String get googlePlayPurchasesUnavailableDescription =>
      'Gli acquisti saranno collegati nel passaggio successivo. Questa build non può addebitarti nulla né attivare Premium.';

  @override
  String get restorePurchasesUnavailableDescription =>
      'Il ripristino Google Play sarà collegato al flusso di fatturazione. Lo stato attuale del tuo account viene comunque caricato da Language Voice Tutor.';

  @override
  String get purchasePendingConfirmation =>
      'L\'elaborazione dell\'acquisto non è ancora confermata. Aggiorna di nuovo lo stato tra poco.';

  @override
  String get purchaseActionFailed =>
      'Impossibile completare la richiesta al momento. Riprova.';

  @override
  String get premiumOk => 'OK';

  @override
  String get leaveLessonTitle => 'Abbandonare la lezione?';

  @override
  String get leaveLessonDescription =>
      'Abbandonando termini questa lezione incompleta senza creare un riepilogo.';

  @override
  String get stay => 'Resta';

  @override
  String get leaveLesson => 'Abbandona lezione';

  @override
  String get finishLessonTitle => 'Terminare la lezione?';

  @override
  String get finishLessonDescription =>
      'Terminare questa lezione e visualizzare il riepilogo?';

  @override
  String get continueLesson => 'Continua lezione';

  @override
  String get gettingHint => 'Recupero suggerimento...';

  @override
  String get dismissHint => 'Chiudi suggerimento';

  @override
  String get finishingLesson => 'Completamento lezione...';

  @override
  String get finishLessonAuthRequired =>
      'Accedi di nuovo per terminare la lezione.';

  @override
  String get finishLessonSessionUnavailable =>
      'Questa sessione di lezione non è più disponibile.';

  @override
  String get finishLessonFailed =>
      'Impossibile terminare la lezione. Controlla la connessione e riprova.';

  @override
  String get lessonFeedback => 'Feedback';

  @override
  String get loadingLessonFeedback => 'Caricamento feedback...';

  @override
  String get showLessonFeedback => 'Mostra feedback';

  @override
  String get hideLessonFeedback => 'Nascondi feedback';

  @override
  String get retryLessonFeedback => 'Riprova feedback';

  @override
  String get feedbackNotReady => 'Il feedback non è ancora pronto. Riprova.';

  @override
  String get feedbackQuickSummary => 'Riepilogo rapido';

  @override
  String get feedbackCorrectedVersion => 'Versione corretta';

  @override
  String get feedbackGrammarTip => 'Suggerimento grammaticale';

  @override
  String get feedbackVocabularyTip => 'Suggerimento di vocabolario';

  @override
  String get feedbackCultureTip => 'Suggerimento culturale';

  @override
  String get feedbackNaturalVersion => 'Versione più naturale';

  @override
  String get lessonFeedbackAuthRequired =>
      'Accedi di nuovo per continuare la lezione.';

  @override
  String get lessonFeedbackSessionEnded => 'Questa lezione è già terminata.';

  @override
  String get lessonFeedbackNotAvailableForMessage =>
      'Il feedback non è disponibile per questo messaggio.';

  @override
  String get lessonFeedbackFailed =>
      'Impossibile ottenere il feedback. Riprova.';

  @override
  String get lessonStartBlocked =>
      'Hai usato la lezione gratuita di oggi. Riprova domani o passa a Premium.';

  @override
  String get lessonStartConflict =>
      'Hai già una lezione attiva. Terminala o abbandonala prima di iniziarne una nuova.';

  @override
  String get lessonStartAuthRequired =>
      'Accedi di nuovo per iniziare una lezione.';

  @override
  String get lessonStartUnavailable =>
      'Impossibile iniziare la lezione. Controlla la connessione e riprova.';

  @override
  String get lessonStartFailed => 'Impossibile iniziare la lezione. Riprova.';

  @override
  String get lessonSummary => 'Riepilogo della lezione';

  @override
  String get lessonCompleted => 'Lezione completata';

  @override
  String get summaryWhatWentWell => 'Cosa è andato bene';

  @override
  String get summaryStrengths => 'Punti di forza';

  @override
  String get summaryImprovements => 'Aree di miglioramento';

  @override
  String get summaryVocabulary => 'Vocabolario';

  @override
  String get summaryGrammar => 'Grammatica';

  @override
  String get summaryNextSteps => 'Prossimi passi';

  @override
  String get retrySummary => 'Riprova riepilogo';

  @override
  String get summaryUnavailableMessage =>
      'La lezione è stata salvata, ma non è stato possibile creare un riepilogo.';

  @override
  String get summaryAuthRequiredMessage =>
      'Accedi di nuovo per caricare il riepilogo della lezione.';

  @override
  String get summaryLoadErrorMessage =>
      'La lezione è stata salvata, ma non è possibile caricare il riepilogo al momento.';

  @override
  String get startRecording => 'Avvia registrazione';

  @override
  String get stopRecording => 'Interrompi registrazione';

  @override
  String get progressCompletedLessons => 'Lezioni completate';

  @override
  String get progressAllTime => 'Sempre';

  @override
  String get progressLast7Days => 'Ultimi 7 giorni';

  @override
  String get progressLast30Days => 'Ultimi 30 giorni';

  @override
  String get progressCurrentStreak => 'Serie attuale';

  @override
  String get progressLongestStreak => 'Serie più lunga';

  @override
  String get progressRecentActivity => 'Attività recente';

  @override
  String get progressLastCompletedLesson => 'Ultima lezione completata';

  @override
  String get progressLessonsByLanguage => 'Lezioni per lingua';

  @override
  String get progressLessonsByLevel => 'Lezioni per livello';

  @override
  String get progressEmptyTitle => 'I tuoi progressi appariranno qui';

  @override
  String get progressEmptyDescription =>
      'Le lezioni completate appariranno qui dopo aver terminato una lezione.';

  @override
  String get progressUnavailable =>
      'I progressi non sono disponibili temporaneamente. Riprova.';

  @override
  String get progressLoadFailed => 'Impossibile caricare i progressi. Riprova.';

  @override
  String progressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
      zero: '0 giorni',
    );
    return '$_temp0';
  }

  @override
  String get achievementsLoadFailed =>
      'Impossibile caricare gli obiettivi. Riprova.';

  @override
  String achievementUnlockedSemantics(String title) {
    return 'Obiettivo sbloccato: $title';
  }

  @override
  String achievementLockedSemantics(String title, num current, num target) {
    return 'Obiettivo bloccato: $title. Progresso: $current di $target.';
  }

  @override
  String closeAchievementPreview(String title) {
    return 'Chiudi anteprima dell\'obiettivo $title';
  }

  @override
  String get closeAllAchievementPreviews =>
      'Chiudi tutte le anteprime degli obiettivi';

  @override
  String get achievementTitleStreak7 => 'Serie di 7 giorni';

  @override
  String get achievementTitleStreak30 => 'Serie di 30 giorni';

  @override
  String get achievementTitleStreak60 => 'Serie di 60 giorni';

  @override
  String get achievementTitleStreak100 => 'Serie di 100 giorni';

  @override
  String get achievementTitleStreak365 => 'Serie di 365 giorni';

  @override
  String get achievementTitleLessons1 => 'Primo passo';

  @override
  String get achievementTitleLessons5 => 'Primi passi';

  @override
  String get achievementTitleLessons10 => '10 lezioni completate';

  @override
  String get achievementTitleLessons25 => 'Apprendista costante';

  @override
  String get achievementTitleLessons50 => '50 lezioni completate';

  @override
  String get achievementTitleLessons100 => 'Club dei 100';

  @override
  String get achievementTitleDailyLifeIntroductions => 'Primo saluto';

  @override
  String get achievementTitleDailyLifeNeighborChat => 'Chiacchiere col vicino';

  @override
  String get achievementTitleDailyLifeHelpfulHand => 'Mano amica';

  @override
  String get achievementTitleDailyLifePlanMaker => 'Creatore di piani';

  @override
  String get achievementTitleDailyLifeDayTeller => 'Narratore della giornata';

  @override
  String get achievementTitleDailyLifeEverydayHero => 'Eroe quotidiano';

  @override
  String get achievementTitleTravelAirportExpert => 'Esperto di aeroporti';

  @override
  String get achievementTitleTravelHonoredGuest => 'Ospite d\'onore';

  @override
  String get achievementTitleTravelCityNavigator => 'Navigatore urbano';

  @override
  String get achievementTitleTravelRideReady => 'Pronto al viaggio';

  @override
  String get achievementTitleTravelBaggageFinder => 'Cercabagagli';

  @override
  String get achievementTitleTravelTraveler => 'Viaggiatore';

  @override
  String get achievementTitleWorkMeetingReady => 'Pronto per le riunioni';

  @override
  String get achievementTitleWorkStandupStar => 'Stella del briefing';

  @override
  String get achievementTitleWorkClientCaller =>
      'Esperto nelle chiamate con clienti';

  @override
  String get achievementTitleWorkClearCommunicator => 'Comunicatore chiaro';

  @override
  String get achievementTitleWorkDeadlineDriver => 'Maestro delle scadenze';

  @override
  String get achievementTitleWorkBusinessReady => 'Pronto per il business';

  @override
  String get achievementTitleInterviewStrongIntroduction =>
      'Presentazione efficace';

  @override
  String get achievementTitleInterviewCareerStory => 'Storia professionale';

  @override
  String get achievementTitleInterviewSelfAwareCandidate =>
      'Candidato consapevole';

  @override
  String get achievementTitleInterviewRightFit => 'Scelta giusta';

  @override
  String get achievementTitleInterviewCuriousCandidate => 'Candidato curioso';

  @override
  String get achievementTitleInterviewReady => 'Pronto per il colloquio';

  @override
  String get achievementTitleRestaurantTableBooker => 'Prenotatore di tavoli';

  @override
  String get achievementTitleRestaurantMenuExpert => 'Esperto del menu';

  @override
  String get achievementTitleRestaurantIngredientGuide =>
      'Guida agli ingredienti';

  @override
  String get achievementTitleRestaurantOrderFixer => 'Risolutore di ordini';

  @override
  String get achievementTitleRestaurantBillSettled => 'Conto saldato';

  @override
  String get achievementTitleRestaurantDiningPro =>
      'Professionista della ristorazione';

  @override
  String get autoSendMessage => 'Auto-send message';

  @override
  String get autoPlayTutorVoice => 'Auto-play tutor voice';

  @override
  String get voiceRecognitionUnclear =>
      'Non sono riuscito a riconoscerlo chiaramente. Riprova.';

  @override
  String get microphoneBlockedOpenSettings =>
      'L\'accesso al microfono è bloccato. Apri le impostazioni di Android per abilitarlo.';

  @override
  String get microphonePermissionDeniedRetry =>
      'L\'accesso al microfono non è stato concesso. Tocca il microfono per riprovare.';

  @override
  String get recordingStartFailedCheckMicrophone =>
      'Impossibile avviare la registrazione. Controlla il microfono.';

  @override
  String get recordingStartFailed =>
      'Impossibile avviare la registrazione. Riprova.';

  @override
  String get recordingTooShort =>
      'Registra una risposta leggermente più lunga.';

  @override
  String get recordingStopFailed =>
      'Impossibile interrompere la registrazione. Riprova.';

  @override
  String get recordingProcessingFailed =>
      'Impossibile elaborare la registrazione. Riprova.';

  @override
  String get recordingAuthRequired =>
      'Accedi di nuovo per usare la registrazione.';

  @override
  String get transcriptionTemporarilyUnavailable =>
      'La trascrizione non è disponibile temporaneamente. Riprova tra poco.';

  @override
  String get transcriptionTimedOut =>
      'La trascrizione ha richiesto troppo tempo. Riprova.';

  @override
  String get transcriptionConnectionFailed =>
      'Connessione non riuscita durante la trascrizione. Riprova.';

  @override
  String get transcriptionFailed =>
      'Impossibile trascrivere la registrazione. Riprova.';

  @override
  String get voiceTemporarilyUnavailable =>
      'La voce non è disponibile temporaneamente. Riprova tra poco.';

  @override
  String get voicePlaybackFailed => 'Impossibile riprodurre la voce. Riprova.';

  @override
  String get voicePlaybackTimedOut =>
      'La riproduzione vocale ha richiesto troppo tempo. Riprova.';

  @override
  String get voicePlaybackStopped =>
      'La riproduzione vocale si è interrotta. Puoi registrare di nuovo.';

  @override
  String get replaceTypedTextTitle => 'Sostituire il testo digitato?';

  @override
  String get replaceTypedTextDescription =>
      'Usare la registrazione trascritta invece della bozza digitata?';

  @override
  String get keepTypedText => 'Mantieni testo digitato';

  @override
  String get replaceTypedText => 'Sostituisci testo digitato';

  @override
  String get transcribingRecording => 'Trascrizione della registrazione...';

  @override
  String get retryLessonContent => 'Riprova contenuto della lezione';

  @override
  String get translation => 'Traduzione';

  @override
  String get playVoice => 'Riproduci voce';

  @override
  String get openConversationMode => 'Apri modalità conversazione';

  @override
  String get conversationPaused =>
      'Conversazione in pausa. Puoi registrare di nuovo.';

  @override
  String get tutorReplyTimedOut =>
      'Il tutor ha impiegato troppo tempo per rispondere. Riprova.';

  @override
  String get conversationSendFailed =>
      'Impossibile inviare la risposta. Prova a registrare di nuovo.';

  @override
  String get openAndroidSettingsFailed =>
      'Impossibile aprire le impostazioni di Android. Riprova.';

  @override
  String get conversationReady => 'La conversazione è pronta.';

  @override
  String get tutorAvatarSemantics => 'Avatar del tutor';

  @override
  String get lessonContentLoadFailed =>
      'Impossibile caricare il contenuto della lezione. Riprova.';

  @override
  String get lessonHistoryDetails => 'Dettagli della lezione';

  @override
  String get historySummary => 'Riepilogo';

  @override
  String get noHistoryConversation =>
      'Nessuna conversazione disponibile per questa lezione.';

  @override
  String get noHistorySummary => 'Nessun riepilogo della lezione disponibile.';

  @override
  String get overallSummary => 'Riepilogo generale';

  @override
  String get historyTutor => 'Insegnante';

  @override
  String get historyYou => 'Tu';

  @override
  String get feedbackCorrectedText => 'Testo corretto';

  @override
  String get feedbackExplanation => 'Spiegazione';

  @override
  String get feedbackPraise => 'Lode';

  @override
  String get lessonUnavailable => 'Quella lezione non è disponibile.';

  @override
  String get lessonNoLongerAvailable => 'Questa lezione non è più disponibile.';

  @override
  String get lessonHistoryUnavailable =>
      'La cronologia delle lezioni non è disponibile temporaneamente. Riprova.';

  @override
  String get lessonDetailLoadFailed =>
      'Impossibile caricare i dettagli della lezione. Riprova.';
}
