// lib/models/grammar_detail_content.dart

class GrammarArticle {
  final String id;
  final String titleEn;
  final String titleEs;
  final String previewEn;
  final String previewEs;
  final String contentEn;
  final String contentEs;
  final List<GrammarExample> examples;

  GrammarArticle({
    required this.id,
    required this.titleEn,
    required this.titleEs,
    required this.previewEn,
    required this.previewEs,
    required this.contentEn,
    required this.contentEs,
    this.examples = const [],
  });

  // Helper methods to get the right language
  String getTitle(String locale) => locale == 'es' ? titleEs : titleEn;
  String getPreview(String locale) => locale == 'es' ? previewEs : previewEn;
  String getContent(String locale) => locale == 'es' ? contentEs : contentEn;
}

class GrammarExample {
  final String chinese;
  final String pinyin;
  final String translationEn;
  final String translationEs;

  GrammarExample({
    required this.chinese, 
    required this.pinyin, 
    required this.translationEn, 
    required this.translationEs
  });

  String getTranslation(String locale) => locale == 'es' ? translationEs : translationEn;
}

// Global list of articles
final List<GrammarArticle> grammarLibrary = [
  GrammarArticle(
    id: 'basic_structure',
    titleEn: 'Basic Sentence Structure',
    titleEs: 'Estructura Básica de la Oración',
    previewEn: 'Subject + Verb + Object',
    previewEs: 'Sujeto + Verbo + Objeto',
    contentEn: 'Chinese follows a SVO structure similar to English...',
    contentEs: 'El chino sigue una estructura SVO similar al español...',
    examples: [
      GrammarExample(
        chinese: '我喝茶。', 
        pinyin: 'Wǒ hē chá.', 
        translationEn: 'I drink tea.', 
        translationEs: 'Yo bebo té.'
      ),
    ],
  ),
];