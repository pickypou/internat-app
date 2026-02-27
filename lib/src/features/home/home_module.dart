import 'package:go_router/go_router.dart';
import 'presentation/pages/home_page.dart';

/// Module configuration for the home feature navigation.
class HomeModule {
  /// Defines all GoRoutes belonging to the home feature.
  static List<GoRoute> get routes {
    return [GoRoute(path: '/', builder: (context, state) => const HomePage())];
  }
}
