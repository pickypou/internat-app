import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/archives_remote_datasource.dart';
import 'presentation/pages/archives_page.dart';

class ArchivesModule {
  static List<GoRoute> get routes => [
        GoRoute(
          path: '/archives',
          builder: (context, state) => ArchivesPage(
            dataSource: ArchivesRemoteDataSource(Supabase.instance.client),
          ),
        ),
      ];
}
