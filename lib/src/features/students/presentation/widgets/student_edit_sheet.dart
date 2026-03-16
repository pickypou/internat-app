import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internat_app/src/core/di/injection.dart';
import 'package:internat_app/src/features/attendance/domain/entities/attendance_entity.dart';
import 'package:internat_app/src/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:internat_app/src/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:internat_app/src/features/group_selection/domain/entities/group_entity.dart';
import 'package:internat_app/src/features/group_selection/domain/usecases/get_groups_usecase.dart';
import 'package:internat_app/src/features/students/domain/entities/student_entity.dart';
import 'package:internat_app/src/features/students/domain/usecases/delete_student_usecase.dart';
import 'package:internat_app/src/features/students/domain/usecases/update_student_usecase.dart';
import 'package:internat_app/src/shared/theme/theme_ext.dart';

/// Fiche complète de l'élève : édition, changement de groupe, note, suppression.
/// S'affiche en BottomSheet en remplacement du précédent AlertDialog de note.
class StudentEditSheet extends StatefulWidget {
  final StudentEntity student;
  final AttendanceEntity? currentAttendance;
  final String groupId;
  final DateTime date;
  final Color groupColor;

  const StudentEditSheet({
    super.key,
    required this.student,
    required this.currentAttendance,
    required this.groupId,
    required this.date,
    required this.groupColor,
  });

  @override
  State<StudentEditSheet> createState() => _StudentEditSheetState();
}

class _StudentEditSheetState extends State<StudentEditSheet> {
  final _formKey = GlobalKey<FormState>();

  // Champs éditables
  late TextEditingController _lastNameCtrl;
  late TextEditingController _firstNameCtrl;
  late TextEditingController _classCtrl;
  late TextEditingController _roomCtrl;
  late TextEditingController _noteCtrl;

  // Groupe sélectionné
  String? _selectedGroupId;
  List<GroupEntity> _groups = [];
  bool _loadingGroups = true;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _lastNameCtrl = TextEditingController(text: s.lastName);
    _firstNameCtrl = TextEditingController(text: s.firstName);
    _classCtrl = TextEditingController(text: s.className);
    _roomCtrl = TextEditingController(text: s.roomNumber);
    _noteCtrl = TextEditingController(
      text: widget.currentAttendance?.note ?? '',
    );
    _selectedGroupId = s.groupId;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await getIt<GetGroupsUseCase>()();
      if (mounted) {
        setState(() {
          _groups = groups;
          _loadingGroups = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingGroups = false);
    }
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _classCtrl.dispose();
    _roomCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Enregistrer ─────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = StudentEntity(
      id: widget.student.id,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      className: _classCtrl.text.trim(),
      roomNumber: _roomCtrl.text.trim(),
      groupId: _selectedGroupId ?? widget.student.groupId,
    );

    try {
      await getIt<UpdateStudentUseCase>()(updated);
    } catch (_) {}

    // Mettre à jour la note d'appel si présente
    final newNote = _noteCtrl.text.trim();
    final att = widget.currentAttendance;
    if (att != null || newNote.isNotEmpty) {
      final bool noteChanged = att?.note != newNote;
      final now = DateTime.now();

      final updatedAtt = AttendanceEntity(
        id: att?.id ?? '',
        studentId: widget.student.id,
        checkDate: widget.date,
        isPresentEvening: att?.isPresentEvening ?? false,
        isInBus: att?.isInBus ?? false,
        note: newNote,
        groupId: widget.groupId,
        checkInTime: att?.checkInTime,
        checkOutTime: noteChanged ? now : att?.checkOutTime,
      );
      if (mounted) {
        context.read<AttendanceBloc>().add(
          UpdateAttendance(updatedAtt, widget.groupId, widget.date),
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Modifications enregistrées'),
          backgroundColor: widget.groupColor,
        ),
      );
    }
  }

  // ── Effacer la note ──────────────────────────────────────────────────────
  void _clearNote() {
    final att = widget.currentAttendance;
    if (att != null && att.id.isNotEmpty) {
      context.read<AttendanceBloc>().add(DeleteAttendance(att.id));
    }
    Navigator.of(context).pop();
  }

  // ── Supprimer l'élève ────────────────────────────────────────────────────
  Future<void> _deleteStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet élève ?'),
        content: Text(
          'Voulez-vous vraiment supprimer définitivement\n'
          '${widget.student.lastName.toUpperCase()} ${widget.student.firstName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await getIt<DeleteStudentUseCase>()(widget.student.id);
      } catch (_) {}
      if (mounted) {
        context.read<AttendanceBloc>().add(
          LoadAttendance(widget.groupId, widget.date),
        );
        Navigator.of(context).pop();
      }
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Titre ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.student.lastName.toUpperCase()} ${widget.student.firstName}',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.groupColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // ── Champs d'édition ──
              _buildField('Nom', _lastNameCtrl, TextCapitalization.characters),
              const SizedBox(height: 12),
              _buildField('Prénom', _firstNameCtrl, TextCapitalization.words),
              const SizedBox(height: 12),
              _buildField('Classe', _classCtrl, TextCapitalization.characters),
              const SizedBox(height: 12),
              _buildField(
                'Chambre',
                _roomCtrl,
                TextCapitalization.none,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // ── Sélecteur de groupe ──
              Text('Groupe', style: context.textTheme.labelLarge),
              const SizedBox(height: 6),
              _loadingGroups
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedGroupId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      items: _groups
                          .map(
                            (g) => DropdownMenuItem(
                              value: g.id,
                              child: Text(g.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGroupId = v),
                    ),
              const SizedBox(height: 16),

              // ── Note d'appel ──
              Text('Note', style: context.textTheme.labelLarge),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ex : Parents venus à 20h15',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.groupColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.groupColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Boutons principaux ──
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.groupColor,
                        foregroundColor:
                            widget.groupColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Effacer la note ──
              ElevatedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text(
                  'Effacer / Vide',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.errorContainer,
                  foregroundColor: context.colorScheme.onErrorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _clearNote,
              ),
              const SizedBox(height: 8),

              // ── Supprimer l'élève ──
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Supprimer cet élève',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: _deleteStudent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    TextCapitalization capitalization, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      textCapitalization: capitalization,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
    );
  }
}
