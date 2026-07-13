import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/models/audio_speech.dart';

AudioSpeechRequest _request({AudioSpeechPurpose? purpose}) =>
    AudioSpeechRequest(
      text: 'Visible tutor reply',
      speechVoice: 'nova',
      speechSpeed: 1.1,
      targetLanguageId: 'en',
      targetLanguageName: 'English',
      targetLanguageNativeName: 'English',
      targetLanguageCode: 'en',
      backendSessionId: 'session-1',
      purpose: purpose ?? AudioSpeechPurpose.lessonChatTts,
    );

void main() {
  test('manual tutor speech defaults to lesson_chat_tts', () {
    final json = _request().toJson();

    expect(json['purpose'], 'lesson_chat_tts');
    expect(json.containsKey('model'), isFalse);
  });

  test('conversation tutor speech uses conversation_mode_tts', () {
    final json = _request(
      purpose: AudioSpeechPurpose.conversationModeTts,
    ).toJson();

    expect(json['purpose'], 'conversation_mode_tts');
    expect(json.containsKey('model'), isFalse);
  });
}
