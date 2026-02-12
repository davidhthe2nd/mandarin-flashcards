import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/flashcard.dart';
import "../../services/audio_service.dart";
import "../../state/options_state.dart";

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

  Widget _playButton(String fileName, {double size = 24, Color? color}) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.volume_up_rounded,
        size: size, 
        color: color ?? Colors.blueGrey.withOpacity(0.5)
      ),
      onPressed: () => AudioService.play(fileName),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch OptionsState to react to language (localeCode) changes
    final opts = context.watch<OptionsState>();
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Determine the main text and example translation based on current locale
    final mainText = isFront 
        ? card.hanzi 
        : card.getTranslation(opts.localeCode);

    final exampleTranslation = card.getExampleTranslation(opts.localeCode);

    // Custom styles for better hierarchy
    final pinyinStyle = t.headlineSmall?.copyWith(
      color: cs.primary.withOpacity(0.7),
      letterSpacing: 1.2,
    );

    final exampleStyle = (t.bodyLarge ?? t.bodyMedium!).copyWith(
      fontSize: ((t.bodyLarge ?? t.bodyMedium!).fontSize ?? 16) * exampleScale,
      height: 1.4,
      color: cs.onSurface.withOpacity(0.9),
    );

    final examplePinyinStyle = (t.bodyMedium ?? t.bodySmall!).copyWith(
      fontStyle: FontStyle.italic,
      color: cs.onSurfaceVariant.withOpacity(0.6),
    );

    return InkWell(
      onTap: onFlip,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. MAIN SECTION (Hanzi or Translation)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 40), 
                  Flexible(
                    child: Text(
                      mainText,
                      style: t.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (isFront) _playButton(card.id, size: 32, color: cs.primary.withOpacity(0.6)),
                ],
              ),
              
              if (isFront && showPinyin)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(card.pinyin, style: pinyinStyle),
                ),

              const SizedBox(height: 40),

              // 2. EXAMPLES SECTION
              if (card.exampleCN.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 32),
                    Flexible(
                      child: Text(
                        card.exampleCN, 
                        style: exampleStyle, 
                        textAlign: TextAlign.center
                      ),
                    ),
                    _playButton("${card.id}_ex", size: 22),
                  ],
                ),
                
                if (showPinyin && card.examplePinyin.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      card.examplePinyin, 
                      style: examplePinyinStyle, 
                      textAlign: TextAlign.center
                    ),
                  ),

                // Show localized example translation on the back if it exists
                if (!isFront && exampleTranslation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      exampleTranslation,
                      style: exampleStyle.copyWith(
                        color: cs.secondary.withOpacity(0.8), 
                        fontSize: exampleStyle.fontSize! * 0.85,
                        fontStyle: FontStyle.italic
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}