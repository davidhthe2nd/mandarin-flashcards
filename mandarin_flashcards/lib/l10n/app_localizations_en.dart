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

  @override
  String get grammarTitle => 'Grammar';

  @override
  String get tonesTitle => 'Mandarin Tones';

  @override
  String get tonesIntro => 'Mandarin is a tonal language. The same syllable can have different meanings based on its pitch.';

  @override
  String get tone1Name => 'First Tone (High Flat)';

  @override
  String get tone2Name => 'Second Tone (Rising)';

  @override
  String get tone3Name => 'Third Tone (Dipping)';

  @override
  String get tone4Name => 'Fourth Tone (Falling)';

  @override
  String get toneSandhiTitle => 'Tone Sandhi (Changes)';

  @override
  String get toneSandhiDesc => 'When two 3rd tones appear together, the first one changes to a 2nd tone. For example: Nǐ + hǎo = Níhǎo.';

  @override
  String get examplesLabel => 'Examples';

  @override
  String get grammarSubtitle => 'Basic grammar articles';

  @override
  String get tone1Desc => 'Keep your voice high and steady, like a flat line. Imagine singing a high note.';

  @override
  String get tone2Desc => 'Start middle-pitch and rise quickly. It sounds like you are asking a question: \'What?\'';

  @override
  String get tone3Desc => 'Start low, go lower, then rise. It\'s the longest tone and feels like a \'dip\'.';

  @override
  String get tone4Desc => 'Start high and drop sharply. It sounds like a sharp command or an exclamation.';
}
