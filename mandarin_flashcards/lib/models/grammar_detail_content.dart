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
  GrammarArticle(
    id: 'tones_theory',
    titleEn: 'Understanding Mandarin Tones',
    titleEs: 'Entendiendo los Tonos del Mandarín',
    previewEn: 'How pitch changes meaning',
    previewEs: 'Cómo el tono cambia el significado',
    contentEn: 'Mandarin is a tonal language. There are four main tones and a neutral tone. '
               'For example, "ma" can mean mother, hemp, horse, or scold depending on the tone.',
    contentEs: 'El mandarín es un idioma tonal. Hay cuatro tonos principales y un tono neutro. '
               'Por ejemplo, "ma" puede significar madre, cáñamo, caballo o regañar según el tono.',
    examples: [
      GrammarExample(
        chinese: '妈妈骑马，马慢，妈妈骂马。', 
        pinyin: 'Māma qí mǎ, mǎ màn, māma mà mǎ.', 
        translationEn: 'Mother rides a horse, the horse is slow, mother scolds the horse.', 
        translationEs: 'Mamá monta a caballo, el caballo es lento, mamá regaña al caballo.'
      ),
    ],
  ),
];