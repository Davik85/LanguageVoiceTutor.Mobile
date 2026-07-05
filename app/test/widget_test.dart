import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/main.dart';

void main() {
  testWidgets('renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LanguageVoiceTutorApp());

    expect(find.text('Language Voice Tutor'), findsOneWidget);
    expect(find.text('Mobile client skeleton'), findsOneWidget);
  });
}
