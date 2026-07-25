// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Language Voice Tutor';

  @override
  String get settings => '設定';

  @override
  String get profile => 'プロフィール';

  @override
  String get app => 'アプリ';

  @override
  String get saveSettings => '設定を保存';

  @override
  String get saving => '保存中...';

  @override
  String get settingsSaved => '設定を保存しました。';

  @override
  String get unableToSaveSettings => '現在、設定を保存できません。';

  @override
  String get learning => '学習';

  @override
  String get studyLanguage => '学習言語';

  @override
  String get nativeLanguage => '母語';

  @override
  String get interfaceLanguage => 'インターフェース言語';

  @override
  String get interfaceExplanationLanguage => 'インターフェース／説明言語';

  @override
  String get interfaceLanguageDescription => 'アプリのインターフェースの言語のみを変更します。';

  @override
  String get currentLevel => '現在のレベル';

  @override
  String get selectedTutor => '選択中のチューター';

  @override
  String get loadingSettings => '設定を読み込み中...';

  @override
  String get unableToLoadSettings => '現在、設定を読み込めません。';

  @override
  String get retry => '再試行';

  @override
  String get back => '戻る';

  @override
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get displayNameOptional => '表示名（任意）';

  @override
  String get signIn => 'ログイン';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get unableToCheckSession => 'セッションを確認できません。もう一度お試しください。';

  @override
  String get lessons => 'レッスン';

  @override
  String get lessonHistory => 'レッスン履歴';

  @override
  String get progress => '進捗';

  @override
  String get rewards => '報酬';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get achievements => '実績';

  @override
  String get account => 'アカウント';

  @override
  String get logout => 'ログアウト';

  @override
  String get audio => '音声';

  @override
  String get feedbackAndReports => 'フィードバックと報告';

  @override
  String get cancel => 'キャンセル';

  @override
  String get submit => '送信';

  @override
  String get send => '送信';

  @override
  String get done => '完了';

  @override
  String get openAndroidSettings => 'Android の設定を開く';

  @override
  String get hint => 'ヒント';

  @override
  String get finishLesson => 'レッスンを終了';

  @override
  String get typeYourMessage => 'メッセージを入力';

  @override
  String get sending => '送信中...';

  @override
  String get languageNameEnglish => '英語';

  @override
  String get languageNameRussian => 'ロシア語';

  @override
  String get languageNameSpanish => 'スペイン語';

  @override
  String get languageNameFrench => 'フランス語';

  @override
  String get languageNameGerman => 'ドイツ語';

  @override
  String get signInToApp => 'Language Voice Tutor にログイン';

  @override
  String get pleaseWait => 'お待ちください...';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちです';

  @override
  String get invalidEmail => '有効なメールアドレスを入力してください。';

  @override
  String get enterPassword => 'パスワードを入力してください。';

  @override
  String get chooseTopic => 'トピックを選択';

  @override
  String get chooseTopicTitle => 'トピックを選択';

  @override
  String get chooseTopicSubtitle => '練習したい会話の種類を選んでください。';

  @override
  String get chooseSituation => '場面を選択';

  @override
  String get chooseSituationTitle => '場面を選択';

  @override
  String get chooseSituationSubtitle => 'このトピックの具体的な場面を一つ練習しましょう。';

  @override
  String get viewAllRewards => 'すべてのバッジと学習報酬を表示します。';

  @override
  String get accountDeletion => 'アカウントの削除';

  @override
  String get requestAccountDeletion => 'アカウント削除をリクエスト';

  @override
  String get loadingAccount => 'アカウントを読み込み中...';

  @override
  String get premiumAndSubscription => 'Premium とサブスクリプション';

  @override
  String get currentPassword => '現在のパスワード';

  @override
  String get reasonOptional => '理由（任意）';

  @override
  String get submitting => '送信中...';

  @override
  String get loadingTutors => 'チューターを読み込み中...';

  @override
  String get noTutorsAvailable => '現在利用可能なチューターはいません。';

  @override
  String get loadingAudioSettings => '音声設定を読み込み中...';

  @override
  String get conversationModeEnabled => '会話モードが有効';

  @override
  String get sendSuggestionOrReport => '提案を送信または問題を報告';

  @override
  String get reportType => '報告の種類';

  @override
  String get pasteAiResponseOptional => 'AI の応答を貼り付け（任意）';

  @override
  String get lessonHistoryHeading => '最近完了したレッスン';

  @override
  String get noCompletedLessons => 'まだ完了したレッスンはありません';

  @override
  String get completedLessonsAppearHere => '完了したレッスンがここに表示されます。';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get lesson => 'レッスン';

  @override
  String get level => 'レベル';

  @override
  String get completed => '完了';

  @override
  String get finished => '終了';

  @override
  String get lessonChat => 'レッスンチャット';

  @override
  String get conversation => '会話';

  @override
  String turnCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countターン',
      one: '1ターン',
    );
    return '$_temp0';
  }

  @override
  String get achievementsUnavailable => 'まだ利用可能な実績はありません。';

  @override
  String unlockedCount(num unlocked, num total) {
    return '$unlocked / $total 件解除済み';
  }

  @override
  String learningLanguage(String language) {
    return '$languageを学習中';
  }

  @override
  String get streaks => '連続学習';

  @override
  String get lessonMilestones => 'レッスンのマイルストーン';

  @override
  String get topics => 'トピック';

  @override
  String get situations => '場面';

  @override
  String get otherAchievements => 'その他の実績';

  @override
  String progressCount(num current, num total) {
    return '$current / $total';
  }

  @override
  String get startLesson => 'レッスンを開始';

  @override
  String get openSettings => '設定を開く';

  @override
  String get keepLearningRhythm => '学習のリズムを保つ';

  @override
  String get reminderPermissionExplanation =>
      'Language Voice Tutor は、忙しい一日でも練習を忘れないよう、毎日2件の楽しいリマインダーを送信できます。設定で時刻を変更したり、リマインダーをオフにしたりできます。';

  @override
  String get notNow => '今はしない';

  @override
  String get allowReminders => 'リマインダーを許可';

  @override
  String get achievementsTemporarilyUnavailable => '実績は一時的に利用できません';

  @override
  String get achievementsEmpty => '実績がここに表示されます。';

  @override
  String learningStreak(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日連続学習',
      one: '1日連続学習',
    );
    return '$_temp0';
  }

  @override
  String get learningStreakLoading => '連続学習を読み込み中';

  @override
  String get learningStreakUnavailable => '連続学習の記録は利用できません';

  @override
  String get learnerFallbackName => '学習者';

  @override
  String get premiumPlan => 'Premium プラン';

  @override
  String get premiumTrial => 'Premium 無料トライアル';

  @override
  String get freePlan => '無料プラン';

  @override
  String signedInAs(String name) {
    return '$nameとしてログイン中';
  }

  @override
  String get premiumDetails => 'Premium の詳細';

  @override
  String get explorePremium => 'Premium を確認';

  @override
  String freeLessonsAvailableToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今日利用できる無料レッスンは$count件',
      one: '今日利用できる無料レッスンは1件',
    );
    return '$_temp0';
  }

  @override
  String get yourWeek => '今週';

  @override
  String lessonsLastSevenDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '過去7日間のレッスンは$count件',
      one: '過去7日間のレッスンは1件',
    );
    return '$_temp0';
  }

  @override
  String get startStreakToday => '今日から連続学習を始めましょう';

  @override
  String get activityUnavailable => '現在、アクティビティを利用できません。';

  @override
  String lessonsCompleted(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレッスンを完了',
      one: '1件のレッスンを完了',
    );
    return '$_temp0';
  }

  @override
  String activityDaySemantics(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '完了したレッスン$count件',
      one: '完了したレッスン1件',
    );
    return '$date：$_temp0';
  }

  @override
  String get weekdayMon => '月';

  @override
  String get weekdayTue => '火';

  @override
  String get weekdayWed => '水';

  @override
  String get weekdayThu => '木';

  @override
  String get weekdayFri => '金';

  @override
  String get weekdaySat => '土';

  @override
  String get weekdaySun => '日';

  @override
  String get remindersTemporarilyUnavailable => '練習リマインダーは一時的に利用できません。';

  @override
  String get unableToUpdateReminders => '現在リマインダーを更新できません。もう一度お試しください。';

  @override
  String get unableToLoadAccount => '現在アカウント情報を読み込めません。';

  @override
  String get tutorChoicesUnavailable => '現在チューターを選択できません。ほかの設定は確認して保存できます。';

  @override
  String get pleaseEnterDescription => '説明を入力してください。';

  @override
  String get emailRequired => 'メールアドレスは必須です。';

  @override
  String get resetCodePasswordRequired => 'リセットコードと新しいパスワードは必須です。';

  @override
  String get passwordsMustMatch => '新しいパスワードと確認用パスワードが一致しません。';

  @override
  String get signInToChangePassword => 'パスワードを変更するにはログインしてください。';

  @override
  String get currentPasswordRequired => '現在のパスワードは必須です。';

  @override
  String get accountDeletionDescription =>
      'Language Voice Tutor のアカウントと個人データを完全に削除するリクエストを送信します。';

  @override
  String get accountDeletionNotice =>
      'このリクエストを送信しても、アカウントはすぐには削除されません。サポートが確認して処理し、追加情報を求める場合があります。回答はアカウントに登録されたメールアドレスに送信されます。このリクエストを送信しただけでは、アカウントは削除されたものとは見なされません。';

  @override
  String get noDisplayName => '表示名なし';

  @override
  String get subscriptionUnavailable => 'サブスクリプションを利用できません';

  @override
  String get noPaidPlan => '有料プランなし';

  @override
  String requestId(String id) {
    return 'リクエスト ID：$id';
  }

  @override
  String statusValue(String status) {
    return 'ステータス：$status';
  }

  @override
  String get passwordRecovery => 'パスワードと復旧';

  @override
  String get accountEmail => 'アカウントのメールアドレス';

  @override
  String get sendingResetInstructions => 'リセット手順を送信中...';

  @override
  String get forgotPassword => 'パスワードを忘れた場合';

  @override
  String get resetCode => 'リセットコード';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get confirmNewPassword => '新しいパスワードを確認';

  @override
  String get updatingPassword => 'パスワードを更新中...';

  @override
  String get resetPassword => 'パスワードをリセット';

  @override
  String get newAccountPassword => '新しいアカウントのパスワード';

  @override
  String get confirmNewAccountPassword => '新しいアカウントのパスワードを確認';

  @override
  String get changingPassword => 'パスワードを変更中...';

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get tutorVoice => 'チューターの音声';

  @override
  String speechSpeed(String speed) {
    return '話す速さ：${speed}x';
  }

  @override
  String get feedbackSuggestion => '提案';

  @override
  String get feedbackAppProblem => 'アプリの問題';

  @override
  String get feedbackAiResponse => 'AI の応答';

  @override
  String get yourSuggestion => 'あなたの提案';

  @override
  String get describeProblem => '問題を説明してください';

  @override
  String get aiResponseProblem => 'AI の応答のどこに問題がありましたか？';

  @override
  String get practiceReminders => '練習リマインダー';

  @override
  String get localRemindersDescription => 'これらのリマインダーはこの端末内でのみ有効です。';

  @override
  String get dailyPracticeReminders => '毎日の練習リマインダー';

  @override
  String get morningReminder => '朝のリマインダー';

  @override
  String get eveningReminder => '夜のリマインダー';

  @override
  String get notificationsAllowed => '通知を許可済み';

  @override
  String get notificationStatusUnavailable => '通知の状態を取得できません';

  @override
  String get notificationsBlocked => 'Android により通知がブロックされています。';

  @override
  String get allowNotifications => '通知を許可';

  @override
  String get feedbackReceived => 'ありがとうございます。メッセージを受け取りました。';

  @override
  String get feedbackValidationFailure => 'メッセージを確認して、もう一度お試しください。';

  @override
  String get feedbackUnavailable => 'フィードバックは一時的に利用できません。もう一度お試しください。';

  @override
  String get deletionRequestAlreadyExists => '有効なアカウント削除リクエストがすでにあります。';

  @override
  String get deletionRequestSubmitted => 'アカウント削除リクエストがサポートでの処理に送信されました。';

  @override
  String get incorrectCurrentPassword => '現在のパスワードが正しくありません。';

  @override
  String get unableToReachService => 'サービスに接続できません。もう一度お試しください。';

  @override
  String get unexpectedServiceResponse => 'サービスから予期しない応答が返されました。もう一度お試しください。';

  @override
  String get unableToSubmitRequest => '現在リクエストを送信できません。もう一度お試しください。';

  @override
  String get unableToLoadLearningSettings => '現在、学習設定を読み込めません。もう一度お試しください。';

  @override
  String get settingsTemporarilyUnavailable => '設定は一時的に利用できません。もう一度お試しください。';

  @override
  String selectedLevelContext(String level) {
    return 'レベル：$level';
  }

  @override
  String selectedLevelTopicContext(String level, String topic) {
    return 'レベル：$level／トピック：$topic';
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
    return '$topicを開く';
  }

  @override
  String openSituationTooltip(String situation) {
    return '$situationを開く';
  }

  @override
  String get noSituationsAvailable => 'このトピックで利用できる場面はありません。';

  @override
  String get levelA1Label => 'A1 入門';

  @override
  String get levelA1Description => '簡単な挨拶や希望の伝え方、日常的な短い返答を身につけます。';

  @override
  String get levelA2Label => 'A2 初級';

  @override
  String get levelA2Description => 'よく知っている単語や表現を使って、日常的な会話をします。';

  @override
  String get levelB1Label => 'B1 中級';

  @override
  String get levelB1Description => 'より長い会話、意見の表現、日常的な問題解決を練習します。';

  @override
  String get levelB2Label => 'B2 中上級';

  @override
  String get levelB2Description => 'より自然な細部を交えた、ニュアンスのある会話を磨きます。';

  @override
  String get topicDailyLifeLabel => '日常生活';

  @override
  String get topicDailyLifeDescription => '雑談、自己紹介、日常の場面。';

  @override
  String get topicTravelLabel => '旅行';

  @override
  String get topicTravelDescription => '空港、ホテル、道案内、交通機関。';

  @override
  String get topicWorkBusinessLabel => '仕事とビジネス';

  @override
  String get topicWorkBusinessDescription => '会議、メール、電話、職場での会話。';

  @override
  String get topicJobInterviewLabel => '就職面接';

  @override
  String get topicJobInterviewDescription => 'よくある面接の質問と回答を練習します。';

  @override
  String get topicRestaurantCafeLabel => 'レストランとカフェ';

  @override
  String get topicRestaurantCafeDescription => '料理の注文、席の予約、丁寧な依頼。';

  @override
  String get topicFreeConversationLabel => '自由会話';

  @override
  String get topicFreeConversationDescription => '話したいことに合わせた自由な練習。';

  @override
  String get situationIntroductionsLabel => '自己紹介';

  @override
  String get situationIntroductionsDescription => '自己紹介をして、基本的な個人的な質問をします。';

  @override
  String get situationSmallTalkNeighborLabel => '近所の人と話す';

  @override
  String get situationSmallTalkNeighborDescription => '家の近くで短く親しみのある会話をします。';

  @override
  String get situationAskingForHelpLabel => '助けを求める';

  @override
  String get situationAskingForHelpDescription => '簡単な日常の場面で助けを求めます。';

  @override
  String get situationMakingPlansLabel => '予定を立てる';

  @override
  String get situationMakingPlansDescription => '活動を計画し、時間と場所を決めます。';

  @override
  String get situationTalkingAboutDayLabel => '一日について話す';

  @override
  String get situationTalkingAboutDayDescription => '一日と日課について説明します。';

  @override
  String get situationAirportCheckInLabel => '空港でのチェックイン';

  @override
  String get situationAirportCheckInDescription => 'フライトのチェックインをし、旅行の詳細を確認します。';

  @override
  String get situationHotelCheckInLabel => 'ホテルでのチェックイン';

  @override
  String get situationHotelCheckInDescription => 'ホテルでチェックインし、よくある質問をします。';

  @override
  String get situationAskingForDirectionsLabel => '道を尋ねる';

  @override
  String get situationAskingForDirectionsDescription => '新しい街で道を尋ね、案内を理解します。';

  @override
  String get situationOrderingTransportLabel => '交通手段を手配する';

  @override
  String get situationOrderingTransportDescription =>
      '目的地までのタクシーや配車サービスを手配します。';

  @override
  String get situationLostLuggageLabel => '荷物の紛失';

  @override
  String get situationLostLuggageDescription => '紛失した手荷物を届け出て、状況を説明します。';

  @override
  String get situationFirstMeetingLabel => '初めての会議';

  @override
  String get situationFirstMeetingDescription => '新しい職場の会議で自己紹介をします。';

  @override
  String get situationDailyStandupLabel => 'デイリースタンドアップ';

  @override
  String get situationDailyStandupDescription => '担当作業について短く報告します。';

  @override
  String get situationClientPhoneCallLabel => '顧客との電話';

  @override
  String get situationClientPhoneCallDescription => '丁寧で明確なビジネス電話に対応します。';

  @override
  String get situationAskingForClarificationLabel => '説明を求める';

  @override
  String get situationAskingForClarificationDescription =>
      '要件を確認するために追加の質問をします。';

  @override
  String get situationDiscussingDeadlinesLabel => '締め切りについて話す';

  @override
  String get situationDiscussingDeadlinesDescription => '予定と納品に対する期待について話します。';

  @override
  String get situationTellMeAboutYourselfLabel => '自己紹介をしてください';

  @override
  String get situationTellMeAboutYourselfDescription =>
      '面接のように、短く関連性のある自己紹介をします。';

  @override
  String get situationWorkExperienceLabel => '職務経験';

  @override
  String get situationWorkExperienceDescription => 'これまでの仕事、責任、成果を一つ説明します。';

  @override
  String get situationStrengthsWeaknessesLabel => '長所と短所';

  @override
  String get situationStrengthsWeaknessesDescription =>
      '一つの長所と改善点について、専門的に話します。';

  @override
  String get situationWhyThisJobLabel => 'この仕事を希望する理由';

  @override
  String get situationWhyThisJobDescription => '動機を説明し、役割とスキルを結び付けます。';

  @override
  String get situationQuestionsAtEndLabel => '最後に質問する';

  @override
  String get situationQuestionsAtEndDescription => '面接が終わる前に、丁寧で役立つ質問をします。';

  @override
  String get situationBookingTableLabel => 'テーブルを予約する';

  @override
  String get situationBookingTableDescription => '電話または直接話して、テーブルを予約します。';

  @override
  String get situationOrderingFoodLabel => '料理を注文する';

  @override
  String get situationOrderingFoodDescription => '食事を注文し、メニューについて簡単な質問をします。';

  @override
  String get situationAskingIngredientsLabel => '食材について尋ねる';

  @override
  String get situationAskingIngredientsDescription => 'アレルギーと料理の材料について尋ねる';

  @override
  String get situationWrongOrderLabel => '注文間違いに対応する';

  @override
  String get situationWrongOrderDescription => '注文の問題を丁寧に説明します。';

  @override
  String get situationPayingBillLabel => '支払いをする';

  @override
  String get situationPayingBillDescription => 'お会計を頼み、支払いを完了します。';

  @override
  String get situationOpenConversationLabel => '自由会話';

  @override
  String get situationOpenConversationDescription =>
      '柔軟な追加質問を交えながら、どのトピックでも練習します。';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatusLoadingSemantics => 'Premium の状態を読み込み中';

  @override
  String get premiumStatusTemporarilyUnavailable =>
      'Premium の状態は一時的に利用できません。もう一度お試しください。';

  @override
  String premiumStatusSemantics(String status) {
    return 'Premium の状態：$status';
  }

  @override
  String get premiumActive => 'Premium が有効です';

  @override
  String get premiumActiveDescription => '毎日の無料レッスン制限なしで練習できます。';

  @override
  String premiumEndsOn(String date) {
    return 'Premium は $date に終了します。';
  }

  @override
  String get premiumTrialActiveDescription => 'Premium の無料トライアルが有効です。';

  @override
  String premiumTrialEndsOn(String date) {
    return 'トライアルは $date に終了します。';
  }

  @override
  String freeLessonsRemainingToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今日利用できる無料レッスンは$count件です。',
      one: '今日利用できる無料レッスンは1件です。',
      zero: '今日利用できる無料レッスンはありません。',
    );
    return '$_temp0';
  }

  @override
  String get premiumRemovesDailyLimit => 'Premium では毎日のレッスン制限がなくなります。';

  @override
  String get premiumAccountLinked =>
      'Premium の利用権は Language Voice Tutor のアカウントに紐付けられています。';

  @override
  String get premiumSharedAcrossClients =>
      '確認済みの Premium 状態は、対応する Language Voice Tutor クライアント間で共有されます。';

  @override
  String get premiumBenefits => 'Premium の特典';

  @override
  String get premiumBenefitDailyLimit => '• 毎日の無料レッスン制限なしで練習';

  @override
  String get premiumBenefitAcrossDevices => '• 対応する端末で同じ Premium 利用権を使用';

  @override
  String get premiumBenefitAccountData => '• アカウント、進捗、履歴、学習設定をまとめて管理';

  @override
  String get getPremium => 'Premium を入手';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get refreshPremiumStatus => '状態を更新';

  @override
  String get billingProviderExplanation =>
      '請求の変更は、Premium を購入した提供元で処理する必要があります。';

  @override
  String get googlePlayPurchasesUnavailableTitle => 'Google Play の購入はまだ利用できません';

  @override
  String get restorePurchasesUnavailableTitle => '購入の復元はまだ利用できません';

  @override
  String get googlePlayPurchasesUnavailableDescription =>
      '購入は次の手順で接続されます。このビルドでは請求や Premium の有効化はできません。';

  @override
  String get restorePurchasesUnavailableDescription =>
      'Google Play での購入復元は請求フローに接続されます。現在のアカウント状態は引き続き Language Voice Tutor から読み込まれます。';

  @override
  String get purchasePendingConfirmation =>
      '購入処理はまだ確認されていません。しばらくしてから状態を更新してください。';

  @override
  String get purchaseActionFailed => '現在、そのリクエストを完了できません。もう一度お試しください。';

  @override
  String get premiumOk => '確認';

  @override
  String get leaveLessonTitle => 'レッスンを退出しますか？';

  @override
  String get leaveLessonDescription => '退出すると、この未完了のレッスンは要約を作成せずに終了します。';

  @override
  String get stay => '続ける';

  @override
  String get leaveLesson => 'レッスンを退出';

  @override
  String get finishLessonTitle => 'レッスンを終了しますか？';

  @override
  String get finishLessonDescription => 'このレッスンを終了して要約を表示しますか？';

  @override
  String get continueLesson => 'レッスンを続ける';

  @override
  String get gettingHint => 'ヒントを取得中...';

  @override
  String get dismissHint => 'ヒントを閉じる';

  @override
  String get finishingLesson => 'レッスンを終了中...';

  @override
  String get finishLessonAuthRequired => 'レッスンを終了するには、もう一度ログインしてください。';

  @override
  String get finishLessonSessionUnavailable => 'このレッスンのセッションは利用できなくなりました。';

  @override
  String get finishLessonFailed => 'レッスンを終了できません。接続を確認して、もう一度お試しください。';

  @override
  String get lessonFeedback => 'フィードバック';

  @override
  String get loadingLessonFeedback => 'フィードバックを読み込み中...';

  @override
  String get showLessonFeedback => 'フィードバックを表示';

  @override
  String get hideLessonFeedback => 'フィードバックを隠す';

  @override
  String get retryLessonFeedback => 'フィードバックを再試行';

  @override
  String get feedbackNotReady => 'フィードバックはまだ準備できていません。もう一度お試しください。';

  @override
  String get feedbackQuickSummary => '簡易要約';

  @override
  String get feedbackCorrectedVersion => '修正済みバージョン';

  @override
  String get feedbackGrammarTip => '文法のヒント';

  @override
  String get feedbackVocabularyTip => '語彙のヒント';

  @override
  String get feedbackCultureTip => '文化に関するヒント';

  @override
  String get feedbackNaturalVersion => 'より自然なバージョン';

  @override
  String get lessonFeedbackAuthRequired => 'レッスンを続けるには、もう一度ログインしてください。';

  @override
  String get lessonFeedbackSessionEnded => 'このレッスンはすでに終了しています。';

  @override
  String get lessonFeedbackNotAvailableForMessage => 'このメッセージのフィードバックは利用できません。';

  @override
  String get lessonFeedbackFailed => 'フィードバックを取得できません。もう一度お試しください。';

  @override
  String get lessonStartBlocked =>
      '今日の無料レッスンを使い切りました。明日もう一度お試しいただくか、アップグレードしてください。';

  @override
  String get lessonStartConflict =>
      'すでに進行中のレッスンがあります。新しいレッスンを始める前に終了するか退出してください。';

  @override
  String get lessonStartAuthRequired => 'レッスンを始めるには、もう一度ログインしてください。';

  @override
  String get lessonStartUnavailable => 'レッスンを開始できません。接続を確認して、もう一度お試しください。';

  @override
  String get lessonStartFailed => 'レッスンを開始できません。もう一度お試しください。';

  @override
  String get lessonSummary => 'レッスンの要約';

  @override
  String get lessonCompleted => 'レッスンを完了しました';

  @override
  String get summaryWhatWentWell => 'うまくできたこと';

  @override
  String get summaryStrengths => '強み';

  @override
  String get summaryImprovements => '改善点';

  @override
  String get summaryVocabulary => '語彙';

  @override
  String get summaryGrammar => '文法';

  @override
  String get summaryNextSteps => '次のステップ';

  @override
  String get retrySummary => '要約を再試行';

  @override
  String get summaryUnavailableMessage => 'レッスンは保存されましたが、このレッスンの要約を作成できませんでした。';

  @override
  String get summaryAuthRequiredMessage => 'レッスンの要約を読み込むには、もう一度ログインしてください。';

  @override
  String get summaryLoadErrorMessage => 'レッスンは保存されましたが、現在要約を読み込めません。';

  @override
  String get startRecording => '録音を開始';

  @override
  String get stopRecording => '録音を停止';

  @override
  String get progressCompletedLessons => '完了したレッスン';

  @override
  String get progressAllTime => '全期間';

  @override
  String get progressLast7Days => '過去7日間';

  @override
  String get progressLast30Days => '過去30日間';

  @override
  String get progressCurrentStreak => '現在の連続記録';

  @override
  String get progressLongestStreak => '最長連続記録';

  @override
  String get progressRecentActivity => '最近のアクティビティ';

  @override
  String get progressLastCompletedLesson => '最後に完了したレッスン';

  @override
  String get progressLessonsByLanguage => '言語別のレッスン';

  @override
  String get progressLessonsByLevel => 'レベル別のレッスン';

  @override
  String get progressEmptyTitle => 'ここに進捗が表示されます';

  @override
  String get progressEmptyDescription => 'レッスンを完了すると、ここに表示されます。';

  @override
  String get progressUnavailable => '進捗は一時的に利用できません。もう一度お試しください。';

  @override
  String get progressLoadFailed => '進捗を読み込めません。もう一度お試しください。';

  @override
  String progressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日',
      one: '1日',
      zero: '0日',
    );
    return '$_temp0';
  }

  @override
  String get achievementsLoadFailed => '実績を読み込めません。もう一度お試しください。';

  @override
  String achievementUnlockedSemantics(String title) {
    return '解除済みの実績：$title';
  }

  @override
  String achievementLockedSemantics(String title, num current, num target) {
    return '未解除の実績：$title。進捗：$current / $target。';
  }

  @override
  String closeAchievementPreview(String title) {
    return '$title の実績プレビューを閉じる';
  }

  @override
  String get closeAllAchievementPreviews => 'すべての実績プレビューを閉じる';

  @override
  String get achievementTitleStreak7 => '7日連続';

  @override
  String get achievementTitleStreak30 => '30日連続';

  @override
  String get achievementTitleStreak60 => '60日連続';

  @override
  String get achievementTitleStreak100 => '100日連続';

  @override
  String get achievementTitleStreak365 => '365日連続';

  @override
  String get achievementTitleLessons1 => '最初の一歩';

  @override
  String get achievementTitleLessons5 => 'スタート';

  @override
  String get achievementTitleLessons10 => '10レッスン達成';

  @override
  String get achievementTitleLessons25 => '着実な学習者';

  @override
  String get achievementTitleLessons50 => '50レッスン達成';

  @override
  String get achievementTitleLessons100 => '100レッスンクラブ';

  @override
  String get achievementTitleDailyLifeIntroductions => '初めてのあいさつ';

  @override
  String get achievementTitleDailyLifeNeighborChat => 'ご近所トーク';

  @override
  String get achievementTitleDailyLifeHelpfulHand => '助けの手';

  @override
  String get achievementTitleDailyLifePlanMaker => '計画名人';

  @override
  String get achievementTitleDailyLifeDayTeller => '一日語り';

  @override
  String get achievementTitleDailyLifeEverydayHero => '日常のヒーロー';

  @override
  String get achievementTitleTravelAirportExpert => '空港の達人';

  @override
  String get achievementTitleTravelHonoredGuest => '大切なお客様';

  @override
  String get achievementTitleTravelCityNavigator => '街のナビゲーター';

  @override
  String get achievementTitleTravelRideReady => '乗車準備完了';

  @override
  String get achievementTitleTravelBaggageFinder => '荷物探しの達人';

  @override
  String get achievementTitleTravelTraveler => '旅人';

  @override
  String get achievementTitleWorkMeetingReady => '会議の準備完了';

  @override
  String get achievementTitleWorkStandupStar => 'スタンドアップスター';

  @override
  String get achievementTitleWorkClientCaller => '顧客コール';

  @override
  String get achievementTitleWorkClearCommunicator => '明快な伝え手';

  @override
  String get achievementTitleWorkDeadlineDriver => '締め切りの達人';

  @override
  String get achievementTitleWorkBusinessReady => 'ビジネスの準備完了';

  @override
  String get achievementTitleInterviewStrongIntroduction => '印象的な自己紹介';

  @override
  String get achievementTitleInterviewCareerStory => 'キャリアストーリー';

  @override
  String get achievementTitleInterviewSelfAwareCandidate => '自己理解のある候補者';

  @override
  String get achievementTitleInterviewRightFit => 'ぴったりの候補者';

  @override
  String get achievementTitleInterviewCuriousCandidate => '好奇心旺盛な候補者';

  @override
  String get achievementTitleInterviewReady => '面接の準備完了';

  @override
  String get achievementTitleRestaurantTableBooker => '予約名人';

  @override
  String get achievementTitleRestaurantMenuExpert => 'メニューの達人';

  @override
  String get achievementTitleRestaurantIngredientGuide => '食材案内人';

  @override
  String get achievementTitleRestaurantOrderFixer => '注文トラブル解決';

  @override
  String get achievementTitleRestaurantBillSettled => 'お会計完了';

  @override
  String get achievementTitleRestaurantDiningPro => '食事の達人';

  @override
  String get autoSendMessage => 'Auto-send message';

  @override
  String get autoPlayTutorVoice => 'Auto-play tutor voice';

  @override
  String get voiceRecognitionUnclear => '音声をはっきり認識できませんでした。もう一度お試しください。';

  @override
  String get microphoneBlockedOpenSettings =>
      'マイクへのアクセスがブロックされています。有効にするには Android の設定を開いてください。';

  @override
  String get microphonePermissionDeniedRetry =>
      'マイクへのアクセスが許可されませんでした。もう一度試すにはマイクをタップしてください。';

  @override
  String get recordingStartFailedCheckMicrophone => '録音を開始できません。マイクを確認してください。';

  @override
  String get recordingStartFailed => '録音を開始できません。もう一度お試しください。';

  @override
  String get recordingTooShort => 'もう少し長い回答を録音してください。';

  @override
  String get recordingStopFailed => '録音を停止できません。もう一度お試しください。';

  @override
  String get recordingProcessingFailed => 'その録音を処理できません。もう一度お試しください。';

  @override
  String get recordingAuthRequired => '録音を使用するには、もう一度ログインしてください。';

  @override
  String get transcriptionTemporarilyUnavailable =>
      '文字起こしは一時的に利用できません。しばらくしてからもう一度お試しください。';

  @override
  String get transcriptionTimedOut => '文字起こしに時間がかかりすぎました。もう一度お試しください。';

  @override
  String get transcriptionConnectionFailed => '文字起こし中に接続に失敗しました。もう一度お試しください。';

  @override
  String get transcriptionFailed => 'その録音を文字起こしできません。もう一度お試しください。';

  @override
  String get voiceTemporarilyUnavailable =>
      '音声は一時的に利用できません。しばらくしてからもう一度お試しください。';

  @override
  String get voicePlaybackFailed => '音声を再生できません。もう一度お試しください。';

  @override
  String get voicePlaybackTimedOut => '音声の再生に時間がかかりすぎました。もう一度お試しください。';

  @override
  String get voicePlaybackStopped => '音声の再生を停止しました。もう一度録音できます。';

  @override
  String get replaceTypedTextTitle => '入力したテキストを置き換えますか？';

  @override
  String get replaceTypedTextDescription => '入力した下書きの代わりに、文字起こしした録音を使用しますか？';

  @override
  String get keepTypedText => '入力したテキストを保持';

  @override
  String get replaceTypedText => '入力したテキストを置き換える';

  @override
  String get transcribingRecording => '録音を文字起こし中...';

  @override
  String get retryLessonContent => 'レッスン内容を再試行';

  @override
  String get translation => '翻訳';

  @override
  String get playVoice => '音声を再生';

  @override
  String get openConversationMode => '自由会話モード';

  @override
  String get conversationPaused => '会話を一時停止しました。もう一度録音できます。';

  @override
  String get tutorReplyTimedOut => 'チューターの応答に時間がかかりすぎました。もう一度お試しください。';

  @override
  String get conversationSendFailed => 'その回答を送信できません。もう一度録音してください。';

  @override
  String get openAndroidSettingsFailed => 'Android の設定を開けません。もう一度お試しください。';

  @override
  String get conversationReady => '会話の準備ができました。';

  @override
  String get tutorAvatarSemantics => 'チューターのアバター';

  @override
  String get lessonContentLoadFailed => 'レッスン内容を読み込めません。もう一度お試しください。';

  @override
  String get lessonHistoryDetails => 'レッスンの詳細';

  @override
  String get historySummary => '要約';

  @override
  String get noHistoryConversation => 'このレッスンで利用できる会話はありません。';

  @override
  String get noHistorySummary => '利用できるレッスンの要約はありません。';

  @override
  String get overallSummary => '全体の要約';

  @override
  String get historyTutor => 'チューター';

  @override
  String get historyYou => 'あなた';

  @override
  String get feedbackCorrectedText => '修正済みテキスト';

  @override
  String get feedbackExplanation => '説明';

  @override
  String get feedbackPraise => '称賛';

  @override
  String get lessonUnavailable => 'そのレッスンは利用できません。';

  @override
  String get lessonNoLongerAvailable => 'このレッスンは利用できなくなりました。';

  @override
  String get lessonHistoryUnavailable => 'レッスン履歴は一時的に利用できません。もう一度お試しください。';

  @override
  String get lessonDetailLoadFailed => 'レッスンの詳細を読み込めません。もう一度お試しください。';
}
