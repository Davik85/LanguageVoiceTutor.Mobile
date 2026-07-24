// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Language Voice Tutor';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get app => 'App';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get saving => 'Saving...';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String get unableToSaveSettings => 'Unable to save settings right now.';

  @override
  String get learning => 'Learning';

  @override
  String get studyLanguage => 'Study language';

  @override
  String get nativeLanguage => 'Native language';

  @override
  String get interfaceLanguage => 'Interface language';

  @override
  String get interfaceExplanationLanguage => 'Interface / explanation language';

  @override
  String get interfaceLanguageDescription =>
      'Changes the language of the application interface only.';

  @override
  String get currentLevel => 'Current level';

  @override
  String get selectedTutor => 'Selected tutor';

  @override
  String get loadingSettings => 'Loading settings...';

  @override
  String get unableToLoadSettings => 'Unable to load settings right now.';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayNameOptional => 'Display name (optional)';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get unableToCheckSession =>
      'Unable to check your session. Please try again.';

  @override
  String get lessons => 'Lessons';

  @override
  String get lessonHistory => 'Lesson history';

  @override
  String get progress => 'Progress';

  @override
  String get rewards => 'Rewards';

  @override
  String get viewAll => 'View all';

  @override
  String get achievements => 'Achievements';

  @override
  String get account => 'Account';

  @override
  String get logout => 'Logout';

  @override
  String get audio => 'Audio';

  @override
  String get feedbackAndReports => 'Feedback & reports';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get send => 'Send';

  @override
  String get done => 'Done';

  @override
  String get openAndroidSettings => 'Open Android settings';

  @override
  String get hint => 'Hint';

  @override
  String get finishLesson => 'Finish lesson';

  @override
  String get typeYourMessage => 'Type your message';

  @override
  String get sending => 'Sending...';

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
  String get signInToApp => 'Sign in to Language Voice Tutor';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get enterPassword => 'Enter your password.';

  @override
  String get chooseTopic => 'Choose Topic';

  @override
  String get chooseTopicTitle => 'Choose a topic';

  @override
  String get chooseTopicSubtitle =>
      'Pick the kind of conversation you want to practice.';

  @override
  String get chooseSituation => 'Choose Situation';

  @override
  String get chooseSituationTitle => 'Choose a situation';

  @override
  String get chooseSituationSubtitle =>
      'Practice one specific moment from this topic.';

  @override
  String get viewAllRewards => 'View all badges and learning rewards.';

  @override
  String get accountDeletion => 'Account deletion';

  @override
  String get requestAccountDeletion => 'Request account deletion';

  @override
  String get loadingAccount => 'Loading account...';

  @override
  String get premiumAndSubscription => 'Premium & subscription';

  @override
  String get currentPassword => 'Current password';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get submitting => 'Submitting...';

  @override
  String get loadingTutors => 'Loading tutors...';

  @override
  String get noTutorsAvailable => 'No tutors are available right now.';

  @override
  String get loadingAudioSettings => 'Loading audio settings...';

  @override
  String get conversationModeEnabled => 'Conversation mode enabled';

  @override
  String get sendSuggestionOrReport => 'Send a suggestion or report a problem';

  @override
  String get reportType => 'Report type';

  @override
  String get pasteAiResponseOptional => 'Paste the AI response (optional)';

  @override
  String get lessonHistoryHeading => 'Your recent completed lessons';

  @override
  String get noCompletedLessons => 'No completed lessons yet';

  @override
  String get completedLessonsAppearHere =>
      'Completed lessons will appear here.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get lesson => 'Lesson';

  @override
  String get level => 'Level';

  @override
  String get completed => 'Completed';

  @override
  String get finished => 'Finished';

  @override
  String get lessonChat => 'Lesson chat';

  @override
  String get conversation => 'Conversation';

  @override
  String turnCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count turns',
      one: '1 turn',
    );
    return '$_temp0';
  }

  @override
  String get achievementsUnavailable => 'No achievements are available yet.';

  @override
  String unlockedCount(num unlocked, num total) {
    return '$unlocked of $total unlocked';
  }

  @override
  String learningLanguage(String language) {
    return 'Learning $language';
  }

  @override
  String get streaks => 'Streaks';

  @override
  String get lessonMilestones => 'Lesson milestones';

  @override
  String get topics => 'Topics';

  @override
  String get situations => 'Situations';

  @override
  String get otherAchievements => 'Other achievements';

  @override
  String progressCount(num current, num total) {
    return '$current of $total';
  }

  @override
  String get startLesson => 'Start lesson';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get keepLearningRhythm => 'Keep your learning rhythm';

  @override
  String get reminderPermissionExplanation =>
      'Language Voice Tutor can send two cheerful daily reminders so practice does not get lost in a busy day. You can change the times or turn reminders off in Settings.';

  @override
  String get notNow => 'Not now';

  @override
  String get allowReminders => 'Allow reminders';

  @override
  String get achievementsTemporarilyUnavailable =>
      'Achievements are temporarily unavailable';

  @override
  String get achievementsEmpty => 'Your achievements will appear here.';

  @override
  String learningStreak(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day learning streak',
      one: '1 day learning streak',
    );
    return '$_temp0';
  }

  @override
  String get learningStreakLoading => 'Learning streak loading';

  @override
  String get learningStreakUnavailable => 'Learning streak unavailable';

  @override
  String get learnerFallbackName => 'Learner';

  @override
  String get premiumPlan => 'Premium plan';

  @override
  String get premiumTrial => 'Premium trial';

  @override
  String get freePlan => 'Free plan';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get premiumDetails => 'Premium details';

  @override
  String get explorePremium => 'Explore Premium';

  @override
  String freeLessonsAvailableToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free lessons available today',
      one: '1 free lesson available today',
    );
    return '$_temp0';
  }

  @override
  String get yourWeek => 'Your week';

  @override
  String lessonsLastSevenDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons in the last 7 days',
      one: '1 lesson in the last 7 days',
    );
    return '$_temp0';
  }

  @override
  String get startStreakToday => 'Start your streak today';

  @override
  String get activityUnavailable => 'Activity is unavailable right now.';

  @override
  String lessonsCompleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons completed',
      one: '1 lesson completed',
    );
    return '$_temp0';
  }

  @override
  String activityDaySemantics(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed lessons',
      one: '1 completed lesson',
    );
    return '$date: $_temp0';
  }

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get remindersTemporarilyUnavailable =>
      'Practice reminders are temporarily unavailable.';

  @override
  String get unableToUpdateReminders =>
      'Unable to update reminders right now. Please try again.';

  @override
  String get unableToLoadAccount => 'Unable to load account details right now.';

  @override
  String get tutorChoicesUnavailable =>
      'Tutor choices are unavailable right now. You can still review and save your other settings.';

  @override
  String get pleaseEnterDescription => 'Please enter a description.';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get resetCodePasswordRequired =>
      'Reset code and new password are required.';

  @override
  String get passwordsMustMatch => 'New password and confirmation must match.';

  @override
  String get signInToChangePassword =>
      'Please sign in to change your password.';

  @override
  String get currentPasswordRequired => 'Current password is required.';

  @override
  String get accountDeletionDescription =>
      'Send a request to permanently delete your Language Voice Tutor account and personal data.';

  @override
  String get accountDeletionNotice =>
      'Submitting this request does not delete your account immediately. Support will review and process it, and may ask for more information. Their response will be sent to the email address associated with your account. Your account is not considered deleted just because you submitted this request.';

  @override
  String get noDisplayName => 'No display name';

  @override
  String get subscriptionUnavailable => 'Subscription unavailable';

  @override
  String get noPaidPlan => 'No paid plan';

  @override
  String requestId(String id) {
    return 'Request ID: $id';
  }

  @override
  String statusValue(String status) {
    return 'Status: $status';
  }

  @override
  String get passwordRecovery => 'Password & recovery';

  @override
  String get accountEmail => 'Account email';

  @override
  String get sendingResetInstructions => 'Sending reset instructions...';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get resetCode => 'Reset code';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get updatingPassword => 'Updating password...';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get newAccountPassword => 'New account password';

  @override
  String get confirmNewAccountPassword => 'Confirm new account password';

  @override
  String get changingPassword => 'Changing password...';

  @override
  String get changePassword => 'Change password';

  @override
  String get tutorVoice => 'Tutor voice';

  @override
  String speechSpeed(String speed) {
    return 'Speech speed: ${speed}x';
  }

  @override
  String get feedbackSuggestion => 'Suggestion';

  @override
  String get feedbackAppProblem => 'App problem';

  @override
  String get feedbackAiResponse => 'AI response';

  @override
  String get yourSuggestion => 'Your suggestion';

  @override
  String get describeProblem => 'Describe the problem';

  @override
  String get aiResponseProblem => 'What was wrong with the AI response?';

  @override
  String get practiceReminders => 'Practice reminders';

  @override
  String get localRemindersDescription =>
      'These reminders are local to this device.';

  @override
  String get dailyPracticeReminders => 'Daily practice reminders';

  @override
  String get morningReminder => 'Morning reminder';

  @override
  String get eveningReminder => 'Evening reminder';

  @override
  String get notificationsAllowed => 'Notifications allowed';

  @override
  String get notificationStatusUnavailable => 'Notification status unavailable';

  @override
  String get notificationsBlocked => 'Notifications are blocked by Android.';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get feedbackReceived => 'Thank you. Your message has been received.';

  @override
  String get feedbackValidationFailure =>
      'Please check your message and try again.';

  @override
  String get feedbackUnavailable =>
      'Feedback is temporarily unavailable. Please try again.';

  @override
  String get deletionRequestAlreadyExists =>
      'An active account deletion request already exists.';

  @override
  String get deletionRequestSubmitted =>
      'Your account deletion request has been submitted for support processing.';

  @override
  String get incorrectCurrentPassword => 'Your current password is incorrect.';

  @override
  String get unableToReachService =>
      'Unable to reach the service. Please try again.';

  @override
  String get unexpectedServiceResponse =>
      'The service returned an unexpected response. Please try again.';

  @override
  String get unableToSubmitRequest =>
      'Unable to submit your request right now. Please try again.';

  @override
  String get unableToLoadLearningSettings =>
      'Unable to load your learning settings right now. Please try again.';

  @override
  String get settingsTemporarilyUnavailable =>
      'Settings are temporarily unavailable. Please try again.';

  @override
  String selectedLevelContext(String level) {
    return 'Level: $level';
  }

  @override
  String selectedLevelTopicContext(String level, String topic) {
    return 'Level: $level / Topic: $topic';
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
    return 'Open $topic';
  }

  @override
  String openSituationTooltip(String situation) {
    return 'Open $situation';
  }

  @override
  String get noSituationsAvailable =>
      'No situations are available for this topic.';

  @override
  String get levelA1Label => 'A1 Beginner';

  @override
  String get levelA1Description =>
      'Build simple greetings, needs, and short everyday answers.';

  @override
  String get levelA2Label => 'A2 Elementary';

  @override
  String get levelA2Description =>
      'Handle routine conversations with familiar words and phrases.';

  @override
  String get levelB1Label => 'B1 Intermediate';

  @override
  String get levelB1Description =>
      'Practice longer exchanges, opinions, and everyday problem solving.';

  @override
  String get levelB2Label => 'B2 Upper-Intermediate';

  @override
  String get levelB2Description =>
      'Sharpen nuanced conversations with more natural detail.';

  @override
  String get topicDailyLifeLabel => 'Daily Life';

  @override
  String get topicDailyLifeDescription =>
      'Small talk, introductions, and daily situations.';

  @override
  String get topicTravelLabel => 'Travel';

  @override
  String get topicTravelDescription =>
      'Airports, hotels, directions, and transport.';

  @override
  String get topicWorkBusinessLabel => 'Work & Business';

  @override
  String get topicWorkBusinessDescription =>
      'Meetings, emails, calls, and workplace conversations.';

  @override
  String get topicJobInterviewLabel => 'Job Interview';

  @override
  String get topicJobInterviewDescription =>
      'Practice common interview questions and answers.';

  @override
  String get topicRestaurantCafeLabel => 'Restaurant & Cafe';

  @override
  String get topicRestaurantCafeDescription =>
      'Ordering food, booking tables, and polite requests.';

  @override
  String get topicFreeConversationLabel => 'Free Conversation';

  @override
  String get topicFreeConversationDescription =>
      'Open-ended practice shaped around what you want to say.';

  @override
  String get situationIntroductionsLabel => 'Introductions';

  @override
  String get situationIntroductionsDescription =>
      'Introduce yourself and ask basic personal questions.';

  @override
  String get situationSmallTalkNeighborLabel => 'Talk with a neighbor';

  @override
  String get situationSmallTalkNeighborDescription =>
      'Have a short friendly conversation near home.';

  @override
  String get situationAskingForHelpLabel => 'Ask for help';

  @override
  String get situationAskingForHelpDescription =>
      'Ask for help in a simple everyday situation.';

  @override
  String get situationMakingPlansLabel => 'Make plans';

  @override
  String get situationMakingPlansDescription =>
      'Plan an activity and agree on time and place.';

  @override
  String get situationTalkingAboutDayLabel => 'Talk about your day';

  @override
  String get situationTalkingAboutDayDescription =>
      'Describe your day and daily routine.';

  @override
  String get situationAirportCheckInLabel => 'Airport check-in';

  @override
  String get situationAirportCheckInDescription =>
      'Check in for a flight and confirm travel details.';

  @override
  String get situationHotelCheckInLabel => 'Hotel check-in';

  @override
  String get situationHotelCheckInDescription =>
      'Check in at a hotel and ask common questions.';

  @override
  String get situationAskingForDirectionsLabel => 'Ask for directions';

  @override
  String get situationAskingForDirectionsDescription =>
      'Ask for and understand directions in a new city.';

  @override
  String get situationOrderingTransportLabel => 'Order transport';

  @override
  String get situationOrderingTransportDescription =>
      'Arrange a taxi or rideshare to your destination.';

  @override
  String get situationLostLuggageLabel => 'Lost luggage';

  @override
  String get situationLostLuggageDescription =>
      'Report lost baggage and explain your situation.';

  @override
  String get situationFirstMeetingLabel => 'First meeting';

  @override
  String get situationFirstMeetingDescription =>
      'Introduce yourself in a new work meeting.';

  @override
  String get situationDailyStandupLabel => 'Daily standup';

  @override
  String get situationDailyStandupDescription =>
      'Give a short update about your tasks.';

  @override
  String get situationClientPhoneCallLabel => 'Phone call with a client';

  @override
  String get situationClientPhoneCallDescription =>
      'Handle a polite and clear business call.';

  @override
  String get situationAskingForClarificationLabel => 'Ask for clarification';

  @override
  String get situationAskingForClarificationDescription =>
      'Ask follow-up questions to confirm requirements.';

  @override
  String get situationDiscussingDeadlinesLabel => 'Discuss deadlines';

  @override
  String get situationDiscussingDeadlinesDescription =>
      'Talk about timelines and delivery expectations.';

  @override
  String get situationTellMeAboutYourselfLabel => 'Tell me about yourself';

  @override
  String get situationTellMeAboutYourselfDescription =>
      'Give a short, relevant interview-style self-introduction.';

  @override
  String get situationWorkExperienceLabel => 'Work experience';

  @override
  String get situationWorkExperienceDescription =>
      'Describe previous work, responsibilities, and one result.';

  @override
  String get situationStrengthsWeaknessesLabel => 'Strengths and weaknesses';

  @override
  String get situationStrengthsWeaknessesDescription =>
      'Talk about one strength and one improvement area professionally.';

  @override
  String get situationWhyThisJobLabel => 'Why do you want this job?';

  @override
  String get situationWhyThisJobDescription =>
      'Explain your motivation and connect the role to your skills.';

  @override
  String get situationQuestionsAtEndLabel => 'Ask questions at the end';

  @override
  String get situationQuestionsAtEndDescription =>
      'Ask polite, useful questions before the interview finishes.';

  @override
  String get situationBookingTableLabel => 'Book a table';

  @override
  String get situationBookingTableDescription =>
      'Call or speak to reserve a table.';

  @override
  String get situationOrderingFoodLabel => 'Order food';

  @override
  String get situationOrderingFoodDescription =>
      'Order a meal and ask simple menu questions.';

  @override
  String get situationAskingIngredientsLabel => 'Ask about ingredients';

  @override
  String get situationAskingIngredientsDescription =>
      'Ask about allergies and dish ingredients.';

  @override
  String get situationWrongOrderLabel => 'Handle a wrong order';

  @override
  String get situationWrongOrderDescription =>
      'Politely explain an issue with your order.';

  @override
  String get situationPayingBillLabel => 'Pay the bill';

  @override
  String get situationPayingBillDescription =>
      'Ask for the check and complete payment.';

  @override
  String get situationOpenConversationLabel => 'Open conversation';

  @override
  String get situationOpenConversationDescription =>
      'Practice any topic with flexible follow-up.';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatusLoadingSemantics => 'Loading Premium status';

  @override
  String get premiumStatusTemporarilyUnavailable =>
      'Premium status is temporarily unavailable. Please try again.';

  @override
  String premiumStatusSemantics(String status) {
    return 'Premium status: $status';
  }

  @override
  String get premiumActive => 'Premium active';

  @override
  String get premiumActiveDescription =>
      'Practice without the daily free-lesson limit.';

  @override
  String premiumEndsOn(String date) {
    return 'Premium ends $date.';
  }

  @override
  String get premiumTrialActiveDescription => 'Your Premium trial is active.';

  @override
  String premiumTrialEndsOn(String date) {
    return 'Trial ends $date.';
  }

  @override
  String freeLessonsRemainingToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free lessons remaining today.',
      one: '1 free lesson remaining today.',
      zero: 'No free lessons remaining today.',
    );
    return '$_temp0';
  }

  @override
  String get premiumRemovesDailyLimit =>
      'Premium removes the daily lesson limit.';

  @override
  String get premiumAccountLinked =>
      'Premium access is linked to your Language Voice Tutor account.';

  @override
  String get premiumSharedAcrossClients =>
      'Your confirmed Premium status is shared across supported Language Voice Tutor clients.';

  @override
  String get premiumBenefits => 'Premium benefits';

  @override
  String get premiumBenefitDailyLimit =>
      '• Practice without the daily free-lesson cap';

  @override
  String get premiumBenefitAcrossDevices =>
      '• Use the same Premium access across supported devices';

  @override
  String get premiumBenefitAccountData =>
      '• Keep your account, progress, history, and learning settings together';

  @override
  String get getPremium => 'Get Premium';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get refreshPremiumStatus => 'Refresh status';

  @override
  String get billingProviderExplanation =>
      'Billing changes must be handled through the provider where Premium was purchased.';

  @override
  String get googlePlayPurchasesUnavailableTitle =>
      'Google Play purchases are not available yet';

  @override
  String get restorePurchasesUnavailableTitle =>
      'Restore purchases is not available yet';

  @override
  String get googlePlayPurchasesUnavailableDescription =>
      'Purchases will be connected in the next step. This build cannot charge you or activate Premium.';

  @override
  String get restorePurchasesUnavailableDescription =>
      'Google Play restoration will be connected with the billing flow. Your current account status is still loaded from Language Voice Tutor.';

  @override
  String get purchasePendingConfirmation =>
      'Purchase processing is not confirmed yet. Refresh your status again shortly.';

  @override
  String get purchaseActionFailed =>
      'Unable to complete that request right now. Please try again.';

  @override
  String get premiumOk => 'OK';

  @override
  String get leaveLessonTitle => 'Leave lesson?';

  @override
  String get leaveLessonDescription =>
      'Leaving ends this unfinished lesson without creating a summary.';

  @override
  String get stay => 'Stay';

  @override
  String get leaveLesson => 'Leave lesson';

  @override
  String get finishLessonTitle => 'Finish lesson?';

  @override
  String get finishLessonDescription =>
      'Finish this lesson and view your summary?';

  @override
  String get continueLesson => 'Continue lesson';

  @override
  String get gettingHint => 'Getting hint...';

  @override
  String get dismissHint => 'Dismiss hint';

  @override
  String get finishingLesson => 'Finishing lesson...';

  @override
  String get finishLessonAuthRequired =>
      'Please sign in again to finish the lesson.';

  @override
  String get finishLessonSessionUnavailable =>
      'This lesson session is no longer available.';

  @override
  String get finishLessonFailed =>
      'Could not finish the lesson. Please check your connection and try again.';

  @override
  String get lessonFeedback => 'Feedback';

  @override
  String get loadingLessonFeedback => 'Loading feedback...';

  @override
  String get showLessonFeedback => 'Show feedback';

  @override
  String get hideLessonFeedback => 'Hide feedback';

  @override
  String get retryLessonFeedback => 'Retry feedback';

  @override
  String get feedbackNotReady => 'Feedback is not ready yet. Please try again.';

  @override
  String get feedbackQuickSummary => 'Quick summary';

  @override
  String get feedbackCorrectedVersion => 'Corrected version';

  @override
  String get feedbackGrammarTip => 'Grammar tip';

  @override
  String get feedbackVocabularyTip => 'Vocabulary tip';

  @override
  String get feedbackCultureTip => 'Culture tip';

  @override
  String get feedbackNaturalVersion => 'More natural version';

  @override
  String get lessonFeedbackAuthRequired =>
      'Please sign in again to continue the lesson.';

  @override
  String get lessonFeedbackSessionEnded => 'This lesson has already ended.';

  @override
  String get lessonFeedbackNotAvailableForMessage =>
      'Feedback is not available for this message.';

  @override
  String get lessonFeedbackFailed =>
      'Could not get feedback. Please try again.';

  @override
  String get lessonStartBlocked =>
      'You have used today\'s free lesson. Please try again tomorrow or upgrade.';

  @override
  String get lessonStartConflict =>
      'You already have an active lesson. Finish or leave it before starting a new one.';

  @override
  String get lessonStartAuthRequired =>
      'Please sign in again to start a lesson.';

  @override
  String get lessonStartUnavailable =>
      'Could not start the lesson. Please check your connection and try again.';

  @override
  String get lessonStartFailed =>
      'Could not start the lesson. Please try again.';

  @override
  String get lessonSummary => 'Lesson summary';

  @override
  String get lessonCompleted => 'Lesson completed';

  @override
  String get summaryWhatWentWell => 'What went well';

  @override
  String get summaryStrengths => 'Strengths';

  @override
  String get summaryImprovements => 'Improvements';

  @override
  String get summaryVocabulary => 'Vocabulary';

  @override
  String get summaryGrammar => 'Grammar';

  @override
  String get summaryNextSteps => 'Next steps';

  @override
  String get retrySummary => 'Retry summary';

  @override
  String get summaryUnavailableMessage =>
      'Your lesson was saved, but a summary could not be created for this lesson.';

  @override
  String get summaryAuthRequiredMessage =>
      'Please sign in again to load your lesson summary.';

  @override
  String get summaryLoadErrorMessage =>
      'Your lesson was saved, but we could not load the summary right now.';

  @override
  String get startRecording => 'Start recording';

  @override
  String get stopRecording => 'Stop recording';
}
