import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show FlutterError;

import '../models/flashcard.dart';

/// Simple wrapper for a deck and its metadata.
class Deck {
  final String deckName;
  final int deckVersion;
  /// e.g., {"front": "zh-Hant", "back": "es-ES"}
  final Map<String, String> languagePair;
  final List<Flashcard> cards;

  Deck({
    required this.deckName,
    required this.deckVersion,
    required this.languagePair,
    required this.cards,
  });

  factory Deck.fromJson(Map<String, dynamic> json) {
    final rawCards = (json['cards'] as List? ?? []);
    final cards = rawCards
        .whereType<Map<String, dynamic>>() // be safe with types
        .map((m) => Flashcard.fromJson(m))
        .toList();

    final lp = Map<String, dynamic>.from(json['languagePair'] ?? {});
    return Deck(
      deckName: (json['deckName'] as String?) ?? 'UnknownDeck',
      deckVersion: (json['deckVersion'] as int?) ?? 1,
      languagePair: {
        'front': (lp['front'] as String?) ?? 'zh-Hant',
        'back' : (lp['back']  as String?) ?? 'es-ES',
      },
      cards: cards,
    );
  }
}

class DeckLoader {
  /// Load a Deck from a bundled asset JSON file.
  static Future<Deck> loadFromAsset(String assetPath) async {
    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonStr);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Deck JSON root must be an object.');
      }
      return Deck.fromJson(data);
    } on FlutterError catch (e) {
      // Asset not found or pubspec not configured
      throw Exception(
        'Failed to load asset "$assetPath". '
        'Check pubspec.yaml assets section. Original error: $e',
      );
    } on FormatException catch (e) {
      throw Exception('Invalid JSON in "$assetPath": $e');
    }
  }
}