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
            // 1. Pitch Chart Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/tones_chart.png', 
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.tonesIntro, style: t.bodyLarge),
            const SizedBox(height: 32),

            // 2. Localized Tone Guides with HSK1 IDs
            _ToneRow(
              title: l10n.tone1Name,
              desc: l10n.tone1Desc,
              hanzi: "三", // HSK1 Example
              pinyin: "sān",
              audioId: "p6q7r8s9t0u1", // ID from HSK_master.csv
            ),
            _ToneRow(
              title: l10n.tone2Name,
              desc: l10n.tone2Desc,
              hanzi: "來",
              pinyin: "lái",
              audioId: "m9n0o1p2q3r4", // ID from HSK_master.csv
            ),
            _ToneRow(
              title: l10n.tone3Name,
              desc: l10n.tone3Desc,
              hanzi: "你",
              pinyin: "nǐ",
              audioId: "a1b2c3d4e5f6", // ID from HSK_master.csv
            ),
            _ToneRow(
              title: l10n.tone4Name,
              desc: l10n.tone4Desc,
              hanzi: "去",
              pinyin: "qù",
              audioId: "o1p2q3r4s5t6", // ID from HSK_master.csv
            ),

            const SizedBox(height: 32),
            Text(l10n.toneSandhiTitle, style: t.titleLarge?.copyWith(color: cs.primary)),
            const Divider(),
            Text(l10n.toneSandhiDesc, style: t.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ToneRow extends StatelessWidget {
  final String title;
  final String desc;
  final String hanzi;
  final String pinyin;
  final String audioId;

  const _ToneRow({
    required this.title,
    required this.desc,
    required this.hanzi,
    required this.pinyin,
    required this.audioId,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
          Text(desc, style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Text(hanzi, style: t.headlineMedium),
                const SizedBox(width: 12),
                Text(pinyin, style: t.titleMedium?.copyWith(fontStyle: FontStyle.italic)),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => AudioService.play(audioId), // Plays using the unique CSV ID
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}