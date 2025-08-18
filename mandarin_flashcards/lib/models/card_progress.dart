import 'enums.dart';

/// Tracks the learning progress for a single flashcard.
class CardProgress {
  final String cardId;           // Link to Flashcard.id
  LearningStatus status;         // Current learning pile
  AnswerQuality? lastAnswer;     // Last result (can be null if never answered)
  int timesSeen;                 // How many times shown to the user
  DateTime? lastReviewed;        // Last time this card was reviewed
  DateTime? nextDue;             // When this card becomes due again

  CardProgress({
    required this.cardId,
    this.status = LearningStatus.toLearn,
    this.lastAnswer,
    this.timesSeen = 0,
    this.lastReviewed,
    this.nextDue,
  });

  /// Update progress when the user answers a card.
  /// (Scheduling is handled by DeckState; this does not change nextDue.)
  void recordAnswer(AnswerQuality quality) {
    lastAnswer = quality;
    timesSeen++;
    lastReviewed = DateTime.now();

    switch (quality) {
      case AnswerQuality.wrong:
        status = LearningStatus.toLearn;
        break;
      case AnswerQuality.unsure:
        status = LearningStatus.reinforce;
        break;
      case AnswerQuality.correct:
        status = LearningStatus.learned;
        break;
    }
  }

  /// Helper used by DeckState to set the next due time.
  void setNextDue(Duration interval, {DateTime? from}) {
    final base = from ?? DateTime.now();
    nextDue = base.add(interval);
  }

  /// Create from JSON (backward-compatible).
  factory CardProgress.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for older / inconsistent data.
    int _safeIndex(List values, Object? raw, int fallback) {
      if (raw is int && raw >= 0 && raw < values.length) return raw;
      return fallback;
    }

    return CardProgress(
      cardId: json['cardId'] as String,
      status: LearningStatus.values[
          _safeIndex(LearningStatus.values, json['status'], LearningStatus.toLearn.index)
      ],
      lastAnswer: json['lastAnswer'] == null
          ? null
          : AnswerQuality.values[
              _safeIndex(AnswerQuality.values, json['lastAnswer'], 0)
            ],
      timesSeen: (json['timesSeen'] is int)
          ? json['timesSeen'] as int
          : int.tryParse('${json['timesSeen']}') ?? 0,
      lastReviewed: json['lastReviewed'] != null
          ? DateTime.tryParse(json['lastReviewed'] as String)
          : null,
      nextDue: json['nextDue'] != null
          ? DateTime.tryParse(json['nextDue'] as String)
          : null,
    );
  }

  /// Convert to JSON for persistence.
  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'status': status.index,
      'lastAnswer': lastAnswer?.index,
      'timesSeen': timesSeen,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextDue': nextDue?.toIso8601String(),
    };
  }
}