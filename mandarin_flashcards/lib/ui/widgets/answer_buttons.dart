import 'package:flutter/material.dart';

typedef AnswerCallback = void Function();

class AnswerButtons extends StatelessWidget {
  const AnswerButtons({
    super.key,
    required this.onWrong,
    required this.onUnsure,
    required this.onCorrect,
    this.enabled = true,
  });

  final VoidCallback onWrong;
  final VoidCallback onUnsure;
  final VoidCallback onCorrect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.tonal(
          onPressed: enabled ? onWrong : null,
          child: const Text('I forgot'),
        ),
        FilledButton.tonal(
          onPressed: enabled ? onUnsure : null,
          child: const Text('Almost'),
        ),
        FilledButton.tonal(
          onPressed: enabled ? onCorrect : null,
          child: const Text('I got it'),
        ),
      ],
    );
  }
}