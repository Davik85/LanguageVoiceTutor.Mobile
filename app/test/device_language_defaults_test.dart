import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/l10n/device_language_defaults.dart';

void main() {
  test('resolves Android language forms independently', () {
    final cases = <({Locale locale, String interfaceId, String nativeId})>[
      (locale: const Locale('ru', 'RU'), interfaceId: 'ru', nativeId: 'ru'),
      (locale: const Locale('pl', 'PL'), interfaceId: 'pl', nativeId: 'pl'),
      (locale: const Locale('pt', 'BR'), interfaceId: 'pt', nativeId: 'pt'),
      (
        locale: const Locale.fromSubtags(
            languageCode: 'sr', scriptCode: 'Cyrl', countryCode: 'RS'),
        interfaceId: 'sr',
        nativeId: 'sr'
      ),
      (locale: const Locale('uk', 'UA'), interfaceId: 'en', nativeId: 'uk'),
      (
        locale: const Locale('zh', 'CN'),
        interfaceId: 'en',
        nativeId: 'zh-Hans'
      ),
      (locale: const Locale('zh', 'TW'), interfaceId: 'en', nativeId: 'en'),
      (locale: const Locale('ka', 'GE'), interfaceId: 'en', nativeId: 'en'),
      (locale: const Locale('iw'), interfaceId: 'en', nativeId: 'he'),
      (locale: const Locale('in'), interfaceId: 'en', nativeId: 'id'),
      (locale: const Locale('nb', 'NO'), interfaceId: 'en', nativeId: 'no'),
    ];
    for (final item in cases) {
      final defaults = resolveDeviceLanguageDefaults([item.locale]);
      expect(defaults.interfaceLanguageId, item.interfaceId);
      expect(defaults.nativeLanguageId, item.nativeId);
    }
  });

  test('uses later Android locales separately when needed', () {
    final defaults = resolveDeviceLanguageDefaults(
      [const Locale('uk', 'UA'), const Locale('en', 'US')],
    );
    expect(defaults.interfaceLanguageId, 'en');
    expect(defaults.nativeLanguageId, 'uk');
  });

  test('skips unsupported locales for later supported locales', () {
    final defaults = resolveDeviceLanguageDefaults(
      [const Locale('ka', 'GE'), const Locale('fr', 'FR')],
    );
    expect(defaults.interfaceLanguageId, 'fr');
    expect(defaults.nativeLanguageId, 'fr');
  });

  test('Chinese script takes precedence over a conflicting region', () {
    final cases = <({Locale locale, String nativeId})>[
      (
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
        nativeId: 'en',
      ),
      (
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'CN'),
        nativeId: 'en',
      ),
      (
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'SG'),
        nativeId: 'en',
      ),
      (
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: 'TW'),
        nativeId: 'zh-Hans',
      ),
      (locale: const Locale('zh', 'HK'), nativeId: 'en'),
      (locale: const Locale('zh', 'MO'), nativeId: 'en'),
      (locale: const Locale('zh', 'SG'), nativeId: 'zh-Hans'),
    ];
    for (final item in cases) {
      final defaults = resolveDeviceLanguageDefaults([item.locale]);
      expect(defaults.interfaceLanguageId, 'en');
      expect(defaults.nativeLanguageId, item.nativeId);
    }
  });

  test('Traditional Chinese allows a later supported locale', () {
    final defaults = resolveDeviceLanguageDefaults([
      const Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hant', countryCode: 'CN'),
      const Locale('fr', 'FR'),
    ]);
    expect(defaults.interfaceLanguageId, 'fr');
    expect(defaults.nativeLanguageId, 'fr');
  });
}
