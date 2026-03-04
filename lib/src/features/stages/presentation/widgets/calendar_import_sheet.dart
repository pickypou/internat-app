import 'package:flutter/material.dart';
import 'package:internat_app/src/core/di/injection.dart';
import 'package:internat_app/src/features/stages/domain/usecases/calendar_import_usecase.dart';
import 'package:internat_app/src/shared/theme/app_colors.dart';
import 'package:internat_app/src/shared/theme/theme_ext.dart';
import 'package:internat_app/src/shared/widgets/import_paste_field.dart';

/// Bottom sheet for importing calendar periods (PRESENCE / STAGE / ALTERNANCE).
/// Tab-separated: Classe | Type | Début (DD/MM/YYYY) | Fin (DD/MM/YYYY)
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
            : '✅ ${result.imported} période(s) importée(s) avec succès !';
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
                const Icon(
                  Icons.calendar_view_day,
                  color: AppColors.teal,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Importer Calendrier',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Champ de collage (shared widget) ──
            ImportPasteField(
              controller: _controller,
              accentColor: AppColors.teal,
              instruction:
                  'Colonnes : Classe | Type | Début (JJ/MM/AAAA) | Fin (JJ/MM/AAAA)\n'
                  'Types : PRESENCE, STAGE, ALTERNANCE',
              hint:
                  '3eme-A\tSTAGE\t02/03/2026\t15/03/2026\n'
                  'BTS-1\tPRESENCE\t20/08/2025\t05/09/2025',
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
                backgroundColor: AppColors.teal,
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
