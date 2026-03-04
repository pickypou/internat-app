import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../../shared/widgets/import_paste_field.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/global_import_usecase.dart';

/// Modal bottom sheet for global import of students from Excel copy-paste.
/// Supports 4-column and 5-column layouts (delegated to ImportParser).
class GlobalImportSheet extends StatefulWidget {
  const GlobalImportSheet({super.key});

  @override
  State<GlobalImportSheet> createState() => _GlobalImportSheetState();
}

class _GlobalImportSheetState extends State<GlobalImportSheet> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _clearDb = true; // default to true to help him clear existing messy data

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);

    // Close the modal immediately so the SnackBar is visible
    Navigator.of(context).pop();

    try {
      final result = await getIt<GlobalImportUseCase>()(
        text,
        clearDatabase: _clearDb,
      );
      dev.log('[GlobalImportSheet] Import done: ${result.summary}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result.summary}'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      dev.log('[GlobalImportSheet] Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'importation : $e'),
          backgroundColor: context.colorScheme.error,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Import global depuis Excel',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ImportPasteField(
            controller: _controller,
            accentColor: accent,
            instruction:
                'Format 5 cols : Nom | Prénom | Classe | Chambre | Groupe\n'
                'Format 4 cols : Nom Complet | Classe | Chambre | Groupe\n'
                'Format 2 cols : Nom | Prénom',
            hint:
                'DUPONT\tJean\t3A\t12\tHugue\n'
                'MARTIN Lucie\t2B\t14\tHugue',
          ),
          const SizedBox(height: 12),

          CheckboxListTile(
            value: _clearDb,
            onChanged: (val) {
              if (val != null) setState(() => _clearDb = val);
            },
            title: Text(
              'Vider la base de données avant l\'import',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Attention: Action irréversible. Tous les élèves actuels du système seront supprimés.',
              style: TextStyle(fontSize: 12),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: context.colorScheme.error,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Importer'),
          ),
        ],
      ),
    );
  }
}
