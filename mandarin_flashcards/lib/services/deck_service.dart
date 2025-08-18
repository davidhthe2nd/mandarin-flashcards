import '../models/flashcard.dart';
import '../models/card_progress.dart';

abstract class DeckService {
  Future<List<Flashcard>> loadDeck();
  Future<List<CardProgress>> loadProgress();
  Future<void> saveProgress(CardProgress entry);
}