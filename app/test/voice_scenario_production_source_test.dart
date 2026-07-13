import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('voice resolution production files contain no fixture vocabulary', () {
    final production = [
      File('lib/services/voice_scenario_intent_resolver.dart')
          .readAsStringSync(),
      File('lib/models/voice_scenario_resolution.dart').readAsStringSync(),
    ].join('\n').toLowerCase();
    for (final phrase in [
      'language school',
      'meeting neighbor',
      'meeting a friend in a park',
      'hobby club',
      'doctor',
      'manager',
    ]) {
      expect(production, isNot(contains(phrase)));
    }
  });
}
