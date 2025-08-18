// lib/services/deck_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/flashcard.dart';

class Deck {
  final List<Flashcard> cards;
  Deck(this.cards);
}

class DeckLoader {
  /// Loads a deck from an asset file (CSV or JSON).
  static Future<Deck> loadFromAsset(String assetPath) async {
    if (assetPath.toLowerCase().endsWith('.csv')) {
      final raw = await rootBundle.loadString(assetPath);
      return _fromCsv(raw);
    } else if (assetPath.toLowerCase().endsWith('.json')) {
      final raw = await rootBundle.loadString(assetPath);
      return _fromJson(raw);
    } else {
      throw UnsupportedError('Unsupported deck format: $assetPath');
    }
  }

  static Deck _fromCsv(String csvText) {
    final lines = const LineSplitter().convert(csvText);
    if (lines.isEmpty) return Deck([]);

    // Assume first line is headers
    final headers = lines.first.split(',');
    final cards = <Flashcard>[];

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final cols = line.split(',');

      // Map columns by header
      final map = <String, String>{};
      for (int i = 0; i < headers.length && i < cols.length; i++) {
        map[headers[i].trim()] = cols[i].trim();
      }

      // Build Flashcard from the row
      cards.add(
        Flashcard(
          id: map['id'] ?? '${cards.length}',
          hanzi: map['hanzi'] ?? '',
          simplified: map['simplified'],
          pinyin: map['pinyin'] ?? '',
          translations: {
            'enUS': map['enUS'],
            'esES': map['esES'],
          },
          example: null, // TODO: parse if CSV contains it
          hsk: int.tryParse(map['hsk'] ?? '0') ?? 0,
          tags: (map['tags'] ?? '').split(';').where((t) => t.isNotEmpty).toList(),
        ),
      );
    }

    return Deck(cards);
  }

  static Deck _fromJson(String jsonText) {
    final decoded = json.decode(jsonText);
    if (decoded is List) {
      final cards = decoded.map<Flashcard>((e) {
        return Flashcard.fromJson(Map<String, dynamic>.from(e));
      }).toList();
      return Deck(cards);
    } else {
      throw FormatException('JSON deck must be an array of cards');
    }
  }
}
