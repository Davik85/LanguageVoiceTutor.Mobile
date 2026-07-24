import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Voice Tutor'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// No description provided for @unableToSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to save settings right now.'**
  String get unableToSaveSettings;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @studyLanguage.
  ///
  /// In en, this message translates to:
  /// **'Study language'**
  String get studyLanguage;

  /// No description provided for @nativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Native language'**
  String get nativeLanguage;

  /// No description provided for @interfaceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get interfaceLanguage;

  /// No description provided for @interfaceExplanationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface / explanation language'**
  String get interfaceExplanationLanguage;

  /// No description provided for @interfaceLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Changes the language of the application interface only.'**
  String get interfaceLanguageDescription;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current level'**
  String get currentLevel;

  /// No description provided for @selectedTutor.
  ///
  /// In en, this message translates to:
  /// **'Selected tutor'**
  String get selectedTutor;

  /// No description provided for @loadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get loadingSettings;

  /// No description provided for @unableToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load settings right now.'**
  String get unableToLoadSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get displayNameOptional;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @unableToCheckSession.
  ///
  /// In en, this message translates to:
  /// **'Unable to check your session. Please try again.'**
  String get unableToCheckSession;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @lessonHistory.
  ///
  /// In en, this message translates to:
  /// **'Lesson history'**
  String get lessonHistory;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @feedbackAndReports.
  ///
  /// In en, this message translates to:
  /// **'Feedback & reports'**
  String get feedbackAndReports;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @openAndroidSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Android settings'**
  String get openAndroidSettings;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @finishLesson.
  ///
  /// In en, this message translates to:
  /// **'Finish lesson'**
  String get finishLesson;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message'**
  String get typeYourMessage;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageNameRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageNameRussian;

  /// No description provided for @languageNameSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageNameSpanish;

  /// No description provided for @languageNameFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageNameFrench;

  /// No description provided for @languageNameGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageNameGerman;

  /// No description provided for @signInToApp.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Language Voice Tutor'**
  String get signInToApp;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterPassword;

  /// No description provided for @chooseTopic.
  ///
  /// In en, this message translates to:
  /// **'Choose Topic'**
  String get chooseTopic;

  /// No description provided for @chooseTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic'**
  String get chooseTopicTitle;

  /// No description provided for @chooseTopicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the kind of conversation you want to practice.'**
  String get chooseTopicSubtitle;

  /// No description provided for @chooseSituation.
  ///
  /// In en, this message translates to:
  /// **'Choose Situation'**
  String get chooseSituation;

  /// No description provided for @chooseSituationTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a situation'**
  String get chooseSituationTitle;

  /// No description provided for @chooseSituationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice one specific moment from this topic.'**
  String get chooseSituationSubtitle;

  /// No description provided for @viewAllRewards.
  ///
  /// In en, this message translates to:
  /// **'View all badges and learning rewards.'**
  String get viewAllRewards;

  /// No description provided for @accountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account deletion'**
  String get accountDeletion;

  /// No description provided for @requestAccountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Request account deletion'**
  String get requestAccountDeletion;

  /// No description provided for @loadingAccount.
  ///
  /// In en, this message translates to:
  /// **'Loading account...'**
  String get loadingAccount;

  /// No description provided for @premiumAndSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium & subscription'**
  String get premiumAndSubscription;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @loadingTutors.
  ///
  /// In en, this message translates to:
  /// **'Loading tutors...'**
  String get loadingTutors;

  /// No description provided for @noTutorsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tutors are available right now.'**
  String get noTutorsAvailable;

  /// No description provided for @loadingAudioSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading audio settings...'**
  String get loadingAudioSettings;

  /// No description provided for @conversationModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Conversation mode enabled'**
  String get conversationModeEnabled;

  /// No description provided for @sendSuggestionOrReport.
  ///
  /// In en, this message translates to:
  /// **'Send a suggestion or report a problem'**
  String get sendSuggestionOrReport;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Report type'**
  String get reportType;

  /// No description provided for @pasteAiResponseOptional.
  ///
  /// In en, this message translates to:
  /// **'Paste the AI response (optional)'**
  String get pasteAiResponseOptional;

  /// No description provided for @lessonHistoryHeading.
  ///
  /// In en, this message translates to:
  /// **'Your recent completed lessons'**
  String get lessonHistoryHeading;

  /// No description provided for @noCompletedLessons.
  ///
  /// In en, this message translates to:
  /// **'No completed lessons yet'**
  String get noCompletedLessons;

  /// No description provided for @completedLessonsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Completed lessons will appear here.'**
  String get completedLessonsAppearHere;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @lessonChat.
  ///
  /// In en, this message translates to:
  /// **'Lesson chat'**
  String get lessonChat;

  /// No description provided for @conversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get conversation;

  /// No description provided for @turnCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 turn} other{{count} turns}}'**
  String turnCount(num count);

  /// No description provided for @achievementsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No achievements are available yet.'**
  String get achievementsUnavailable;

  /// No description provided for @unlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} unlocked'**
  String unlockedCount(num unlocked, num total);

  /// No description provided for @learningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Learning {language}'**
  String learningLanguage(String language);

  /// No description provided for @streaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// No description provided for @lessonMilestones.
  ///
  /// In en, this message translates to:
  /// **'Lesson milestones'**
  String get lessonMilestones;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @situations.
  ///
  /// In en, this message translates to:
  /// **'Situations'**
  String get situations;

  /// No description provided for @otherAchievements.
  ///
  /// In en, this message translates to:
  /// **'Other achievements'**
  String get otherAchievements;

  /// No description provided for @progressCount.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String progressCount(num current, num total);

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start lesson'**
  String get startLesson;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @keepLearningRhythm.
  ///
  /// In en, this message translates to:
  /// **'Keep your learning rhythm'**
  String get keepLearningRhythm;

  /// No description provided for @reminderPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Language Voice Tutor can send two cheerful daily reminders so practice does not get lost in a busy day. You can change the times or turn reminders off in Settings.'**
  String get reminderPermissionExplanation;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allowReminders.
  ///
  /// In en, this message translates to:
  /// **'Allow reminders'**
  String get allowReminders;

  /// No description provided for @achievementsTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Achievements are temporarily unavailable'**
  String get achievementsTemporarilyUnavailable;

  /// No description provided for @achievementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your achievements will appear here.'**
  String get achievementsEmpty;

  /// No description provided for @learningStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day learning streak} other{{count} day learning streak}}'**
  String learningStreak(num count);

  /// No description provided for @learningStreakLoading.
  ///
  /// In en, this message translates to:
  /// **'Learning streak loading'**
  String get learningStreakLoading;

  /// No description provided for @learningStreakUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Learning streak unavailable'**
  String get learningStreakUnavailable;

  /// No description provided for @learnerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get learnerFallbackName;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium plan'**
  String get premiumPlan;

  /// No description provided for @premiumTrial.
  ///
  /// In en, this message translates to:
  /// **'Premium trial'**
  String get premiumTrial;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get freePlan;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String signedInAs(String name);

  /// No description provided for @premiumDetails.
  ///
  /// In en, this message translates to:
  /// **'Premium details'**
  String get premiumDetails;

  /// No description provided for @explorePremium.
  ///
  /// In en, this message translates to:
  /// **'Explore Premium'**
  String get explorePremium;

  /// No description provided for @freeLessonsAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 free lesson available today} other{{count} free lessons available today}}'**
  String freeLessonsAvailableToday(num count);

  /// No description provided for @yourWeek.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get yourWeek;

  /// No description provided for @lessonsLastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson in the last 7 days} other{{count} lessons in the last 7 days}}'**
  String lessonsLastSevenDays(num count);

  /// No description provided for @startStreakToday.
  ///
  /// In en, this message translates to:
  /// **'Start your streak today'**
  String get startStreakToday;

  /// No description provided for @activityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Activity is unavailable right now.'**
  String get activityUnavailable;

  /// No description provided for @lessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson completed} other{{count} lessons completed}}'**
  String lessonsCompleted(num count);

  /// No description provided for @activityDaySemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}: {count, plural, =1{1 completed lesson} other{{count} completed lessons}}'**
  String activityDaySemantics(String date, num count);

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @remindersTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Practice reminders are temporarily unavailable.'**
  String get remindersTemporarilyUnavailable;

  /// No description provided for @unableToUpdateReminders.
  ///
  /// In en, this message translates to:
  /// **'Unable to update reminders right now. Please try again.'**
  String get unableToUpdateReminders;

  /// No description provided for @unableToLoadAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to load account details right now.'**
  String get unableToLoadAccount;

  /// No description provided for @tutorChoicesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tutor choices are unavailable right now. You can still review and save your other settings.'**
  String get tutorChoicesUnavailable;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description.'**
  String get pleaseEnterDescription;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequired;

  /// No description provided for @resetCodePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Reset code and new password are required.'**
  String get resetCodePasswordRequired;

  /// No description provided for @passwordsMustMatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation must match.'**
  String get passwordsMustMatch;

  /// No description provided for @signInToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to change your password.'**
  String get signInToChangePassword;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required.'**
  String get currentPasswordRequired;

  /// No description provided for @accountDeletionDescription.
  ///
  /// In en, this message translates to:
  /// **'Send a request to permanently delete your Language Voice Tutor account and personal data.'**
  String get accountDeletionDescription;

  /// No description provided for @accountDeletionNotice.
  ///
  /// In en, this message translates to:
  /// **'Submitting this request does not delete your account immediately. Support will review and process it, and may ask for more information. Their response will be sent to the email address associated with your account. Your account is not considered deleted just because you submitted this request.'**
  String get accountDeletionNotice;

  /// No description provided for @noDisplayName.
  ///
  /// In en, this message translates to:
  /// **'No display name'**
  String get noDisplayName;

  /// No description provided for @subscriptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Subscription unavailable'**
  String get subscriptionUnavailable;

  /// No description provided for @noPaidPlan.
  ///
  /// In en, this message translates to:
  /// **'No paid plan'**
  String get noPaidPlan;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID: {id}'**
  String requestId(String id);

  /// No description provided for @statusValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusValue(String status);

  /// No description provided for @passwordRecovery.
  ///
  /// In en, this message translates to:
  /// **'Password & recovery'**
  String get passwordRecovery;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get accountEmail;

  /// No description provided for @sendingResetInstructions.
  ///
  /// In en, this message translates to:
  /// **'Sending reset instructions...'**
  String get sendingResetInstructions;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get resetCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @updatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Updating password...'**
  String get updatingPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @newAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'New account password'**
  String get newAccountPassword;

  /// No description provided for @confirmNewAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new account password'**
  String get confirmNewAccountPassword;

  /// No description provided for @changingPassword.
  ///
  /// In en, this message translates to:
  /// **'Changing password...'**
  String get changingPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @tutorVoice.
  ///
  /// In en, this message translates to:
  /// **'Tutor voice'**
  String get tutorVoice;

  /// No description provided for @speechSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speech speed: {speed}x'**
  String speechSpeed(String speed);

  /// No description provided for @feedbackSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get feedbackSuggestion;

  /// No description provided for @feedbackAppProblem.
  ///
  /// In en, this message translates to:
  /// **'App problem'**
  String get feedbackAppProblem;

  /// No description provided for @feedbackAiResponse.
  ///
  /// In en, this message translates to:
  /// **'AI response'**
  String get feedbackAiResponse;

  /// No description provided for @yourSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion'**
  String get yourSuggestion;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get describeProblem;

  /// No description provided for @aiResponseProblem.
  ///
  /// In en, this message translates to:
  /// **'What was wrong with the AI response?'**
  String get aiResponseProblem;

  /// No description provided for @practiceReminders.
  ///
  /// In en, this message translates to:
  /// **'Practice reminders'**
  String get practiceReminders;

  /// No description provided for @localRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'These reminders are local to this device.'**
  String get localRemindersDescription;

  /// No description provided for @dailyPracticeReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily practice reminders'**
  String get dailyPracticeReminders;

  /// No description provided for @morningReminder.
  ///
  /// In en, this message translates to:
  /// **'Morning reminder'**
  String get morningReminder;

  /// No description provided for @eveningReminder.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder'**
  String get eveningReminder;

  /// No description provided for @notificationsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications allowed'**
  String get notificationsAllowed;

  /// No description provided for @notificationStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notification status unavailable'**
  String get notificationStatusUnavailable;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked by Android.'**
  String get notificationsBlocked;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @feedbackReceived.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your message has been received.'**
  String get feedbackReceived;

  /// No description provided for @feedbackValidationFailure.
  ///
  /// In en, this message translates to:
  /// **'Please check your message and try again.'**
  String get feedbackValidationFailure;

  /// No description provided for @feedbackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Feedback is temporarily unavailable. Please try again.'**
  String get feedbackUnavailable;

  /// No description provided for @deletionRequestAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An active account deletion request already exists.'**
  String get deletionRequestAlreadyExists;

  /// No description provided for @deletionRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your account deletion request has been submitted for support processing.'**
  String get deletionRequestSubmitted;

  /// No description provided for @incorrectCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Your current password is incorrect.'**
  String get incorrectCurrentPassword;

  /// No description provided for @unableToReachService.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the service. Please try again.'**
  String get unableToReachService;

  /// No description provided for @unexpectedServiceResponse.
  ///
  /// In en, this message translates to:
  /// **'The service returned an unexpected response. Please try again.'**
  String get unexpectedServiceResponse;

  /// No description provided for @unableToSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit your request right now. Please try again.'**
  String get unableToSubmitRequest;

  /// No description provided for @unableToLoadLearningSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your learning settings right now. Please try again.'**
  String get unableToLoadLearningSettings;

  /// No description provided for @settingsTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Settings are temporarily unavailable. Please try again.'**
  String get settingsTemporarilyUnavailable;

  /// No description provided for @selectedLevelContext.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String selectedLevelContext(String level);

  /// No description provided for @selectedLevelTopicContext.
  ///
  /// In en, this message translates to:
  /// **'Level: {level} / Topic: {topic}'**
  String selectedLevelTopicContext(String level, String topic);

  /// No description provided for @topicCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label}. {description}'**
  String topicCardSemantics(String label, String description);

  /// No description provided for @situationCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label}. {description}'**
  String situationCardSemantics(String label, String description);

  /// No description provided for @openTopicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open {topic}'**
  String openTopicTooltip(String topic);

  /// No description provided for @openSituationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open {situation}'**
  String openSituationTooltip(String situation);

  /// No description provided for @noSituationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No situations are available for this topic.'**
  String get noSituationsAvailable;

  /// No description provided for @levelA1Label.
  ///
  /// In en, this message translates to:
  /// **'A1 Beginner'**
  String get levelA1Label;

  /// No description provided for @levelA1Description.
  ///
  /// In en, this message translates to:
  /// **'Build simple greetings, needs, and short everyday answers.'**
  String get levelA1Description;

  /// No description provided for @levelA2Label.
  ///
  /// In en, this message translates to:
  /// **'A2 Elementary'**
  String get levelA2Label;

  /// No description provided for @levelA2Description.
  ///
  /// In en, this message translates to:
  /// **'Handle routine conversations with familiar words and phrases.'**
  String get levelA2Description;

  /// No description provided for @levelB1Label.
  ///
  /// In en, this message translates to:
  /// **'B1 Intermediate'**
  String get levelB1Label;

  /// No description provided for @levelB1Description.
  ///
  /// In en, this message translates to:
  /// **'Practice longer exchanges, opinions, and everyday problem solving.'**
  String get levelB1Description;

  /// No description provided for @levelB2Label.
  ///
  /// In en, this message translates to:
  /// **'B2 Upper-Intermediate'**
  String get levelB2Label;

  /// No description provided for @levelB2Description.
  ///
  /// In en, this message translates to:
  /// **'Sharpen nuanced conversations with more natural detail.'**
  String get levelB2Description;

  /// No description provided for @topicDailyLifeLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Life'**
  String get topicDailyLifeLabel;

  /// No description provided for @topicDailyLifeDescription.
  ///
  /// In en, this message translates to:
  /// **'Small talk, introductions, and daily situations.'**
  String get topicDailyLifeDescription;

  /// No description provided for @topicTravelLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get topicTravelLabel;

  /// No description provided for @topicTravelDescription.
  ///
  /// In en, this message translates to:
  /// **'Airports, hotels, directions, and transport.'**
  String get topicTravelDescription;

  /// No description provided for @topicWorkBusinessLabel.
  ///
  /// In en, this message translates to:
  /// **'Work & Business'**
  String get topicWorkBusinessLabel;

  /// No description provided for @topicWorkBusinessDescription.
  ///
  /// In en, this message translates to:
  /// **'Meetings, emails, calls, and workplace conversations.'**
  String get topicWorkBusinessDescription;

  /// No description provided for @topicJobInterviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Job Interview'**
  String get topicJobInterviewLabel;

  /// No description provided for @topicJobInterviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice common interview questions and answers.'**
  String get topicJobInterviewDescription;

  /// No description provided for @topicRestaurantCafeLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant & Cafe'**
  String get topicRestaurantCafeLabel;

  /// No description provided for @topicRestaurantCafeDescription.
  ///
  /// In en, this message translates to:
  /// **'Ordering food, booking tables, and polite requests.'**
  String get topicRestaurantCafeDescription;

  /// No description provided for @topicFreeConversationLabel.
  ///
  /// In en, this message translates to:
  /// **'Free Conversation'**
  String get topicFreeConversationLabel;

  /// No description provided for @topicFreeConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'Open-ended practice shaped around what you want to say.'**
  String get topicFreeConversationDescription;

  /// No description provided for @situationIntroductionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Introductions'**
  String get situationIntroductionsLabel;

  /// No description provided for @situationIntroductionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Introduce yourself and ask basic personal questions.'**
  String get situationIntroductionsDescription;

  /// No description provided for @situationSmallTalkNeighborLabel.
  ///
  /// In en, this message translates to:
  /// **'Talk with a neighbor'**
  String get situationSmallTalkNeighborLabel;

  /// No description provided for @situationSmallTalkNeighborDescription.
  ///
  /// In en, this message translates to:
  /// **'Have a short friendly conversation near home.'**
  String get situationSmallTalkNeighborDescription;

  /// No description provided for @situationAskingForHelpLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask for help'**
  String get situationAskingForHelpLabel;

  /// No description provided for @situationAskingForHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask for help in a simple everyday situation.'**
  String get situationAskingForHelpDescription;

  /// No description provided for @situationMakingPlansLabel.
  ///
  /// In en, this message translates to:
  /// **'Make plans'**
  String get situationMakingPlansLabel;

  /// No description provided for @situationMakingPlansDescription.
  ///
  /// In en, this message translates to:
  /// **'Plan an activity and agree on time and place.'**
  String get situationMakingPlansDescription;

  /// No description provided for @situationTalkingAboutDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Talk about your day'**
  String get situationTalkingAboutDayLabel;

  /// No description provided for @situationTalkingAboutDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe your day and daily routine.'**
  String get situationTalkingAboutDayDescription;

  /// No description provided for @situationAirportCheckInLabel.
  ///
  /// In en, this message translates to:
  /// **'Airport check-in'**
  String get situationAirportCheckInLabel;

  /// No description provided for @situationAirportCheckInDescription.
  ///
  /// In en, this message translates to:
  /// **'Check in for a flight and confirm travel details.'**
  String get situationAirportCheckInDescription;

  /// No description provided for @situationHotelCheckInLabel.
  ///
  /// In en, this message translates to:
  /// **'Hotel check-in'**
  String get situationHotelCheckInLabel;

  /// No description provided for @situationHotelCheckInDescription.
  ///
  /// In en, this message translates to:
  /// **'Check in at a hotel and ask common questions.'**
  String get situationHotelCheckInDescription;

  /// No description provided for @situationAskingForDirectionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask for directions'**
  String get situationAskingForDirectionsLabel;

  /// No description provided for @situationAskingForDirectionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask for and understand directions in a new city.'**
  String get situationAskingForDirectionsDescription;

  /// No description provided for @situationOrderingTransportLabel.
  ///
  /// In en, this message translates to:
  /// **'Order transport'**
  String get situationOrderingTransportLabel;

  /// No description provided for @situationOrderingTransportDescription.
  ///
  /// In en, this message translates to:
  /// **'Arrange a taxi or rideshare to your destination.'**
  String get situationOrderingTransportDescription;

  /// No description provided for @situationLostLuggageLabel.
  ///
  /// In en, this message translates to:
  /// **'Lost luggage'**
  String get situationLostLuggageLabel;

  /// No description provided for @situationLostLuggageDescription.
  ///
  /// In en, this message translates to:
  /// **'Report lost baggage and explain your situation.'**
  String get situationLostLuggageDescription;

  /// No description provided for @situationFirstMeetingLabel.
  ///
  /// In en, this message translates to:
  /// **'First meeting'**
  String get situationFirstMeetingLabel;

  /// No description provided for @situationFirstMeetingDescription.
  ///
  /// In en, this message translates to:
  /// **'Introduce yourself in a new work meeting.'**
  String get situationFirstMeetingDescription;

  /// No description provided for @situationDailyStandupLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily standup'**
  String get situationDailyStandupLabel;

  /// No description provided for @situationDailyStandupDescription.
  ///
  /// In en, this message translates to:
  /// **'Give a short update about your tasks.'**
  String get situationDailyStandupDescription;

  /// No description provided for @situationClientPhoneCallLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone call with a client'**
  String get situationClientPhoneCallLabel;

  /// No description provided for @situationClientPhoneCallDescription.
  ///
  /// In en, this message translates to:
  /// **'Handle a polite and clear business call.'**
  String get situationClientPhoneCallDescription;

  /// No description provided for @situationAskingForClarificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask for clarification'**
  String get situationAskingForClarificationLabel;

  /// No description provided for @situationAskingForClarificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask follow-up questions to confirm requirements.'**
  String get situationAskingForClarificationDescription;

  /// No description provided for @situationDiscussingDeadlinesLabel.
  ///
  /// In en, this message translates to:
  /// **'Discuss deadlines'**
  String get situationDiscussingDeadlinesLabel;

  /// No description provided for @situationDiscussingDeadlinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Talk about timelines and delivery expectations.'**
  String get situationDiscussingDeadlinesDescription;

  /// No description provided for @situationTellMeAboutYourselfLabel.
  ///
  /// In en, this message translates to:
  /// **'Tell me about yourself'**
  String get situationTellMeAboutYourselfLabel;

  /// No description provided for @situationTellMeAboutYourselfDescription.
  ///
  /// In en, this message translates to:
  /// **'Give a short, relevant interview-style self-introduction.'**
  String get situationTellMeAboutYourselfDescription;

  /// No description provided for @situationWorkExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Work experience'**
  String get situationWorkExperienceLabel;

  /// No description provided for @situationWorkExperienceDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe previous work, responsibilities, and one result.'**
  String get situationWorkExperienceDescription;

  /// No description provided for @situationStrengthsWeaknessesLabel.
  ///
  /// In en, this message translates to:
  /// **'Strengths and weaknesses'**
  String get situationStrengthsWeaknessesLabel;

  /// No description provided for @situationStrengthsWeaknessesDescription.
  ///
  /// In en, this message translates to:
  /// **'Talk about one strength and one improvement area professionally.'**
  String get situationStrengthsWeaknessesDescription;

  /// No description provided for @situationWhyThisJobLabel.
  ///
  /// In en, this message translates to:
  /// **'Why do you want this job?'**
  String get situationWhyThisJobLabel;

  /// No description provided for @situationWhyThisJobDescription.
  ///
  /// In en, this message translates to:
  /// **'Explain your motivation and connect the role to your skills.'**
  String get situationWhyThisJobDescription;

  /// No description provided for @situationQuestionsAtEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask questions at the end'**
  String get situationQuestionsAtEndLabel;

  /// No description provided for @situationQuestionsAtEndDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask polite, useful questions before the interview finishes.'**
  String get situationQuestionsAtEndDescription;

  /// No description provided for @situationBookingTableLabel.
  ///
  /// In en, this message translates to:
  /// **'Book a table'**
  String get situationBookingTableLabel;

  /// No description provided for @situationBookingTableDescription.
  ///
  /// In en, this message translates to:
  /// **'Call or speak to reserve a table.'**
  String get situationBookingTableDescription;

  /// No description provided for @situationOrderingFoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Order food'**
  String get situationOrderingFoodLabel;

  /// No description provided for @situationOrderingFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Order a meal and ask simple menu questions.'**
  String get situationOrderingFoodDescription;

  /// No description provided for @situationAskingIngredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask about ingredients'**
  String get situationAskingIngredientsLabel;

  /// No description provided for @situationAskingIngredientsDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask about allergies and dish ingredients.'**
  String get situationAskingIngredientsDescription;

  /// No description provided for @situationWrongOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Handle a wrong order'**
  String get situationWrongOrderLabel;

  /// No description provided for @situationWrongOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'Politely explain an issue with your order.'**
  String get situationWrongOrderDescription;

  /// No description provided for @situationPayingBillLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay the bill'**
  String get situationPayingBillLabel;

  /// No description provided for @situationPayingBillDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask for the check and complete payment.'**
  String get situationPayingBillDescription;

  /// No description provided for @situationOpenConversationLabel.
  ///
  /// In en, this message translates to:
  /// **'Open conversation'**
  String get situationOpenConversationLabel;

  /// No description provided for @situationOpenConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice any topic with flexible follow-up.'**
  String get situationOpenConversationDescription;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumStatusLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading Premium status'**
  String get premiumStatusLoadingSemantics;

  /// No description provided for @premiumStatusTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Premium status is temporarily unavailable. Please try again.'**
  String get premiumStatusTemporarilyUnavailable;

  /// No description provided for @premiumStatusSemantics.
  ///
  /// In en, this message translates to:
  /// **'Premium status: {status}'**
  String premiumStatusSemantics(String status);

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// No description provided for @premiumActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice without the daily free-lesson limit.'**
  String get premiumActiveDescription;

  /// No description provided for @premiumEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Premium ends {date}.'**
  String premiumEndsOn(String date);

  /// No description provided for @premiumTrialActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Your Premium trial is active.'**
  String get premiumTrialActiveDescription;

  /// No description provided for @premiumTrialEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Trial ends {date}.'**
  String premiumTrialEndsOn(String date);

  /// No description provided for @freeLessonsRemainingToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No free lessons remaining today.} =1{1 free lesson remaining today.} other{{count} free lessons remaining today.}}'**
  String freeLessonsRemainingToday(num count);

  /// No description provided for @premiumRemovesDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium removes the daily lesson limit.'**
  String get premiumRemovesDailyLimit;

  /// No description provided for @premiumAccountLinked.
  ///
  /// In en, this message translates to:
  /// **'Premium access is linked to your Language Voice Tutor account.'**
  String get premiumAccountLinked;

  /// No description provided for @premiumSharedAcrossClients.
  ///
  /// In en, this message translates to:
  /// **'Your confirmed Premium status is shared across supported Language Voice Tutor clients.'**
  String get premiumSharedAcrossClients;

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'Premium benefits'**
  String get premiumBenefits;

  /// No description provided for @premiumBenefitDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'• Practice without the daily free-lesson cap'**
  String get premiumBenefitDailyLimit;

  /// No description provided for @premiumBenefitAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'• Use the same Premium access across supported devices'**
  String get premiumBenefitAcrossDevices;

  /// No description provided for @premiumBenefitAccountData.
  ///
  /// In en, this message translates to:
  /// **'• Keep your account, progress, history, and learning settings together'**
  String get premiumBenefitAccountData;

  /// No description provided for @getPremium.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get getPremium;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @refreshPremiumStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshPremiumStatus;

  /// No description provided for @billingProviderExplanation.
  ///
  /// In en, this message translates to:
  /// **'Billing changes must be handled through the provider where Premium was purchased.'**
  String get billingProviderExplanation;

  /// No description provided for @googlePlayPurchasesUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Play purchases are not available yet'**
  String get googlePlayPurchasesUnavailableTitle;

  /// No description provided for @restorePurchasesUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases is not available yet'**
  String get restorePurchasesUnavailableTitle;

  /// No description provided for @googlePlayPurchasesUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Purchases will be connected in the next step. This build cannot charge you or activate Premium.'**
  String get googlePlayPurchasesUnavailableDescription;

  /// No description provided for @restorePurchasesUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Google Play restoration will be connected with the billing flow. Your current account status is still loaded from Language Voice Tutor.'**
  String get restorePurchasesUnavailableDescription;

  /// No description provided for @purchasePendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Purchase processing is not confirmed yet. Refresh your status again shortly.'**
  String get purchasePendingConfirmation;

  /// No description provided for @purchaseActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete that request right now. Please try again.'**
  String get purchaseActionFailed;

  /// No description provided for @premiumOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get premiumOk;

  /// No description provided for @leaveLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave lesson?'**
  String get leaveLessonTitle;

  /// No description provided for @leaveLessonDescription.
  ///
  /// In en, this message translates to:
  /// **'Leaving ends this unfinished lesson without creating a summary.'**
  String get leaveLessonDescription;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leaveLesson.
  ///
  /// In en, this message translates to:
  /// **'Leave lesson'**
  String get leaveLesson;

  /// No description provided for @finishLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish lesson?'**
  String get finishLessonTitle;

  /// No description provided for @finishLessonDescription.
  ///
  /// In en, this message translates to:
  /// **'Finish this lesson and view your summary?'**
  String get finishLessonDescription;

  /// No description provided for @continueLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue lesson'**
  String get continueLesson;

  /// No description provided for @gettingHint.
  ///
  /// In en, this message translates to:
  /// **'Getting hint...'**
  String get gettingHint;

  /// No description provided for @dismissHint.
  ///
  /// In en, this message translates to:
  /// **'Dismiss hint'**
  String get dismissHint;

  /// No description provided for @finishingLesson.
  ///
  /// In en, this message translates to:
  /// **'Finishing lesson...'**
  String get finishingLesson;

  /// No description provided for @finishLessonAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to finish the lesson.'**
  String get finishLessonAuthRequired;

  /// No description provided for @finishLessonSessionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This lesson session is no longer available.'**
  String get finishLessonSessionUnavailable;

  /// No description provided for @finishLessonFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not finish the lesson. Please check your connection and try again.'**
  String get finishLessonFailed;

  /// No description provided for @lessonFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get lessonFeedback;

  /// No description provided for @loadingLessonFeedback.
  ///
  /// In en, this message translates to:
  /// **'Loading feedback...'**
  String get loadingLessonFeedback;

  /// No description provided for @showLessonFeedback.
  ///
  /// In en, this message translates to:
  /// **'Show feedback'**
  String get showLessonFeedback;

  /// No description provided for @hideLessonFeedback.
  ///
  /// In en, this message translates to:
  /// **'Hide feedback'**
  String get hideLessonFeedback;

  /// No description provided for @retryLessonFeedback.
  ///
  /// In en, this message translates to:
  /// **'Retry feedback'**
  String get retryLessonFeedback;

  /// No description provided for @feedbackNotReady.
  ///
  /// In en, this message translates to:
  /// **'Feedback is not ready yet. Please try again.'**
  String get feedbackNotReady;

  /// No description provided for @feedbackQuickSummary.
  ///
  /// In en, this message translates to:
  /// **'Quick summary'**
  String get feedbackQuickSummary;

  /// No description provided for @feedbackCorrectedVersion.
  ///
  /// In en, this message translates to:
  /// **'Corrected version'**
  String get feedbackCorrectedVersion;

  /// No description provided for @feedbackGrammarTip.
  ///
  /// In en, this message translates to:
  /// **'Grammar tip'**
  String get feedbackGrammarTip;

  /// No description provided for @feedbackVocabularyTip.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary tip'**
  String get feedbackVocabularyTip;

  /// No description provided for @feedbackCultureTip.
  ///
  /// In en, this message translates to:
  /// **'Culture tip'**
  String get feedbackCultureTip;

  /// No description provided for @feedbackNaturalVersion.
  ///
  /// In en, this message translates to:
  /// **'More natural version'**
  String get feedbackNaturalVersion;

  /// No description provided for @lessonFeedbackAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue the lesson.'**
  String get lessonFeedbackAuthRequired;

  /// No description provided for @lessonFeedbackSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'This lesson has already ended.'**
  String get lessonFeedbackSessionEnded;

  /// No description provided for @lessonFeedbackNotAvailableForMessage.
  ///
  /// In en, this message translates to:
  /// **'Feedback is not available for this message.'**
  String get lessonFeedbackNotAvailableForMessage;

  /// No description provided for @lessonFeedbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get feedback. Please try again.'**
  String get lessonFeedbackFailed;

  /// No description provided for @lessonStartBlocked.
  ///
  /// In en, this message translates to:
  /// **'You have used today\'s free lesson. Please try again tomorrow or upgrade.'**
  String get lessonStartBlocked;

  /// No description provided for @lessonStartConflict.
  ///
  /// In en, this message translates to:
  /// **'You already have an active lesson. Finish or leave it before starting a new one.'**
  String get lessonStartConflict;

  /// No description provided for @lessonStartAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to start a lesson.'**
  String get lessonStartAuthRequired;

  /// No description provided for @lessonStartUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not start the lesson. Please check your connection and try again.'**
  String get lessonStartUnavailable;

  /// No description provided for @lessonStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the lesson. Please try again.'**
  String get lessonStartFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
