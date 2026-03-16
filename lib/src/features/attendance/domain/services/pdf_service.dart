import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../entities/attendance_archive_entity.dart';

class PdfService {
  /// Generates a PDF report from the "Boîte Noire" archive records.
  /// [records] must be pre-filtered for the desired period and groups (Lycée vs Pôle-Sup).
  /// [title] should be either "Semaine du [Dimanche] au [Vendredi]"
  /// or "Quinzaine du [1er Lundi] au [2e Vendredi]"
  static Future<Uint8List> generateArchivePdf(
    List<AttendanceArchiveEntity> records,
    String title,
  ) async {
    final pdf = pw.Document();

    // Group records by class name, then optionally by student Name
    // We want a clean table. Let's just sort them by Class, then LastName.
    records.sort((a, b) {
      final classComp = a.storedClassName.compareTo(b.storedClassName);
      if (classComp != 0) return classComp;
      return a.storedLastName.compareTo(b.storedLastName);
    });

    final now = DateTime.now();
    final DateFormat generationFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final String footerText =
        "Document généré le ${generationFormat.format(now)} - Archive permanente de l'internat";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(title),
        footer: (context) => _buildFooter(footerText),
        build: (context) => [_buildRecordsTable(records)],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildFooter(String text) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildRecordsTable(List<AttendanceArchiveEntity> records) {
    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: [
        'Classe',
        'Nom',
        'Prénom',
        'Chambre',
        'Date (Appel)',
        'Statut',
        'Note / Horaires',
      ],
      data: records.map((r) {
        final checkDateFormat = DateFormat('dd/MM/yyyy');
        final timeFormat = DateFormat('HH:mm');

        String extraInfo = r.note ?? '';
        List<String> times = [];
        if (r.checkInTime != null) {
          times.add('In: ${timeFormat.format(r.checkInTime!)}');
        }
        if (r.checkOutTime != null) {
          times.add('Out: ${timeFormat.format(r.checkOutTime!)}');
        }
        if (times.isNotEmpty) {
          final timeStr = times.join(' | ');
          extraInfo = extraInfo.isEmpty ? timeStr : '$extraInfo\n($timeStr)';
        }

        return [
          r.storedClassName,
          r.storedLastName,
          r.storedFirstName,
          r.storedRoomNumber,
          checkDateFormat.format(r.checkDate),
          r.status,
          extraInfo,
        ];
      }).toList(),
    );
  }

  /// Triggers the system print/share dialog for the generated Document.
  static Future<void> printPdf(Uint8List pdfData, String jobName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: jobName,
    );
  }
}
