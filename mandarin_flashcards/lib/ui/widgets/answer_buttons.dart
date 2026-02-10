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
  final cs = Theme.of(context).colorScheme;

  // Helper to create a subtle tonal style
  ButtonStyle subtleStyle(Color baseColor) {
    return FilledButton.styleFrom(
      backgroundColor: baseColor.withOpacity(0.08), // Even lower opacity (8%)
      foregroundColor: baseColor.withOpacity(0.8),  // Muted text
      elevation: 0,                                // Flat look
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 12,
    runSpacing: 12,
    children: [
      // 1. FORGOT (Subtle Coral/Red)
      FilledButton(
        onPressed: enabled ? onWrong : null,
        style: subtleStyle(Colors.redAccent.shade200),
        child: const Text('I forgot'),
      ),

      // 2. ALMOST (Subtle Amber/Sand)
      FilledButton(
        onPressed: enabled ? onUnsure : null,
        style: subtleStyle(Colors.orangeAccent.shade100),
        child: const Text('Almost'),
      ),

      // 3. GOT IT (Subtle Mint/Green)
      FilledButton(
        onPressed: enabled ? onCorrect : null,
        style: subtleStyle(Colors.tealAccent.shade700),
        child: const Text('I got it'),
      ),
    ],
  );
}
}