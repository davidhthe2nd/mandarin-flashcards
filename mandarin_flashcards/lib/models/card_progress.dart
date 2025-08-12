import 'enums.dart';

/// Tracks the learning progress for a single flashcard.
class CardProgress {
  final String cardId;           // Link to Flashcard.id
  LearningStatus status;         // Current learning pile
  AnswerQuality? lastAnswer;     // Last result (can be null if never answered)
  int timesSeen;                  // How many times shown to the user
  DateTime? lastReviewed;         // Last time this card was reviewed

  CardProgress({
    required this.cardId,
    this.status = LearningStatus.toLearn,
    this.lastAnswer,
    this.timesSeen = 0,
    this.lastReviewed,
  });

  /// Update progress when the user answers a card.
  void recordAnswer(AnswerQuality quality) {
    lastAnswer = quality;
    timesSeen++;
    lastReviewed = DateTime.now();

    // Update status based on answer quality
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

  /// Create from JSON (e.g., loading saved progress)
  factory CardProgress.fromJson(Map<String, dynamic> json) {
    return CardProgress(
      cardId: json['cardId'] as String,
      status: LearningStatus.values[json['status'] as int],
      lastAnswer: json['lastAnswer'] != null
          ? AnswerQuality.values[json['lastAnswer'] as int]
          : null,
      timesSeen: json['timesSeen'] as int,
      lastReviewed: json['lastReviewed'] != null
          ? DateTime.parse(json['lastReviewed'] as String)
          : null,
    );
  }

  /// Convert to JSON (e.g., for saving progress)
  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'status': status.index,
      'lastAnswer': lastAnswer?.index,
      'timesSeen': timesSeen,
      'lastReviewed': lastReviewed?.toIso8601String(),
    };
  }
}