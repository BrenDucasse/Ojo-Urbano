import 'package:flutter/material.dart';

class AppTheme {

  // 🎨 COLORES BASE
  static const primary = Color(0xFF0F4C5C); // verde petróleo
  static const secondary = Color(0xFF008080); // turquesa
  static const accent = Color(0xFF00B4D8); // turquesa claro
  static const background = Color(0xFFF5F7FA);

  // 🌞 LIGHT THEME
  static final lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
    ),

    // 📱 APPBAR
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // 🔘 BOTONES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    // ✏️ INPUTS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: secondary, width: 2),
      ),
    ),

    // 🧊 CARDS (clave para estilo startup)
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // 🌙 DARK THEME
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,

    colorScheme: ColorScheme.dark(
      primary: secondary,
      secondary: accent,
    ),
  );
}