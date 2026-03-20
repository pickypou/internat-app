import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../widgets/attendance_table_widget.dart';

class AttendanceStudentRow extends StatelessWidget {
  final StudentEntity student;
  final AttendanceEntity? todayAttendance;
  final DateTime selectedDate;
  final List<TableColumn> columns;
  final double Function(TableColumn) getColumnWidth;
  final Widget Function(TableColumn, StudentEntity, AttendanceEntity?) buildCellContent;
  final void Function(TableColumn, StudentEntity) onTap;
  final Color groupColor;
  final bool isSelectedColumn;

  const AttendanceStudentRow({
    super.key,
    required this.student,
    this.todayAttendance,
    required this.selectedDate,
    required this.columns,
    required this.getColumnWidth,
    required this.buildCellContent,
    required this.onTap,
    required this.groupColor,
    this.isSelectedColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final String? status = todayAttendance?.computedStatus;

    return Row(
      children: columns.map((col) {
        Color cellColor = Colors.transparent;

        // Special highlight for the selected day column
        final isMatch = _isColumnMatchingDay(col, selectedDate);
        if (status != null && status != 'Absent' && isMatch) {
          if (status == 'Présent') {
            cellColor = Colors.green.withValues(alpha: 0.7);
          } else if (status == 'Stage') {
            cellColor = AppColors.stageBadge;
          } else if (status == 'Absent Justifié') {
            cellColor = AppColors.appelOrange;
          }
        } else if (status == 'Absent' && isMatch) {
          cellColor = colorScheme.error.withValues(alpha: 0.8);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(col, student),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: getColumnWidth(col),
            height: 60,
            decoration: BoxDecoration(
              color: cellColor,
              border: Border(
                right: BorderSide(
                  color: groupColor.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                bottom: BorderSide(
                  color: groupColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: buildCellContent(col, student, todayAttendance),
          ),
        );
      }).toList(),
    );
  }

  bool _isColumnMatchingDay(TableColumn col, DateTime date) {
    if (col == TableColumn.lundi && date.weekday == DateTime.monday) return true;
    if (col == TableColumn.mardi && date.weekday == DateTime.tuesday) return true;
    if (col == TableColumn.mercredi && date.weekday == DateTime.wednesday) return true;
    if (col == TableColumn.jeudi && date.weekday == DateTime.thursday) return true;
    if (col == TableColumn.vendredi && date.weekday == DateTime.friday) return true;
    if (col == TableColumn.samedi && date.weekday == DateTime.saturday) return true;
    if (col == TableColumn.dimanche && date.weekday == DateTime.sunday) return true;
    return false;
  }
}

/// Helper component for the Fixed Name part of the row
class AttendanceStudentNameCell extends StatelessWidget {
  final StudentEntity student;
  final Color groupColor;
  final VoidCallback onTap;

  const AttendanceStudentNameCell({
    super.key,
    required this.student,
    required this.groupColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 60,
      padding: const EdgeInsets.only(left: 10, right: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: groupColor, width: 3),
          bottom: BorderSide(
            color: groupColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          '${student.lastName.toUpperCase()} ${student.firstName}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
