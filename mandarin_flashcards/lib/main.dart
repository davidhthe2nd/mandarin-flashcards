import 'package:flutter/material.dart';
import 'package:mandarin_flashcards/ui/screens/menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'state/options_state.dart';
import 'state/deck_state.dart';
import 'state/hive_keys.dart'; // kOptionsBox, kProgressBox

import 'models/card_progress.dart';
import 'utils/colors.dart'; // theming helpers
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // keep a single init 🌙
  // REGISTER ADAPTERS FIRST — BEFORE opening any boxes
  if (!Hive.isAdapterRegistered(kLearningStatusTypeId)) {
    Hive.registerAdapter(
      LearningStatusAdapter(),
    ); // new: register enum adapter early 🌙
  }
  if (!Hive.isAdapterRegistered(kCardProgressTypeId)) {
    Hive.registerAdapter(
      CardProgressAdapter(),
    ); // new: register model adapter early 🌙
  }

  // 1) Init options (blocking)
  final options = OptionsState(kOptionsBox);
  await options.init(); // uses Hive boxes safely (adapters are ready) 🌙

  // 2) Init deck (blocking) — use your JSON path (make sure it’s in pubspec assets)
  final deck = DeckState(kProgressBox);
  await deck.init(options); // loads deck & progress 🌙

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
    final isDark = opts.darkMode;

    final palette = TestPalettes.all[opts.activePaletteIndex];
    final scheme  = buildSchemeFromPalette(dark: isDark, palette: palette);

    final theme = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
    );

    return MaterialApp(
      title: 'Mandarin Flashcards',
      theme: theme,
      darkTheme: ThemeData(
        colorScheme: buildSchemeFromPalette(dark: true, palette: palette),
        useMaterial3: true,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(opts.localeCode), // Tells the app which .arb file to use
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
    return const Scaffold(body: Center(child: Text('Loading / No cards due')));
  }
}
