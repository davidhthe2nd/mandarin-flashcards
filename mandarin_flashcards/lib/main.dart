import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'state/options_state.dart';
import 'state/deck_state.dart';
import "app_router.dart";
import "theme.dart" as app_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // 🔹 Initialize Hive once, before runApp

  // Open boxes here (step 18) so providers can receive them
  final progressBox = await Hive.openBox('cardsProgress');
  final optionsBox  = await Hive.openBox('options');

  // Set default options if first run (step 19)
  if (!optionsBox.containsKey('prefs')) {
  optionsBox.put('prefs', {
    'showPinyin': true,
    'invertPair': false,
  });
}

  runApp(MyApp(
    progressBoxName: progressBox.name,
    optionsBoxName: optionsBox.name,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.progressBoxName,
    required this.optionsBoxName,
  });

  final String progressBoxName;
  final String optionsBoxName;

  @override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => OptionsState(optionsBoxName)),
      ChangeNotifierProvider(create: (_) => DeckState(progressBoxName)
        ..loadDeck('assets/decks/hsk1_trad_esES_deck.json')),
    ],
    child: Consumer<OptionsState>( // 👈 opts is only valid inside here
      builder: (context, opts, _) {
        return MaterialApp.router(
          title: 'Mandarin Flashcards',
          theme: app_theme.buildtheme(),
          darkTheme: app_theme.buildDarkTheme(),
          themeMode: opts.darkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: appRouter,
        );
      },
    ),
  );
  }
}