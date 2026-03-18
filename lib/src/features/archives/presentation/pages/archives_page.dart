import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/datasources/archives_remote_datasource.dart';
import '../../data/models/attendance_history_report.dart';
import '../widgets/report_details_sheet.dart';

class ArchivesPage extends StatefulWidget {
  final ArchivesRemoteDataSource dataSource;
  const ArchivesPage({super.key, required this.dataSource});

  @override
  State<ArchivesPage> createState() => _ArchivesPageState();
}

class _ArchivesPageState extends State<ArchivesPage> {
  List<AttendanceHistoryReport> _allReports = [];
  List<AttendanceHistoryReport> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reports = await widget.dataSource.fetchReports();
      setState(() {
        _allReports = reports;
        _filtered = reports;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _allReports;
      } else {
        _filtered = _allReports.where((r) {
          return r.reportName.toLowerCase().contains(query) ||
              r.periodLabel.toLowerCase().contains(query) ||
              _dateFmt.format(r.checkDate).contains(query);
        }).toList();
      }
    });
  }

  Future<void> _openPdf(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun PDF disponible pour ce rapport.')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le PDF.')),
        );
      }
    }
  }

  void _showDetails(AttendanceHistoryReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportDetailsSheet(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Historique des Rapports'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _fetchReports,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, période ou date (ex: 15/03)…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter();
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: colorScheme.error, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.error)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _fetchReports,
                            child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 56, color: colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun rapport trouvé.',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchReports,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final report = _filtered[i];
                        return _ReportCard(
                          report: report,
                          dateFmt: _dateFmt,
                          onOpenPdf: () => _openPdf(report.pdfUrl),
                          onDetails: () => _showDetails(report),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Report Card ──────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final AttendanceHistoryReport report;
  final DateFormat dateFmt;
  final VoidCallback onOpenPdf;
  final VoidCallback onDetails;

  const _ReportCard({
    required this.report,
    required this.dateFmt,
    required this.onOpenPdf,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLycee = report.reportName.toUpperCase().contains('LYC');

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLycee
                        ? Colors.indigo.withValues(alpha: 0.15)
                        : Colors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isLycee ? 'LYCÉE' : 'POL-SUP',
                    style: textTheme.labelSmall?.copyWith(
                      color: isLycee ? Colors.indigo : Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.periodLabel.isNotEmpty
                        ? report.periodLabel
                        : report.reportName,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Date row
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  dateFmt.format(report.checkDate),
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.outline),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people_outline, size: 14, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  '${report.reportData.length} élèves',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Détails'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: report.pdfUrl != null ? onOpenPdf : null,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('Voir PDF'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
