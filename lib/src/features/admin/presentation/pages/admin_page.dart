import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../../shared/widgets/custom_card.dart';

import '../../../group_selection/presentation/bloc/group_bloc.dart';
import '../../../group_selection/presentation/widgets/create_group_form.dart';
import '../../../group_selection/presentation/widgets/global_import_sheet.dart';
import '../../../stages/presentation/widgets/calendar_import_sheet.dart';
import '../../../students/domain/usecases/delete_all_students_usecase.dart';
import '../../../attendance/domain/usecases/archive_attendance_usecases.dart';
import '../../../attendance/domain/services/pdf_service.dart';
import '../../../attendance/domain/entities/attendance_archive_entity.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _showCreateGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (context) => getIt<GroupBloc>(),
          child: const CreateGroupForm(),
        );
      },
    );
  }

  void _showGlobalImport(BuildContext context) {
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const GlobalImportSheet(),
    ).then((count) {
      if (count != null && count > 0 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $count élèves importés avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showCalendarImport(BuildContext context) {
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CalendarImportSheet(),
    ).then((count) {
      if (count != null && count > 0 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $count période(s) importée(s) !'),
            backgroundColor: const Color(0xFF00BFA5),
          ),
        );
      }
    });
  }

  Future<void> _handleArchive(
    BuildContext context, {
    required bool isLycee,
  }) async {
    final title = isLycee
        ? 'Clôturer la semaine Lycée'
        : 'Clôturer la quinzaine Pôle-Sup';
    final content = isLycee
        ? 'Cette action va archiver les présences de TOUS LES GROUPES SAUF Pôle-Sup et vider le tableau pour la nouvelle semaine. Procéder ?'
        : 'Cette action va archiver UNIQUEMENT les présences du groupe Pôle-Sup et vider leur tableau pour la nouvelle quinzaine. Procéder ?';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLycee ? Colors.blue : Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Archiver et Vider'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final now = DateTime.now();
        final endDate = now;
        final startDate = endDate.subtract(Duration(days: isLycee ? 7 : 14));
        final format = DateFormat('dd/MM/yyyy');
        late String periodLabel;

        if (isLycee) {
          final sunday = endDate.subtract(Duration(days: endDate.weekday % 7));
          final friday = sunday.add(const Duration(days: 5));
          periodLabel =
              'LYCÉE : ${format.format(sunday)} au ${format.format(friday)}';
        } else {
          final sundayS = endDate.subtract(
            Duration(days: (endDate.weekday % 7) + 7),
          );
          final fridayS1 = sundayS.add(const Duration(days: 12));
          periodLabel =
              'POL-SUP : ${format.format(sundayS)} au ${format.format(fridayS1)}';
        }

        List<AttendanceArchiveEntity> archives = [];

        if (isLycee) {
          archives = await getIt<GetLyceeArchiveDataUseCase>()(
            startDate: startDate,
            endDate: endDate,
            periodLabel: periodLabel,
          );
        } else {
          archives = await getIt<GetPolSupArchiveDataUseCase>()(
            startDate: startDate,
            endDate: endDate,
            periodLabel: periodLabel,
          );
        }

        if (archives.isNotEmpty) {
          final pdfBytes = await PdfService.generateArchivePdf(
            archives,
            periodLabel,
          );

          await getIt<ArchiveAndResetUseCase>()(
            archives: archives,
            pdfBytes: pdfBytes,
            reportName: periodLabel, // use periodLabel as reportName
            periodLabel: periodLabel,
          );

          if (context.mounted) {
            Navigator.of(context).pop(); // hide loader
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '✅ Archivage réussi ! Les présences ont été sauvegardées et le PDF est disponible dans l\'onglet Archives.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pop(); // hide loader
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aucune présence à archiver.')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // hide loader
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  Future<void> _handleDeleteAllStudents(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nettoyage complet'),
        content: const Text(
          'Tous les élèves de tous les groupes seront supprimés définitivement. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Vider tout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await getIt<DeleteAllStudentsUseCase>()();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'La liste des élèves a été entièrement vidée.',
              ),
              backgroundColor: context.colorScheme.primary,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Gestion des Données',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateGroup(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un nouveau groupe'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.secondaryContainer,
                      foregroundColor: context.colorScheme.onSecondaryContainer,
                    ),
                    onPressed: () => _showGlobalImport(context),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import global (Excel)'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.tertiaryContainer,
                      foregroundColor: context.colorScheme.onTertiaryContainer,
                    ),
                    onPressed: () => _showCalendarImport(context),
                    icon: const Icon(Icons.calendar_view_day),
                    label: const Text('Importer Calendrier (Stages)'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.error,
                      foregroundColor: context.colorScheme.onError,
                    ),
                    onPressed: () => _handleDeleteAllStudents(context),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text(
                      'Suppression totale de la liste des élèves',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Clôture Administrative',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _handleArchive(context, isLycee: true),
                    icon: const Icon(Icons.archive),
                    label: const Text('Clôturer la semaine Lycée (PDF)'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _handleArchive(context, isLycee: false),
                    icon: const Icon(Icons.archive_outlined),
                    label: const Text('Clôturer la quinzaine Pôle-Sup (PDF)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Historique des Rapports',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => context.go('/archives'),
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Voir l\'Historique des Archives'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
