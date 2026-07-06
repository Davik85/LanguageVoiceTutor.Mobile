import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Placeholder login screen'),
            const SizedBox(height: 12),
            const Text(
                'Backend placeholder: ${AppConfig.productionApiBaseUrl}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                HomeScreen.routeName,
              ),
              child: const Text('Enter demo shell'),
            ),
          ],
        ),
      ),
    );
  }
}
