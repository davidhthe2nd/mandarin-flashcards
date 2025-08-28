import 'package:flutter/material.dart';

Color _hex(String h) => Color(int.parse(h.replaceFirst('#', '0xFF')));

class TestPalettes {
  // Add/adjust to taste — order is [primary, secondary, surface-ish, dark accent/tertiary, highlight]
  static const aOcean = ['#2F6690', '#3A7CA5', '#D9DCD6', '#16425B', '#81C3D7'];
  static const bSunset = ['#F7B267', '#F79D65', '#FFF2E0', '#F27059', '#C8553D'];
  static const cForest = ['#2B9348', '#55A630', '#E9F5EA', '#007F5F', '#80B918'];

  static const all = [aOcean, bSunset, cForest];

  static const names = ['Ocean', 'Sunset', 'Forest'];
}

ColorScheme buildSchemeFromPalette({
  required bool dark,
  required List<String> palette,
}) {
  final base = ColorScheme.fromSeed(
    brightness: dark ? Brightness.dark : Brightness.light,
    seedColor: _hex(palette[0]),
  );
  // Nudge primary/secondary/tertiary to match your palette exactly; leave the rest harmonized.
  return base.copyWith(
    primary: _hex(palette[0]),
    secondary: _hex(palette[1]),
    tertiary: _hex(palette[4]),
    // Uncomment if you want surfaces steered by the palette:
    // surface: _hex(palette[2]),
    // background: _hex(palette[2]),
  );
}
