import 'package:flutter/material.dart';

import '../models/lesson_start_selection.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, this.selection});

  static const String routeName = '/lesson';

  final LessonStartSelection? selection;

  @override
  Widget build(BuildContext context) {
    final selection = this.selection;
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lesson placeholder',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (selection != null) ...[
                Text('Level: ${selection.level}', textAlign: TextAlign.center),
                Text('Topic: ${selection.topic}', textAlign: TextAlign.center),
                Text(
                  'Situation: ${selection.situation}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Placeholder lesson screen. Lesson runtime, voice recording, TTS, and AI tutor calls are intentionally not implemented.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
