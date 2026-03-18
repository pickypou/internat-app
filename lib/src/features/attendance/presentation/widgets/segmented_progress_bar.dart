import 'package:flutter/material.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../../students/domain/entities/student_entity.dart';

class SegmentedProgressBar extends StatelessWidget {
  final List<StudentEntity> students;
  final List<AttendanceEntity> attendances;

  const SegmentedProgressBar({
    super.key,
    required this.students,
    required this.attendances,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) return const SizedBox.shrink();

    int present = 0;
    int stage = 0;
    int justified = 0;
    int absent = 0;
    int unchecked = 0;

    final Map<String, AttendanceEntity> attendanceMap = {
      for (var a in attendances) a.studentId: a
    };

    for (final student in students) {
      final att = attendanceMap[student.id];
      if (att == null) {
        unchecked++;
        continue;
      }

      final status = att.computedStatus;
      switch (status) {
        case 'Présent':
          present++;
          break;
        case 'Stage':
          stage++;
          break;
        case 'Absent Justifié':
        case 'Famille':
        case 'Retard':
          justified++;
          break;
        case 'Absent':
          absent++;
          break;
        default:
          // 'Bus' or others might be considered present or separate?
          // User didn't specify 'Bus', let's assume 'Présent' for 'Bus' or just group with unchecked if not sure.
          // Actually, let's treat 'Bus' as present for the bar if it's considered a positive state.
          if (status == 'Bus') {
            present++;
          } else {
            unchecked++;
          }
      }
    }

    return Container(
      height: 6,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          if (present > 0)
            Expanded(
              flex: present,
              child: Container(color: Colors.green),
            ),
          if (stage > 0)
            Expanded(
              flex: stage,
              child: Container(color: Colors.blue),
            ),
          if (justified > 0)
            Expanded(
              flex: justified,
              child: Container(color: Colors.orange),
            ),
          if (absent > 0)
            Expanded(
              flex: absent,
              child: Container(color: Colors.red),
            ),
          if (unchecked > 0)
            Expanded(
              flex: unchecked,
              child: Container(color: Colors.grey.withValues(alpha: 0.3)),
            ),
        ],
      ),
    );
  }
}
