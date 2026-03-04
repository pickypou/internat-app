import 'package:flutter/material.dart';

/// Visual badge for a class/student calendar status.
///
/// [status] values:
///   'STAGE'          → 🟠 orange
///   'HORS_QUINZAINE' → 🔵 blue
///   'ALTERNANCE'     → 🟣 purple
///   'PRESENT' / ''   → nothing (returns [SizedBox.shrink])
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    final config = _config(status.toUpperCase());
    if (config == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: config.$1.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.$1),
      ),
      child: Text(
        config.$2,
        style: TextStyle(
          fontSize: fontSize,
          color: config.$1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static (Color, String)? _config(String s) {
    return switch (s) {
      'STAGE' => (Colors.orange, '🟠 STAGE'),
      'ALTERNANCE' => (Colors.purple, '🟣 ALT'),
      'HORS_QUINZAINE' => (Colors.blue, '🔵 HORS'),
      _ => null,
    };
  }
}
