import 'package:go_router/go_router.dart';
import '../../features/home/home_module.dart';
import '../../features/group_selection/group_selection_module.dart';

/// Central application router.
/// Aggregates routing modules from all FSD features.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ...HomeModule.routes,
    ...GroupSelectionModule.routes,
    // Add other modules here in the future
  ],
);
