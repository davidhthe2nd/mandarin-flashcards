// lib/ui/widgets/flashcard_face.dart
import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import "../../services/audio_service.dart";

class FlashcardFace extends StatelessWidget {
  final Flashcard card;
  final VoidCallback onFlip;
  final bool isFront;
  final bool showPinyin;
  final double exampleScale;

  const FlashcardFace({
    super.key,
    required this.card,
    required this.onFlip,
    required this.isFront,
    required this.showPinyin,
    this.exampleScale = 1.15,
  });

  Widget _playButton(String fileName, {double size = 24}) {
  return IconButton(
    visualDensity: VisualDensity.compact,
    icon: Icon(Icons.volume_up, size: size, color: Colors.blueGrey.withOpacity(0.7)),
    onPressed: () => AudioService.play(fileName),
  );
}

  @override
Widget build(BuildContext context) {
  final t = Theme.of(context).textTheme;
  final cs = Theme.of(context).colorScheme;

  final exampleStyle = (t.bodyLarge ?? t.bodyMedium!).copyWith(
    fontSize: ((t.bodyLarge ?? t.bodyMedium!).fontSize ?? 16) * exampleScale,
    height: 1.25,
  );

  final examplePinyinStyle = (t.bodyMedium ?? t.bodySmall!).copyWith(
    fontStyle: FontStyle.italic,
    color: cs.onSurfaceVariant.withOpacity(0.7),
  );

  return InkWell(
    onTap: onFlip,
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // 1. MAIN CONTENT (Hanzi or Spanish) + MAIN AUDIO
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    isFront ? card.hanzi : card.esES,
                    style: t.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Only show main word audio on the front (Chinese side)
                if (isFront) _playButton(card.id, size: 30),
              ],
            ),

            // MAIN PINYIN (Displayed under the main word if it's the front side)
            if (isFront && showPinyin)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(card.pinyin, style: t.headlineSmall),
              ),

            const Divider(height: 48),

            // 2. EXAMPLES SECTION
            if (card.exampleCN.isNotEmpty) ...[
              // Example Sentence + Example Audio
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      card.exampleCN,
                      style: exampleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _playButton("${card.id}_ex", size: 24),
                ],
              ),

              // Example Pinyin (Right under the sentence)
              if (showPinyin && card.examplePinyin.isNotEmpty)
                Text(
                  card.examplePinyin,
                  style: examplePinyinStyle,
                  textAlign: TextAlign.center,
                ),

              // Spanish Translation of the Example (Only on the back)
              if (!isFront && card.exampleES.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    card.exampleES,
                    style: exampleStyle.copyWith(
                      color: cs.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}