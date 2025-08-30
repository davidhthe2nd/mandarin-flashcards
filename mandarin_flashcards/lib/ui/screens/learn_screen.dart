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
  // controller for unifying card height
  static const double _kCardViewportHeight = 380; // try 360–420 if you want

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
          Row(
            children: [
              const Text('Show pinyin'),
              Switch(
                value: opts.showPinyin,
                onChanged: (v) => context.read<OptionsState>().toggleShowPinyin(
                  v,
                ), // new: persist + notify 🌙
              ),
              const SizedBox(
                width: 12,
              ), // new: little spacing between switches 🌙
              const Text('Invert'),
              Switch(
                value: opts.invertPair,
                onChanged: (v) => context.read<OptionsState>().toggleInvertPair(
                  v,
                ), // new: flip prompt/answer sides 🌙
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: deck.isBusy
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // new: show spinner while DeckState is processing 🌙
                : (card == null
                      ? const _EmptyState()
                      : Column(
                          // CHANGED: make the column take available height so the scroller below has room 🌙
                          mainAxisSize: MainAxisSize
                              .max, // new: allow Flexible to work properly 🌙
                          children: [
                            DailyProgressHeader(
                              // new: shows “x / y” + progress bar 🌙
                              position: deck.position,
                              total: deck.totalToday,
                            ),
                            const SizedBox(
                              height: 12,
                            ), // new: spacing under header 🌙
                            // new: let the card area grow/shrink and enable scrolling for long text 🌙
                            SizedBox(
                              height: _kCardViewportHeight,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: isFront
                                    ? _FrontFace(
                                        key: const ValueKey('front'),
                                        card: card,
                                        showPinyin: opts.showPinyin,
                                        invert: opts.invertPair,
                                        onFlip: () =>
                                            setState(() => isFront = false),
                                      )
                                    : _BackFace(
                                        key: const ValueKey('back'),
                                        card: card,
                                        showPinyin: opts.showPinyin,
                                        invert: opts.invertPair,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isFront)
                              FilledButton(
                                onPressed: () =>
                                    setState(() => isFront = false),
                                child: const Text('Flip card'),
                              )
                            else
                              // Prefer this if your AnswerButtons supports an `enabled` flag:
                              AnswerButtons(
                                enabled: !deck
                                    .isBusy, // new: prevent double-taps during async work 🌙
                                onWrong: () =>
                                    _answer(context, AnswerQuality.wrong),
                                onUnsure: () =>
                                    _answer(context, AnswerQuality.unsure),
                                onCorrect: () =>
                                    _answer(context, AnswerQuality.correct),
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
    final deck = context
        .watch<
          DeckState
        >(); // new: access DeckState to allow refresh from empty state 🌙
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('All done for now!'),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: deck.isBusy
              ? null
              : () => deck.refresh(), // new: one-tap rebuild of due queue 🌙
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
    required this.onFlip,
  });

  final Flashcard card;
  final bool showPinyin;
  final bool invert;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    // If invert == true, we want the Spanish side on “front”,
    // which corresponds to FlashcardFace(isFront: false).
    final bool faceIsFront = !invert;

    return FlashcardFace(
      card: card,
      onFlip:
          onFlip, // only the actual “front” shows the Flip button in your screen logic
      isFront: faceIsFront,
      showPinyin: showPinyin,
      // If you added an exampleScale in Options, pass it here; otherwise use a sensible default:
      exampleScale: 1.15,
    );
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
    final t = Theme.of(context).textTheme;

    // Back face = meaning-first. If you later support other locales, swap 'esES'.
    final es = card.translations['esES'] ?? '';

    // When invert==true your LearnScreen already swaps which side is shown first.
    // Here we always render the "meaning" layout for the back.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1) Translation as the main title
          Text(es, style: t.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),

          // 2) Big Hanzi with optional pinyin to the right (single occurrence)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // BIG Hanzi
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  card.hanzi,
                  textAlign: TextAlign.center,
                  // Bigger than front: displaySmall works well; tweak if you want larger
                  style: t.displaySmall,
                ),
              ),
              if (showPinyin) ...[
                const SizedBox(width: 12),
                // Align pinyin baseline with the bottom of the Hanzi for a clean look
                Baseline(
                  baselineType: TextBaseline.alphabetic,
                  // Use a sensible baseline; if null, fallback to 24
                  baseline: (t.titleMedium?.fontSize ?? 24),
                  child: Text(
                    card.pinyin,
                    style: t.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
          // 👇 reserve area that the front uses for example CN + example pinyin
          const SizedBox(height: 12),
          const SizedBox(height: 56), // _exampleReserve; adjust if needed
        ],
      ),
    );
  }
}
