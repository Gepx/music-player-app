import 'package:flutter/material.dart';

class FColors {
  FColors._();

  // Base Colors
  static const Color primary = Color(0xFF9C27B0); // Purple
  static const Color secondary = Color(0xFF7C4DFF); // Indigo Purple
  static const Color accent = Color(0xFFE040FB); // Neon Pink-Purple

  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [
      Color(0xFF9C27B0), // Purple
      Color(0xFFE040FB), // Neon Pink-Purple
      Color(0xFF7C4DFF), // Indigo Purple
    ],
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark text (light theme)
  static const Color textSecondary = Color(0xFF757575); // Gray text
  static const Color textWhite = Colors.white; // White text (dark theme)

  // Background Colors
  static const Color light = Color(0xFFF5F5F5); // Light BG
  static const Color dark = Color(0xFF121212); // Dark BG
  static const Color primaryBackground = Color(
    0xFF1E1E2C,
  ); // Dark Navy-Purple BG

  // Container Colors
  static const Color lightContainer = Color(0xFFEDE7F6); // Soft Lavender
  static const Color darkContainer = Color(0xFF1E1E2C); // Dark Navy-Purple

  // Button Colors
  static const Color buttonPrimary = Color(0xFF9C27B0); // Brand Purple
  static const Color buttonSecondary = Color(0xFF7C4DFF); // Indigo Purple
  static const Color buttonDisabled = Color(0xFF9E9E9E); // Neutral Gray

  // Border Colors
  static const Color borderPrimary = Color(0xFFB388FF); // Soft Lavender
  static const Color borderSecondary = Color(0xFFE0E0E0); // Neutral Gray

  // Error & Validation Colors
  static const Color error = Color(0xFFF44336); // Red
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color info = Color(0xFF29B6F6); // Blue

  // Neutral Shades
  static const Color black = Color(0xFF121212); // True Black
  static const Color darkerGrey = Color(0xFF2C2C2C); // Dark Surface
  static const Color darkGrey = Color(0xFF616161); // Medium Gray
  static const Color grey = Color(0xFF9E9E9E); // Disabled
  static const Color lightGrey = Color(0xFFE0E0E0); // Light Gray
  static const Color white = Colors.white; // White
}
