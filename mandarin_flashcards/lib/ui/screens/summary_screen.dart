import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/deck_state.dart';
import '../../state/options_state.dart';
import '../screens/learn_screen.dart'; // for navigation back to learning
import "../../l10n/app_localizations.dart"; // for localized strings

class SummaryScreen extends StatelessWidget {
  final int correct;
  final int unsure;
  final int wrong;

  const SummaryScreen({
    super.key,
    required this.correct,
    required this.unsure,
    required this.wrong,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final total = correct + unsure + wrong;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/good_job.png',
                height: 180, // Adjusted size to make the seal prominent
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              // Text("GOOD JOB!", style: t.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(l10n.summaryWordsReviewed(total), style: t.bodyLarge),
              const SizedBox(height: 40),
              
              // Stats Table
              _StatRow(label: l10n.mastered, count: correct, color: Colors.green),
              const Divider(),
              _StatRow(label: l10n.almostThere, count: unsure, color: Colors.orange),
              const Divider(),
              _StatRow(label: l10n.needPractice, count: wrong, color: Colors.red),
              
              const SizedBox(height: 60),

              FilledButton.icon(
                onPressed: () async {
                  final deck = context.read<DeckState>();
                  final opts = context.read<OptionsState>();
                  
                  // 1. Rebuild the queue with a fresh batch of 20 cards
                  await deck.refresh(); 
                  
                  if (context.mounted) {
                    // 2. Go back to LearnScreen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LearnScreen()));
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.studyMore),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

            const SizedBox(height: 18),  
              FilledButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.backToMenu),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatRow({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}