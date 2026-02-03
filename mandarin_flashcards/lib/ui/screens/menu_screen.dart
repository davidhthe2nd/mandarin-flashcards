import 'package:flutter/material.dart';
import 'package:mandarin_flashcards/ui/screens/options_screen.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../screens/learn_screen.dart'; 
import '../../state/options_state.dart';
import '../../models/enums.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    final opts = context.read<OptionsState>();

    return Scaffold(
      // We remove the AppBar if we want the image to go "Full Screen"
      // or keep it—it will stay at the very top layer.
      appBar: AppBar(title: const Text('Mandarin Flashcards')),
      
      body: Stack(
        children: [
          // 1. BACKGROUND LAYER
          Positioned.fill(
            child: Image.asset(
              'assets/images/main2.JPEG', // Ensure this exists & is in pubspec!
              fit: BoxFit.cover, 
            ),
          ),

          // 2. OVERLAY LAYER (Darkens the image by 40%)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4), 
            ),
          ),

          // 3. UI LAYER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MenuCard(
                    title: "HSK Study",
                    subtitle: "Levels 1-3 • ${deck.totalToday} due",
                    icon: Icons.school,
                    onTap: () async {
                      await deck.loadSource(DeckSource.hsk, opts);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LearnScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    title: "Textbook Practice",
                    subtitle: "Classroom & Quiz Content",
                    icon: Icons.book,
                    onTap: () async {
                      await deck.loadSource(DeckSource.textbook, opts);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LearnScreen()),
                        );
                      }
                    },
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Options'),
                      trailing: const Icon(Icons.settings),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OptionsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}