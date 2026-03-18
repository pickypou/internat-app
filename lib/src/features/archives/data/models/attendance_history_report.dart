/// Represents a single report row from the `attendance_history` table.
class AttendanceHistoryReport {
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

  factory AttendanceHistoryReport.fromJson(Map<String, dynamic> json) {
    // report_data can be a List<dynamic> (JSONB from Supabase)
    final rawData = json['report_data'];
    final reportData = rawData is List
        ? rawData.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];

    return AttendanceHistoryReport(
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
}
