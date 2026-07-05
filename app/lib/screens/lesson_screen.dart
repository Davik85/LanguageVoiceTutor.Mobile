import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  static const String routeName = '/lesson';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Placeholder lesson screen. Lesson runtime, voice recording, TTS, and AI tutor calls are intentionally not implemented.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
