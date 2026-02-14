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
            // 1) Pitch Diagram Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/tones_chart.png', // Ensure you save your image here
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.tonesIntro, style: t.bodyLarge),
            const SizedBox(height: 32),

            // 2) Tone Detail List
            _ToneRow(
              number: 1,
              title: l10n.tone1Name,
              description: l10n.tone1Desc,
              exampleHanzi: "天", // HSK1 ID: tian1
              examplePinyin: "tiān",
              audioId: "tian1",
            ),
            _ToneRow(
              number: 2,
              title: l10n.tone2Name,
              description: l10n.tone2Desc,
              exampleHanzi: "來", // HSK1 ID: lai2
              examplePinyin: "lái",
              audioId: "lai2",
            ),
            _ToneRow(
              number: 3,
              title: l10n.tone3Name,
              description: l10n.tone3Desc,
              exampleHanzi: "你", // HSK1 ID: ni3
              examplePinyin: "nǐ",
              audioId: "ni3",
            ),
            _ToneRow(
              number: 4,
              title: l10n.tone4Name,
              description: l10n.tone4Desc,
              exampleHanzi: "去", // HSK1 ID: qu4
              examplePinyin: "qù",
              audioId: "qu4",
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

class _ToneRow extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String exampleHanzi;
  final String examplePinyin;
  final String audioId;

  const _ToneRow({
    required this.number,
    required this.title,
    required this.description,
    required this.exampleHanzi,
    required this.examplePinyin,
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
          const SizedBox(height: 4),
          Text(description, style: t.bodyMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(exampleHanzi, style: t.headlineMedium),
                const SizedBox(width: 12),
                Text(examplePinyin, style: t.titleMedium?.copyWith(fontStyle: FontStyle.italic)),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => AudioService.play(audioId), //
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