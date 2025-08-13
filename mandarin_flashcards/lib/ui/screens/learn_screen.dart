import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../../state/options_state.dart';
import '../../models/enums.dart';
import '../../models/flashcard.dart';

import '../widgets/flashcard_face.dart';
import '../widgets/answer_buttons.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool isFront = true;

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    final opts = context.watch<OptionsState>();
    final Flashcard? card = deck.current;

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: card == null
                ? const _EmptyState()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: isFront
                            ? _FrontFace(key: const ValueKey('front'), card: card, showPinyin: opts.showPinyin, invert: opts.invertPair)
                            : _BackFace(key: const ValueKey('back'), card: card, showPinyin: opts.showPinyin, invert: opts.invertPair),
                      ),
                      const SizedBox(height: 16),
                      if (isFront)
                        FilledButton(
                          onPressed: () => setState(() => isFront = false),
                          child: const Text('Show answer'),
                        )
                      else
                        AnswerButtons(
                          onWrong:  () => _answer(context, AnswerQuality.wrong),
                          onUnsure: () => _answer(context, AnswerQuality.unsure),
                          onCorrect:() => _answer(context, AnswerQuality.correct),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _answer(BuildContext context, AnswerQuality q) {
    context.read<DeckState>().answer(q);
    setState(() => isFront = true);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('All done for now!'),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Back to menu'),
        ),
      ],
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({
    super.key,
    required this.card,
    required this.showPinyin,
    required this.invert,
  });

  final Flashcard card;
  final bool showPinyin;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    if (!invert) {
      // Default: front shows Traditional + optional pinyin + optional example (cn)
      return FlashcardFace(
        title: card.hanzi,
        subtitle: showPinyin ? card.pinyin : null,
        footnote: card.example?.cn,
      );
    } else {
      // Inverted mode: front shows Spanish only
      final es = card.translations['esES'] ?? '';
      return FlashcardFace(
        title: es,
      );
    }
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({
    super.key,
    required this.card,
    required this.showPinyin,
    required this.invert,
  });

  final Flashcard card;
  final bool showPinyin;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    if (!invert) {
      // Default: back shows Spanish; footnote shows Hanzi (+ pinyin if enabled)
      final es = card.translations['esES'] ?? '';
      return FlashcardFace(
        title: es,
        subtitle: showPinyin ? card.pinyin : null,
        footnote: '${card.hanzi}${showPinyin ? "  •  ${card.pinyin}" : ""}',
      );
    } else {
      // Inverted: back shows Hanzi (+ pinyin) and optional example
      return FlashcardFace(
        title: card.hanzi,
        subtitle: showPinyin ? card.pinyin : null,
        footnote: card.example?.cn,
      );
    }
  }
}