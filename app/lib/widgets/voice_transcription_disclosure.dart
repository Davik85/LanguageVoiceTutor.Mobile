import 'package:flutter/material.dart';

class VoiceTranscriptionDisclosure extends StatelessWidget {
  const VoiceTranscriptionDisclosure({super.key, this.color});

  static const message =
      'Voice is sent for transcription. You can use text input in Lesson Chat instead.';

  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: message,
        child: Text(
          message,
          key: const Key('voice-transcription-disclosure'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                height: 1.3,
              ),
        ),
      );
}
