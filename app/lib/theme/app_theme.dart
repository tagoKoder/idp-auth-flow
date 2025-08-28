import 'package:flutter/material.dart';

ThemeData appTheme() {
  final color = ColorScheme.fromSeed(seedColor: const Color(0xFF1F6FEB), brightness: Brightness.light);
  return ThemeData(
    colorScheme: color,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
    ),
  );
}
