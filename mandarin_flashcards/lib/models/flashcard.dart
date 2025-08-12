class Flashcard {
  final String id;
  final String hanzi;        // Traditional
  final String? simplified;  // Optional Simplified form
  final String pinyin;
  final Map<String, String?> translations; // enUS, esES
  final Example? example;
  final int hsk;
  final List<String> tags;

  Flashcard({
    required this.id,
    required this.hanzi,
    this.simplified,
    required this.pinyin,
    required this.translations,
    this.example,
    required this.hsk,
    required this.tags,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hanzi': hanzi,
      'simplified': simplified,
      'pinyin': pinyin,
      'translations': translations,
      'example': example?.toJson(), // use ?. to call only if not null
      'hsk': hsk,
      'tags': tags,
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