import 'package:flutter/material.dart';

Color hex(String h) => Color(int.parse(h.replaceFirst('#', '0xFF')));

class TestPalettes {
  static const paletteA = ['#2F6690', '#3A7CA5', '#D9DCD6', '#16425B', '#81C3D7'];
  static const paletteB = ['#F7B267', '#F79D65', '#F4845F', '#F27059', '#C8553D'];
  // add more…
}

ColorScheme buildSchemeFromPalette({
  required bool dark,
  required List<String> palette,
}) {
  final base = ColorScheme.fromSeed(
    brightness: dark ? Brightness.dark : Brightness.light,
    seedColor: hex(palette[0]),
  );
  return base.copyWith(
    primary:   hex(palette[0]),
    secondary: hex(palette[1]),
    tertiary:  hex(palette[4]),
    // Optional: steer surfaces a bit
    // surface:   hex(palette[2]),
    // background:hex(palette[2]),
  );
}
