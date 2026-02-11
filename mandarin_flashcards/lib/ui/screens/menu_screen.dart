import 'package:flutter/material.dart';
import 'package:mandarin_flashcards/ui/screens/options_screen.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../screens/learn_screen.dart'; 
import '../../state/options_state.dart';
import '../../models/enums.dart';
import "../../l10n/app_localizations.dart"; 

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
Widget build(BuildContext context) {
  final deck = context.watch<DeckState>();
  final opts = context.watch<OptionsState>();
  final l10n = AppLocalizations.of(context)!;

  return Scaffold(
    extendBodyBehindAppBar: true, 
    body: Stack(
      children: [
        // 1. BACKGROUND IMAGE
        Positioned.fill(
          child: Image.asset(
            'assets/images/main2.JPEG',
            fit: BoxFit.cover,
          ),
        ),

        // 2. GRADIENT OVERLAY
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.7), // Slightly darker for contrast
                ],
              ),
            ),
          ),
        ),
        // 2.5 Language selector (top-right)
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: PopupMenuButton<String>(
            // NEW: Dynamic Icon based on selected locale
            icon: Text(
              opts.localeCode == 'es' ? "🇪🇸" : "🇺🇸",
              style: const TextStyle(fontSize: 28),
            ),
            onSelected: (String code) => opts.setLocale(code),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text("🇺🇸 English")),
              const PopupMenuItem(value: 'es', child: Text("🇪🇸 Español")),
            ],
          ),
        ),
        // 3. CONTENT
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO AREA ---
                    // Replace 'logo.png' with your actual generated filename
                    Image.asset(
                      'assets/images/logo.png', 
                      height: 240,
                    ),
                    const SizedBox(height: 28),
                    // Text(
                    //   'Let\'s Learn Mandarin!',
                    //   textAlign: TextAlign.center,
                    //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.w900,
                    //     letterSpacing: 4,
                    //   ),
                    // ),
                    // const SizedBox(height: 60),

                    // --- BUTTONS (Removed 'const' from parent to allow theme lookup) ---
                    _MenuCard(
                      title: l10n.studyHsk,
                      subtitle: l10n.hskSubtitle,
                      icon: Icons.school_rounded,
                      enabled: !deck.isBusy, // New property
                      onTap: () async {
                        await deck.loadSource(DeckSource.hsk, opts); 
                        if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen()));
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      title: l10n.studyTextbook,
                      subtitle: l10n.textbookSubtitle,
                      icon: Icons.menu_book_rounded, // Fixed name
                      onTap: () async {
                        // Always reload source to apply current filters before entering LearnScreen
                        await deck.loadSource(DeckSource.textbook, opts);
                        if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen()));
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      title: l10n.settings,
                      subtitle: l10n.settingsSubtitle,
                      icon: Icons.settings_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OptionsScreen())),
                    ),
                  ],
                ),
              ),
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
  final bool enabled;

  const _MenuCard({required this.title, required this.subtitle, required this.icon, required this.onTap, this.enabled = true,});

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