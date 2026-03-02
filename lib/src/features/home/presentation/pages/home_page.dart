import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/theme/theme_ext.dart';

// Import the specific logic and presentation pieces we need to assemble the homepage.
import '../../../group_selection/presentation/bloc/group_bloc.dart';
import '../../../group_selection/presentation/bloc/group_event.dart';
import '../../../group_selection/presentation/widgets/group_selection_view.dart';
import '../../../group_selection/presentation/widgets/create_group_form.dart';
import '../../../group_selection/presentation/widgets/global_import_sheet.dart';
import '../../../stages/presentation/widgets/calendar_import_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupBloc>()..add(LoadGroups()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Groupes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  tooltip: 'Import global (Excel)',
                  onPressed: () => _showGlobalImport(context),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_view_day),
                  tooltip: 'Importer Calendrier',
                  onPressed: () => _showCalendarImport(context),
                ),
              ],
            ),
            body: const GroupSelectionView(),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showCreateGroup(context),
              icon: const Icon(Icons.add),
              label: const Text('Nouveau groupe'),
            ),
          );
        },
      ),
    );
  }

  void _showCreateGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: BlocProvider.of<GroupBloc>(context),
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
        // Reload groups list after import
        context.read<GroupBloc>().add(LoadGroups());
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
}
