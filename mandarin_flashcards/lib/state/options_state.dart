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

  // new 🌙 control card mixing ratios
  double _mixToLearn = 0.60; // new 🌙
  double _mixForgotten = 0.30; // new 🌙
  double _mixAlmost = 0.10; // new 🌙

  double get mixToLearn => _mixToLearn; // new 🌙
  double get mixForgotten => _mixForgotten; // new 🌙
  double get mixAlmost => _mixAlmost; // new 🌙

  // HSK levels (1 to 6); default to HSK 1 only
  final Set<int> _hskLevels = {1, 2};
  Set<int> get hskLevels => _hskLevels;

  double exampleScale = 1.15; // new 🌙 fallback if you don’t persist it yet

  /// Initialize the box and load options.
  Future<void> init() async {
    _box = await Hive.openBox(_optionsBoxName);
    await _read();
    _darkMode = _box.get('darkMode', defaultValue: false) as bool;
    _activePaletteIndex = _box.get(kActivePaletteIndex, defaultValue: 0) as int;

    final savedLevels = (_box.get(kHSKLevelsKey) as List?)?.cast<int>() ?? [1];
    _hskLevels
      ..clear()
      ..addAll(savedLevels);

    // new 🌙 – read the mix (fallback to defaults)
    _mixToLearn = (_box.get(kMixToLearn, defaultValue: _mixToLearn) as num)
        .toDouble();
    _mixForgotten =
        (_box.get(kMixForgotten, defaultValue: _mixForgotten) as num)
            .toDouble();
    _mixAlmost = (_box.get(kMixAlmost, defaultValue: _mixAlmost) as num)
        .toDouble();
    _normalizeMix(); // keep sums ≈ 1.0 // new 🌙

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
    _darkMode = (map['darkMode'] as bool?) ?? false;

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
  // also persist mix // new 🌙
  await _box.put(kMixToLearn,   _mixToLearn);
  await _box.put(kMixForgotten, _mixForgotten);
  await _box.put(kMixAlmost,    _mixAlmost);
}

  Future<void> toggleShowPinyin(bool value) async {
    _showPinyin = value;
    await _write();
    notifyListeners();
  }

  Future<void> toggleInvertPair(bool value) async {
    _invertPair = value;
    await _write();
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

  Future<void> setActivePaletteIndex(int idx) async {
    // NEW
    _activePaletteIndex = idx.clamp(0, TestPalettes.all.length - 1);
    await _box.put(kActivePaletteIndex, _activePaletteIndex);
    notifyListeners();
  }

  // new 🌙
  Future<void> toggleHSK(int level, bool include) async {
    if (include) {
      _hskLevels.add(level);
    } else {
      _hskLevels.remove(level);
    }
    await _box.put(kHSKLevelsKey, _hskLevels.toList()..sort());
    notifyListeners();
  }

  // new 🌙
  bool includesHSK(int level) => _hskLevels.contains(level);

  void _normalizeMix() {
  final sum = _mixToLearn + _mixForgotten + _mixAlmost;
  if (sum <= 0) {
    _mixToLearn = 1; _mixForgotten = 0; _mixAlmost = 0;
  } else {
    _mixToLearn   /= sum;
    _mixForgotten /= sum;
    _mixAlmost    /= sum;
  }
}

// new 🌙 – set all three in one go (values can be 0–1 or 0–100)
Future<void> setMix({double? toLearn, double? forgotten, double? almost}) async {
  if (toLearn   != null) _mixToLearn   = (toLearn   > 1) ? toLearn   / 100 : toLearn;
  if (forgotten != null) _mixForgotten = (forgotten > 1) ? forgotten / 100 : forgotten;
  if (almost    != null) _mixAlmost    = (almost    > 1) ? almost    / 100 : almost;

  _normalizeMix();
  await _write();
  notifyListeners();
}
}
