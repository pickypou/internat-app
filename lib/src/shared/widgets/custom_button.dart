import 'package:flutter/material.dart';
import '../theme/theme_ext.dart';

/// A reusable generic button widget that respects the global dark theme.
/// Ensures responsive constraints for touch targets and adapts perfectly
/// to the FSD AppTheme without hardcoded styles.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Use the theme's color scheme
    final primaryColor = context.colorScheme.primary;
    final surfaceColor = context.colorScheme.surface;

    // Choose colors based on the button intent (primary or secondary)
    final backgroundColor = isSecondary ? surfaceColor : primaryColor;
    final foregroundColor = isSecondary ? primaryColor : Colors.black87;

    final baseStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: isSecondary ? 0 : 2,
      side: isSecondary
          ? BorderSide(color: primaryColor, width: 2)
          : BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      // Minimum size to ensure a good touch target responsive layout
      minimumSize: const Size(120, 48),
    );

    if (isLoading) {
      return ElevatedButton(
        onPressed: null,
        style: baseStyle,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
      );
    }

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: baseStyle,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: baseStyle,
      child: Text(
        text,
        style: context.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: foregroundColor,
        ),
      ),
    );
  }
}
