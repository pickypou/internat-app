import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Main background and surface colors for dark mode
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);

  // 6 vivid pastel accent colors for dark mode
  static const Color pastelBlue = Color(0xFF82B1FF);
  static const Color pastelGreen = Color(0xFFB9F6CA);
  static const Color pastelOrange = Color(0xFFFFD180);
  static const Color pastelRed = Color(0xFFFF8A80);
  static const Color pastelPink = Color(0xFFFF80AB);
  static const Color pastelTeal = Color(0xFFA7FFEB);

  // Default accent
  static const Color defaultAccent = pastelTeal;

  /// Returns the global ThemeData for the application.
  /// Uses [BuildContext] and [MediaQuery] to apply a simple responsive scaling factor.
  static ThemeData getTheme(BuildContext context) {
    // Determine screen width to apply a simple scaling factor
    // Using MediaQuery.sizeOf since it's the recommended modern approach
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Simple responsive factor: if width > 600, apply 1.2 scaling (Web/Tablet), else 1.0 (Mobile)
    final double scaleFactor = screenWidth > 600 ? 1.2 : 1.0;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surface,

      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: defaultAccent,
        secondary: defaultAccent,
        error: Colors.redAccent,
      ),

      // Typography configuration: Roboto for titles, Lato for body
      textTheme: TextTheme(
        // Display - For huge numbers or landing titles
        displayLarge: GoogleFonts.roboto(
          fontSize: 57 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.roboto(
          fontSize: 45 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.roboto(
          fontSize: 36 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        // Headline - Section headers
        headlineLarge: GoogleFonts.roboto(
          fontSize: 32 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 28 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.roboto(
          fontSize: 24 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),

        // Title - Standard titles
        titleLarge: GoogleFonts.roboto(
          fontSize: 22 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.roboto(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),

        // Body - Standard reading text
        bodyLarge: GoogleFonts.lato(
          fontSize: 16 * scaleFactor,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14 * scaleFactor,
          color: Colors.white70,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12 * scaleFactor,
          color: Colors.white70,
        ),

        // Label - For buttons and small inputs
        labelLarge: GoogleFonts.lato(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        labelMedium: GoogleFonts.lato(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        labelSmall: GoogleFonts.lato(
          fontSize: 11 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),

      // Global Card Theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // Global Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return defaultAccent;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Colors.white70, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
