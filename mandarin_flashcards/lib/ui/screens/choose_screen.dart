// lib/screens/choose_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/choose_state.dart';
import '../../state/options_state.dart';
import '../../models/flashcard.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final choose = context.watch<ChooseState>();
    final opts = context.watch<OptionsState>();

    if (choose.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (choose.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${choose.error!}')),
      );
    }
    if (!choose.hasCards) {
      return const Scaffold(
        body: Center(child: Text('No cards to choose 🎉')),
      );
    }

    final Flashcard card = choose.current!;
    final front = card.frontText(
      invertPair: opts.invertPair,
      langCode: 'enUS', // you can make this configurable
    );
    final back = card.backText(
      invertPair: opts.invertPair,
      langCode: 'enUS',
    );

    return Scaffold(
      appBar: AppBar(title: Text('Choose (${choose.remaining})')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FRONT
            Text(
              front,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Optional pinyin
            if (opts.showPinyin && card.pinyinText.isNotEmpty)
              Text(
                card.pinyinText,
                style: Theme.of(context).textTheme.titleMedium,
              ),

            const Spacer(),

            // BACK (peek or reveal—here shown directly)
            Text(
              back,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => choose.skip(),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => choose.chooseCurrent(),
                    child: const Text('Choose'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
