import 'package:go_router/go_router.dart';
import 'presentation/pages/admin_page.dart';

class AdminModule {
  static List<GoRoute> get routes => [
    GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
  ];
}
