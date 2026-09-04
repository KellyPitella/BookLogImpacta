import 'package:flutter/material.dart';

/// Controlador global do tema (claro/escuro) do app, ouvido pelo MaterialApp.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  static bool get isDarkMode => themeMode.value == ThemeMode.dark;

  static void setDarkMode(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void toggle() => setDarkMode(!isDarkMode);
}
