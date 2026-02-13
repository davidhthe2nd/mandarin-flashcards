// lib/ui/screens/grammar_tones.dart
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../l10n/app_localizations.dart';

class GrammarTonesScreen extends StatelessWidget {
  const GrammarTonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tonesTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tonesIntro, style: t.bodyLarge),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _ToneCard(pinyin: "mā", label: l10n.tone1Name, audio: "tone1"),
                _ToneCard(pinyin: "má", label: l10n.tone2Name, audio: "tone2"),
                _ToneCard(pinyin: "mǎ", label: l10n.tone3Name, audio: "tone3"),
                _ToneCard(pinyin: "mà", label: l10n.tone4Name, audio: "tone4"),
              ],
            ),
            const SizedBox(height: 40),
            Text(l10n.toneSandhiTitle, style: t.titleLarge?.copyWith(color: cs.primary)),
            const Divider(),
            Text(l10n.toneSandhiDesc, style: t.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ToneCard extends StatelessWidget {
  final String pinyin;
  final String label;
  final String audio;
  const _ToneCard({required this.pinyin, required this.label, required this.audio});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: () => AudioService.play(audio), //
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pinyin, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}