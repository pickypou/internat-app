import 'package:equatable/equatable.dart';

/// Represents a single report row from the `attendance_history` table.
class AttendanceHistoryReport extends Equatable {
  final String id;
  final String reportName;
  final String periodLabel;
  final String? pdfUrl;
  final String groupId;
  final DateTime checkDate;
  final DateTime archiveDate;
  final List<Map<String, dynamic>> reportData;

  const AttendanceHistoryReport({
    required this.id,
    required this.reportName,
    required this.periodLabel,
    this.pdfUrl,
    required this.groupId,
    required this.checkDate,
    required this.archiveDate,
    required this.reportData,
  });

  @override
  List<Object?> get props => [
        id,
        reportName,
        periodLabel,
        pdfUrl,
        groupId,
        checkDate,
        archiveDate,
        reportData,
      ];
}
