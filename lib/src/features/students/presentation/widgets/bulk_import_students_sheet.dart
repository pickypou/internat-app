import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../domain/entities/student_entity.dart';

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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_textController.text.trim().isEmpty) return;

    final lines = _textController.text.split('\n');
    final List<StudentEntity> students = [];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      // Support both tab (Excel copy/paste) and semicolon separators
      final parts = line.contains('\t') ? line.split('\t') : line.split(';');

      // We expect at least: Nom + Prénom (+ optional Classe, Chambre)
      if (parts.length >= 2) {
        final lastName = parts[0].trim();
        final firstName = parts[1].trim();
        final className = parts.length > 2 ? parts[2].trim() : '';
        final roomNumber = parts.length > 3 ? parts[3].trim() : '';

        if (lastName.isNotEmpty && firstName.isNotEmpty) {
          students.add(
            StudentEntity(
              id: '',
              firstName: firstName,
              lastName: lastName,
              roomNumber: roomNumber,
              className: className,
              groupId: widget.groupId,
            ),
          );
        }
      }
    }

    if (students.isNotEmpty) {
      context.read<StudentBloc>().add(AddStudents(students, widget.groupId));
      _textController.text = students.length
          .toString(); // Store count in controller just to pass it to the dialog state or we can just emit it in a new event, but here we'll just show it in the state listener if we can, or we can just pop right now and show snackbar immediately since the bloc handles it asynchronously. Wait, AddStudents gives a "StudentsLoaded" event. We can just use the length now.
      Navigator.of(context).pop(students.length);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aucun format valide détecté.'),
          backgroundColor: context.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentsLoaded) {
          // If we wanted to show the snackbar locally we could, but we pop() in _submit so this is handled by the caller or we can do it here. If we pop() here, we might pop too late if the user closes it. Actually we removed the pop from here to put it in _submit.
        } else if (state is StudentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colorScheme.error,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Importation Massive',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Collez ci-dessous la liste de vos élèves. Attention au format, il doit y avoir un élève par ligne.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Format attendu :\nNom;Prénom;Classe;Chambre;Groupe\n\nExemple :\nDupont;Jean;Seconde A;101;Patriarches',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textController,
              maxLines: 8,
              minLines: 5,
              decoration: InputDecoration(
                labelText: 'Collez le document ici',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                final isLoading = state is StudentsLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.groupColor,
                    foregroundColor: widget.groupColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Valider l\'importation'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
