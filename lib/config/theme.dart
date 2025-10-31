import 'package:flutter/material.dart';

class AppTheme {
  // Colores Light Theme
  static const Color _lightPrimary = Color(0xFF1E3A8A);
  static const Color _lightSecondary = Color(0xFF87CEEB);
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightBackgroundSecondary = Color(0xFFF8F9FA);
  static const Color _lightTextPrimary = Color(0xFF374151);
  static const Color _lightTextSecondary = Color(0xFF9CA3AF);
  static const Color _lightBorder = Color(0xFFE5E7EB);
  static const Color _accentYellow = Color(0xFFF59E0B);
  static const Color _accentCoral = Color(0xFFFF4747);

  // Colores Dark Theme
  static const Color _darkPrimary = Color(0xFF3B82F6);
  static const Color _darkSecondary = Color(0xFF60A5FA);
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkBackgroundSecondary = Color(0xFF1E293B);
  static const Color _darkCard = Color(0xFF334155);
  static const Color _darkTextPrimary = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFFCBD5E1);
  static const Color _darkBorder = Color(0xFF475569);
  static const Color _accentCoralDark = Color(0xFFFB7185);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        surface: _lightBackground,
        background: _lightBackgroundSecondary,
        error: _accentCoral,
      ),
      scaffoldBackgroundColor: _lightBackground,
      cardColor: _lightBackground,
      dividerColor: _lightBorder,
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: _lightTextSecondary, fontSize: 14),
        titleLarge: TextStyle(color: _lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: _lightPrimary),
        titleTextStyle: TextStyle(color: _lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        surface: _darkBackgroundSecondary,
        background: _darkBackground,
        error: _accentCoralDark,
      ),
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _darkCard,
      dividerColor: _darkBorder,
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: _darkTextSecondary, fontSize: 14),
        titleLarge: TextStyle(color: _darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: _darkPrimary),
        titleTextStyle: TextStyle(color: _darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

static const Color _success = Color(0xFF4CAF50);

  // Colores personalizados accesibles
  static const Color accentYellow = _accentYellow;
  static const Color accentCoral = _accentCoral;
  static const Color accentCoralDark = _accentCoralDark;
  static const Color success = _success;
  static const Color lightPrimary = _lightPrimary;
  static const Color lightTextPrimary = _lightTextPrimary;
  static const Color lightTextSecondary = _lightTextSecondary;
  static const Color lightSecondary = _lightSecondary;
  static const Color lightBackgroundSecondary = _lightBackgroundSecondary;
  static const Color lightBackground = _lightBackground;
  static const Color lightBorder = _lightBorder;
}