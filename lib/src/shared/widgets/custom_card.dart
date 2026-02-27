import 'package:flutter/material.dart';
import '../theme/theme_ext.dart';

/// A reusable Card widget that respects the global dark theme.
/// It optionally accepts an accent [color] (e.g. from GroupTheme)
/// to apply a colored border.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the border based on whether an accent color is provided.
    final shape = context.theme.cardTheme.shape as RoundedRectangleBorder?;
    final resolvedShape = color != null
        ? RoundedRectangleBorder(
            borderRadius: shape?.borderRadius ?? BorderRadius.circular(12),
            side: BorderSide(color: color!.withValues(alpha: 0.5), width: 1.5),
          )
        : shape;

    return Card(
      shape: resolvedShape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: resolvedShape is RoundedRectangleBorder
            ? resolvedShape.borderRadius as BorderRadius
            : null,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
