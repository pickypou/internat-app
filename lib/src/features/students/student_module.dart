import 'package:go_router/go_router.dart';
import '../attendance/presentation/pages/attendance_table_page.dart';

class StudentModule {
  static final List<GoRoute> routes = [
    GoRoute(
      path: '/group/:groupId',
      name: 'student_list',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        // Use extra param if available, fallback to default text
        final extraMap = state.extra as Map<String, dynamic>? ?? {};
        final groupName = extraMap['name'] as String? ?? 'Étudiants du Groupe';
        final groupColor = extraMap['color'] as String? ?? '#808080';

        return AttendanceTablePage(
          groupId: groupId,
          groupName: groupName,
          groupColorHex: groupColor,
        );
      },
    ),
  ];
}
