import 'package:flutter/material.dart';

class AppTheme {
  // COLORES DE ROL - ASPIRANTE
  static const Color _aspirantePrimario = Color(0xFF1A43FF);
  static const Color _aspiranteSobrePrimario = Color(0xFFFFFFFF);

  // MODO CLARO
  // Fondos
  static const Color _lightFondoPrincipal = Color(0xFFFFFFFF);
  static const Color _lightFondoAzul2 = Color(0xFFE6F0FA);
  static const Color _lightFondoAzul3 = Color(0xFFCCE0F5);
  static const Color _lightFondoAzul4 = Color(0xFFB3D1F0);

  // Texto
  static const Color _lightTextoPrincipal = Color(0xFF1E293B);
  static const Color _lightTextoSecundario = Color(0xFF475569);
  static const Color _lightTextoTerciario = Color(0xFF667388);

  // Acentos y Estados
  static const Color _lightAcentoCoral = Color(0xFFFF4747);
  static const Color _lightSobreCoral = Color(0xFFEAE1E1);
  static const Color _lightColorExito = Color(0xFF10B981);
  static const Color _lightSobreExito = Color(0xFFFFFFFF);

  // Errores
  static const Color _lightError = Color(0xFFB00020);
  static const Color _lightSobreError = Color(0xFFFFFFFF);
  static const Color _lightErrorContenedor = Color(0xFFFCDADA);
  static const Color _lightSobreErrorContenedor = Color(0xFF410E0B);

  // Superficies
  static const Color _lightSuperficie = Color(0xFFFAFAFA);
  static const Color _lightSobreSuperficie = Color(0xFF1F2937);
  static const Color _lightSuperficieVariante = Color(0xFFE5E7EB);
  static const Color _lightSobreSuperficieVariante = Color(0xFF374151);
  static const Color _lightLineasDivisorias = Color(0xFF475569);

  // MODO OSCURO  
  // Fondos
  static const Color _darkFondoGris1 = Color(0xFF0A1120);
  static const Color _darkFondoGris2 = Color(0xFF152238);
  static const Color _darkFondoGris3 = Color(0xFF1F314D);
  static const Color _darkFondoGris4 = Color(0xFF2A4163);
  static const Color _darkFondoPrincipal = Color(0xFF0F172A);

  // Texto
  static const Color _darkTextoPrincipal = Color(0xFFFFFFFF);
  static const Color _darkTextoSecundario = Color(0xFFBAC8DA);
  static const Color _darkTextoTerciario = Color(0xFF7D8CA1);

  // Acentos y Estados
  static const Color _darkAcentoCoral = Color(0xFFFB7185);
  static const Color _darkSobreCoral = Color(0xFF1A0E0E);
  static const Color _darkColorExito = Color(0xFF34D399);
  static const Color _darkSobreExito = Color(0xFF06281E);

  // Errores
  static const Color _darkError = Color(0xFFEF4444);
  static const Color _darkSobreError = Color(0xFF1A0E0E);
  static const Color _darkErrorContenedor = Color(0xFF7F1D1D);
  static const Color _darkSobreErrorContenedor = Color(0xFFFECACA);

  // Superficies
  static const Color _darkSuperficie = Color(0xFF1E293B);
  static const Color _darkSobreSuperficie = Color(0xFFE2E8F0);
  static const Color _darkSuperficieVariante = Color(0xFF334155);
  static const Color _darkSobreSuperficieVariante = Color(0xFFCBD5E1);
  static const Color _darkLineasDivisorias = Color(0xFF475569);

  // TEMAS
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _aspirantePrimario,
        onPrimary: _aspiranteSobrePrimario,
        secondary: _lightFondoAzul3,
        surface: _lightSuperficie,
        onSurface: _lightSobreSuperficie,
        error: _lightError,
        onError: _lightSobreError,
      ),
      scaffoldBackgroundColor: _lightFondoPrincipal,
      cardColor: _lightSuperficie,
      dividerColor: _lightLineasDivisorias,
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _lightTextoPrincipal, fontSize: 16),
        bodyMedium: TextStyle(color: _lightTextoSecundario, fontSize: 14),
        titleLarge: TextStyle(
          color: _lightTextoPrincipal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _lightTextoPrincipal,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _aspirantePrimario,
          foregroundColor: _aspiranteSobrePrimario,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _aspirantePrimario, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _aspirantePrimario, width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightFondoPrincipal,
        elevation: 0,
        iconTheme: IconThemeData(color: _aspirantePrimario),
        titleTextStyle: TextStyle(
          color: _lightTextoPrincipal,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _aspirantePrimario,
        onPrimary: _aspiranteSobrePrimario,
        secondary: _darkFondoGris3,
        surface: _darkSuperficie,
        onSurface: _darkSobreSuperficie,
        error: _darkError,
        onError: _darkSobreError,
      ),
      scaffoldBackgroundColor: _darkFondoPrincipal,
      cardColor: _darkSuperficie,
      dividerColor: _darkLineasDivisorias,
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _darkTextoPrincipal, fontSize: 16),
        bodyMedium: TextStyle(color: _darkTextoSecundario, fontSize: 14),
        titleLarge: TextStyle(
          color: _darkTextoPrincipal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _darkTextoPrincipal,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _aspirantePrimario,
          foregroundColor: _aspiranteSobrePrimario,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _aspirantePrimario, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _aspirantePrimario, width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkFondoPrincipal,
        elevation: 0,
        iconTheme: IconThemeData(color: _aspirantePrimario),
        titleTextStyle: TextStyle(
          color: _darkTextoPrincipal,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  // COLORES ACCESIBLES (para usar en código)  
  // Aspirante
  static const Color lightPrimary = _aspirantePrimario;
  static const Color lightOnPrimary = _aspiranteSobrePrimario;
  
  // Fondos Light
  static const Color lightBackground = _lightFondoPrincipal;
  static const Color lightBackgroundSecondary = _lightFondoAzul2;
  static const Color lightBackgroundTertiary = _lightFondoAzul3;
  static const Color lightBackgroundQuaternary = _lightFondoAzul4;
  
  // Texto Light
  static const Color lightTextPrimary = _lightTextoPrincipal;
  static const Color lightTextSecondary = _lightTextoSecundario;
  static const Color lightTextTertiary = _lightTextoTerciario;
  
  // Acentos Light
  static const Color lightAccentCoral = _lightAcentoCoral;
  static const Color lightSuccess = _lightColorExito;
  
  // Superficies Light
  static const Color lightSurface = _lightSuperficie;
  static const Color lightSecondary = _lightFondoAzul3;
  
  // Fondos Dark
  static const Color darkBackground = _darkFondoPrincipal;
  static const Color darkBackgroundSecondary = _darkFondoGris2;
  
  // Texto Dark
  static const Color darkTextPrimary = _darkTextoPrincipal;
  static const Color darkTextSecondary = _darkTextoSecundario;
  
  // Acentos Dark
  static const Color darkAccentCoral = _darkAcentoCoral;
  static const Color darkSuccess = _darkColorExito;
  
  // Colores de éxito y error (compatibilidad)
  static const Color success = _lightColorExito;
  static const Color accentCoral = _lightAcentoCoral;
  static const Color accentCoralDark = _darkAcentoCoral;
  static const Color accentYellow = Color(0xFFF59E0B); // Color empresa (por si lo necesitas)
}