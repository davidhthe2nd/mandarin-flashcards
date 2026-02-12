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
  String get hskSubtitle => 'Niveles 1-3 • Selección aleatoria';

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
}
