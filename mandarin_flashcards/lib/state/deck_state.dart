// lib/state/deck_state.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/flashcard.dart';
import '../models/card_progress.dart';
import '../models/enums.dart'; // AnswerQuality, LearningStatus
import '../services/deck_loader.dart';
import '../state/options_state.dart';

// new 🌙 (REPLACE your previous _Buckets + _bucketize)

// Buckets we want for mixing: toLearn, forgotten (derived), almost(reinforce), learned
class _Buckets { // new 🌙
  final List<Flashcard> toLearn;
  final List<Flashcard> forgotten;    // derived: toLearn + lastAnswer == wrong
  final List<Flashcard> almost;       // LearningStatus.reinforce
  final List<Flashcard> learned;      // LearningStatus.learned
  _Buckets({
    required this.toLearn,
    required this.forgotten,
    required this.almost,
    required this.learned,
  });
}

// We must read progress via your DeckState's _readProgressFor, so accept a reader fn
_Buckets _bucketize( // new 🌙
  List<Flashcard> cards,
  Random rng,
  CardProgress Function(String) readProgress,
) {
  final toLearn    = <Flashcard>[];
  final forgotten  = <Flashcard>[];
  final almost     = <Flashcard>[];
  final learned    = <Flashcard>[];

  for (final c in cards) {
    final p = readProgress(c.id); // new 🌙
    switch (p.status) {
      case LearningStatus.toLearn:
        if (p.lastAnswer == AnswerQuality.wrong) {
          forgotten.add(c);       // wrong → treat as "forgotten"
        } else {
          toLearn.add(c);         // unseen/new or non-wrong last answer
        }
        break;
      case LearningStatus.reinforce:
        almost.add(c);            // "almost there"
        break;
      case LearningStatus.learned:
        learned.add(c);
        break;
    }
  }

  // shuffle within buckets for variety
  toLearn.shuffle(rng);
  forgotten.shuffle(rng);
  almost.shuffle(rng);
  learned.shuffle(rng);

  return _Buckets(
    toLearn: toLearn,
    forgotten: forgotten,
    almost: almost,
    learned: learned,
  );
}


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

  // NEW: Busy flag so UI can disable buttons / show spinner
  bool isBusy = false; // NEW

  // NEW: Remember the last daily target used to build queue (for refresh())
  int _lastLimit = 0; // NEW

  // ---- Public getters for UI ----
  Flashcard? get current => _current;
  bool get isEmpty => _order.isEmpty;
  int get position => _order.isEmpty ? 0 : (_idx + 1);
  int get totalToday => _order.length;
  int get remainingToday => _order.isEmpty ? 0 : (_order.length - _idx);

  // Weights for selecting cards
  double weightToLearn = 0.60;
  double weightForgotten = 0.30;
  double weightAlmost = 0.10;

  // Optional: cap how many cards to prepare for a session
  int? _sessionTarget; // null -> use your existing daily goal if you have one

  List<Flashcard> _pool = <Flashcard>[]; // new 🌙 filtered by options

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
    _pool = _all; // default // new 🌙

    _applyHSKFilter(opts.hskLevels);                                   // new 🌙
    rebuildDueQueueWeighted(target: (opts.dailyTarget <= 0 ? 20 : opts.dailyTarget)); // new 🌙

    _idx = 0;
    _current = isEmpty ? null : _lookup(_order[_idx]);

    _t(
      "Init: all=${_all.length}, target=$_lastLimit",
    ); // CHANGED: clearer log 🌙
    if (_all.isEmpty) {
      _t(
        "WARNING: deck loaded 0 cards. Check JSON format & assets path.",
      ); // new 🌙
    } else {
      _t("Sample ids: ${_all.take(3).map((c) => c.id).toList()}"); // new 🌙
    }
  }

  // ---- Answer flow: ❌ / ❓ / ✔️ ----
  Future<void> answer(AnswerQuality quality) async {
    // NEW: guard against re-entrancy and null current
    if (isBusy || _current == null) {
      _t("Answer ignored (busy=$isBusy, current=${_current?.id})");
      return;
    }

    _setBusy(true); // NEW
    try {
      final now = DateTime.now();
      final cardId = _current!.id;

      // Look up or create progress
      final progress = _readProgressFor(cardId);

      // Apply scheduling (updates timesSeen, lastReviewed, nextDue, status, lastAnswer)
      _schedule(progress, quality, now);

      // Persist to Hive
      await _progressBox.put(cardId, progress);

      // Move to next card (same behavior as before)
      if (_idx < _order.length - 1) {
        _idx++;
        _current = _lookup(_order[_idx]);
      } else {
        _current = null; // session finished
      }

      notifyListeners();
    } finally {
      _setBusy(false); // NEW
    }
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

  // NEW: Rebuild the due queue using the last known daily target.
  Future<void> refresh() async {
    // NEW
    if (isBusy) return; // NEW
    _setBusy(true); // NEW
    try {
      rebuildDueQueueWeighted(target: _lastLimit); // new 🌙
      _idx = 0;
      _current = isEmpty ? null : _lookup(_order[_idx]);
      _t("Refreshed: dueToday=${_order.length}, limit=$_lastLimit");
      notifyListeners();
    } finally {
      _setBusy(false);
    }
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

    _t(
      "Queue built: kept=${_order.length} (found due=${dueIds.length}, limit=$limit)",
    );
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

  // NEW: centralize busy state changes
  void _setBusy(bool v) {
    // NEW
    isBusy = v;
    notifyListeners();
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
    rebuildDueQueueWeighted(
      target: (opts.dailyTarget <= 0 ? 20 : opts.dailyTarget),
    ); // new 🌙
    _lastLimit = (opts.dailyTarget <= 0 ? 20 : opts.dailyTarget); // new 🌙
    _idx = 0;
    _current = isEmpty ? null : _lookup(_order[_idx]);
    notifyListeners();
    _t("Progress reset");
  }

  // new 🌙
  void rebuildDueQueueWeighted({int? target}) {
    final buckets = _bucketize(_pool, _rng, _readProgressFor); // fix to use _pool // new 🌙

    final desired = target ?? _sessionTarget ?? _lastLimit ?? 20;

    int nToLearn = (desired * weightToLearn).round().clamp(
      0,
      buckets.toLearn.length,
    );
    int nForgotten = (desired * weightForgotten).round().clamp(
      0,
      buckets.forgotten.length,
    );
    int nAlmost = (desired * weightAlmost).round().clamp(
      0,
      buckets.almost.length,
    );

    final queue = <String>[
      ...buckets.toLearn.take(nToLearn).map((c) => c.id),
      ...buckets.forgotten.take(nForgotten).map((c) => c.id),
      ...buckets.almost.take(nAlmost).map((c) => c.id),
    ];

    void topUp(List<Flashcard> src, int alreadyTook) {
      if (queue.length >= desired) return;
      final remain = src.skip(alreadyTook);
      final can = desired - queue.length;
      if (can > 0) {
        queue.addAll(remain.take(can).map((c) => c.id));
      }
    }

    topUp(buckets.toLearn, nToLearn);
    topUp(buckets.forgotten, nForgotten);
    topUp(buckets.almost, nAlmost);
    topUp(buckets.learned, 0);

    _order
      ..clear()
      ..addAll(queue);

    _idx = 0;
    _current = isEmpty ? null : _lookup(_order[_idx]);

    _lastLimit = desired;
    _t(
      "Weighted queue built: kept=${_order.length}, desired=$desired",
    ); // new 🌙
    notifyListeners();
  }

  void _applyHSKFilter(Set<int> levels) { // new 🌙
  // Adjust this selector if your field name differs (e.g., card.hsk or card.tags.contains)
    _pool = _all.where((c) {
    final int level = c.hsk; // <— if your model uses `hsk`, change to `c.hsk` // new 🌙
    return levels.contains(level);
  }).toList();
    _t('HSK filter -> levels=$levels, pool=${_pool.length}'); // new 🌙
  }

  void applyHSKAndRequeue(Set<int> levels, {int? target}) { // new 🌙
  _applyHSKFilter(levels);
  rebuildDueQueueWeighted(target: target ?? _lastLimit);
  notifyListeners();
  }

  void setMix({double? toLearn, double? forgotten, double? almost}) {
  if (toLearn   != null) weightToLearn   = toLearn;
  if (forgotten != null) weightForgotten = forgotten;
  if (almost    != null) weightAlmost    = almost;
  final sum = weightToLearn + weightForgotten + weightAlmost;
  if (sum > 0) {
    weightToLearn   /= sum;
    weightForgotten /= sum;
    weightAlmost    /= sum;
  } else {
    weightToLearn = 1; weightForgotten = 0; weightAlmost = 0;
  }
  notifyListeners();
}
}
