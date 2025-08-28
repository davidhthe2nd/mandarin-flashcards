import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // new: for light haptics on celebrate 🌙

import '../../state/deck_state.dart';
import '../../state/options_state.dart';
import '../../models/enums.dart';
import '../../models/flashcard.dart';

import '../widgets/flashcard_face.dart';
import '../widgets/answer_buttons.dart';
import '../widgets/daily_progress_header.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool isFront = true;
  bool _celebratedToday = false; // new: one-shot guard per session 🌙

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckState>();
    final opts = context.watch<OptionsState>();
    final Flashcard? card = deck.current;

    // new: fire a one-time celebration when daily goal is reached 🌙
    if (!_celebratedToday &&
        deck.totalToday > 0 &&
        deck.position >= deck.totalToday &&
        deck.current == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Haptic + SnackBar 🎉
        HapticFeedback.lightImpact(); // new: subtle haptic 🌙
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Nice! Daily goal reached.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _celebratedToday = true); // new: prevent repeats 🌙
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          // new: quick toggles so you can switch study mode on the fly 🌙
          Row(children: [
            const Text('Show pinyin'),
            Switch(
              value: opts.showPinyin,
              onChanged: (v) => context.read<OptionsState>().toggleShowPinyin(v), // new: persist + notify 🌙
            ),
            const SizedBox(width: 12), // new: little spacing between switches 🌙
            const Text('Invert'),
            Switch(
              value: opts.invertPair,
              onChanged: (v) => context.read<OptionsState>().toggleInvertPair(v), // new: flip prompt/answer sides 🌙
            ),
            const SizedBox(width: 8),
          ]),
        ],
    ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: deck.isBusy
                ? const Center(child: CircularProgressIndicator()) // new: show spinner while DeckState is processing 🌙
                : (card == null
                    ? const _EmptyState()
                    : Column(
                        // CHANGED: make the column take available height so the scroller below has room 🌙
                        mainAxisSize: MainAxisSize.max, // new: allow Flexible to work properly 🌙
                        children: [
                          DailyProgressHeader( // new: shows “x / y” + progress bar 🌙
                            position: deck.position,
                            total: deck.totalToday,
                          ),
                          const SizedBox(height: 12), // new: spacing under header 🌙
                          // new: let the card area grow/shrink and enable scrolling for long text 🌙
                          Flexible( // new: prevents overflow when content is tall 🌙
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: SingleChildScrollView( // new: scroll when text is very long 🌙
                                key: ValueKey(isFront ? 'frontScroll' : 'backScroll'), // new: keep switcher identity distinct 🌙
                                padding: const EdgeInsets.only(bottom: 8), // new: breathing room at bottom 🌙
                                child: isFront
                                    ? _FrontFace(
                                        key: const ValueKey('front'),
                                        card: card,
                                        showPinyin: opts.showPinyin,
                                        invert: opts.invertPair,
                                      )
                                    : _BackFace(
                                        key: const ValueKey('back'),
                                        card: card,
                                        showPinyin: opts.showPinyin,
                                        invert: opts.invertPair,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (isFront)
                            FilledButton(
                              onPressed: () => setState(() => isFront = false),
                              child: const Text('Flip card'),
                            )
                          else
                            // Prefer this if your AnswerButtons supports an `enabled` flag:
                            AnswerButtons(
                              enabled: !deck.isBusy, // new: prevent double-taps during async work 🌙
                              onWrong:  () => _answer(context, AnswerQuality.wrong),
                              onUnsure: () => _answer(context, AnswerQuality.unsure),
                              onCorrect:() => _answer(context, AnswerQuality.correct),
                            ),
                            // If your AnswerButtons does NOT have `enabled`, use this instead (requires its callbacks to be nullable):
                            // AnswerButtons(
                            //   onWrong:  deck.isBusy ? null : () => _answer(context, AnswerQuality.wrong),   // new: disable while busy 🌙
                            //   onUnsure: deck.isBusy ? null : () => _answer(context, AnswerQuality.unsure),  // new: disable while busy 🌙
                            //   onCorrect:deck.isBusy ? null : () => _answer(context, AnswerQuality.correct), // new: disable while busy 🌙
                            // ),
                        ],
                      )),
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
    final deck = context.watch<DeckState>(); // new: access DeckState to allow refresh from empty state 🌙
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('All done for now!'),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: deck.isBusy ? null : () => deck.refresh(), // new: one-tap rebuild of due queue 🌙
          child: const Text('Keep learning'),
        ),
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
