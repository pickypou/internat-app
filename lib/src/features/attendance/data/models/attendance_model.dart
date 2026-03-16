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
    super.checkInTime,
    super.checkOutTime,
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
      checkInTime: json['check_in_time'] != null
          ? DateTime.tryParse(json['check_in_time'] as String)
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.tryParse(json['check_out_time'] as String)
          : null,
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
    if (checkInTime != null) {
      json['check_in_time'] = checkInTime!.toUtc().toIso8601String();
    }
    if (checkOutTime != null) {
      json['check_out_time'] = checkOutTime!.toUtc().toIso8601String();
    }
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    return json;
  }
}
