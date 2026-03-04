import 'package:flutter/material.dart';

/// Central colour constants to avoid hard-coded hex values scattered everywhere.
abstract final class AppColors {
  /// Import calendar — teal accent
  static const Color teal = Color(0xFF00BFA5);

  /// Appel Dimanche — warm orange
  static const Color appelOrange = Color(0xFFFF6D00);

  /// Status: STAGE badge
  static const Color stageBadge = Colors.orange;

  /// Status: HORS_QUINZAINE badge
  static const Color horsBadge = Colors.blue;

  /// Status: ALTERNANCE badge
  static const Color alternanceBadge = Colors.purple;
}
