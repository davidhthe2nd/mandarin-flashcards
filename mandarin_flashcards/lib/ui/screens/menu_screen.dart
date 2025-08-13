import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final due = context.select<DeckState, int>((s) => s.dueCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Mandarin Flashcards')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Due today: $due', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                // Use push() so the next screen shows a back arrow
                FilledButton(
                  onPressed: () => context.push('/learn'),
                  child: const Text('Start Learning'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/options'),
                  child: const Text('Options'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset cards?'),
                        content: const Text('This will move all cards back to “To Learn”.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await context.read<DeckState>().resetProgress();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Progress reset.')),
                        );
                      }
                    }
                  },
                  child: const Text('Reset cards'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}