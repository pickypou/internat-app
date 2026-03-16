import 'package:go_router/go_router.dart';
import 'presentation/pages/lycee_page.dart';
import 'presentation/pages/pole_sup_page.dart';

class GroupSelectionModule {
  static List<GoRoute> get routes {
    return [
      GoRoute(path: '/lycee', builder: (context, state) => const LyceePage()),
      GoRoute(
        path: '/pole-sup',
        builder: (context, state) => const PoleSupPage(),
      ),
    ];
  }
}
