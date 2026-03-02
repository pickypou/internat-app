import 'package:flutter/material.dart';
import 'package:internat_app/src/core/di/injection.dart';
import 'package:internat_app/src/features/stages/domain/usecases/calendar_import_usecase.dart';
import 'package:internat_app/src/shared/theme/theme_ext.dart';

/// Bottom sheet for importing stage / alternance calendar periods.
/// Same UX as GlobalImportSheet for students.
///
/// Expected paste format (tab-separated):
///   Class \t Type \t StartDate(DD/MM/YYYY) \t EndDate(DD/MM/YYYY)
///   3eme-A \t STAGE \t 02/03/2026 \t 15/03/2026
class CalendarImportSheet extends StatefulWidget {
  const CalendarImportSheet({super.key});

  @override
  State<CalendarImportSheet> createState() => _CalendarImportSheetState();
}

class _CalendarImportSheetState extends State<CalendarImportSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _result;
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _hasError = false;
    });

    try {
      final result = await getIt<CalendarImportUseCase>()(text);
      if (!mounted) return;

      final hasErrors = result.errors.isNotEmpty;
      setState(() {
        _isLoading = false;
        _hasError = hasErrors;
        _result = hasErrors
            ? '✅ ${result.imported} période(s) importée(s)\n'
                  '⚠️ ${result.skipped} ligne(s) ignorée(s) :\n'
                  '${result.errors.join('\n')}'
            : '✅ ${result.imported} période(s) imortée(s) avec succès !';
      });

      if (!hasErrors) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.of(context).pop(result.imported);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _result = '❌ Erreur : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(
      0xFF00BFA5,
    ); // teal — distinct from blue of students import

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Titre ──
            Row(
              children: [
                Icon(Icons.calendar_view_day, color: accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Importer Calendrier',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Instructions ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Collez votre tableau (séparateur : Tabulation)\n'
                'Colonnes : Classe | Type | Début (JJ/MM/AAAA) | Fin (JJ/MM/AAAA)\n\n'
                'Ex : 3eme-A\tSTAGE\t02/03/2026\t15/03/2026',
                style: context.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: context.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Zone de texte ──
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 12,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText:
                    '3eme-A\tSTAGE\t02/03/2026\t15/03/2026\n3eme-B\tSTAGE\t09/03/2026\t20/03/2026',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Résultat ──
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasError
                      ? context.colorScheme.errorContainer
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _result!,
                  style: TextStyle(
                    color: _hasError
                        ? context.colorScheme.onErrorContainer
                        : Colors.green.shade900,
                    fontSize: 13,
                  ),
                ),
              ),
            if (_result != null) const SizedBox(height: 12),

            // ── Bouton importer ──
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isLoading ? 'Import en cours…' : 'Importer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _import,
            ),
          ],
        ),
      ),
    );
  }
}
