class PracticeReminderMessages {
  const PracticeReminderMessages({
    required this.morningTitle,
    required this.morningBody,
    required this.eveningTitle,
    required this.eveningBody,
  });

  final String morningTitle;
  final String morningBody;
  final String eveningTitle;
  final String eveningBody;

  static const _english = PracticeReminderMessages(
    morningTitle: 'Ready for a tiny language win? 🌞',
    morningBody:
        'A few minutes of practice today can make a big difference. Let’s go!',
    eveningTitle: 'Keep your streak glowing! 🔥',
    eveningBody:
        'There’s still time for a quick lesson and one more win today.',
  );

  static const Map<String, PracticeReminderMessages> _byLanguageId = {
    'en': _english,
    'ru': PracticeReminderMessages(
      morningTitle: 'Готовы к маленькой языковой победе? 🌞',
      morningBody:
          'Несколько минут практики сегодня могут многое изменить. Начнём!',
      eveningTitle: 'Поддержите свою серию! 🔥',
      eveningBody: 'Ещё есть время на короткий урок и ещё одну победу сегодня.',
    ),
    'es': PracticeReminderMessages(
      morningTitle: '¿Qué tal una pequeña victoria con el idioma? 🌞',
      morningBody:
          'Unos minutos de práctica hoy pueden marcar una gran diferencia. ¡Vamos!',
      eveningTitle: '¡Mantén viva tu racha! 🔥',
      eveningBody:
          'Aún estás a tiempo de hacer una lección rápida y sumar otra victoria hoy.',
    ),
    'fr': PracticeReminderMessages(
      morningTitle: 'Une petite victoire linguistique aujourd’hui ? 🌞',
      morningBody:
          'Quelques minutes de pratique aujourd’hui peuvent faire toute la différence. C’est parti !',
      eveningTitle: 'Continuez votre série ! 🔥',
      eveningBody:
          'Il est encore temps de faire une courte leçon et de remporter une nouvelle victoire aujourd’hui.',
    ),
    'de': PracticeReminderMessages(
      morningTitle: 'Bereit für einen kleinen Spracherfolg? 🌞',
      morningBody:
          'Ein paar Minuten Übung heute können viel bewirken. Los geht’s!',
      eveningTitle: 'Halte deine Serie am Laufen! 🔥',
      eveningBody:
          'Für eine kurze Lektion und einen weiteren Erfolg heute ist noch Zeit.',
    ),
    'it': PracticeReminderMessages(
      morningTitle: 'Che ne dici di una piccola vittoria linguistica? 🌞',
      morningBody:
          'Bastano pochi minuti di pratica oggi per fare una grande differenza. Cominciamo!',
      eveningTitle: 'Mantieni viva la tua serie! 🔥',
      eveningBody:
          'C’è ancora tempo per una lezione veloce e un altro piccolo successo oggi.',
    ),
    'pt': PracticeReminderMessages(
      morningTitle: 'Preparado para uma pequena vitória linguística? 🌞',
      morningBody:
          'Alguns minutos de prática hoje podem fazer uma grande diferença. Vamos a isso!',
      eveningTitle: 'Mantém a tua série ativa! 🔥',
      eveningBody:
          'Ainda vais a tempo de fazer uma lição rápida e somar mais uma vitória hoje.',
    ),
    'pl': PracticeReminderMessages(
      morningTitle: 'Czas na mały językowy sukces? 🌞',
      morningBody: 'Kilka minut ćwiczeń dzisiaj może wiele zmienić. Zaczynamy!',
      eveningTitle: 'Podtrzymaj swoją serię! 🔥',
      eveningBody: 'Wciąż masz czas na krótką lekcję i kolejny sukces dzisiaj.',
    ),
    'sr': PracticeReminderMessages(
      morningTitle: 'Mala jezička pobeda za danas? 🌞',
      morningBody: 'Nekoliko minuta vežbe danas može mnogo da znači. Krenimo!',
      eveningTitle: 'Nastavi svoj niz! 🔥',
      eveningBody:
          'Još ima vremena za kratku lekciju i još jednu pobedu danas.',
    ),
    'hr': PracticeReminderMessages(
      morningTitle: 'Mala jezična pobjeda za danas? 🌞',
      morningBody: 'Nekoliko minuta vježbe danas može puno značiti. Krenimo!',
      eveningTitle: 'Nastavi svoj niz! 🔥',
      eveningBody:
          'Još ima vremena za kratku lekciju i još jednu pobjedu danas.',
    ),
    'bg': PracticeReminderMessages(
      morningTitle: 'Готови ли сте за малка езикова победа? 🌞',
      morningBody:
          'Няколко минути практика днес могат да имат голям ефект. Да започваме!',
      eveningTitle: 'Поддържайте серията си! 🔥',
      eveningBody: 'Все още има време за кратък урок и още една победа днес.',
    ),
    'ja': PracticeReminderMessages(
      morningTitle: '今日も小さな語学の一歩を！🌞',
      morningBody: '数分の練習が大きな違いにつながります。始めましょう！',
      eveningTitle: '連続学習記録を伸ばしましょう！🔥',
      eveningBody: 'まだ短いレッスンをする時間があります。今日の達成をもう一つ！',
    ),
    'ko': PracticeReminderMessages(
      morningTitle: '오늘도 작은 언어 학습 성취를 만들어 볼까요? 🌞',
      morningBody: '오늘 몇 분만 연습해도 큰 변화를 만들 수 있어요. 시작해요!',
      eveningTitle: '연속 학습 기록을 이어 가세요! 🔥',
      eveningBody: '아직 짧은 레슨을 하고 오늘의 성취를 하나 더 만들 시간이 있어요.',
    ),
    'ar': PracticeReminderMessages(
      morningTitle: 'هل أنت مستعد لتحقيق إنجاز لغوي صغير؟ 🌞',
      morningBody: 'بضع دقائق من التدريب اليوم قد تُحدث فرقًا كبيرًا. لنبدأ!',
      eveningTitle: 'حافظ على سلسلة تعلّمك! 🔥',
      eveningBody: 'ما زال هناك وقت لدرس قصير وإنجاز آخر اليوم.',
    ),
  };

  static Iterable<String> get supportedLanguageIds => _byLanguageId.keys;

  static String normalizeLanguageId(String? languageId) {
    final value = languageId?.trim();
    if (value == null ||
        !RegExp(r'^[A-Za-z]{2}(?:[-_][A-Za-z0-9]+)*$').hasMatch(value)) {
      return 'en';
    }
    final id = value.split(RegExp('[-_]')).first.toLowerCase();
    return _byLanguageId.containsKey(id) ? id : 'en';
  }

  static PracticeReminderMessages resolve(String? languageId) =>
      _byLanguageId[normalizeLanguageId(languageId)] ?? _english;
}
