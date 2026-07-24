// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Language Voice Tutor';

  @override
  String get settings => 'Configuración';

  @override
  String get profile => 'Perfil';

  @override
  String get app => 'Aplicación';

  @override
  String get saveSettings => 'Guardar configuración';

  @override
  String get saving => 'Guardando...';

  @override
  String get settingsSaved => 'Configuración guardada.';

  @override
  String get unableToSaveSettings => 'No se pudo guardar la configuración.';

  @override
  String get learning => 'Aprendizaje';

  @override
  String get studyLanguage => 'Idioma de estudio';

  @override
  String get nativeLanguage => 'Idioma nativo';

  @override
  String get interfaceLanguage => 'Idioma de la interfaz';

  @override
  String get interfaceExplanationLanguage =>
      'Idioma de la interfaz / explicaciones';

  @override
  String get interfaceLanguageDescription =>
      'Solo cambia el idioma de la interfaz de la aplicación.';

  @override
  String get currentLevel => 'Nivel actual';

  @override
  String get selectedTutor => 'Tutor seleccionado';

  @override
  String get loadingSettings => 'Cargando configuración...';

  @override
  String get unableToLoadSettings => 'No se pudo cargar la configuración.';

  @override
  String get retry => 'Reintentar';

  @override
  String get back => 'Atrás';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get displayNameOptional => 'Nombre visible (opcional)';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get unableToCheckSession =>
      'No se pudo comprobar la sesión. Inténtalo de nuevo.';

  @override
  String get lessons => 'Lecciones';

  @override
  String get lessonHistory => 'Historial de lecciones';

  @override
  String get progress => 'Progreso';

  @override
  String get rewards => 'Recompensas';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get achievements => 'Logros';

  @override
  String get account => 'Cuenta';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get audio => 'Audio';

  @override
  String get feedbackAndReports => 'Comentarios e informes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get submit => 'Enviar';

  @override
  String get send => 'Enviar';

  @override
  String get done => 'Listo';

  @override
  String get openAndroidSettings => 'Abrir ajustes de Android';

  @override
  String get hint => 'Pista';

  @override
  String get finishLesson => 'Terminar lección';

  @override
  String get typeYourMessage => 'Escribe tu mensaje';

  @override
  String get sending => 'Enviando...';

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
  String get signInToApp => 'Inicia sesión en Language Voice Tutor';

  @override
  String get pleaseWait => 'Espera...';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get invalidEmail => 'Introduce una dirección de correo válida.';

  @override
  String get enterPassword => 'Introduce tu contraseña.';

  @override
  String get chooseTopic => 'Elegir tema';

  @override
  String get chooseTopicTitle => 'Elige un tema';

  @override
  String get chooseTopicSubtitle =>
      'Elige el tipo de conversación que quieres practicar.';

  @override
  String get chooseSituation => 'Elegir situación';

  @override
  String get chooseSituationTitle => 'Elige una situación';

  @override
  String get chooseSituationSubtitle =>
      'Practica un momento concreto de este tema.';

  @override
  String get viewAllRewards => 'Ver todas las insignias y recompensas';

  @override
  String get accountDeletion => 'Eliminar cuenta';

  @override
  String get requestAccountDeletion => 'Solicitar eliminación de cuenta';

  @override
  String get loadingAccount => 'Cargando cuenta...';

  @override
  String get premiumAndSubscription => 'Premium y suscripción';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get submitting => 'Enviando...';

  @override
  String get loadingTutors => 'Cargando tutores...';

  @override
  String get noTutorsAvailable => 'No hay tutores disponibles ahora.';

  @override
  String get loadingAudioSettings => 'Cargando ajustes de audio...';

  @override
  String get conversationModeEnabled => 'Modo conversación activado';

  @override
  String get sendSuggestionOrReport =>
      'Envía una sugerencia o informa de un problema';

  @override
  String get reportType => 'Tipo de informe';

  @override
  String get pasteAiResponseOptional => 'Pega la respuesta de IA (opcional)';

  @override
  String get lessonHistoryHeading => 'Tus lecciones terminadas recientemente';

  @override
  String get noCompletedLessons => 'Aún no hay lecciones terminadas';

  @override
  String get completedLessonsAppearHere =>
      'Aquí aparecerán las lecciones terminadas.';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get lesson => 'Lección';

  @override
  String get level => 'Nivel';

  @override
  String get completed => 'Completada';

  @override
  String get finished => 'Terminada';

  @override
  String get lessonChat => 'Chat de la lección';

  @override
  String get conversation => 'Conversación';

  @override
  String turnCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count turnos',
      one: '1 turno',
    );
    return '$_temp0';
  }

  @override
  String get achievementsUnavailable => 'Aún no hay logros disponibles.';

  @override
  String unlockedCount(num unlocked, num total) {
    return '$unlocked de $total desbloqueados';
  }

  @override
  String learningLanguage(String language) {
    return 'Aprendiendo $language';
  }

  @override
  String get streaks => 'Rachas';

  @override
  String get lessonMilestones => 'Hitos de lecciones';

  @override
  String get topics => 'Temas';

  @override
  String get situations => 'Situaciones';

  @override
  String get otherAchievements => 'Otros logros';

  @override
  String progressCount(num current, num total) {
    return '$current de $total';
  }

  @override
  String get startLesson => 'Empezar lección';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get keepLearningRhythm => 'Mantén tu ritmo de aprendizaje';

  @override
  String get reminderPermissionExplanation =>
      'Language Voice Tutor puede enviar dos recordatorios diarios para que practiques incluso en días ocupados. Puedes cambiar las horas o desactivarlos en Configuración.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get allowReminders => 'Permitir recordatorios';

  @override
  String get achievementsTemporarilyUnavailable =>
      'Los logros no están disponibles temporalmente';

  @override
  String get achievementsEmpty => 'Aquí aparecerán tus logros.';

  @override
  String learningStreak(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de aprendizaje de $count días',
      one: 'Racha de aprendizaje de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get learningStreakLoading => 'Cargando la racha de aprendizaje';

  @override
  String get learningStreakUnavailable =>
      'La racha de aprendizaje no está disponible';

  @override
  String get learnerFallbackName => 'Estudiante';

  @override
  String get premiumPlan => 'Plan Premium';

  @override
  String get premiumTrial => 'Prueba Premium';

  @override
  String get freePlan => 'Plan gratuito';

  @override
  String signedInAs(String name) {
    return 'Sesión iniciada como $name';
  }

  @override
  String get premiumDetails => 'Detalles de Premium';

  @override
  String get explorePremium => 'Descubrir Premium';

  @override
  String freeLessonsAvailableToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lecciones gratuitas disponibles hoy',
      one: '1 lección gratuita disponible hoy',
    );
    return '$_temp0';
  }

  @override
  String get yourWeek => 'Tu semana';

  @override
  String lessonsLastSevenDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lecciones en los últimos 7 días',
      one: '1 lección en los últimos 7 días',
    );
    return '$_temp0';
  }

  @override
  String get startStreakToday => 'Empieza tu racha hoy';

  @override
  String get activityUnavailable => 'La actividad no está disponible ahora.';

  @override
  String lessonsCompleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lecciones completadas',
      one: '1 lección completada',
    );
    return '$_temp0';
  }

  @override
  String activityDaySemantics(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lecciones completadas',
      one: '1 lección completada',
    );
    return '$date: $_temp0';
  }

  @override
  String get weekdayMon => 'Lun';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mié';

  @override
  String get weekdayThu => 'Jue';

  @override
  String get weekdayFri => 'Vie';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get remindersTemporarilyUnavailable =>
      'Los recordatorios no están disponibles temporalmente.';

  @override
  String get unableToUpdateReminders =>
      'No se pudieron actualizar los recordatorios. Inténtalo de nuevo.';

  @override
  String get unableToLoadAccount =>
      'No se pudieron cargar los datos de la cuenta.';

  @override
  String get tutorChoicesUnavailable =>
      'Los tutores no están disponibles ahora. Puedes revisar y guardar los demás ajustes.';

  @override
  String get pleaseEnterDescription => 'Introduce una descripción.';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio.';

  @override
  String get resetCodePasswordRequired =>
      'Se requieren el código de restablecimiento y la contraseña nueva.';

  @override
  String get passwordsMustMatch =>
      'La contraseña nueva y su confirmación deben coincidir.';

  @override
  String get signInToChangePassword =>
      'Inicia sesión para cambiar la contraseña.';

  @override
  String get currentPasswordRequired => 'La contraseña actual es obligatoria.';

  @override
  String get accountDeletionDescription =>
      'Envía una solicitud para eliminar permanentemente tu cuenta de Language Voice Tutor y tus datos personales.';

  @override
  String get accountDeletionNotice =>
      'Enviar esta solicitud no elimina tu cuenta de inmediato. El equipo de soporte la revisará y procesará, y puede pedir más información. La respuesta se enviará al correo asociado a tu cuenta. La cuenta no se considera eliminada solo por haber enviado la solicitud.';

  @override
  String get noDisplayName => 'Sin nombre visible';

  @override
  String get subscriptionUnavailable => 'Suscripción no disponible';

  @override
  String get noPaidPlan => 'Sin plan de pago';

  @override
  String requestId(String id) {
    return 'ID de solicitud: $id';
  }

  @override
  String statusValue(String status) {
    return 'Estado: $status';
  }

  @override
  String get passwordRecovery => 'Contraseña y recuperación';

  @override
  String get accountEmail => 'Correo de la cuenta';

  @override
  String get sendingResetInstructions => 'Enviando instrucciones...';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get resetCode => 'Código de restablecimiento';

  @override
  String get newPassword => 'Contraseña nueva';

  @override
  String get confirmNewPassword => 'Confirmar contraseña nueva';

  @override
  String get updatingPassword => 'Actualizando contraseña...';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get newAccountPassword => 'Contraseña nueva de la cuenta';

  @override
  String get confirmNewAccountPassword =>
      'Confirmar contraseña nueva de la cuenta';

  @override
  String get changingPassword => 'Cambiando contraseña...';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get tutorVoice => 'Voz del tutor';

  @override
  String speechSpeed(String speed) {
    return 'Velocidad de voz: ${speed}x';
  }

  @override
  String get feedbackSuggestion => 'Sugerencia';

  @override
  String get feedbackAppProblem => 'Problema de la aplicación';

  @override
  String get feedbackAiResponse => 'Respuesta de IA';

  @override
  String get yourSuggestion => 'Tu sugerencia';

  @override
  String get describeProblem => 'Describe el problema';

  @override
  String get aiResponseProblem =>
      '¿Qué tenía de incorrecto la respuesta de IA?';

  @override
  String get practiceReminders => 'Recordatorios de práctica';

  @override
  String get localRemindersDescription =>
      'Estos recordatorios solo se guardan en este dispositivo.';

  @override
  String get dailyPracticeReminders => 'Recordatorios diarios';

  @override
  String get morningReminder => 'Recordatorio matutino';

  @override
  String get eveningReminder => 'Recordatorio vespertino';

  @override
  String get notificationsAllowed => 'Notificaciones permitidas';

  @override
  String get notificationStatusUnavailable =>
      'Estado de notificaciones no disponible';

  @override
  String get notificationsBlocked => 'Android ha bloqueado las notificaciones.';

  @override
  String get allowNotifications => 'Permitir notificaciones';

  @override
  String get feedbackReceived => 'Gracias. Hemos recibido tu mensaje.';

  @override
  String get feedbackValidationFailure =>
      'Comprueba el mensaje e inténtalo de nuevo.';

  @override
  String get feedbackUnavailable =>
      'Los comentarios no están disponibles temporalmente. Inténtalo de nuevo.';

  @override
  String get deletionRequestAlreadyExists =>
      'Ya existe una solicitud activa para eliminar la cuenta.';

  @override
  String get deletionRequestSubmitted =>
      'La solicitud para eliminar la cuenta se ha enviado al equipo de soporte.';

  @override
  String get incorrectCurrentPassword => 'La contraseña actual es incorrecta.';

  @override
  String get unableToReachService =>
      'No se pudo contactar con el servicio. Inténtalo de nuevo.';

  @override
  String get unexpectedServiceResponse =>
      'El servicio devolvió una respuesta inesperada. Inténtalo de nuevo.';

  @override
  String get unableToSubmitRequest =>
      'No se pudo enviar la solicitud. Inténtalo de nuevo.';

  @override
  String get unableToLoadLearningSettings =>
      'No se pudieron cargar los ajustes de aprendizaje. Inténtalo de nuevo.';

  @override
  String get settingsTemporarilyUnavailable =>
      'La configuración no está disponible temporalmente. Inténtalo de nuevo.';

  @override
  String selectedLevelContext(String level) {
    return 'Nivel: $level';
  }

  @override
  String selectedLevelTopicContext(String level, String topic) {
    return 'Nivel: $level / Tema: $topic';
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
      'No hay situaciones disponibles para este tema.';

  @override
  String get levelA1Label => 'A1 Principiante';

  @override
  String get levelA1Description =>
      'Practica saludos, necesidades y respuestas cotidianas sencillas.';

  @override
  String get levelA2Label => 'A2 Elemental';

  @override
  String get levelA2Description =>
      'Mantén conversaciones habituales con palabras y frases conocidas.';

  @override
  String get levelB1Label => 'B1 Intermedio';

  @override
  String get levelB1Description =>
      'Practica intercambios más largos, opiniones y problemas cotidianos.';

  @override
  String get levelB2Label => 'B2 Intermedio alto';

  @override
  String get levelB2Description =>
      'Perfecciona conversaciones matizadas con detalles más naturales.';

  @override
  String get topicDailyLifeLabel => 'Vida diaria';

  @override
  String get topicDailyLifeDescription =>
      'Charla informal, presentaciones y situaciones diarias.';

  @override
  String get topicTravelLabel => 'Viajes';

  @override
  String get topicTravelDescription =>
      'Aeropuertos, hoteles, direcciones y transporte.';

  @override
  String get topicWorkBusinessLabel => 'Trabajo y negocios';

  @override
  String get topicWorkBusinessDescription =>
      'Reuniones, correos, llamadas y conversaciones de trabajo.';

  @override
  String get topicJobInterviewLabel => 'Entrevista de trabajo';

  @override
  String get topicJobInterviewDescription =>
      'Practica preguntas y respuestas habituales.';

  @override
  String get topicRestaurantCafeLabel => 'Restaurante y cafetería';

  @override
  String get topicRestaurantCafeDescription =>
      'Pedir comida, reservar mesa y hacer peticiones educadas.';

  @override
  String get topicFreeConversationLabel => 'Conversación libre';

  @override
  String get topicFreeConversationDescription =>
      'Práctica abierta adaptada a lo que quieras decir.';

  @override
  String get situationIntroductionsLabel => 'Presentaciones';

  @override
  String get situationIntroductionsDescription =>
      'Preséntate y haz preguntas personales básicas.';

  @override
  String get situationSmallTalkNeighborLabel => 'Hablar con un vecino';

  @override
  String get situationSmallTalkNeighborDescription =>
      'Ten una conversación breve y amable cerca de casa.';

  @override
  String get situationAskingForHelpLabel => 'Pedir ayuda';

  @override
  String get situationAskingForHelpDescription =>
      'Pide ayuda en una situación cotidiana sencilla.';

  @override
  String get situationMakingPlansLabel => 'Hacer planes';

  @override
  String get situationMakingPlansDescription =>
      'Planifica una actividad y acuerda hora y lugar.';

  @override
  String get situationTalkingAboutDayLabel => 'Hablar de tu día';

  @override
  String get situationTalkingAboutDayDescription =>
      'Describe tu día y tu rutina diaria.';

  @override
  String get situationAirportCheckInLabel => 'Facturación en el aeropuerto';

  @override
  String get situationAirportCheckInDescription =>
      'Factura para un vuelo y confirma los detalles del viaje.';

  @override
  String get situationHotelCheckInLabel => 'Registro en el hotel';

  @override
  String get situationHotelCheckInDescription =>
      'Regístrate en un hotel y haz preguntas comunes.';

  @override
  String get situationAskingForDirectionsLabel => 'Pedir indicaciones';

  @override
  String get situationAskingForDirectionsDescription =>
      'Pide y entiende indicaciones en una ciudad nueva.';

  @override
  String get situationOrderingTransportLabel => 'Pedir transporte';

  @override
  String get situationOrderingTransportDescription =>
      'Organiza un taxi o transporte compartido hasta tu destino.';

  @override
  String get situationLostLuggageLabel => 'Equipaje perdido';

  @override
  String get situationLostLuggageDescription =>
      'Informa de equipaje perdido y explica tu situación.';

  @override
  String get situationFirstMeetingLabel => 'Primera reunión';

  @override
  String get situationFirstMeetingDescription =>
      'Preséntate en una nueva reunión de trabajo.';

  @override
  String get situationDailyStandupLabel => 'Reunión diaria';

  @override
  String get situationDailyStandupDescription =>
      'Da una breve actualización sobre tus tareas.';

  @override
  String get situationClientPhoneCallLabel => 'Llamada con un cliente';

  @override
  String get situationClientPhoneCallDescription =>
      'Maneja una llamada de negocios clara y cortés.';

  @override
  String get situationAskingForClarificationLabel => 'Pedir aclaraciones';

  @override
  String get situationAskingForClarificationDescription =>
      'Haz preguntas de seguimiento para confirmar requisitos.';

  @override
  String get situationDiscussingDeadlinesLabel => 'Hablar de plazos';

  @override
  String get situationDiscussingDeadlinesDescription =>
      'Habla sobre tiempos y expectativas de entrega.';

  @override
  String get situationTellMeAboutYourselfLabel => 'Háblame de ti';

  @override
  String get situationTellMeAboutYourselfDescription =>
      'Da una presentación breve y relevante para una entrevista.';

  @override
  String get situationWorkExperienceLabel => 'Experiencia laboral';

  @override
  String get situationWorkExperienceDescription =>
      'Describe trabajos anteriores, responsabilidades y un resultado.';

  @override
  String get situationStrengthsWeaknessesLabel => 'Fortalezas y debilidades';

  @override
  String get situationStrengthsWeaknessesDescription =>
      'Habla profesionalmente de una fortaleza y un área de mejora.';

  @override
  String get situationWhyThisJobLabel => '¿Por qué quieres este trabajo?';

  @override
  String get situationWhyThisJobDescription =>
      'Explica tu motivación y conecta el puesto con tus habilidades.';

  @override
  String get situationQuestionsAtEndLabel => 'Preguntas al final';

  @override
  String get situationQuestionsAtEndDescription =>
      'Haz preguntas útiles y corteses antes de terminar la entrevista.';

  @override
  String get situationBookingTableLabel => 'Reservar una mesa';

  @override
  String get situationBookingTableDescription =>
      'Llama o habla para reservar una mesa.';

  @override
  String get situationOrderingFoodLabel => 'Pedir comida';

  @override
  String get situationOrderingFoodDescription =>
      'Pide una comida y haz preguntas sencillas sobre el menú.';

  @override
  String get situationAskingIngredientsLabel => 'Preguntar por ingredientes';

  @override
  String get situationAskingIngredientsDescription =>
      'Pregunta por alergias e ingredientes de los platos.';

  @override
  String get situationWrongOrderLabel => 'Resolver un pedido incorrecto';

  @override
  String get situationWrongOrderDescription =>
      'Explica cortésmente un problema con tu pedido.';

  @override
  String get situationPayingBillLabel => 'Pagar la cuenta';

  @override
  String get situationPayingBillDescription =>
      'Pide la cuenta y completa el pago.';

  @override
  String get situationOpenConversationLabel => 'Conversación abierta';

  @override
  String get situationOpenConversationDescription =>
      'Practica cualquier tema con preguntas de seguimiento flexibles.';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatusLoadingSemantics => 'Cargando el estado de Premium';

  @override
  String get premiumStatusTemporarilyUnavailable =>
      'El estado de Premium no está disponible temporalmente. Inténtalo de nuevo.';

  @override
  String premiumStatusSemantics(String status) {
    return 'Estado de Premium: $status';
  }

  @override
  String get premiumActive => 'Premium activo';

  @override
  String get premiumActiveDescription =>
      'Practica sin el límite diario de lecciones gratuitas.';

  @override
  String premiumEndsOn(String date) {
    return 'Premium termina el $date.';
  }

  @override
  String get premiumTrialActiveDescription =>
      'Tu prueba de Premium está activa.';

  @override
  String premiumTrialEndsOn(String date) {
    return 'La prueba de Premium termina el $date.';
  }

  @override
  String freeLessonsRemainingToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count lecciones gratuitas hoy.',
      one: 'Queda 1 lección gratuita hoy.',
      zero: 'No quedan lecciones gratuitas hoy.',
    );
    return '$_temp0';
  }

  @override
  String get premiumRemovesDailyLimit =>
      'Premium elimina el límite diario de lecciones.';

  @override
  String get premiumAccountLinked =>
      'El acceso a Premium está vinculado a tu cuenta de Language Voice Tutor.';

  @override
  String get premiumSharedAcrossClients =>
      'Tu estado de Premium confirmado se comparte entre los clientes compatibles de Language Voice Tutor.';

  @override
  String get premiumBenefits => 'Ventajas de Premium';

  @override
  String get premiumBenefitDailyLimit =>
      '• Practica sin el límite diario de lecciones gratuitas';

  @override
  String get premiumBenefitAcrossDevices =>
      '• Usa el mismo acceso Premium en dispositivos compatibles';

  @override
  String get premiumBenefitAccountData =>
      '• Mantén juntos tu cuenta, progreso, historial y ajustes de aprendizaje';

  @override
  String get getPremium => 'Obtener Premium';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get refreshPremiumStatus => 'Actualizar estado';

  @override
  String get billingProviderExplanation =>
      'Los cambios de facturación deben gestionarse con el proveedor donde se compró Premium.';

  @override
  String get googlePlayPurchasesUnavailableTitle =>
      'Las compras de Google Play aún no están disponibles';

  @override
  String get restorePurchasesUnavailableTitle =>
      'La restauración de compras aún no está disponible';

  @override
  String get googlePlayPurchasesUnavailableDescription =>
      'Las compras se conectarán en el siguiente paso. Esta compilación no puede cobrarte ni activar Premium.';

  @override
  String get restorePurchasesUnavailableDescription =>
      'La restauración de Google Play se conectará con el flujo de facturación. El estado actual de tu cuenta se sigue cargando desde Language Voice Tutor.';

  @override
  String get purchasePendingConfirmation =>
      'El procesamiento de la compra aún no está confirmado. Actualiza tu estado de nuevo en breve.';

  @override
  String get purchaseActionFailed =>
      'No se puede completar esa solicitud ahora. Inténtalo de nuevo.';

  @override
  String get premiumOk => 'Aceptar';

  @override
  String get leaveLessonTitle => '¿Salir de la lección?';

  @override
  String get leaveLessonDescription =>
      'Al salir se termina esta lección sin finalizar y no se crea un resumen.';

  @override
  String get stay => 'Quedarse';

  @override
  String get leaveLesson => 'Salir de la lección';

  @override
  String get finishLessonTitle => '¿Terminar la lección?';

  @override
  String get finishLessonDescription =>
      '¿Terminar esta lección y ver tu resumen?';

  @override
  String get continueLesson => 'Continuar la lección';

  @override
  String get gettingHint => 'Obteniendo una pista...';

  @override
  String get dismissHint => 'Cerrar pista';

  @override
  String get finishingLesson => 'Terminando la lección...';

  @override
  String get finishLessonAuthRequired =>
      'Vuelve a iniciar sesión para terminar la lección.';

  @override
  String get finishLessonSessionUnavailable =>
      'Esta sesión de lección ya no está disponible.';

  @override
  String get finishLessonFailed =>
      'No se pudo terminar la lección. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get lessonFeedback => 'Comentarios';

  @override
  String get loadingLessonFeedback => 'Cargando comentarios...';

  @override
  String get showLessonFeedback => 'Mostrar comentarios';

  @override
  String get hideLessonFeedback => 'Ocultar comentarios';

  @override
  String get retryLessonFeedback => 'Reintentar comentarios';

  @override
  String get feedbackNotReady =>
      'Los comentarios aún no están listos. Inténtalo de nuevo.';

  @override
  String get feedbackQuickSummary => 'Resumen breve';

  @override
  String get feedbackCorrectedVersion => 'Versión corregida';

  @override
  String get feedbackGrammarTip => 'Consejo de gramática';

  @override
  String get feedbackVocabularyTip => 'Consejo de vocabulario';

  @override
  String get feedbackCultureTip => 'Consejo cultural';

  @override
  String get feedbackNaturalVersion => 'Versión más natural';

  @override
  String get lessonFeedbackAuthRequired =>
      'Vuelve a iniciar sesión para continuar la lección.';

  @override
  String get lessonFeedbackSessionEnded => 'Esta lección ya ha terminado.';

  @override
  String get lessonFeedbackNotAvailableForMessage =>
      'Los comentarios no están disponibles para este mensaje.';

  @override
  String get lessonFeedbackFailed =>
      'No se pudieron obtener los comentarios. Inténtalo de nuevo.';

  @override
  String get lessonStartBlocked =>
      'Ya has usado la lección gratuita de hoy. Inténtalo mañana o mejora tu plan.';

  @override
  String get lessonStartConflict =>
      'Ya tienes una lección activa. Termínala o sal de ella antes de iniciar otra.';

  @override
  String get lessonStartAuthRequired =>
      'Vuelve a iniciar sesión para empezar una lección.';

  @override
  String get lessonStartUnavailable =>
      'No se pudo iniciar la lección. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get lessonStartFailed =>
      'No se pudo iniciar la lección. Inténtalo de nuevo.';

  @override
  String get lessonSummary => 'Resumen de la lección';

  @override
  String get lessonCompleted => 'Lección completada';

  @override
  String get summaryWhatWentWell => 'Lo que salió bien';

  @override
  String get summaryStrengths => 'Puntos fuertes';

  @override
  String get summaryImprovements => 'Aspectos a mejorar';

  @override
  String get summaryVocabulary => 'Vocabulario';

  @override
  String get summaryGrammar => 'Gramática';

  @override
  String get summaryNextSteps => 'Próximos pasos';

  @override
  String get retrySummary => 'Reintentar resumen';

  @override
  String get summaryUnavailableMessage =>
      'Tu lección se guardó, pero no se pudo crear un resumen para esta lección.';

  @override
  String get summaryAuthRequiredMessage =>
      'Vuelve a iniciar sesión para cargar el resumen de la lección.';

  @override
  String get summaryLoadErrorMessage =>
      'Tu lección se guardó, pero no se pudo cargar el resumen ahora.';

  @override
  String get startRecording => 'Iniciar grabación';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get progressCompletedLessons => 'Lecciones completadas';

  @override
  String get progressAllTime => 'Todo el tiempo';

  @override
  String get progressLast7Days => 'Últimos 7 días';

  @override
  String get progressLast30Days => 'Últimos 30 días';

  @override
  String get progressCurrentStreak => 'Racha actual';

  @override
  String get progressLongestStreak => 'Racha más larga';

  @override
  String get progressRecentActivity => 'Actividad reciente';

  @override
  String get progressLastCompletedLesson => 'Última lección completada';

  @override
  String get progressLessonsByLanguage => 'Lecciones por idioma';

  @override
  String get progressLessonsByLevel => 'Lecciones por nivel';

  @override
  String get progressEmptyTitle => 'Tu progreso aparecerá aquí';

  @override
  String get progressEmptyDescription =>
      'Las lecciones completadas aparecerán aquí después de terminar una lección.';

  @override
  String get progressUnavailable =>
      'El progreso no está disponible temporalmente. Inténtalo de nuevo.';

  @override
  String get progressLoadFailed =>
      'No se pudo cargar el progreso. Inténtalo de nuevo.';

  @override
  String progressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
      zero: '0 días',
    );
    return '$_temp0';
  }

  @override
  String get achievementsLoadFailed =>
      'No se pudieron cargar los logros. Inténtalo de nuevo.';

  @override
  String achievementUnlockedSemantics(String title) {
    return 'Logro desbloqueado: $title';
  }

  @override
  String achievementLockedSemantics(String title, num current, num target) {
    return 'Logro bloqueado: $title. Progreso: $current de $target.';
  }

  @override
  String closeAchievementPreview(String title) {
    return 'Cerrar la vista previa del logro $title';
  }

  @override
  String get closeAllAchievementPreviews =>
      'Cerrar todas las vistas previas de logros';
}
