import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.studentId,
    required super.checkDate,
    required super.isPresentEvening,
    required super.isInBus,
    required super.note,
    super.groupId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      checkDate:
          DateTime.tryParse(json['check_date'] as String? ?? '') ??
          DateTime.now(),
      isPresentEvening: json['is_present_evening'] as bool? ?? false,
      isInBus: json['is_in_bus'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'student_id': studentId,
      'check_date':
          "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}",
      'is_present_evening': isPresentEvening,
      'is_in_bus': isInBus,
      'note': note,
      'group_id': groupId,
    };
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    return json;
  }
}
