import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import 'presentation/bloc/archives_bloc.dart';
import 'presentation/bloc/archives_event.dart';
import 'presentation/pages/archives_page.dart';

class ArchivesModule {
  static List<GoRoute> get routes => [
        GoRoute(
          path: '/archives',
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<ArchivesBloc>()..add(LoadArchives()),
            child: const ArchivesPage(),
          ),
        ),
      ];
}
