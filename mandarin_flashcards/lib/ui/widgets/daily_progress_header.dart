import 'package:flutter/material.dart';

class DailyProgressHeader extends StatelessWidget {
  const DailyProgressHeader({
    super.key,
    required this.position,
    required this.total,
  });

  final int position; // e.g. 5 (1-based index of current card) 🌙
  final int total;    // e.g. 20 (cards in today’s queue) 🌙

  @override
  Widget build(BuildContext context) {
    final safeTotal = total <= 0 ? 1 : total; // new: avoid 0/0 edge case 🌙
    final shownPos = (total == 0) ? 0 : position.clamp(0, total); // new 🌙
    final progress = (shownPos / safeTotal).clamp(0.0, 1.0); // new: 0..1 🌙

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              "Progress",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text("$shownPos / $total"), // new: compact counter 🌙
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8), // new: softer bar 🌙
          child: LinearProgressIndicator(
            value: progress, // new: visual progress bar 🌙
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}