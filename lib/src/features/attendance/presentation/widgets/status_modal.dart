import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internat_app/src/shared/theme/theme_ext.dart';
import 'package:internat_app/src/features/attendance/domain/entities/attendance_entity.dart';
import 'package:internat_app/src/features/students/domain/entities/student_entity.dart';
import 'package:internat_app/src/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:internat_app/src/features/attendance/presentation/bloc/attendance_event.dart';

class StatusModal extends StatelessWidget {
  final StudentEntity student;
  final AttendanceEntity? currentAttendance;
  final String groupId;
  final DateTime date;
  final bool isPoleSup;

  const StatusModal({
    super.key,
    required this.student,
    required this.currentAttendance,
    required this.groupId,
    required this.date,
    this.isPoleSup = false,
  });

  void _updateStatus(BuildContext context, String statusKey) {
    bool isPresentEvening = false;
    bool isInBus = false;
    String newNote = currentAttendance?.note ?? '';

    if (newNote == 'Famille' || newNote == 'Retard') {
      newNote = '';
    }

    if (statusKey == 'Présent') {
      isPresentEvening = true;
    } else if (statusKey == 'Absent') {
      isPresentEvening = false;
    } else if (statusKey == 'Absent Justifié') {
      isPresentEvening = false;
      newNote = 'Absent Justifié';
    } else if (statusKey == 'Stage') {
      isPresentEvening = false;
      newNote = 'Stage';
    }

    final now = DateTime.now();

    final updated = AttendanceEntity(
      id: currentAttendance?.id ?? '', // empty if new
      studentId: student.id,
      checkDate: date,
      isPresentEvening: isPresentEvening,
      isInBus: isInBus,
      note: newNote,
      groupId: groupId,
      checkInTime: isPoleSup
          ? now
          : (statusKey == 'Présent' ? now : currentAttendance?.checkInTime),
      checkOutTime: currentAttendance?.checkOutTime,
    );
    context.read<AttendanceBloc>().add(
      UpdateAttendance(updated, groupId, date),
    );
    Navigator.of(context).pop();
  }

  void _clearStatus(BuildContext context) {
    if (currentAttendance != null && currentAttendance!.id.isNotEmpty) {
      context.read<AttendanceBloc>().add(
        DeleteAttendance(currentAttendance!.id),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Statut : ${student.firstName} ${student.lastName}',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildStatusButton(context, 'Présent', '✅', Colors.green),
            const SizedBox(height: 12),
            _buildStatusButton(context, 'Stage', '💼', Colors.blue),
            const SizedBox(height: 12),
            _buildStatusButton(context, 'Absent Justifié', '⚠️', Colors.orange),
            const SizedBox(height: 12),
            _buildStatusButton(context, 'Absent', '❌', Colors.red),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.errorContainer,
                foregroundColor: context.colorScheme.onErrorContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => _clearStatus(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text(
                'Effacer / Vide',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String status,
    String emoji,
    Color color,
  ) {
    final isSelected = currentAttendance?.computedStatus == status;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? color.withValues(alpha: 0.2)
            : context.colorScheme.surfaceContainerHighest,
        foregroundColor: isSelected ? color : context.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide(color: color, width: 2)
              : BorderSide.none,
        ),
        elevation: 0,
      ),
      onPressed: () => _updateStatus(context, status),
      child: Text(
        '$emoji $status',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
