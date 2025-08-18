import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../../state/options_state.dart';

class FlashcardWidget extends StatelessWidget {
  const FlashcardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    final opts = context.watch<OptionsState>();

    final card = deck.current;
    if (card == null) {
      return const Center(
        child: Text("🎉 No cards due right now!"),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hanzi
        Text(
          card.hanzi,
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Pinyin (toggleable)
        if (opts.showPinyin)
          Text(
            card.pinyin,
            style: const TextStyle(fontSize: 24, color: Colors.grey),
          ),

        const SizedBox(height: 16),

        // Example sentence (if present)
        if (card.example?.cn != null)
          Text(card.example!.cn!,
              style: const TextStyle(fontSize: 18)),
        if (card.example?.es != null)
          Text(card.example!.es!,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
