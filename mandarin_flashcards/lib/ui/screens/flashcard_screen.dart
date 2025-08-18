import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../../models/enums.dart';
import '../widgets/flashcard_widget.dart';

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's learning: ${deck.position}/${deck.totalToday}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlashcardWidget(),
            const SizedBox(height: 24),

            // Answer buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 40),
                  onPressed: () =>
                      context.read<DeckState>().answer(AnswerQuality.wrong),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.help, color: Colors.orange, size: 40),
                  onPressed: () =>
                      context.read<DeckState>().answer(AnswerQuality.unsure),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green, size: 40),
                  onPressed: () =>
                      context.read<DeckState>().answer(AnswerQuality.correct),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
