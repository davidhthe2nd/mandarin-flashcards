/// Quality of the user's recall when flipping a card.
enum AnswerQuality {
  wrong,      // X → didn't remember
  unsure,     // ? → somewhat remembered
  correct     // ✓ → knew well
}

/// Current learning status of the card.
enum LearningStatus {
  toLearn,    // Card is new or reset
  reinforce,  // Needs extra practice
  learned     // Mastered
}

/// Type of deck (future-proof for multiple decks or languages).
enum DeckType {
  hsk1TradEs,
  // hsk2TradEs,
  // hsk1TradEn,
}