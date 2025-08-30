import 'package:flutter/material.dart';
import '../../models/flashcard.dart';

class FlashcardFace extends StatelessWidget {
  final Flashcard card;
  final VoidCallback onFlip;

  // new 🌙
  final bool isFront; // true = Mandarin side
  final bool showPinyin; // respect OptionsState
  final double exampleScale; // 0.8–1.6 suggested

  const FlashcardFace({
    super.key,
    required this.card,
    required this.onFlip,
    // new 🌙
    required this.isFront,
    required this.showPinyin,
    this.exampleScale = 1.15, // new 🌙 a touch bigger by default
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final es = card.translations['esES'] ?? '';

    // new 🌙 scale example sentence
    final exampleStyle = (t.bodyLarge ?? t.bodyMedium!).copyWith(
      fontSize: ((t.bodyLarge ?? t.bodyMedium!).fontSize ?? 16) * exampleScale,
      height: 1.25,
    );

    // new 🌙 smaller, italic pinyin for example line
    final examplePinyinStyle = (t.bodyMedium ?? t.bodySmall!).copyWith(
      fontStyle: FontStyle.italic,
      color: (t.bodyMedium ?? t.bodySmall!).color?.withOpacity(0.85),
      height: 1.15,
    );

    // new 🌙 reserve a fixed height for pinyin line to prevent button jump
    const double reservedPinyinHeight = 22.0;

    // derive values per build, based on this.card
    final String? exampleCn = card.example?.cn ?? card.exampleChinese;
    final String? examplePinyin = card.example?.pinyin ?? card.examplePinyin;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TOP
          Column(
            children: [
              if (isFront)
                Opacity(
                  opacity: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      es, // Spanish translation, invisible here
                      style: t.headlineMedium, // same style as back face
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Title (hanzi / main line)
              Text(
                card.hanzi,
                style: t.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Front-side pinyin under the title (optional)
              if (isFront && showPinyin)
                Text(
                  card.pinyin,
                  style: t.titleMedium,
                  textAlign: TextAlign.center,
                )
              else if (isFront && !showPinyin)
                const SizedBox(
                  height: 20,
                ), // keep spacing when hidden // new 🌙

              const SizedBox(height: 12),

              // Example CN (Traditional)
              if (card.exampleChinese != null &&
                  card.exampleChinese!.isNotEmpty)
                Text(
                  card.exampleChinese!,
                  style: exampleStyle,
                  textAlign: TextAlign.center,
                ),

              // Example pinyin line (right under example CN) // new 🌙
              SizedBox(
                height: isFront ? reservedPinyinHeight : 0,
                child:
                    (isFront &&
                        showPinyin &&
                        // If your model uses exampleUS for pinyin, swap below accordingly:
                        card.examplePinyin != null &&
                        card.examplePinyin!.isNotEmpty)
                    ? Align(
                        alignment: Alignment.center,
                        child: Text(
                          card.examplePinyin!, // <- pinyin for the example sentence
                          style: examplePinyinStyle,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),

          // BOTTOM (Flip button stays put thanks to the reserved height above)
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
