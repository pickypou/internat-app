import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';

// Import the specific logic and presentation pieces we need to assemble the homepage.
import '../../../group_selection/presentation/bloc/group_bloc.dart';
import '../../../group_selection/presentation/bloc/group_event.dart';
import '../../../group_selection/presentation/widgets/group_selection_view.dart';
import 'package:go_router/go_router.dart';

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
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Administration',
                  onPressed: () => context.push('/admin'),
                ),
              ],
            ),
            body: const GroupSelectionView(),
          );
        },
      ),
    );
  }
}
