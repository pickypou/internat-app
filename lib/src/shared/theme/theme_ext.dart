import 'package:flutter/material.dart';

/// Extension to easily access theme properties from the [BuildContext].
/// Follows FSD to avoid repetitive `Theme.of(context)` calls in UI code.
extension ThemeExtension on BuildContext {
  /// Shorthand to access the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Shorthand to access the current [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Shorthand to access the current [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Responsive padding shorthand based on screen width.
  /// Example: for padding that should be larger on tablets/web.
  EdgeInsets get responsivePadding {
    final width = MediaQuery.sizeOf(this).width;
    if (width > 600) {
      return const EdgeInsets.all(24.0);
    }
    return const EdgeInsets.all(16.0);
  }
}
