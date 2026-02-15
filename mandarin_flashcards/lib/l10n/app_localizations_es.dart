// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mandarin Flashcards';

  @override
  String get studyHsk => 'HSK';

  @override
  String get hskSubtitle => 'Selecciona los niveles en Opciones';

  @override
  String get studyTextbook => 'Libro de texto';

  @override
  String get textbookSubtitle => 'Selección aleatoria o por lección';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsSubtitle => 'Preferencias';

  @override
  String get optionsTitle => 'Opciones';

  @override
  String get themePalette => 'Paleta de colores';

  @override
  String get hskLevels => 'Niveles HSK';

  @override
  String get textbookLesson => 'Lecciones del libro';

  @override
  String get allLessons => 'Todas las lecciones';

  @override
  String lesson(int number) {
    return 'Lección $number';
  }

  @override
  String get studyMix => 'Study mix';

  @override
  String get toLearn => 'Nuevas';

  @override
  String get forgotten => 'Olvidadas';

  @override
  String get almost => 'Casi aprendidas';

  @override
  String get clearFilters => 'Reiniciar filtros';

  @override
  String get comingSoon => 'Pronto disponible';

  @override
  String get fontSize => 'Tamaño de la fuente';

  @override
  String get fontSubtitle => 'Ajustar tamaño de caracteres y pinyin';

  @override
  String get showPinyin => 'Mostrar pinyin';

  @override
  String summaryWordsReviewed(int total) {
    return 'Has revisado $total palabras.';
  }

  @override
  String get mastered => 'Aprendidas';

  @override
  String get almostThere => 'Casi';

  @override
  String get needPractice => 'Para revisar';

  @override
  String get studyMore => 'Estudiar 20 más';

  @override
  String get backToMenu => 'Menú principal';

  @override
  String get flipCard => 'Girar tarjeta';

  @override
  String get iForgot => 'Olvidada';

  @override
  String get iGotIt => '¡Me la sé!';

  @override
  String get learnTitle => 'Aprender';

  @override
  String studyMixTotal(int percentage) {
    return 'Total: $percentage%';
  }

  @override
  String get grammarTitle => 'Gramática';

  @override
  String get tonesTitle => 'Tonos del Mandarín';

  @override
  String get tonesIntro => 'El mandarín es un idioma tonal. La misma sílaba tiene diferentes significados según su tono.';

  @override
  String get tone1Name => 'Primer Tono (Alto y Plano)';

  @override
  String get tone2Name => 'Segundo Tono (Ascendente)';

  @override
  String get tone3Name => 'Tercer Tono (Descendente-Ascendente)';

  @override
  String get tone4Name => 'Cuarto Tono (Descendente)';

  @override
  String get toneSandhiTitle => 'Cambios de Tono (Sandhi)';

  @override
  String get toneSandhiDesc => 'Cuando aparecen dos terceros tonos seguidos, el primero cambia a un segundo tono. Ejemplo: Nǐ + hǎo = Níhǎo.';

  @override
  String get examplesLabel => 'Ejemplos';

  @override
  String get grammarSubtitle => 'Artículos básicos de gramática';

  @override
  String get tone1Desc => 'Mantén la voz alta y constante, como una línea plana. Imagina que cantas una nota alta.';

  @override
  String get tone2Desc => 'Empieza en un tono medio y sube rápido. Suena como si hicieras una pregunta: \'¿Qué?\'';

  @override
  String get tone3Desc => 'Empieza bajo, baja más y luego sube. Es el tono más largo y se siente como un \'bache\'.';

  @override
  String get tone4Desc => 'Empieza alto y cae bruscamente. Suena como una orden tajante o una exclamación.';

  @override
  String get openToneTool => 'Abrir Gráfico de Tonos';
}
