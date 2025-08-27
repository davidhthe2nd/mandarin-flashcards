import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../../state/options_state.dart';                 // new: read pinyin/invert options 🌙
import '../../models/enums.dart';
import '../widgets/flashcard_face.dart';                 // new: use Face everywhere 🌙
                                                        // removed: import '../widgets/flashcard_widget.dart'; ❌

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    final opts = context.watch<OptionsState>();         // new: options for pinyin/invert 🌙
    final card = deck.current;                           // new: single source of truth 🌙

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's learning: ${deck.position}/${deck.totalToday}"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // keep nice margins 🌙
          child: (card == null)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('All done for now! 🎉'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: deck.isBusy ? null : () => deck.refresh(), // new: quick refresh 🌙
                      child: const Text('Refresh queue'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    // new: make the card area flexible & scrollable for long content 🌙
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8), // new 🌙
                        child: FlashcardFace(
                          title: opts.invertPair
                              ? (card.translations['esES'] ?? '')
                              : card.hanzi,                               // new: uses invert setting 🌙
                          subtitle: opts.invertPair
                              ? null
                              : (opts.showPinyin ? card.pinyin : null),   // new: pinyin toggle 🌙
                          footnote: opts.invertPair
                              ? (opts.showPinyin ? card.pinyin : card.example?.cn)
                              : card.example?.cn,                          // new: small hint/extra 🌙
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Answer buttons (disabled while busy)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 40),
                          onPressed: deck.isBusy
                              ? null                                       // new: disable during async 🌙
                              : () => context.read<DeckState>().answer(AnswerQuality.wrong),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.help, color: Colors.orange, size: 40),
                          onPressed: deck.isBusy
                              ? null                                       // new 🌙
                              : () => context.read<DeckState>().answer(AnswerQuality.unsure),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green, size: 40),
                          onPressed: deck.isBusy
                              ? null                                       // new 🌙
                              : () => context.read<DeckState>().answer(AnswerQuality.correct),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
        ),
      ),
    );
  }
}
