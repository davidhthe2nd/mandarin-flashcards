// lib/state/deck_state.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/flashcard.dart';
import '../models/card_progress.dart';
import '../models/enums.dart';          // AnswerQuality, LearningStatus
import '../services/deck_loader.dart';
import '../state/options_state.dart';

class DeckState extends ChangeNotifier {
  DeckState(this._progressBoxName);

  // ---- Hive (per-card progress) ----
  final String _progressBoxName;
  late Box<CardProgress> _progressBox;

  // ---- All cards & today's due queue ----
  final _rng = Random();
  List<Flashcard> _all = <Flashcard>[];

  /// Ordered list of card IDs due today.
  final List<String> _order = <String>[];

  /// Pointer within [_order].
  int _idx = 0;

  /// Cached current card (null when queue exhausted).
  Flashcard? _current;

  // ---- Public getters for UI ----
  Flashcard? get current => _current;
  bool get isEmpty => _order.isEmpty;
  int get position => _order.isEmpty ? 0 : (_idx + 1);
  int get totalToday => _order.length;
  int get remainingToday => _order.isEmpty ? 0 : (_order.length - _idx);

  /// Convenience: current progress for the active card.
  CardProgress? get currentProgress =>
      (_current == null) ? null : _readProgressFor(_current!.id);

  // ---- Init: open box, load cards, build today's queue ----
  ///
  /// Call this after OptionsState.init() in your app bootstrap:
  ///   await deck.init(options, 'assets/data/hsk1.csv');
  Future<void> init(OptionsState opts, String assetPath) async {
    _progressBox = await Hive.openBox<CardProgress>(_progressBoxName);

    // Use your real loader (CSV/JSON) that returns a deck with a .cards list
    final deck = await DeckLoader.loadFromAsset(assetPath);
    _all = deck.cards;

    _buildDueQueue(limit: opts.dailyTarget);

    _idx = 0;
    _current = isEmpty ? null : _lookup(_order[_idx]);

    _t("Init: all=${_all.length}, dueToday=${_order.length}, target=${opts.dailyTarget}");
    notifyListeners();
  }

  // ---- Answer flow: ❌ / ❓ / ✔️ ----
  Future<void> answer(AnswerQuality quality) async {
    if (_current == null) {
      _t("Answer called but no current card");
      return;
    }

    final now = DateTime.now();
    final cardId = _current!.id;

    // Look up or create progress
    final progress = _readProgressFor(cardId);

    // Apply scheduling (updates timesSeen, lastReviewed, nextDue, status, lastAnswer)
    _schedule(progress, quality, now);

    // Persist to Hive
    await _progressBox.put(cardId, progress);

    // Move to next card
    if (_idx < _order.length - 1) {
      _idx++;
      _current = _lookup(_order[_idx]);
    } else {
      _current = null; // session finished
    }

    notifyListeners();
  }

  /// Advance to the next due card; when finished, clear queue/current.
  Future<void> nextCard() async {
    if (isEmpty) return;

    if (_idx + 1 < _order.length) {
      _idx++;
      _current = _lookup(_order[_idx]);
    } else {
      // Queue exhausted
      _order.clear();
      _current = null;
    }
    _t("Advance: idx=$_idx/${_order.length}, current=${_current?.id}");
    notifyListeners();
  }

  // ---- Queue building ----
  void _buildDueQueue({required int limit}) {
    final now = DateTime.now();
    final dueIds = <String>[];

    for (final c in _all) {
      final p = _readProgressFor(c.id);
      final due = p.nextDue;
      if (due == null || !due.isAfter(now)) {
        dueIds.add(c.id);
      }
    }

    // Shuffle for a bit of variety (optional), then cap by daily target
    dueIds.shuffle(_rng);
    _order
      ..clear()
      ..addAll(dueIds.take(limit));

    _t("Queue built: kept=${_order.length} (found due=${dueIds.length}, limit=$limit)");
  }

  // ---- Scheduling heuristic (swap for SM-2 later if desired) ----
  CardProgress _schedule(CardProgress p, AnswerQuality q, DateTime now) {
    Duration interval;

    switch (q) {
      case AnswerQuality.wrong:
        interval = const Duration(hours: 8);
        p.status = LearningStatus.toLearn;
        break;
      case AnswerQuality.unsure:
        interval = const Duration(days: 1);
        p.status = LearningStatus.reinforce;
        break;
      case AnswerQuality.correct:
        // naive doubling based on previous interval length (in days)
        final prevDays = (p.nextDue == null || p.lastReviewed == null)
            ? 0
            : p.nextDue!.difference(p.lastReviewed!).inDays;
        final nextDays = prevDays == 0 ? 1 : (prevDays * 2);
        interval = Duration(days: nextDays.clamp(1, 60));
        p.status = LearningStatus.learned;
        break;
    }

    p
      ..lastAnswer = q
      ..timesSeen = p.timesSeen + 1
      ..lastReviewed = now
      ..nextDue = now.add(interval);

    return p;
  }

  // ---- Helpers ----
  Flashcard _lookup(String id) {
    if (_all.isEmpty) {
      throw StateError('Deck is empty; cannot lookup "$id".');
    }
    return _all.firstWhere(
      (c) => c.id == id,
      orElse: () {
        // If content set changed, this prevents a crash; you can also choose to skip.
        _t("Lookup miss for id=$id");
        return _all.first;
      },
    );
  }

  void _t(String msg) {
    if (kDebugMode) debugPrint("[DeckState] $msg");
  }

  // ---- Persistence helpers ----------
  CardProgress _readProgressFor(String id) {
    final existing = _progressBox.get(id);
    if (existing != null) return existing;

    // Default for unseen cards
    final cp = CardProgress(cardId: id, status: LearningStatus.toLearn);
    _progressBox.put(id, cp);
    return cp;
    }

  /// Reset all progress: clears Hive progress box and rebuilds queue.
  Future<void> resetProgress(OptionsState opts, String assetPath) async {
    await _progressBox.clear();
    _buildDueQueue(limit: opts.dailyTarget);
    _idx = 0;
    _current = isEmpty ? null : _lookup(_order[_idx]);
    notifyListeners();
    _t("Progress reset");
  }
}
