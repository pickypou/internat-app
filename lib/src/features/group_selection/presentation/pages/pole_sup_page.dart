import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../attendance/presentation/widgets/attendance_table_widget.dart';
import '../../../students/presentation/widgets/add_student_form.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../bloc/group_state.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../../domain/entities/group_entity.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../attendance/presentation/bloc/attendance_event.dart';
import '../../../attendance/presentation/bloc/attendance_state.dart';
import '../../../students/domain/entities/student_entity.dart';

class PoleSupPage extends StatefulWidget {
  const PoleSupPage({super.key});

  @override
  State<PoleSupPage> createState() => _PoleSupPageState();
}

class _PoleSupPageState extends State<PoleSupPage> {
  late DateTime _selectedDate;
  bool _showAll = false;
  bool _sortByClass = false; // Tri alphabétique par défaut
  int _reloadTrigger = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _showAddStudentBottomSheet(
    BuildContext context,
    List<GroupEntity> groups,
  ) {
    if (groups.isEmpty) return;

    if (groups.length == 1) {
      _openAddStudentForm(context, groups.first);
      return;
    }

    showDialog<GroupEntity>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir le groupe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: groups.map((g) {
              return ListTile(
                title: Text(g.name),
                onTap: () => Navigator.of(context).pop(g),
              );
            }).toList(),
          ),
        );
      },
    ).then((selectedGroup) {
      if (selectedGroup != null && context.mounted) {
        _openAddStudentForm(context, selectedGroup);
      }
    });
  }

  void _openAddStudentForm(BuildContext context, GroupEntity group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (context) => getIt<StudentBloc>(),
          child: AddStudentForm(groupId: group.id),
        );
      },
    ).then((_) {
      if (context.mounted) {
        setState(() {
          _reloadTrigger++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      "'Aujourd''hui,' EEEE d MMMM",
      'fr_FR',
    ).format(DateTime.now());

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<GroupBloc>()..add(LoadGroups())),
        BlocProvider(
          create: (context) =>
              getIt<AttendanceBloc>()..add(LoadPoleSupClasses(_selectedDate)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pôle-Sup'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                formattedDate,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _showAll ? Icons.visibility : Icons.visibility_off,
                color: _showAll ? Colors.orange : null,
              ),
              tooltip: _showAll
                  ? 'Filtrage actif : Tout afficher'
                  : 'Tout afficher',
              onPressed: () => setState(() => _showAll = !_showAll),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null && context.mounted) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ordre Alphabétique',
                    style: TextStyle(
                      fontWeight: !_sortByClass
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: !_sortByClass
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Switch(
                    value: _sortByClass,
                    onChanged: (val) {
                      setState(() {
                        _sortByClass = val;
                      });
                    },
                  ),
                  Text(
                    'Classe',
                    style: TextStyle(
                      fontWeight: _sortByClass
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _sortByClass
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {
                  if (state is AttendanceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AttendanceError) {
                    return Center(child: Text(state.message));
                  } else if (state is AttendanceLoaded) {
                    final students = state.students;
                    final attendances = state.attendances;

                    if (students.isEmpty) {
                      return const Center(
                        child: Text('Aucun élève Pôle-Sup trouvé.'),
                      );
                    }

                    // Group students by className
                    final Map<String, List<StudentEntity>> classGroups = {};
                    for (final s in students) {
                      final className = s.className.isEmpty ? 'Sans classe' : s.className;
                      classGroups.putIfAbsent(className, () => []).add(s);
                    }

                    final sortedClasses = classGroups.keys.toList()..sort();

                    return ListView.builder(
                      itemCount: sortedClasses.length,
                      itemBuilder: (context, index) {
                        final className = sortedClasses[index];
                        final classStudents = classGroups[className]!;

                        // Count presence for this class
                        final classStudentIds =
                            classStudents.map((s) => s.id).toSet();
                        final classAttendances = attendances
                            .where((a) => classStudentIds.contains(a.studentId))
                            .toList();
                        final presentCount = classAttendances
                            .where((a) => a.isPresentEvening)
                            .length;

                        final Color parsedColor = context.colorScheme.primary;

                        return ExpansionTile(
                          initiallyExpanded: false,
                          collapsedIconColor: parsedColor,
                          iconColor: parsedColor,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  className,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: parsedColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: parsedColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$presentCount / ${classStudents.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: parsedColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: parsedColor.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              child: AttendanceTableWidget(
                                groupId:
                                    'mixed-pole-sup', // Not used when injecting data
                                groupName: className,
                                groupColorHex: '4CAF50', // Default green
                                selectedDate: _selectedDate,
                                showAll: _showAll,
                                sortByClass: _sortByClass,
                                reloadTrigger: _reloadTrigger,
                                isPoleSup: true,
                                students: classStudents,
                                attendances: classAttendances,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: BlocBuilder<GroupBloc, GroupState>(
          builder: (context, state) {
            if (state is GroupsLoaded) {
              final poleSupGroups = state.groups.where((g) => g.isPoleSup).toList();

              return FloatingActionButton(
                onPressed: () =>
                    _showAddStudentBottomSheet(context, poleSupGroups),
                child: const Icon(Icons.person_add),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
