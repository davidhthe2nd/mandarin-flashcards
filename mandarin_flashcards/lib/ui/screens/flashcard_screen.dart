import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/deck_state.dart';
import '../../state/options_state.dart';                 // new: read pinyin/invert options 🌙
import '../../models/enums.dart';
import '../widgets/flashcard_face.dart';                 // new: use Face everywhere 🌙
import '../../models/flashcard.dart';                                                        

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.card});
  final Flashcard card;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}


class _FlashcardScreenState extends State<FlashcardScreen> {
  bool _isFront = true;

  @override
  Widget build(BuildContext context) {
    final opts = context.watch<OptionsState>();

    // If “invert pair” is on, Spanish should be shown when _isFront is true
    final faceIsFront = opts.invertPair ? !_isFront : _isFront;

    return FlashcardFace(
      card: widget.card,
      onFlip: () => setState(() => _isFront = !_isFront),
      isFront: faceIsFront,
      showPinyin: opts.showPinyin,
      exampleScale: 1.15, // or opts.exampleScale
    );
  }
}
