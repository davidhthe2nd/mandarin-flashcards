class Flashcard {
  final String id;
  final String hanzi;
  final String simplified;
  final String pinyin;
  
  // Flattened translations for easier CSV mapping
  final String enUS;
  final String esES;

  // Flattened example fields
  final String exampleCN;
  final String examplePinyin;
  final String exampleES;

  final int hsk;
  final List<String> tags;
  final String? audio;

  Flashcard({
    required this.id,
    required this.hanzi,
    required this.simplified,
    required this.pinyin,
    required this.enUS,
    required this.esES,
    required this.exampleCN,
    required this.examplePinyin,
    required this.exampleES,
    required this.hsk,
    required this.tags,
    this.audio,
  });

  /// Factory for CSV mapping (used by DeckLoader)
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id']?.toString() ?? '',
      hanzi: map['hanzi']?.toString() ?? '',
      simplified: map['simplified']?.toString() ?? '',
      pinyin: map['pinyin']?.toString() ?? '',
      enUS: map['enUS']?.toString() ?? '',
      esES: map['esES']?.toString() ?? '',
      exampleCN: map['exampleCN']?.toString() ?? '',
      examplePinyin: map['examplePinyin']?.toString() ?? '',
      exampleES: map['exampleES']?.toString() ?? '',
      hsk: int.tryParse(map['hsk']?.toString() ?? '1') ?? 1,
      tags: (map['tags'] ?? '').toString().split(';').where((t) => t.isNotEmpty).toList(),
      audio: map['audio']?.toString(),
    );
  }

  /// Helper to get the correct translation based on app settings
  String get translation => esES.isNotEmpty ? esES : enUS;

  /// Logic for ChooseScreen / LearnScreen prompts
  String frontText({required bool invertPair}) {
    if (!invertPair) return hanzi;
    return translation;
  }

  String backText({required bool invertPair}) {
    if (!invertPair) return translation;
    return hanzi;
  }
}