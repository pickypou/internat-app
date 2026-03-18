import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance_history_report.dart';

class ReportDetailsSheet extends StatelessWidget {
  final AttendanceHistoryReport report;
  const ReportDetailsSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy');

    // Sort by class then last name
    final sorted = List<Map<String, dynamic>>.from(report.reportData)
      ..sort((a, b) {
        final classComp = (a['class_name'] as String? ?? '')
            .compareTo(b['class_name'] as String? ?? '');
        if (classComp != 0) return classComp;
        return (a['last_name'] as String? ?? '')
            .compareTo(b['last_name'] as String? ?? '');
      });

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.periodLabel.isNotEmpty
                          ? report.periodLabel
                          : report.reportName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date : ${dateFmt.format(report.checkDate)} — ${sorted.length} élèves',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: sorted.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun détail disponible.',
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: sorted.length,
                        itemBuilder: (_, i) {
                          final s = sorted[i];
                          final status = s['status'] as String? ?? '—';
                          final Color statusColor = _statusColor(status, colorScheme);
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: statusColor.withValues(alpha: 0.15),
                              child: Text(
                                (s['last_name'] as String? ?? '?')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${s['last_name'] ?? ''} ${s['first_name'] ?? ''}'.trim(),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${s['class_name'] ?? ''}',
                              style: TextStyle(color: colorScheme.outline),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status, ColorScheme cs) {
    switch (status.toLowerCase()) {
      case 'présent':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'stage':
        return Colors.blue;
      case 'justifié':
        return Colors.orange;
      default:
        return cs.outline;
    }
  }
}
