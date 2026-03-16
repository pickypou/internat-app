import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final String id;
  final String studentId;
  final DateTime checkDate;
  final bool isPresentEvening;
  final bool isInBus;
  final String note;
  final String groupId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  const AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.checkDate,
    required this.isPresentEvening,
    required this.isInBus,
    required this.note,
    this.groupId = '',
    this.checkInTime,
    this.checkOutTime,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    checkDate,
    isPresentEvening,
    isInBus,
    note,
    groupId,
    checkInTime,
    checkOutTime,
  ];

  AttendanceEntity copyWith({
    String? id,
    String? studentId,
    DateTime? checkDate,
    bool? isPresentEvening,
    bool? isInBus,
    String? note,
    String? groupId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      checkDate: checkDate ?? this.checkDate,
      isPresentEvening: isPresentEvening ?? this.isPresentEvening,
      isInBus: isInBus ?? this.isInBus,
      note: note ?? this.note,
      groupId: groupId ?? this.groupId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  String get computedStatus {
    if (note == 'Stage') return 'Stage';
    if (note == 'Absent Justifié') return 'Absent Justifié';
    if (note == 'Famille') return 'Famille';
    if (note == 'Retard') return 'Retard';
    if (isInBus) return 'Bus';
    if (isPresentEvening) return 'Présent';
    return 'Absent';
  }
}
