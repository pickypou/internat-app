import 'package:flutter/material.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import 'attendance_student_row.dart';
import 'attendance_table_widget.dart';

class AttendanceSection extends StatelessWidget {
  final String title;
  final List<StudentEntity> students;
  final List<AttendanceEntity> attendances;
  final Color groupColor;
  final DateTime selectedDate;
  final List<TableColumn> columns;
  final double Function(TableColumn) getColumnWidth;
  final Widget Function(TableColumn, StudentEntity, AttendanceEntity?) buildCellContent;
  final void Function(TableColumn, StudentEntity) onCellTap;
  final void Function(StudentEntity) onNameTap;
  final bool initiallyExpanded;

  const AttendanceSection({
    super.key,
    required this.title,
    required this.students,
    required this.attendances,
    required this.groupColor,
    required this.selectedDate,
    required this.columns,
    required this.getColumnWidth,
    required this.buildCellContent,
    required this.onCellTap,
    required this.onNameTap,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final parsedColor = groupColor;
    
    // Calculated summary for the section header
    final studentIds = students.map((s) => s.id).toSet();
    final sectionAttendances = attendances.where((a) => studentIds.contains(a.studentId)).toList();
    final presentCount = sectionAttendances.where((a) => a.isPresentEvening).length;

    return Column(
      children: [
        // --- Custom Section Header (Expansion Control) ---
        Container(
          color: parsedColor.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: parsedColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: parsedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$presentCount / ${students.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: parsedColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // --- List of Students in this section ---
        ...students.map((student) {
          final todayAtt = attendances
              .where((a) => a.studentId == student.id)
              .firstOrNull;
              
          return Row(
            children: [
              // Left side: Fixed Name
              AttendanceStudentNameCell(
                student: student,
                groupColor: groupColor,
                onTap: () => onNameTap(student),
              ),
              // Right side: Scrollable Matrix part
              // (Note: The parent Row must handle the horizontal scroll)
              AttendanceStudentRow(
                student: student,
                todayAttendance: todayAtt,
                selectedDate: selectedDate,
                columns: columns,
                getColumnWidth: getColumnWidth,
                buildCellContent: buildCellContent,
                onTap: onCellTap,
                groupColor: groupColor,
              ),
            ],
          );
        }),
      ],
    );
  }
}
