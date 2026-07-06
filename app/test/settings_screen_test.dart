import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_voice_tutor_mobile/api/api_client.dart';
import 'package:language_voice_tutor_mobile/screens/settings_screen.dart';
import 'package:language_voice_tutor_mobile/services/backend_health_service.dart';

class FakeApiClient implements ApiClient {
  FakeApiClient(this.response);

  final Future<ApiResponse> Function(String path) response;

  @override
  Future<ApiResponse> get(String path) => response(path);
}

void main() {
  testWidgets('settings screen shows connected after a successful health check', (tester) async {
    final service = BackendHealthService(
      apiClient: FakeApiClient(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: '{"status":"ok","environment":"production","checkedAtUtc":"2026-07-06T12:00:00Z"}',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(healthService: service)),
    );

    expect(find.text('Backend connection'), findsOneWidget);
    expect(find.text('Not checked'), findsOneWidget);

    await tester.tap(find.text('Check connection'));
    await tester.pumpAndSettle();

    expect(find.text('Connected'), findsOneWidget);
  });
}
