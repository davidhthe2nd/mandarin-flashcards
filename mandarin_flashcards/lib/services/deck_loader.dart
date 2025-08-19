// lib/services/deck_loader.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';                 // new: for debugPrint 🌙
import 'package:flutter/services.dart' show rootBundle;

import '../models/flashcard.dart';

class Deck {
  final List<Flashcard> cards;
  Deck(this.cards);
}

class DeckLoader {
  /// Loads a deck from an asset file (CSV or JSON).
  static Future<Deck> loadFromAsset(String assetPath) async {
    try {
      if (assetPath.toLowerCase().endsWith('.csv')) {
        final raw = await rootBundle.loadString(assetPath);
        return _fromCsv(raw);
      } else if (assetPath.toLowerCase().endsWith('.json')) {
        final raw = await rootBundle.loadString(assetPath);
        return _fromJson(raw);
      } else {
        throw UnsupportedError('Unsupported deck format: $assetPath');
      }
    } catch (e, st) {
      // new: graceful fallback + loud log so you see the real cause in console 🌙
      if (kDebugMode) {
        debugPrint('[DeckLoader] Failed to load "$assetPath": $e');
        debugPrint('$st');
        debugPrint('→ Check pubspec.yaml assets and the exact path/casing.'); // new 🌙
      }
      return Deck([]); // new: don’t crash the app; show empty state instead 🌙
    }
  }

  static Deck _fromCsv(String csvText) {
    final lines = const LineSplitter().convert(csvText);
    if (lines.isEmpty) return Deck([]);
    final headers = lines.first.split(',');
    final cards = <Flashcard>[];

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final cols = line.split(',');

      final map = <String, String>{};
      for (int i = 0; i < headers.length && i < cols.length; i++) {
        map[headers[i].trim()] = cols[i].trim();
      }

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
          example: null,
          hsk: int.tryParse(map['hsk'] ?? '0') ?? 0,
          tags: (map['tags'] ?? '').split(';').where((t) => t.isNotEmpty).toList(),
        ),
      );
    }
    return Deck(cards);
  }

  static Deck _fromJson(String jsonText) {
    final decoded = json.decode(jsonText);

    // new: accept both array and object-with-cards 🌙
    if (decoded is List) {
      final cards = decoded.map<Flashcard>((e) {
        return Flashcard.fromJson(Map<String, dynamic>.from(e));
      }).toList();
      return Deck(cards);
    } else if (decoded is Map && decoded['cards'] is List) { // new 🌙
      final list = List<Map<String, dynamic>>.from(decoded['cards'] as List);
      final cards = list.map<Flashcard>((e) => Flashcard.fromJson(e)).toList();
      return Deck(cards);
    } else {
      throw FormatException('JSON deck must be an array or an object with "cards"'); // new 🌙
    }
  }
}
