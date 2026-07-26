import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/services/practice_reminder_messages.dart';

void main() {
  group('localized practice reminder messages', () {
    const expected = <String, List<String>>{
      'en': [
        'Ready for a tiny language win? 🌞',
        'A few minutes of practice today can make a big difference. Let’s go!',
        'Keep your streak glowing! 🔥',
        'There’s still time for a quick lesson and one more win today.'
      ],
      'ru': [
        'Готовы к маленькой языковой победе? 🌞',
        'Несколько минут практики сегодня могут многое изменить. Начнём!',
        'Поддержите свою серию! 🔥',
        'Ещё есть время на короткий урок и ещё одну победу сегодня.'
      ],
      'es': [
        '¿Qué tal una pequeña victoria con el idioma? 🌞',
        'Unos minutos de práctica hoy pueden marcar una gran diferencia. ¡Vamos!',
        '¡Mantén viva tu racha! 🔥',
        'Aún estás a tiempo de hacer una lección rápida y sumar otra victoria hoy.'
      ],
      'fr': [
        'Une petite victoire linguistique aujourd’hui ? 🌞',
        'Quelques minutes de pratique aujourd’hui peuvent faire toute la différence. C’est parti !',
        'Continuez votre série ! 🔥',
        'Il est encore temps de faire une courte leçon et de remporter une nouvelle victoire aujourd’hui.'
      ],
      'de': [
        'Bereit für einen kleinen Spracherfolg? 🌞',
        'Ein paar Minuten Übung heute können viel bewirken. Los geht’s!',
        'Halte deine Serie am Laufen! 🔥',
        'Für eine kurze Lektion und einen weiteren Erfolg heute ist noch Zeit.'
      ],
      'it': [
        'Che ne dici di una piccola vittoria linguistica? 🌞',
        'Bastano pochi minuti di pratica oggi per fare una grande differenza. Cominciamo!',
        'Mantieni viva la tua serie! 🔥',
        'C’è ancora tempo per una lezione veloce e un altro piccolo successo oggi.'
      ],
      'pt': [
        'Preparado para uma pequena vitória linguística? 🌞',
        'Alguns minutos de prática hoje podem fazer uma grande diferença. Vamos a isso!',
        'Mantém a tua série ativa! 🔥',
        'Ainda vais a tempo de fazer uma lição rápida e somar mais uma vitória hoje.'
      ],
      'pl': [
        'Czas na mały językowy sukces? 🌞',
        'Kilka minut ćwiczeń dzisiaj może wiele zmienić. Zaczynamy!',
        'Podtrzymaj swoją serię! 🔥',
        'Wciąż masz czas na krótką lekcję i kolejny sukces dzisiaj.'
      ],
      'sr': [
        'Mala jezička pobeda za danas? 🌞',
        'Nekoliko minuta vežbe danas može mnogo da znači. Krenimo!',
        'Nastavi svoj niz! 🔥',
        'Još ima vremena za kratku lekciju i još jednu pobedu danas.'
      ],
      'hr': [
        'Mala jezična pobjeda za danas? 🌞',
        'Nekoliko minuta vježbe danas može puno značiti. Krenimo!',
        'Nastavi svoj niz! 🔥',
        'Još ima vremena za kratku lekciju i još jednu pobjedu danas.'
      ],
      'bg': [
        'Готови ли сте за малка езикова победа? 🌞',
        'Няколко минути практика днес могат да имат голям ефект. Да започваме!',
        'Поддържайте серията си! 🔥',
        'Все още има време за кратък урок и още една победа днес.'
      ],
      'ja': [
        '今日も小さな語学の一歩を！🌞',
        '数分の練習が大きな違いにつながります。始めましょう！',
        '連続学習記録を伸ばしましょう！🔥',
        'まだ短いレッスンをする時間があります。今日の達成をもう一つ！'
      ],
      'ko': [
        '오늘도 작은 언어 학습 성취를 만들어 볼까요? 🌞',
        '오늘 몇 분만 연습해도 큰 변화를 만들 수 있어요. 시작해요!',
        '연속 학습 기록을 이어 가세요! 🔥',
        '아직 짧은 레슨을 하고 오늘의 성취를 하나 더 만들 시간이 있어요.'
      ],
      'ar': [
        'هل أنت مستعد لتحقيق إنجاز لغوي صغير؟ 🌞',
        'بضع دقائق من التدريب اليوم قد تُحدث فرقًا كبيرًا. لنبدأ!',
        'حافظ على سلسلة تعلّمك! 🔥',
        'ما زال هناك وقت لدرس قصير وإنجاز آخر اليوم.'
      ],
    };

    test('all backend language IDs return their exact copy', () {
      expect(PracticeReminderMessages.supportedLanguageIds, expected.keys);
      for (final entry in expected.entries) {
        final messages = PracticeReminderMessages.resolve(entry.key);
        expect([
          messages.morningTitle,
          messages.morningBody,
          messages.eveningTitle,
          messages.eveningBody
        ], entry.value);
      }
    });

    test('Portuguese, Serbian, and Arabic locale forms normalize', () {
      for (final value in ['pt', 'pt-PT', 'pt_PT']) {
        expect(PracticeReminderMessages.normalizeLanguageId(value), 'pt');
      }
      for (final value in ['sr', 'sr-Latn', 'sr_Latn']) {
        expect(PracticeReminderMessages.normalizeLanguageId(value), 'sr');
      }
      for (final value in ['ar', 'ar-SA', 'ar_SA']) {
        expect(PracticeReminderMessages.normalizeLanguageId(value), 'ar');
      }
    });

    test('Serbian is Latin and Arabic contains no direction controls', () {
      final serbian = PracticeReminderMessages.resolve('sr');
      final arabic = PracticeReminderMessages.resolve('ar');
      expect(
          RegExp(r'[\u0400-\u04FF]').hasMatch([
            serbian.morningTitle,
            serbian.morningBody,
            serbian.eveningTitle,
            serbian.eveningBody
          ].join()),
          isFalse);
      expect(
          RegExp(r'[\u200E\u200F\u202A-\u202E\u2066-\u2069]').hasMatch([
            arabic.morningTitle,
            arabic.morningBody,
            arabic.eveningTitle,
            arabic.eveningBody
          ].join()),
          isFalse);
    });

    test('null, blank, malformed, and unknown IDs fall back to English', () {
      for (final value in [null, '', '  ', 'pt--PT', 'english', 'tr']) {
        expect(PracticeReminderMessages.normalizeLanguageId(value), 'en');
        expect(PracticeReminderMessages.resolve(value).morningTitle,
            expected['en']!.first);
      }
    });
  });
}
