import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_keys.dart';
import '/utils/colors.dart'; // theming helpers

class OptionsState extends ChangeNotifier {
  OptionsState(this._optionsBoxName);

  final String _optionsBoxName;
  late final Box _box;

  int _activePaletteIndex = 0; // NEW

  bool _showPinyin = true;
  bool _invertPair = false;
  bool _darkMode = false; // 🌙 new
  int _dailyTarget = 20;

  bool get showPinyin => _showPinyin;
  bool get invertPair => _invertPair;
  bool get darkMode => _darkMode; // 🌙 new
  int get dailyTarget => _dailyTarget;
  int get activePaletteIndex => _activePaletteIndex;

  /// Initialize the box and load options.
  Future<void> init() async {
    _box = await Hive.openBox(_optionsBoxName);
    await _read();
    _darkMode = _box.get('darkMode', defaultValue: false) as bool;
    _activePaletteIndex = _box.get(kActivePaletteIndex, defaultValue: 0) as int; // NEW
    notifyListeners();
  }

  Future<void> _read() async {
    final raw = _box.get(kOptionsPrefsKey);

    Map<String, dynamic> map;
    if (raw is Map) {
      map = Map<String, dynamic>.from(raw);
    } else {
      map = <String, dynamic>{};
    }

    _showPinyin = (map['showPinyin'] as bool?) ?? true;
    _invertPair = (map['invertPair'] as bool?) ?? false;
    _darkMode   = (map['darkMode']   as bool?) ?? false;

    final dt = map['dailyTarget'];
    if (dt is num) {
      _dailyTarget = dt.toInt().clamp(1, 200);
    } else if (dt is String) {
      _dailyTarget = int.tryParse(dt)?.clamp(1, 200) ?? 20;
    } else {
      _dailyTarget = 20;
    }

    notifyListeners();
  }

  Future<void> _write() async {
    final data = <String, dynamic>{
      'showPinyin': _showPinyin,
      'invertPair': _invertPair,
      'darkMode': _darkMode,
      'dailyTarget': _dailyTarget,
    };
    await _box.put(kOptionsPrefsKey, data);
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

  void toggleDarkMode(bool value) {
    _darkMode = value;
    _write();
    notifyListeners();
  }

  Future<void> setDailyTarget(int value) async {
    _dailyTarget = value.clamp(1, 200);
    await _write();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _box.put('darkMode', value);
    notifyListeners();
  }

  Future<void> setActivePaletteIndex(int idx) async { // NEW
    _activePaletteIndex = idx.clamp(0, TestPalettes.all.length - 1);
    await _box.put(kActivePaletteIndex, _activePaletteIndex);
    notifyListeners();
  }
}
