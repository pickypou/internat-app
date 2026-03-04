import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../../shared/utils/import_parser.dart';
import '../../../../shared/widgets/import_paste_field.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';

/// Import bottom sheet for a single group.
/// Delegates all line parsing to [ImportParser] — supports 2/4/5-column formats.
class BulkImportStudentsSheet extends StatefulWidget {
  final String groupId;
  final Color groupColor;

  const BulkImportStudentsSheet({
    super.key,
    required this.groupId,
    this.groupColor = Colors.grey,
  });

  @override
  State<BulkImportStudentsSheet> createState() =>
      _BulkImportStudentsSheetState();
}

class _BulkImportStudentsSheetState extends State<BulkImportStudentsSheet> {
  final _textController = TextEditingController();
  final List<String> _errors = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) return;

    setState(() => _errors.clear());

    final lines = rawText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    final students = <dynamic>[];
    final errors = <String>[];
    int idx = 0;

    for (final line in lines) {
      idx++;
      final parsed = ImportParser.parseLine(line, widget.groupId, idx);
      if (parsed.isValid) {
        students.add(parsed.student!);
      } else {
        errors.add(parsed.error!);
      }
    }

    if (errors.isNotEmpty) {
      setState(() => _errors.addAll(errors));
    }

    if (students.isNotEmpty) {
      context.read<StudentBloc>().add(
        AddStudents(students.cast(), widget.groupId),
      );
      Navigator.of(context).pop(students.length);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aucun élève valide détecté.'),
          backgroundColor: context.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colorScheme.error,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Titre ──
            Row(
              children: [
                Icon(Icons.upload_file, color: widget.groupColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Importation massive',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Champ de collage ──
            ImportPasteField(
              controller: _textController,
              accentColor: widget.groupColor,
              instruction:
                  'Format 5 cols : Nom | Prénom | Classe | Chambre | Groupe\n'
                  'Format 4 cols : Nom Complet | Classe | Chambre | Groupe\n'
                  'Format 2 cols : Nom | Prénom',
              hint:
                  'DUPONT\tJean\t3A\t12\tHugue\nMARTIN Lucie\t2B\t14\tHugue\nDUBOIS\tPierre',
            ),
            const SizedBox(height: 16),

            // ── Erreurs ──
            if (_errors.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errors.join('\n'),
                  style: TextStyle(
                    color: context.colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            if (_errors.isNotEmpty) const SizedBox(height: 12),

            // ── Bouton ──
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                final isLoading = state is StudentsLoading;
                return ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.groupColor,
                    foregroundColor: widget.groupColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Valider l\'importation'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
