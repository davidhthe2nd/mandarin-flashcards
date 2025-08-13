import 'package:flutter/material.dart';

typedef AnswerCallback = void Function();

class AnswerButtons extends StatelessWidget {
  const AnswerButtons({
    super.key,
    required this.onWrong,
    required this.onUnsure,
    required this.onCorrect,
  });

  final AnswerCallback onWrong;
  final AnswerCallback onUnsure;
  final AnswerCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: onWrong,
          icon: const Icon(Icons.close),
          tooltip: 'Didn’t remember',
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: onUnsure,
          icon: const Icon(Icons.help_outline),
          tooltip: 'Somewhat remembered',
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: onCorrect,
          icon: const Icon(Icons.check),
          tooltip: 'Knew well',
        ),
      ],
    );
  }
}