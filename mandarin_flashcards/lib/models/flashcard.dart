class Flashcard {
  final String id;
  final String hanzi;
  final String simplified;
  final String pinyin;
  final String enUS;
  final String esES;
  final String exampleCN;
  final String examplePinyin;
  final String exampleES;
  final int hsk;
  final List<String> tags;
  final String? audio;
  final int lesson; // Keep this as the filtered integer

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
    required this.lesson,
    this.audio,
  });

  /// NEW: Helper method to extract "5" from "book3_lesson5"
  /// We make it static so it can be used before the object is fully built.
  static int _extractLessonNumber(List<String> tags) {
    for (var tag in tags) {
      final match = RegExp(r'lesson(\d+)').firstMatch(tag.toLowerCase());
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }
    return 0; // Default if no lesson tag is found
  }

  /// UPDATED: Factory for CSV mapping
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    // 1. Process the raw tags string into a list first
    final rawTags = map['tags']?.toString() ?? '';
    final tagsList = rawTags.split(';').where((t) => t.isNotEmpty).toList();

    // 2. Pass that list to our new helper to get the integer lesson
    final lessonInt = _extractLessonNumber(tagsList);

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
      // Ensure HSK is parsed as an int for the HSK Filter
      hsk: int.tryParse(map['hsk']?.toString() ?? '1') ?? 1,
      tags: tagsList,
      lesson: lessonInt, // Now the Textbook Filter has a clean number to use!
      audio: map['audio']?.toString(),
    );
  }

  /// UPDATED: Translation now respects the selected language
  String getTranslation(String localeCode) {
  if (localeCode == 'es') {
    return esES.isNotEmpty ? esES : ''; 
  }
  if (localeCode == 'en') {
    return enUS.isNotEmpty ? enUS : ''; 
  }
  // English users usually don't need a translation of the example sentence
  return ''; 
}

  String getExampleTranslation(String localeCode) {
  if (localeCode == 'es') {
    return exampleES.isNotEmpty ? esES : ''; 
  }
  // English users usually don't need a translation of the example sentence
  return ''; 
}

  /// UPDATED: Accepts localeCode to show correct text on front
  String frontText({required bool invertPair, required String localeCode}) {
    if (!invertPair) return hanzi;
    return getTranslation(localeCode);
  }

  /// UPDATED: Accepts localeCode to show correct text on back
  String backText({required bool invertPair, required String localeCode}) {
  if (!invertPair) return getTranslation(localeCode);
  return hanzi;
}
}