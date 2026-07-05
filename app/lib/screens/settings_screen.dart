import 'package:flutter/material.dart';

import '../config/app_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Placeholder settings screen'),
            SizedBox(height: 12),
            Text('App name: ${AppConfig.appName}'),
            Text('API base URL placeholder: ${AppConfig.productionApiBaseUrl}'),
            SizedBox(height: 12),
            Text('No secrets, auth tokens, billing keys, or analytics are configured.'),
          ],
        ),
      ),
    );
  }
}
