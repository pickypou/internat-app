import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/global_import_usecase.dart';

/// Modal bottom sheet for global import of students from Excel copy-paste.
/// Columns: Nom | Prénom | Classe | Chambre | Groupe  (tab or semicolon)
class GlobalImportSheet extends StatefulWidget {
  const GlobalImportSheet({super.key});

  @override
  State<GlobalImportSheet> createState() => _GlobalImportSheetState();
}

class _GlobalImportSheetState extends State<GlobalImportSheet> {
  final _controller = TextEditingController();
  bool _loading = false;

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
      final result = await getIt<GlobalImportUseCase>()(text);
      dev.log('[GlobalImportSheet] Import done: ${result.summary}');

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
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
              const Icon(Icons.upload_file),
              const SizedBox(width: 10),
              Text(
                'Import global depuis Excel',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Colle le tableau Excel ci-dessous.\nColonnes : Nom | Prénom | Classe | Chambre | Groupe',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 10,
            autofocus: true,
            decoration: const InputDecoration(
              hintText:
                  'DUPONT\tJean\t3A\t12\tHugue\nMARTIN\tLucie\t2B\t5\tCassandra',
              border: OutlineInputBorder(),
              filled: true,
            ),
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
