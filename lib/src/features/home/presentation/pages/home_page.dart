import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/theme/theme_ext.dart';

// Import the specific logic and presentation pieces we need to assemble the homepage.
import '../../../group_selection/presentation/bloc/group_bloc.dart';
import '../../../group_selection/presentation/bloc/group_event.dart';
import '../../../group_selection/presentation/widgets/group_selection_view.dart';
import '../../../group_selection/presentation/widgets/create_group_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupBloc>()..add(LoadGroups()),
      child: Scaffold(
        body: const GroupSelectionView(),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (bottomSheetContext) {
                    return BlocProvider.value(
                      value: BlocProvider.of<GroupBloc>(context),
                      child: const CreateGroupForm(),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouveau groupe'),
            );
          },
        ),
      ),
    );
  }
}
