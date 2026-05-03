import 'package:flutter/material.dart';

class AppTheme {
  // EduVoice Color Palette
  static const Color cream = Color(0xFFE8E4DA);
  static const Color teal = Color(0xFF2D8B7C);
  static const Color darkTeal = Color(0xFF1C4A52);
  static const Color navy = Color(0xFF1A2E38);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      primaryColor: navy,
      colorScheme: const ColorScheme.light(
        primary: navy,
        secondary: darkTeal,
        surface: cream,
        error: Colors.redAccent,
      ),
      
      // Accessible AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: cream, // High contrast for back button and title
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: cream,
          letterSpacing: 0.5,
        ),
      ),

      // Accessible Text Theme (Forces high contrast globally)
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: navy, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: navy, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: navy, fontSize: 18), // Larger default font
        bodyMedium: TextStyle(color: darkTeal, fontSize: 16),
      ).apply(
        bodyColor: navy,
        displayColor: navy,
      ),

      // Accessible Button Theme (Forces large touch targets globally)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTeal,
          foregroundColor: cream,
          minimumSize: const Size.fromHeight(56), // 56px minimum height for a11y touch targets
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      
      // Accessible Input Decoration (For text fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: darkTeal, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkTeal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navy, width: 3), // Thicker border on focus for visibility
        ),
      ),
    );
  }
}
