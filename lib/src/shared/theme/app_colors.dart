import 'package:flutter/material.dart';

/// Central colour constants to avoid hard-coded hex values scattered everywhere.
abstract final class AppColors {
  /// Import calendar — teal accent
  static const Color teal = Color(0xFF00BFA5);

  /// Appel Dimanche — warm orange
  static const Color appelOrange = Color(0xFFFF6D00);

  /// Status UI
  static const Color stageBadge = Color(0xFF1976D2); // Blue 700
  static const Color presentGreen = Color(0xFF388E3C); // Green 700
  static const Color absentRed = Color(0xFFD32F2F); // Red 700
  static const Color warningOrange = Color(0xFFF57C00); // Orange 700
  static const Color horsBadge = Colors.blue;
  static const Color alternanceBadge = Colors.purple;
}
