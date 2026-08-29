// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Language Voice Tutor';

  @override
  String get settings => 'Paramètres';

  @override
  String get profile => 'Profil';

  @override
  String get app => 'Application';

  @override
  String get saveSettings => 'Enregistrer les paramètres';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get settingsSaved => 'Paramètres enregistrés.';

  @override
  String get unableToSaveSettings => 'Impossible d’enregistrer les paramètres.';

  @override
  String get learning => 'Apprentissage';

  @override
  String get studyLanguage => 'Langue d’étude';

  @override
  String get nativeLanguage => 'Langue maternelle';

  @override
  String get interfaceLanguage => 'Langue de l’interface';

  @override
  String get interfaceExplanationLanguage =>
      'Langue de l’interface / des explications';

  @override
  String get interfaceLanguageDescription =>
      'Change uniquement la langue de l’interface de l’application.';

  @override
  String get currentLevel => 'Niveau actuel';

  @override
  String get selectedTutor => 'Tuteur sélectionné';

  @override
  String get loadingSettings => 'Chargement des paramètres...';

  @override
  String get unableToLoadSettings => 'Impossible de charger les paramètres.';

  @override
  String get retry => 'Réessayer';

  @override
  String get back => 'Retour';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S’inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get displayNameOptional => 'Nom affiché (facultatif)';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get unableToCheckSession =>
      'Impossible de vérifier votre session. Réessayez.';

  @override
  String get lessons => 'Leçons';

  @override
  String get lessonHistory => 'Historique des leçons';

  @override
  String get progress => 'Progrès';

  @override
  String get rewards => 'Récompenses';

  @override
  String get viewAll => 'Tout voir';

  @override
  String get achievements => 'Succès';

  @override
  String get account => 'Compte';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get audio => 'Audio';

  @override
  String get feedbackAndReports => 'Commentaires et signalements';

  @override
  String get cancel => 'Annuler';

  @override
  String get submit => 'Envoyer';

  @override
  String get send => 'Envoyer';

  @override
  String get done => 'Terminé';

  @override
  String get openAndroidSettings => 'Ouvrir les paramètres Android';

  @override
  String get hint => 'Indice';

  @override
  String get finishLesson => 'Terminer la leçon';

  @override
  String get typeYourMessage => 'Saisissez votre message';

  @override
  String get sending => 'Envoi...';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameRussian => 'Русский';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameGerman => 'Deutsch';

  @override
  String get signInToApp => 'Connectez-vous à Language Voice Tutor';

  @override
  String get pleaseWait => 'Veuillez patienter...';

  @override
  String get alreadyHaveAccount => 'J’ai déjà un compte';

  @override
  String get invalidEmail => 'Saisissez une adresse e-mail valide.';

  @override
  String get enterPassword => 'Saisissez votre mot de passe.';

  @override
  String get chooseTopic => 'Choisir un thème';

  @override
  String get chooseTopicTitle => 'Choisissez un thème';

  @override
  String get chooseTopicSubtitle =>
      'Choisissez le type de conversation à pratiquer.';

  @override
  String get chooseSituation => 'Choisir une situation';

  @override
  String get chooseSituationTitle => 'Choisissez une situation';

  @override
  String get chooseSituationSubtitle =>
      'Entraînez-vous à un moment précis de ce thème.';

  @override
  String get viewAllRewards => 'Voir tous les badges et récompenses';

  @override
  String get accountDeletion => 'Suppression du compte';

  @override
  String get requestAccountDeletion => 'Demander la suppression du compte';

  @override
  String get loadingAccount => 'Chargement du compte...';

  @override
  String get premiumAndSubscription => 'Premium et abonnement';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get reasonOptional => 'Motif (facultatif)';

  @override
  String get submitting => 'Envoi...';

  @override
  String get loadingTutors => 'Chargement des tuteurs...';

  @override
  String get noTutorsAvailable => 'Aucun tuteur n’est disponible actuellement.';

  @override
  String get loadingAudioSettings => 'Chargement des réglages audio...';

  @override
  String get conversationModeEnabled => 'Mode conversation activé';

  @override
  String get sendSuggestionOrReport =>
      'Envoyer une suggestion ou signaler un problème';

  @override
  String get reportType => 'Type de signalement';

  @override
  String get pasteAiResponseOptional =>
      'Collez la réponse de l’IA (facultatif)';

  @override
  String get lessonHistoryHeading => 'Vos leçons récemment terminées';

  @override
  String get noCompletedLessons => 'Aucune leçon terminée pour l’instant';

  @override
  String get completedLessonsAppearHere =>
      'Les leçons terminées apparaîtront ici.';

  @override
  String get backToHome => 'Retour à l’accueil';

  @override
  String get lesson => 'Leçon';

  @override
  String get level => 'Niveau';

  @override
  String get completed => 'Terminée';

  @override
  String get finished => 'Terminée';

  @override
  String get lessonChat => 'Chat de la leçon';

  @override
  String get conversation => 'Conversation';

  @override
  String turnCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tours',
      one: '1 tour',
    );
    return '$_temp0';
  }

  @override
  String get achievementsUnavailable =>
      'Aucun succès n’est disponible pour le moment.';

  @override
  String unlockedCount(num unlocked, num total) {
    return '$unlocked sur $total débloqués';
  }

  @override
  String learningLanguage(String language) {
    return 'Apprentissage : $language';
  }

  @override
  String get streaks => 'Séries';

  @override
  String get lessonMilestones => 'Étapes des leçons';

  @override
  String get topics => 'Thèmes';

  @override
  String get situations => 'Situations';

  @override
  String get otherAchievements => 'Autres succès';

  @override
  String progressCount(num current, num total) {
    return '$current sur $total';
  }

  @override
  String get startLesson => 'Commencer la leçon';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get keepLearningRhythm => 'Gardez votre rythme d’apprentissage';

  @override
  String get reminderPermissionExplanation =>
      'Language Voice Tutor peut envoyer deux rappels quotidiens pour vous aider à pratiquer même pendant les journées chargées. Vous pouvez modifier les horaires ou les désactiver dans les paramètres.';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get allowReminders => 'Autoriser les rappels';

  @override
  String get achievementsTemporarilyUnavailable =>
      'Les succès sont temporairement indisponibles';

  @override
  String get achievementsEmpty => 'Vos succès apparaîtront ici.';

  @override
  String learningStreak(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série d’apprentissage de $count jours',
      one: 'Série d’apprentissage de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get learningStreakLoading => 'Chargement de la série d’apprentissage';

  @override
  String get learningStreakUnavailable => 'Série d’apprentissage indisponible';

  @override
  String get learnerFallbackName => 'Apprenant';

  @override
  String get premiumPlan => 'Formule Premium';

  @override
  String get premiumTrial => 'Essai Premium';

  @override
  String get freePlan => 'Formule gratuite';

  @override
  String signedInAs(String name) {
    return 'Connecté en tant que $name';
  }

  @override
  String get premiumDetails => 'Détails de Premium';

  @override
  String get explorePremium => 'Découvrir Premium';

  @override
  String freeLessonsAvailableToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leçons gratuites disponibles aujourd’hui',
      one: '1 leçon gratuite disponible aujourd’hui',
    );
    return '$_temp0';
  }

  @override
  String get yourWeek => 'Votre semaine';

  @override
  String lessonsLastSevenDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leçons au cours des 7 derniers jours',
      one: '1 leçon au cours des 7 derniers jours',
    );
    return '$_temp0';
  }

  @override
  String get startStreakToday => 'Commencez votre série aujourd’hui';

  @override
  String get activityUnavailable =>
      'L’activité est indisponible pour le moment.';

  @override
  String lessonsCompleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leçons terminées',
      one: '1 leçon terminée',
    );
    return '$_temp0';
  }

  @override
  String activityDaySemantics(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leçons terminées',
      one: '1 leçon terminée',
    );
    return '$date : $_temp0';
  }

  @override
  String get weekdayMon => 'Lun';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mer';

  @override
  String get weekdayThu => 'Jeu';

  @override
  String get weekdayFri => 'Ven';

  @override
  String get weekdaySat => 'Sam';

  @override
  String get weekdaySun => 'Dim';

  @override
  String get remindersTemporarilyUnavailable =>
      'Les rappels sont temporairement indisponibles.';

  @override
  String get unableToUpdateReminders =>
      'Impossible de mettre à jour les rappels. Réessayez.';

  @override
  String get unableToLoadAccount =>
      'Impossible de charger les informations du compte.';

  @override
  String get tutorChoicesUnavailable =>
      'Les tuteurs sont indisponibles pour le moment. Vous pouvez consulter et enregistrer les autres paramètres.';

  @override
  String get pleaseEnterDescription => 'Saisissez une description.';

  @override
  String get emailRequired => 'L’adresse e-mail est obligatoire.';

  @override
  String get resetCodePasswordRequired =>
      'Le code de réinitialisation et le nouveau mot de passe sont obligatoires.';

  @override
  String get passwordsMustMatch =>
      'Le nouveau mot de passe et sa confirmation doivent correspondre.';

  @override
  String get signInToChangePassword =>
      'Connectez-vous pour modifier votre mot de passe.';

  @override
  String get currentPasswordRequired =>
      'Le mot de passe actuel est obligatoire.';

  @override
  String get accountDeletionDescription =>
      'Envoyez une demande de suppression définitive de votre compte Language Voice Tutor et de vos données personnelles.';

  @override
  String get accountDeletionNotice =>
      'L’envoi de cette demande ne supprime pas immédiatement votre compte. L’assistance l’examinera et la traitera, et pourra demander des informations supplémentaires. La réponse sera envoyée à l’adresse e-mail associée à votre compte. Le compte n’est pas considéré comme supprimé du seul fait de l’envoi de la demande.';

  @override
  String get noDisplayName => 'Aucun nom affiché';

  @override
  String get subscriptionUnavailable => 'Abonnement indisponible';

  @override
  String get noPaidPlan => 'Aucune formule payante';

  @override
  String requestId(String id) {
    return 'ID de la demande : $id';
  }

  @override
  String statusValue(String status) {
    return 'Statut : $status';
  }

  @override
  String get passwordRecovery => 'Mot de passe et récupération';

  @override
  String get accountEmail => 'E-mail du compte';

  @override
  String get sendingResetInstructions => 'Envoi des instructions...';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get resetCode => 'Code de réinitialisation';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get updatingPassword => 'Mise à jour du mot de passe...';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get newAccountPassword => 'Nouveau mot de passe du compte';

  @override
  String get confirmNewAccountPassword =>
      'Confirmer le nouveau mot de passe du compte';

  @override
  String get changingPassword => 'Modification du mot de passe...';

  @override
  String get changePassword => 'Modifier le mot de passe';

  @override
  String get tutorVoice => 'Voix du tuteur';

  @override
  String speechSpeed(String speed) {
    return 'Vitesse de parole : ${speed}x';
  }

  @override
  String get feedbackSuggestion => 'Suggestion';

  @override
  String get feedbackAppProblem => 'Problème de l’application';

  @override
  String get feedbackAiResponse => 'Réponse de l’IA';

  @override
  String get yourSuggestion => 'Votre suggestion';

  @override
  String get describeProblem => 'Décrivez le problème';

  @override
  String get aiResponseProblem =>
      'Quel était le problème avec la réponse de l’IA ?';

  @override
  String get practiceReminders => 'Rappels de pratique';

  @override
  String get localRemindersDescription =>
      'Ces rappels sont enregistrés uniquement sur cet appareil.';

  @override
  String get dailyPracticeReminders => 'Rappels quotidiens';

  @override
  String get morningReminder => 'Rappel du matin';

  @override
  String get eveningReminder => 'Rappel du soir';

  @override
  String get notificationsAllowed => 'Notifications autorisées';

  @override
  String get notificationStatusUnavailable =>
      'État des notifications indisponible';

  @override
  String get notificationsBlocked =>
      'Les notifications sont bloquées par Android.';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get feedbackReceived => 'Merci. Votre message a bien été reçu.';

  @override
  String get feedbackValidationFailure =>
      'Vérifiez votre message et réessayez.';

  @override
  String get feedbackUnavailable =>
      'Les commentaires sont temporairement indisponibles. Réessayez.';

  @override
  String get deletionRequestAlreadyExists =>
      'Une demande active de suppression du compte existe déjà.';

  @override
  String get deletionRequestSubmitted =>
      'Votre demande de suppression du compte a été transmise à l’assistance.';

  @override
  String get incorrectCurrentPassword =>
      'Votre mot de passe actuel est incorrect.';

  @override
  String get unableToReachService =>
      'Impossible de joindre le service. Réessayez.';

  @override
  String get unexpectedServiceResponse =>
      'Le service a renvoyé une réponse inattendue. Réessayez.';

  @override
  String get unableToSubmitRequest =>
      'Impossible d’envoyer votre demande pour le moment. Réessayez.';

  @override
  String get unableToLoadLearningSettings =>
      'Impossible de charger vos paramètres d’apprentissage. Réessayez.';

  @override
  String get settingsTemporarilyUnavailable =>
      'Les paramètres sont temporairement indisponibles. Réessayez.';

  @override
  String selectedLevelContext(String level) {
    return 'Niveau : $level';
  }

  @override
  String selectedLevelTopicContext(String level, String topic) {
    return 'Niveau : $level / Thème : $topic';
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
    return 'Ouvrir $topic';
  }

  @override
  String openSituationTooltip(String situation) {
    return 'Ouvrir $situation';
  }

  @override
  String get noSituationsAvailable =>
      'Aucune situation n’est disponible pour ce thème.';

  @override
  String get levelA1Label => 'A1 Débutant';

  @override
  String get levelA1Description =>
      'Apprenez des salutations, besoins et réponses quotidiennes simples.';

  @override
  String get levelA2Label => 'A2 Élémentaire';

  @override
  String get levelA2Description =>
      'Gérez des conversations courantes avec des mots et phrases familiers.';

  @override
  String get levelB1Label => 'B1 Intermédiaire';

  @override
  String get levelB1Description =>
      'Pratiquez des échanges plus longs, des opinions et des problèmes quotidiens.';

  @override
  String get levelB2Label => 'B2 Intermédiaire supérieur';

  @override
  String get levelB2Description =>
      'Affinez des conversations nuancées avec des détails plus naturels.';

  @override
  String get topicDailyLifeLabel => 'Vie quotidienne';

  @override
  String get topicDailyLifeDescription =>
      'Petites conversations, présentations et situations quotidiennes.';

  @override
  String get topicTravelLabel => 'Voyage';

  @override
  String get topicTravelDescription =>
      'Aéroports, hôtels, directions et transports.';

  @override
  String get topicWorkBusinessLabel => 'Travail et affaires';

  @override
  String get topicWorkBusinessDescription =>
      'Réunions, e-mails, appels et conversations professionnelles.';

  @override
  String get topicJobInterviewLabel => 'Entretien d’embauche';

  @override
  String get topicJobInterviewDescription =>
      'Pratiquez les questions et réponses d’entretien courantes.';

  @override
  String get topicRestaurantCafeLabel => 'Restaurant et café';

  @override
  String get topicRestaurantCafeDescription =>
      'Commander, réserver une table et formuler des demandes polies.';

  @override
  String get topicFreeConversationLabel => 'Conversation libre';

  @override
  String get topicFreeConversationDescription =>
      'Une pratique ouverte adaptée à ce que vous souhaitez dire.';

  @override
  String get situationIntroductionsLabel => 'Présentations';

  @override
  String get situationIntroductionsDescription =>
      'Présentez-vous et posez des questions personnelles simples.';

  @override
  String get situationSmallTalkNeighborLabel => 'Parler avec un voisin';

  @override
  String get situationSmallTalkNeighborDescription =>
      'Ayez une courte conversation amicale près de chez vous.';

  @override
  String get situationAskingForHelpLabel => 'Demander de l’aide';

  @override
  String get situationAskingForHelpDescription =>
      'Demandez de l’aide dans une situation quotidienne simple.';

  @override
  String get situationMakingPlansLabel => 'Faire des projets';

  @override
  String get situationMakingPlansDescription =>
      'Planifiez une activité et convenez d’une heure et d’un lieu.';

  @override
  String get situationTalkingAboutDayLabel => 'Parler de votre journée';

  @override
  String get situationTalkingAboutDayDescription =>
      'Décrivez votre journée et votre routine quotidienne.';

  @override
  String get situationAirportCheckInLabel => 'Enregistrement à l’aéroport';

  @override
  String get situationAirportCheckInDescription =>
      'Enregistrez-vous pour un vol et confirmez les détails du voyage.';

  @override
  String get situationHotelCheckInLabel => 'Arrivée à l’hôtel';

  @override
  String get situationHotelCheckInDescription =>
      'Enregistrez-vous à l’hôtel et posez des questions courantes.';

  @override
  String get situationAskingForDirectionsLabel => 'Demander son chemin';

  @override
  String get situationAskingForDirectionsDescription =>
      'Demandez et comprenez des indications dans une nouvelle ville.';

  @override
  String get situationOrderingTransportLabel => 'Commander un transport';

  @override
  String get situationOrderingTransportDescription =>
      'Organisez un taxi ou un covoiturage jusqu’à votre destination.';

  @override
  String get situationLostLuggageLabel => 'Bagage perdu';

  @override
  String get situationLostLuggageDescription =>
      'Signalez un bagage perdu et expliquez votre situation.';

  @override
  String get situationFirstMeetingLabel => 'Première réunion';

  @override
  String get situationFirstMeetingDescription =>
      'Présentez-vous lors d’une nouvelle réunion de travail.';

  @override
  String get situationDailyStandupLabel => 'Point quotidien';

  @override
  String get situationDailyStandupDescription =>
      'Donnez une courte mise à jour sur vos tâches.';

  @override
  String get situationClientPhoneCallLabel => 'Appel avec un client';

  @override
  String get situationClientPhoneCallDescription =>
      'Menez un appel professionnel clair et poli.';

  @override
  String get situationAskingForClarificationLabel => 'Demander des précisions';

  @override
  String get situationAskingForClarificationDescription =>
      'Posez des questions de suivi pour confirmer les besoins.';

  @override
  String get situationDiscussingDeadlinesLabel => 'Discuter des délais';

  @override
  String get situationDiscussingDeadlinesDescription =>
      'Parlez des échéances et des attentes de livraison.';

  @override
  String get situationTellMeAboutYourselfLabel => 'Parlez-moi de vous';

  @override
  String get situationTellMeAboutYourselfDescription =>
      'Faites une brève présentation pertinente pour un entretien.';

  @override
  String get situationWorkExperienceLabel => 'Expérience professionnelle';

  @override
  String get situationWorkExperienceDescription =>
      'Décrivez vos emplois précédents, responsabilités et un résultat.';

  @override
  String get situationStrengthsWeaknessesLabel => 'Forces et faiblesses';

  @override
  String get situationStrengthsWeaknessesDescription =>
      'Parlez d’une force et d’un point à améliorer de façon professionnelle.';

  @override
  String get situationWhyThisJobLabel => 'Pourquoi voulez-vous ce poste ?';

  @override
  String get situationWhyThisJobDescription =>
      'Expliquez votre motivation et reliez le poste à vos compétences.';

  @override
  String get situationQuestionsAtEndLabel => 'Questions à la fin';

  @override
  String get situationQuestionsAtEndDescription =>
      'Posez des questions utiles et polies avant la fin de l’entretien.';

  @override
  String get situationBookingTableLabel => 'Réserver une table';

  @override
  String get situationBookingTableDescription =>
      'Appelez ou parlez pour réserver une table.';

  @override
  String get situationOrderingFoodLabel => 'Commander à manger';

  @override
  String get situationOrderingFoodDescription =>
      'Commandez un repas et posez des questions simples sur le menu.';

  @override
  String get situationAskingIngredientsLabel => 'Demander les ingrédients';

  @override
  String get situationAskingIngredientsDescription =>
      'Demandez des informations sur les allergies et les ingrédients.';

  @override
  String get situationWrongOrderLabel => 'Gérer une erreur de commande';

  @override
  String get situationWrongOrderDescription =>
      'Expliquez poliment un problème avec votre commande.';

  @override
  String get situationPayingBillLabel => 'Payer l’addition';

  @override
  String get situationPayingBillDescription =>
      'Demandez l’addition et effectuez le paiement.';

  @override
  String get situationOpenConversationLabel => 'Conversation ouverte';

  @override
  String get situationOpenConversationDescription =>
      'Pratiquez n’importe quel sujet avec des relances flexibles.';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatusLoadingSemantics => 'Chargement du statut Premium';

  @override
  String get premiumStatusTemporarilyUnavailable =>
      'Le statut Premium est temporairement indisponible. Réessayez.';

  @override
  String premiumStatusSemantics(String status) {
    return 'Statut Premium : $status';
  }

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get premiumActiveDescription =>
      'Entraînez-vous sans limite quotidienne de leçons gratuites.';

  @override
  String premiumEndsOn(String date) {
    return 'Premium se termine le $date.';
  }

  @override
  String get premiumTrialActiveDescription => 'Votre essai Premium est actif.';

  @override
  String premiumTrialEndsOn(String date) {
    return 'L’essai Premium se termine le $date.';
  }

  @override
  String freeLessonsRemainingToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il reste $count leçons gratuites aujourd’hui.',
      one: 'Il reste 1 leçon gratuite aujourd’hui.',
      zero: 'Aucune leçon gratuite ne reste aujourd’hui.',
    );
    return '$_temp0';
  }

  @override
  String get premiumRemovesDailyLimit =>
      'Premium supprime la limite quotidienne de leçons.';

  @override
  String get premiumAccountLinked =>
      'L’accès Premium est lié à votre compte Language Voice Tutor.';

  @override
  String get premiumSharedAcrossClients =>
      'Votre statut Premium confirmé est partagé entre les clients Language Voice Tutor pris en charge.';

  @override
  String get premiumBenefits => 'Avantages Premium';

  @override
  String get premiumBenefitDailyLimit =>
      '• Entraînez-vous sans plafond quotidien de leçons gratuites';

  @override
  String get premiumBenefitAcrossDevices =>
      '• Utilisez le même accès Premium sur les appareils pris en charge';

  @override
  String get premiumBenefitAccountData =>
      '• Gardez ensemble votre compte, votre progression, votre historique et vos réglages d’apprentissage';

  @override
  String get getPremium => 'Obtenir Premium';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get refreshPremiumStatus => 'Actualiser le statut';

  @override
  String get billingProviderExplanation =>
      'Les changements de facturation doivent être gérés auprès du fournisseur où Premium a été acheté.';

  @override
  String get googlePlayPurchasesUnavailableTitle =>
      'Les achats Google Play sont temporairement indisponibles';

  @override
  String get restorePurchasesUnavailableTitle =>
      'La restauration des achats Google Play est temporairement indisponible';

  @override
  String get googlePlayPurchasesUnavailableDescription =>
      'Les achats Google Play sont temporairement indisponibles. Réessayez plus tard.';

  @override
  String get restorePurchasesUnavailableDescription =>
      'La restauration des achats Google Play est temporairement indisponible. Réessayez plus tard.';

  @override
  String get purchasePendingConfirmation =>
      'Le traitement de l’achat n’est pas encore confirmé. Actualisez bientôt votre statut.';

  @override
  String get purchaseActionFailed =>
      'Impossible de terminer cette demande pour le moment. Réessayez.';

  @override
  String get premiumOk => 'Fermer';

  @override
  String get leaveLessonTitle => 'Quitter la leçon ?';

  @override
  String get leaveLessonDescription =>
      'Quitter met fin à cette leçon inachevée sans créer de résumé.';

  @override
  String get stay => 'Rester';

  @override
  String get leaveLesson => 'Quitter la leçon';

  @override
  String get finishLessonTitle => 'Terminer la leçon ?';

  @override
  String get finishLessonDescription =>
      'Terminer cette leçon et voir votre résumé ?';

  @override
  String get continueLesson => 'Continuer la leçon';

  @override
  String get gettingHint => 'Recherche d’un indice...';

  @override
  String get dismissHint => 'Fermer l’indice';

  @override
  String get finishingLesson => 'Fin de la leçon...';

  @override
  String get finishLessonAuthRequired =>
      'Reconnectez-vous pour terminer la leçon.';

  @override
  String get finishLessonSessionUnavailable =>
      'Cette session de leçon n’est plus disponible.';

  @override
  String get finishLessonFailed =>
      'Impossible de terminer la leçon. Vérifiez votre connexion et réessayez.';

  @override
  String get lessonFeedback => 'Commentaires';

  @override
  String get loadingLessonFeedback => 'Chargement des commentaires...';

  @override
  String get showLessonFeedback => 'Afficher les commentaires';

  @override
  String get hideLessonFeedback => 'Masquer les commentaires';

  @override
  String get retryLessonFeedback => 'Réessayer les commentaires';

  @override
  String get feedbackNotReady =>
      'Les commentaires ne sont pas encore prêts. Réessayez.';

  @override
  String get feedbackQuickSummary => 'Bref résumé';

  @override
  String get feedbackCorrectedVersion => 'Version corrigée';

  @override
  String get feedbackGrammarTip => 'Conseil de grammaire';

  @override
  String get feedbackVocabularyTip => 'Conseil de vocabulaire';

  @override
  String get feedbackCultureTip => 'Conseil culturel';

  @override
  String get feedbackNaturalVersion => 'Version plus naturelle';

  @override
  String get lessonFeedbackAuthRequired =>
      'Reconnectez-vous pour continuer la leçon.';

  @override
  String get lessonFeedbackSessionEnded => 'Cette leçon est déjà terminée.';

  @override
  String get lessonFeedbackNotAvailableForMessage =>
      'Les commentaires ne sont pas disponibles pour ce message.';

  @override
  String get lessonFeedbackFailed =>
      'Impossible d’obtenir les commentaires. Réessayez.';

  @override
  String get lessonStartBlocked =>
      'Vous avez déjà utilisé la leçon gratuite d’aujourd’hui. Réessayez demain ou passez à Premium.';

  @override
  String get lessonStartConflict =>
      'Vous avez déjà une leçon active. Terminez-la ou quittez-la avant d’en commencer une autre.';

  @override
  String get lessonStartAuthRequired =>
      'Reconnectez-vous pour commencer une leçon.';

  @override
  String get lessonStartUnavailable =>
      'Impossible de démarrer la leçon. Vérifiez votre connexion et réessayez.';

  @override
  String get lessonStartFailed => 'Impossible de démarrer la leçon. Réessayez.';

  @override
  String get lessonSummary => 'Résumé de la leçon';

  @override
  String get lessonCompleted => 'Leçon terminée';

  @override
  String get summaryWhatWentWell => 'Ce qui s’est bien passé';

  @override
  String get summaryStrengths => 'Points forts';

  @override
  String get summaryImprovements => 'Points à améliorer';

  @override
  String get summaryVocabulary => 'Vocabulaire';

  @override
  String get summaryGrammar => 'Grammaire';

  @override
  String get summaryNextSteps => 'Prochaines étapes';

  @override
  String get retrySummary => 'Réessayer le résumé';

  @override
  String get summaryUnavailableMessage =>
      'Votre leçon a été enregistrée, mais il n’a pas été possible de créer un résumé pour cette leçon.';

  @override
  String get summaryAuthRequiredMessage =>
      'Reconnectez-vous pour charger le résumé de votre leçon.';

  @override
  String get summaryLoadErrorMessage =>
      'Votre leçon a été enregistrée, mais le résumé ne peut pas être chargé pour le moment.';

  @override
  String get startRecording => 'Commencer l’enregistrement';

  @override
  String get stopRecording => 'Arrêter l’enregistrement';

  @override
  String get progressCompletedLessons => 'Leçons terminées';

  @override
  String get progressAllTime => 'Depuis le début';

  @override
  String get progressLast7Days => '7 derniers jours';

  @override
  String get progressLast30Days => '30 derniers jours';

  @override
  String get progressCurrentStreak => 'Série actuelle';

  @override
  String get progressLongestStreak => 'Plus longue série';

  @override
  String get progressRecentActivity => 'Activité récente';

  @override
  String get progressLastCompletedLesson => 'Dernière leçon terminée';

  @override
  String get progressLessonsByLanguage => 'Leçons par langue';

  @override
  String get progressLessonsByLevel => 'Leçons par niveau';

  @override
  String get progressEmptyTitle => 'Votre progression apparaîtra ici';

  @override
  String get progressEmptyDescription =>
      'Les leçons terminées apparaîtront ici après avoir terminé une leçon.';

  @override
  String get progressUnavailable =>
      'La progression est temporairement indisponible. Réessayez.';

  @override
  String get progressLoadFailed =>
      'Impossible de charger la progression. Réessayez.';

  @override
  String progressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: '0 jour',
    );
    return '$_temp0';
  }

  @override
  String get achievementsLoadFailed =>
      'Impossible de charger les succès. Réessayez.';

  @override
  String achievementUnlockedSemantics(String title) {
    return 'Succès déverrouillé : $title';
  }

  @override
  String achievementLockedSemantics(String title, num current, num target) {
    return 'Succès verrouillé : $title. Progression : $current sur $target.';
  }

  @override
  String closeAchievementPreview(String title) {
    return 'Fermer l’aperçu du succès $title';
  }

  @override
  String get closeAllAchievementPreviews => 'Fermer tous les aperçus de succès';

  @override
  String get achievementTitleStreak7 => 'Série de 7 jours';

  @override
  String get achievementTitleStreak30 => 'Série de 30 jours';

  @override
  String get achievementTitleStreak60 => 'Série de 60 jours';

  @override
  String get achievementTitleStreak100 => 'Série de 100 jours';

  @override
  String get achievementTitleStreak365 => 'Série de 365 jours';

  @override
  String get achievementTitleLessons1 => 'Premier pas';

  @override
  String get achievementTitleLessons5 => 'Bien commencé';

  @override
  String get achievementTitleLessons10 => '10 leçons réussies';

  @override
  String get achievementTitleLessons25 => 'Apprenant régulier';

  @override
  String get achievementTitleLessons50 => '50 leçons réussies';

  @override
  String get achievementTitleLessons100 => 'Club des 100';

  @override
  String get achievementTitleDailyLifeIntroductions => 'Premier bonjour';

  @override
  String get achievementTitleDailyLifeNeighborChat => 'Discussion de voisinage';

  @override
  String get achievementTitleDailyLifeHelpfulHand => 'Coup de main';

  @override
  String get achievementTitleDailyLifePlanMaker => 'Créateur de plans';

  @override
  String get achievementTitleDailyLifeDayTeller => 'Récit du jour';

  @override
  String get achievementTitleDailyLifeEverydayHero => 'Héros du quotidien';

  @override
  String get achievementTitleTravelAirportExpert => 'Expert d’aéroport';

  @override
  String get achievementTitleTravelHonoredGuest => 'Invité d’honneur';

  @override
  String get achievementTitleTravelCityNavigator => 'Navigateur urbain';

  @override
  String get achievementTitleTravelRideReady => 'Prêt à partir';

  @override
  String get achievementTitleTravelBaggageFinder => 'Chercheur de bagages';

  @override
  String get achievementTitleTravelTraveler => 'Voyageur';

  @override
  String get achievementTitleWorkMeetingReady => 'Prêt pour la réunion';

  @override
  String get achievementTitleWorkStandupStar => 'Star du point quotidien';

  @override
  String get achievementTitleWorkClientCaller => 'Appel client';

  @override
  String get achievementTitleWorkClearCommunicator => 'Communication claire';

  @override
  String get achievementTitleWorkDeadlineDriver => 'Maître des délais';

  @override
  String get achievementTitleWorkBusinessReady => 'Prêt pour les affaires';

  @override
  String get achievementTitleInterviewStrongIntroduction =>
      'Présentation assurée';

  @override
  String get achievementTitleInterviewCareerStory => 'Parcours professionnel';

  @override
  String get achievementTitleInterviewSelfAwareCandidate => 'Candidat lucide';

  @override
  String get achievementTitleInterviewRightFit => 'Le bon profil';

  @override
  String get achievementTitleInterviewCuriousCandidate => 'Candidat curieux';

  @override
  String get achievementTitleInterviewReady => 'Prêt pour l’entretien';

  @override
  String get achievementTitleRestaurantTableBooker => 'Réservation de table';

  @override
  String get achievementTitleRestaurantMenuExpert => 'Expert du menu';

  @override
  String get achievementTitleRestaurantIngredientGuide =>
      'Guide des ingrédients';

  @override
  String get achievementTitleRestaurantOrderFixer => 'Correcteur de commande';

  @override
  String get achievementTitleRestaurantBillSettled => 'Addition réglée';

  @override
  String get achievementTitleRestaurantDiningPro => 'Pro de la restauration';

  @override
  String get autoSendMessage => 'Auto-send message';

  @override
  String get autoPlayTutorVoice => 'Auto-play tutor voice';

  @override
  String get voiceRecognitionUnclear =>
      'Je n’ai pas pu reconnaître cela clairement. Réessayez.';

  @override
  String get microphoneBlockedOpenSettings =>
      'L’accès au microphone est bloqué. Ouvrez les paramètres Android pour l’activer.';

  @override
  String get microphonePermissionDeniedRetry =>
      'L’accès au microphone n’a pas été accordé. Touchez le microphone pour réessayer.';

  @override
  String get recordingStartFailedCheckMicrophone =>
      'Impossible de démarrer l’enregistrement. Vérifiez votre microphone.';

  @override
  String get recordingStartFailed =>
      'Impossible de démarrer l’enregistrement. Réessayez.';

  @override
  String get recordingTooShort => 'Enregistrez une réponse un peu plus longue.';

  @override
  String get recordingStopFailed =>
      'Impossible d’arrêter l’enregistrement. Réessayez.';

  @override
  String get recordingProcessingFailed =>
      'Impossible de traiter cet enregistrement. Réessayez.';

  @override
  String get recordingAuthRequired =>
      'Reconnectez-vous pour utiliser l’enregistrement.';

  @override
  String get transcriptionTemporarilyUnavailable =>
      'La transcription est temporairement indisponible. Réessayez bientôt.';

  @override
  String get transcriptionTimedOut =>
      'La transcription a pris trop de temps. Réessayez.';

  @override
  String get transcriptionConnectionFailed =>
      'La connexion a échoué pendant la transcription. Réessayez.';

  @override
  String get transcriptionFailed =>
      'Impossible de transcrire cet enregistrement. Réessayez.';

  @override
  String get voiceTemporarilyUnavailable =>
      'La voix est temporairement indisponible. Réessayez bientôt.';

  @override
  String get voicePlaybackFailed => 'Impossible de lire la voix. Réessayez.';

  @override
  String get voicePlaybackTimedOut =>
      'La lecture de la voix a pris trop de temps. Réessayez.';

  @override
  String get voicePlaybackStopped =>
      'La lecture de la voix s’est arrêtée. Vous pouvez enregistrer à nouveau.';

  @override
  String get replaceTypedTextTitle => 'Remplacer le texte saisi ?';

  @override
  String get replaceTypedTextDescription =>
      'Utiliser l’enregistrement transcrit à la place de votre brouillon saisi ?';

  @override
  String get keepTypedText => 'Conserver le texte saisi';

  @override
  String get replaceTypedText => 'Remplacer le texte saisi';

  @override
  String get transcribingRecording => 'Transcription de l’enregistrement...';

  @override
  String get retryLessonContent =>
      'Réessayer de charger le contenu de la leçon';

  @override
  String get translation => 'Traduction';

  @override
  String get playVoice => 'Lire la voix';

  @override
  String get openConversationMode => 'Ouvrir le mode conversation';

  @override
  String get conversationPaused =>
      'Conversation en pause. Vous pouvez enregistrer à nouveau.';

  @override
  String get tutorReplyTimedOut =>
      'Le tuteur a mis trop de temps à répondre. Réessayez.';

  @override
  String get conversationSendFailed =>
      'Impossible d’envoyer cette réponse. Essayez d’enregistrer à nouveau.';

  @override
  String get openAndroidSettingsFailed =>
      'Impossible d’ouvrir les paramètres Android. Réessayez.';

  @override
  String get conversationReady => 'Votre conversation est prête.';

  @override
  String get tutorAvatarSemantics => 'Avatar du tuteur';

  @override
  String get lessonContentLoadFailed =>
      'Impossible de charger le contenu de la leçon. Réessayez.';

  @override
  String get lessonHistoryDetails => 'Détails de la leçon';

  @override
  String get historySummary => 'Résumé';

  @override
  String get noHistoryConversation =>
      'Aucune conversation n’est disponible pour cette leçon.';

  @override
  String get noHistorySummary =>
      'Aucun résumé n’est disponible pour cette leçon.';

  @override
  String get overallSummary => 'Résumé général';

  @override
  String get historyTutor => 'Tuteur';

  @override
  String get historyYou => 'Vous';

  @override
  String get feedbackCorrectedText => 'Texte corrigé';

  @override
  String get feedbackExplanation => 'Explication';

  @override
  String get feedbackPraise => 'Encouragement';

  @override
  String get lessonUnavailable => 'Cette leçon n’est pas disponible.';

  @override
  String get lessonNoLongerAvailable => 'Cette leçon n’est plus disponible.';

  @override
  String get lessonHistoryUnavailable =>
      'L’historique des leçons est temporairement indisponible. Réessayez.';

  @override
  String get lessonDetailLoadFailed =>
      'Impossible de charger les détails de la leçon. Réessayez.';
}
