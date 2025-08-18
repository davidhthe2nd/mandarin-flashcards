import 'package:hive/hive.dart';

class Flashcard {
  final String id;
  final String hanzi;        
  final String? simplified;  
  final String pinyin;
  final Map<String, String?> translations; // enUS, esES
  final Example? example;
  final int hsk;
  final List<String> tags;

  /// New: optional audio file/URL reference
  final String? audio; // e.g. "assets/audio/ni3.mp3" or a URL

  Flashcard({
    required this.id,
    required this.hanzi,
    this.simplified,
    required this.pinyin,
    required this.translations,
    this.example,
    required this.hsk,
    required this.tags,
    this.audio,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      hanzi: json['hanzi'] as String,
      simplified: json['simplified'] as String?,
      pinyin: json['pinyin'] as String,
      translations: Map<String, String?>.from(json['translations'] ?? {}),
      example: (json['example'] != null && json['example'] is Map<String, dynamic>)
          ? Example.fromJson(Map<String, dynamic>.from(json['example']))
          : null,
      hsk: json['hsk'] as int,
      tags: List<String>.from(json['tags'] ?? []),
      audio: json['audio'] as String?, // 👈 pickup audio field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hanzi': hanzi,
      'simplified': simplified,
      'pinyin': pinyin,
      'translations': translations,
      'example': example?.toJson(),
      'hsk': hsk,
      'tags': tags,
      'audio': audio, // 👈 save audio field
    };
  }
}


class Example {
  final String? cn;      // Mandarin example sentence
  final String? pinyin;  // Example in Pinyin
  final String? es;      // Example in Spanish

  Example({this.cn, this.pinyin, this.es});

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      cn: json['cn'] as String?,
      pinyin: json['pinyin'] as String?,
      es: json['es'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cn': cn,
      'pinyin': pinyin,
      'es': es,
    };
  }
}

// --- View helpers for rendering in Choose/Learn screens ---
extension FlashcardView on Flashcard {
  /// Returns the best translation for a given language code (e.g., 'enUS', 'esES'),
  /// falling back to the first non-empty translation if the requested one is missing.
  String? translationFor(String langCode) {
    final direct = translations[langCode];
    if (direct != null && direct.trim().isNotEmpty) return direct;

    for (final v in translations.values) {
      if (v != null && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  /// The “Chinese side” text (using Traditional by default).
  String get chineseSide => hanzi;

  /// Simplified public API: these let `ChooseState`/UI call `.prompt` / `.answer`
  /// without caring about details.
  String get prompt => chineseSide; // by default: hanzi
  String get answer => translationFor('enUS') ?? '—'; // default to English

  /// Builds the FRONT text according to invertPair.
  String frontText({required bool invertPair, required String langCode}) {
    if (!invertPair) return chineseSide;
    return translationFor(langCode) ?? chineseSide;
  }

  /// Builds the BACK text according to invertPair.
  String backText({required bool invertPair, required String langCode}) {
    if (!invertPair) {
      return translationFor(langCode) ?? '—';
    }
    return chineseSide;
  }

  /// Optional helper for pinyin display.
  String get pinyinText => pinyin;

  /// Optional helpers for example sentences.
  String? get exampleChinese => example?.cn;
  String? get examplePinyin => example?.pinyin;
  String? get exampleEs => example?.es;
}
