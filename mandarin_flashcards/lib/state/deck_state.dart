import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/flashcard.dart';
import '../models/card_progress.dart';
import '../models/enums.dart';
import '../services/deck_loader.dart';

class DeckState extends ChangeNotifier {
  DeckState(this._progressBoxName);

  final String _progressBoxName;
  late final Box _progressBox;

  final _rng = Random();
  List<Flashcard> _all = [];
  Flashcard? _current;
  Map<String, CardProgress> _progress = {};

  Flashcard? get current => _current;
  int get total => _all.length;

  Future<void> loadDeck(String assetPath) async {
    _progressBox = Hive.box(_progressBoxName);

    final deck = await DeckLoader.loadFromAsset(assetPath);
    _all = deck.cards;

    // Hydrate progress from Hive (or defaults)
    _progress = {
      for (final c in _all) c.id: _readProgressFor(c.id)
    };

    _pickNext();
    notifyListeners();
    }
    // How many cards are "due" by our simple rule
    int get dueCount {
    final toLearn = _all.where((c) => _progress[c.id]?.status == LearningStatus.toLearn).length;
    final reinforce = _all.where((c) => _progress[c.id]?.status == LearningStatus.reinforce).length;
    return toLearn + reinforce;
  }

  // Choose next due card (prototype rule: toLearn > reinforce > else random)
  void _pickNext() {
    // Very simple due logic for v1:
    final toLearn = _all.where((c) => _progress[c.id]?.status == LearningStatus.toLearn).toList();
    final reinforce = _all.where((c) => _progress[c.id]?.status == LearningStatus.reinforce).toList();

    List<Flashcard> pool;
    if (toLearn.isNotEmpty) {
      pool = toLearn;
    } else if (reinforce.isNotEmpty) {
      pool = reinforce;
    } else {
      pool = _all; // learned: keep showing something for now
    }

    pool.shuffle(_rng);
    _current = pool.isNotEmpty ? pool.first : null;
  }

  void answer(AnswerQuality quality) {
    final c = _current;
    if (c == null) return;

    final cp = _progress[c.id] ?? CardProgress(cardId: c.id);
    cp.recordAnswer(quality);
    _writeProgressFor(cp);

    _pickNext();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    for (final c in _all) {
      final cp = CardProgress(cardId: c.id, status: LearningStatus.toLearn);
      _writeProgressFor(cp);
      _progress[c.id] = cp;
    }
    _pickNext();
    notifyListeners();
  }

  // ---------- Persistence helpers ----------

  CardProgress _readProgressFor(String id) {
    final raw = _progressBox.get(id);
    if (raw is Map) {
      try {
        return CardProgress.fromJson(Map<String, dynamic>.from(raw));
      } catch (_) {/* fall through */}
    }
    // default
    final cp = CardProgress(cardId: id, status: LearningStatus.toLearn);
    _writeProgressFor(cp);
    return cp;
  }

  void _writeProgressFor(CardProgress cp) {
    _progressBox.put(cp.cardId, cp.toJson());
  }
}