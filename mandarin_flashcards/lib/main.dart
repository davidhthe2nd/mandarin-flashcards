import 'package:flutter/material.dart';
import 'package:mandarin_flashcards/ui/screens/menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'state/options_state.dart';
import 'state/deck_state.dart';
import 'state/hive_keys.dart'; // kOptionsBox, kProgressBox

import 'models/card_progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // keep a single init 🌙
  // REGISTER ADAPTERS FIRST — BEFORE opening any boxes
  if (!Hive.isAdapterRegistered(kLearningStatusTypeId)) {
    Hive.registerAdapter(LearningStatusAdapter()); // new: register enum adapter early 🌙
  }
  if (!Hive.isAdapterRegistered(kCardProgressTypeId)) {
    Hive.registerAdapter(CardProgressAdapter());   // new: register model adapter early 🌙
  }

  // 1) Init options (blocking)
  final options = OptionsState(kOptionsBox);
  await options.init(); // uses Hive boxes safely (adapters are ready) 🌙

  // 2) Init deck (blocking) — use your JSON path (make sure it’s in pubspec assets)
  final deck = DeckState(kProgressBox);
  await deck.init(options, 'assets/decks/hsk1_trad_esES_deck.json'); // adapters already registered 🌙

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
    final opts = context.watch<OptionsState>();
    final theme = ThemeData(
      brightness: opts.darkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Mandarin Flashcards',
      theme: theme,
      home: const MainMenuScreen(),
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

    // If queue is empty, show a friendly empty screen instead of a blank one.
    if (deck.current == null && deck.isEmpty) {
      return const EmptyOrLoaderScreen(); // shows text; not blank 🌙
    }
    return const MainMenuScreen(); // or LearnScreen if that’s your primary 🌙
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
