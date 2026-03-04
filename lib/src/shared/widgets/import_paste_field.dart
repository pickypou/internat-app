import 'package:flutter/material.dart';
import '../theme/theme_ext.dart';

/// Reusable copy-paste textarea for all import bottom sheets.
///
/// Renders:
///   • instruction text + hint chip
///   • multi-line [TextField] with monospace style
class ImportPasteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String instruction;
  final Color accentColor;
  final int minLines;
  final int maxLines;

  const ImportPasteField({
    super.key,
    required this.controller,
    required this.hint,
    required this.instruction,
    required this.accentColor,
    this.minLines = 5,
    this.maxLines = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Instructions ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            instruction,
            style: context.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: context.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Textarea ──
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          autofocus: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
