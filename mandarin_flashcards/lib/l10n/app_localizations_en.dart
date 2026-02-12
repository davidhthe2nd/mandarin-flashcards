// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mandarin Flashcards';

  @override
  String get studyHsk => 'HSK Practice';

  @override
  String get hskSubtitle => 'Select the levels in Options';

  @override
  String get studyTextbook => 'Textbook Practice';

  @override
  String get textbookSubtitle => 'Random selection or by lesson';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'App Preferences';

  @override
  String get optionsTitle => 'Options';

  @override
  String get themePalette => 'Theme palette';

  @override
  String get hskLevels => 'HSK Levels';

  @override
  String get textbookLesson => 'Textbook Lesson';

  @override
  String get allLessons => 'All Lessons';

  @override
  String lesson(int number) {
    return 'Lesson $number';
  }

  @override
  String get studyMix => 'Study mix';

  @override
  String get toLearn => 'To-learn';

  @override
  String get forgotten => 'Forgotten';

  @override
  String get almost => 'Almost';

  @override
  String get clearFilters => 'Clear all filters';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSubtitle => 'Adjust character and pinyin size';

  @override
  String get showPinyin => 'Show pinyin';

  @override
  String summaryWordsReviewed(int total) {
    return 'You reviewed $total words.';
  }

  @override
  String get mastered => 'Mastered';

  @override
  String get almostThere => 'Almost there';

  @override
  String get needPractice => 'Need practice';

  @override
  String get studyMore => 'Study 20 More';

  @override
  String get backToMenu => 'Back to Main Menu';

  @override
  String get flipCard => 'Flip card';

  @override
  String get iForgot => 'I forgot';

  @override
  String get iGotIt => 'I got it';

  @override
  String get learnTitle => 'Learn';

  @override
  String studyMixTotal(int percentage) {
    return 'Total: $percentage%';
  }
}
