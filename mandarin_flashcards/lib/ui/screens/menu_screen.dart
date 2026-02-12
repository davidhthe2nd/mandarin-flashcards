import 'package:flutter/material.dart';
import 'package:mandarin_flashcards/ui/screens/options_screen.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../screens/learn_screen.dart'; 
import '../../state/options_state.dart';
import '../../models/enums.dart';
import "../../l10n/app_localizations.dart"; 

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _logoTapCount = 0; // Move this here so it persists

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    final opts = context.watch<OptionsState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/main2.JPEG',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: PopupMenuButton<String>(
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ // Added missing children property start
                      GestureDetector(
                        onTap: () {
                          _logoTapCount++;
                          if (_logoTapCount >= 7) {
                            opts.toggleBetaFeatures(!opts.showBetaFeatures);
                            _logoTapCount = 0;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(opts.showBetaFeatures ? "Admin Mode Enabled" : "Admin Mode Disabled"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Image.asset(
                          'assets/images/logo.png', 
                          height: 240,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _MenuCard(
                        title: l10n.studyHsk,
                        subtitle: l10n.hskSubtitle,
                        icon: Icons.school_rounded,
                        enabled: !deck.isBusy,
                        onTap: () async {
                          await deck.loadSource(DeckSource.hsk, opts); 
                          if (context.mounted) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen()));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _MenuCard(
                        title: l10n.settings,
                        subtitle: l10n.settingsSubtitle,
                        icon: Icons.settings_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OptionsScreen())),
                      ),
                      if (opts.showBetaFeatures) ...[
                        const SizedBox(height: 16),
                        _MenuCard(
                          title: l10n.studyTextbook,
                          subtitle: l10n.textbookSubtitle,
                          icon: Icons.menu_book_rounded,
                          onTap: () async {
                            await deck.loadSource(DeckSource.textbook, opts);
                            if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen()));
                          },
                        ),
                      ],
                    ], // Fixed the trailing commas and braces here
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

  const _MenuCard({
    required this.title, 
    required this.subtitle, 
    required this.icon, 
    required this.onTap, 
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null, // Respect the enabled flag
      ),
    );
  }
}