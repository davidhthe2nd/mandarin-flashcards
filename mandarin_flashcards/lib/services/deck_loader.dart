// lib/services/deck_loader.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/flashcard.dart';

class Deck {
  final List<Flashcard> cards;
  Deck(this.cards);
}

class DeckLoader {
  static Future<Deck> loadFromAsset(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      if (assetPath.toLowerCase().endsWith('.csv')) {
        return _fromCsv(raw);
      } else {
        return _fromJson(raw);
      }
    } catch (e, st) {
      debugPrint('[DeckLoader] Failed to load "$assetPath": $e');
      return Deck([]);
    }
  }

  static Deck _fromCsv(String csvText) {
    final lines = csvText.split('\n');
    if (lines.isEmpty) return Deck([]);

    final headers = lines[0].split(',');
    final List<Flashcard> cards = [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Simple comma split (Note: doesn't handle commas inside quotes, 
      // which is why we removed them from your examples)
      final cols = line.split(',');

      final map = <String, String>{};
      for (int j = 0; j < headers.length && j < cols.length; j++) {
        map[headers[j].trim()] = cols[j].trim();
      }

      cards.add(Flashcard(
        id: map['id'] ?? '',
        hanzi: map['hanzi'] ?? '',
        simplified: map['simplified'] ?? '',
        pinyin: map['pinyin'] ?? '',
        enUS: map['enUS'] ?? '',
        esES: map['esES'] ?? '',
        exampleCN: map['exampleCN'] ?? '',
        examplePinyin: map['examplePinyin'] ?? '',
        exampleES: map['exampleES'] ?? '',
        hsk: int.tryParse(map['hsk'] ?? '1') ?? 1,
        tags: (map['tags'] ?? '').split(';').where((t) => t.isNotEmpty).toList(),
      ));
    }
    return Deck(cards);
  }

  static Deck _fromJson(String jsonText) {
    final decoded = json.decode(jsonText);
    final List<dynamic> list = (decoded is Map) ? decoded['cards'] : decoded;
    final cards = list.map((e) => Flashcard.fromMap(Map<String, dynamic>.from(e))).toList();
    return Deck(cards);
  }
}