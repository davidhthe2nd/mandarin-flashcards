import 'package:flutter/material.dart';


ThemeData buildtheme(){
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo, // pick any seed color
    textTheme: const TextTheme(
      // Bump sizes for readability; tweak later in Visual Polish
      displaySmall: TextStyle(fontSize: 44, fontWeight: FontWeight.w600), // Hanzi
      titleLarge: TextStyle(fontSize: 22),
      bodyMedium: TextStyle(fontSize: 16, height: 1.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(120, 48)),
    ),
  );
}

ThemeData buildDarkTheme() {
  // Keep the same seed for coherent branding
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.indigo,
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 44, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 22),
      bodyMedium: TextStyle(fontSize: 16, height: 1.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(120, 48)),
    ),
  );
}