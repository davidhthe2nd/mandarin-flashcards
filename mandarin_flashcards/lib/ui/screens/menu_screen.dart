import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarin_flashcards/app_router.dart';
import 'package:mandarin_flashcards/ui/screens/options_screen.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../../state/options_state.dart';
import '../screens/learn_screen.dart'; 

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mandarin Flashcards')),
      body: SafeArea( // new: mobile-friendly padding 🌙
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  title: const Text("Today's learning"),
                  subtitle: Text('${deck.position}/${deck.totalToday} due'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LearnScreen()),
                  ), // new: Start learning 🌙
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Options'),
                  trailing: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OptionsScreen()),
                    ); // new: Open options screen 🌙
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}