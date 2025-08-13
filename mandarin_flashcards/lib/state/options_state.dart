import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_keys.dart';

class OptionsState extends ChangeNotifier {
  OptionsState(this._optionsBoxName) {
    _box = Hive.box(_optionsBoxName);
    _read();
  }

  final String _optionsBoxName;
  late final Box _box;

  bool _showPinyin = true;
  bool _invertPair = false;
  bool _darkMode = false; // 🌙 new

  bool get showPinyin => _showPinyin;
  bool get invertPair => _invertPair;
  bool get darkMode => _darkMode; // 🌙 new

  void _read() {
    final map = Map<String, dynamic>.from(
      _box.get(kOptionsPrefsKey, defaultValue: const {
        'showPinyin': true,
        'invertPair': false,
        'darkMode': false, // 🌙 default
      }),
    );
    _showPinyin = (map['showPinyin'] as bool?) ?? true;
    _invertPair = (map['invertPair'] as bool?) ?? false;
    _darkMode   = (map['darkMode']   as bool?) ?? false; // 🌙
  }

  void _write() {
    _box.put(kOptionsPrefsKey, {
      'showPinyin': _showPinyin,
      'invertPair': _invertPair,
      'darkMode': _darkMode, // 🌙
    });
  }

  void toggleShowPinyin(bool value) {
    _showPinyin = value;
    _write();
    notifyListeners();
  }

  void toggleInvertPair(bool value) {
    _invertPair = value;
    _write();
    notifyListeners();
  }

  void toggleDarkMode(bool value) { // 🌙 new
    _darkMode = value;
    _write();
    notifyListeners();
  }
}