import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'state/options_state.dart';
import 'state/deck_state.dart';
import 'state/hive_keys.dart'; // kOptionsBox, kProgressBox
import "ui/screens/flashcard_screen.dart";

import 'package:hive_flutter/hive_flutter.dart';
import 'models/card_progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 1) Init options (blocking)
  final options = OptionsState(kOptionsBox);
  await options.init();

  // 2) Init deck (blocking) — use your JSON path
  final deck = DeckState(kProgressBox);
  await deck.init(options, 'assets/decks/hsk1_trad_esES_deck.json');

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(kLearningStatusTypeId)) {
    Hive.registerAdapter(LearningStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(kCardProgressTypeId)) {
  Hive.registerAdapter(CardProgressAdapter());
  }

  // 3) Run app with pre-initialized providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<OptionsState>.value(value: options),
        ChangeNotifierProvider<DeckState>.value(value: deck),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // (Optional) you can read options here to set theme dynamically
    final opts = context.watch<OptionsState>();
    final theme = ThemeData(
      brightness: opts.darkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Mandarin Flashcards',
      theme: theme,
      home: const HomeGate(),
    );
  }
}

/// Simple gate in case you later want a splash screen.
/// Right now deck/options are already loaded (blocking), so we go straight in.
class HomeGate extends StatelessWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    // If you ever make init non-blocking, you can show a loader here.
    if (deck.current == null && deck.isEmpty) {
      // Might be "no cards due" rather than loading. Handle both cases in your UI.
      return const EmptyOrLoaderScreen();
    }
    return const FlashcardScreen(); // replace with your actual screen widget
  }
}

class EmptyOrLoaderScreen extends StatelessWidget {
  const EmptyOrLoaderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Loading / No cards due')),
    );
  }
}
