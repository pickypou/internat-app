import 'package:flutter/material.dart';

class GroupTheme {
  // 6 pastel vivid colors for dark mode accentuation
  static const Color pastelBlue = Color(0xFF82B1FF);
  static const Color pastelGreen = Color(0xFFB9F6CA);
  static const Color pastelOrange = Color(0xFFFFD180);
  static const Color pastelRed = Color(0xFFFF8A80);
  static const Color pastelPink = Color(0xFFFF80AB);
  static const Color pastelTeal = Color(0xFFA7FFEB);

  static const List<Color> accentColors = [
    pastelBlue,
    pastelGreen,
    pastelOrange,
    pastelRed,
    pastelPink,
    pastelTeal,
  ];

  /// Parses a hex color string like "#FFFFFF" or "FFFFFF" to a Color object.
  static Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add full opacity by default
    }
    // Fallback if parsing fails for some reason
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return pastelBlue;
    }
  }

  /// Returns a decoration for a group card or container
  static BoxDecoration getGroupDecoration(String hexColor) {
    final color = colorFromHex(hexColor);
    return BoxDecoration(
      color: color.withValues(alpha: 0.15),
      border: Border.all(color: color, width: 2),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Returns a button style based on a group's derived color
  static ButtonStyle getGroupButtonStyle(String hexColor) {
    final color = colorFromHex(hexColor);
    return ElevatedButton.styleFrom(
      backgroundColor: color.withValues(alpha: 0.15),
      foregroundColor: color, // Text color
      side: BorderSide(color: color, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );
  }
}
