import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/flashcard.dart';
import '../models/card_progress.dart';
import '../services/deck_service.dart';
import '../state/options_state.dart';
import "../models/enums.dart"; // LearningStatus

class ChooseState extends ChangeNotifier {
  final DeckService _deckService;
  final OptionsState _options;
  final String _answerLang; // e.g., 'enUS' or 'esES'

  ChooseState(this._deckService, this._options, {String answerLang = 'enUS'})
      : _answerLang = answerLang {
    _options.addListener(_onOptionsChanged);
  }

  /// Full deck and progress
  List<Flashcard> _all = [];
  Map<String, CardProgress> _progressById = {};

  /// Candidate pool for today's choosing session (size ≤ dailyTarget)
  final List<Flashcard> _pool = [];

  /// Current card
  Flashcard? _current;

  /// State flags
  bool _loading = false;
  String? _error;

  /// Public getters
  bool get loading => _loading;
  String? get error => _error;
  Flashcard? get current => _current;
  int get remaining => _pool.length;
  bool get hasCards => _current != null;

  /// Initialize: load deck & progress and build today's pool.
  Future<void> init() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final deck = await _deckService.loadDeck();
      final progress = await _deckService.loadProgress();

      _all = deck ?? [];
      _progressById = {
        for (final p in (progress ?? <CardProgress>[])) p.cardId: p
      };

      _rebuildDailyPool();
      _pickNextInternal();
    } catch (e) {
      _error = 'Failed to load deck/progress: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Choose (confirm) the current card and move on.
  Future<void> chooseCurrent() async {
    final card = _current;
    if (card == null) return;

    final entry = _progressById.putIfAbsent(
      card.id,
      () => CardProgress(cardId: card.id),
    );

    // Minimal, safe progress update for a choose flow
    entry.timesSeen = (entry.timesSeen) + 1;
    entry.status = LearningStatus.toLearn;

    try {
      await _deckService.saveProgress(entry);
    } catch (_) {
      // Non-fatal; keep going
    }

    // Remove from pool so we don't see it again this session
    _pool.removeWhere((c) => c.id == card.id);
    _pickNextInternal();
    notifyListeners();
  }

  /// Skip current card (keeps it in pool, moves to another)
  void skip() {
    final card = _current;
    if (card == null || _pool.length <= 1) return;
    // rotate: move current to the end, pick another
    _pool.removeWhere((c) => c.id == card.id);
    _pool.add(card);
    _pickNextInternal();
    notifyListeners();
  }

  /// Render helpers respecting options
  /// (Use these in your UI to show the right side of the card.)
  String frontText(Flashcard card) {
    // If invertPair => show "answer" as prompt; else show "prompt"
    return _options.invertPair ? card.answer : card.prompt;
  }

  String backText(Flashcard card) {
    return _options.invertPair ? card.prompt : card.answer;
  }

  /// Optional helper for pinyin visibility (UI can honor this)
  bool get showPinyin => _options.showPinyin;

  // --- internals ---

  void _onOptionsChanged() {
    // Recompute pool only if dailyTarget changed materially,
    // but it's cheap enough to just rebuild when any option flips.
    _rebuildDailyPool();
    // Ensure current is always in sync with pool
    if (_current == null || !_pool.any((c) => c.id == _current!.id)) {
      _pickNextInternal();
    }
    notifyListeners();
  }

  /// Build today’s pool: due cards first, then fill up to dailyTarget.
  void _rebuildDailyPool() {
    final target = _options.dailyTarget.clamp(1, 200);
    _pool.clear();

    if (_all.isEmpty) return;

    final now = DateTime.now();

    // Partition: due first, then the rest
    final due = <Flashcard>[];
    final rest = <Flashcard>[];

    for (final c in _all) {
      final p = _progressById[c.id];
      final nextDue = p?.nextDue;
      final isDue = nextDue == null || !nextDue.isAfter(now);
      if (isDue) {
        due.add(c);
      } else {
        rest.add(c);
      }
    }

    // Fill pool: due first
    void addSome(List<Flashcard> src) {
      for (final c in src) {
        if (_pool.length >= target) break;
        _pool.add(c);
      }
    }

    // Shuffle lightly for variety (non-deterministic is fine here)
    due.shuffle(Random());
    rest.shuffle(Random());

    addSome(due);
    if (_pool.length < target) addSome(rest);

    // Ensure uniqueness and truncate to target
    final seen = <String>{};
    final unique = <Flashcard>[];
    for (final c in _pool) {
      if (seen.add(c.id)) unique.add(c);
      if (unique.length >= target) break;
    }

    _pool
      ..clear()
      ..addAll(unique);
  }

  void _pickNextInternal() {
    if (_pool.isEmpty) {
      _current = null;
      return;
    }
    // Random pick; swap to SR algorithm later
    _current = _pool[Random().nextInt(_pool.length)];
  }

  @override
  void dispose() {
    _options.removeListener(_onOptionsChanged);
    super.dispose();
  }
}
