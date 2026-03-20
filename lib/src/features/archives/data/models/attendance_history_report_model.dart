import 'package:internat_app/src/features/archives/domain/entities/attendance_history_report.dart';

class AttendanceHistoryReportModel extends AttendanceHistoryReport {
  const AttendanceHistoryReportModel({
    required super.id,
    required super.reportName,
    required super.periodLabel,
    super.pdfUrl,
    required super.groupId,
    required super.checkDate,
    required super.archiveDate,
    required super.reportData,
  });

  factory AttendanceHistoryReportModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['report_data'];
    final reportData = rawData is List
        ? rawData.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];

    return AttendanceHistoryReportModel(
      id: json['id']?.toString() ?? '',
      reportName: json['report_name'] as String? ?? 'Sans Nom',
      periodLabel: json['period_label'] as String? ?? '',
      pdfUrl: json['pdf_url'] as String?,
      groupId: json['group_id'] as String? ?? '',
      checkDate: json['check_date'] != null
          ? DateTime.parse(json['check_date'] as String)
          : DateTime.now(),
      archiveDate: json['archive_date'] != null
          ? DateTime.parse(json['archive_date'] as String)
          : DateTime.now(),
      reportData: reportData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_name': reportName,
      'period_label': periodLabel,
      'pdf_url': pdfUrl,
      'group_id': groupId,
      'check_date': checkDate.toIso8601String(),
      'archive_date': archiveDate.toIso8601String(),
      'report_data': reportData,
    };
  }
}
