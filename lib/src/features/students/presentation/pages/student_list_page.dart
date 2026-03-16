import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/add_student_form.dart';
import '../../../attendance/presentation/pages/attendance_table_page.dart';
import '../../domain/entities/student_entity.dart';

class StudentListPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupColorHex;

  const StudentListPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupColorHex,
  });

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStudentBottomSheet(
    BuildContext context, {
    StudentEntity? student,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: BlocProvider.of<StudentBloc>(context),
          child: AddStudentForm(groupId: widget.groupId, student: student),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    StudentEntity student,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Voulez-vous vraiment supprimer ${student.firstName} ${student.lastName} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Supprimer',
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<StudentBloc>()..add(LoadStudents(widget.groupId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.groupName),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AttendanceTablePage(
                          groupId: widget.groupId,
                          groupName: widget.groupName,
                          groupColorHex: widget.groupColorHex,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fact_check_outlined),
                  tooltip: 'Faire l\'appel',
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un élève...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: context.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
            ),
            body: BlocConsumer<StudentBloc, StudentState>(
              listener: (context, state) {
                if (state is StudentsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: context.colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is StudentsLoading) {
                  // Keep showing previous items while reloading in background
                  // Or show a simple overlay. For simplicity, circular progress only if really initial
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StudentsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: context.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<StudentBloc>().add(
                              LoadStudents(widget.groupId),
                            );
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is StudentsLoaded) {
                  // Local filtering
                  final filteredStudents = state.students.where((s) {
                    final fullName = '${s.firstName} ${s.lastName}'
                        .toLowerCase();
                    return fullName.contains(_searchQuery);
                  }).toList();

                  if (filteredStudents.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Aucun élève dans ce groupe.'
                            : 'Aucun résultat pour cette recherche.',
                        style: context.textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      bottom: 80,
                      top: 8,
                    ), // space for FAB
                    itemCount: filteredStudents.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Dismissible(
                        key: Key(student.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: context.colorScheme.error,
                          child: Icon(
                            Icons.delete,
                            color: context.colorScheme.onError,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmation(
                            context,
                            student,
                          );
                        },
                        onDismissed: (direction) {
                          context.read<StudentBloc>().add(
                            DeleteStudent(student.id, widget.groupId),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Élève supprimé'),
                              backgroundColor: context.colorScheme.primary,
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                context.colorScheme.primaryContainer,
                            child: Text(
                              student.firstName.isNotEmpty
                                  ? student.firstName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: context.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${student.firstName} ${student.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            student.roomNumber.isNotEmpty
                                ? 'Chambre: ${student.roomNumber} ${student.className.isNotEmpty ? '• Classe: ${student.className}' : ''}'
                                : student.className.isNotEmpty
                                ? 'Classe: ${student.className}'
                                : 'Aucune info',
                          ),
                          onTap: () {
                            _showAddStudentBottomSheet(
                              context,
                              student: student,
                            );
                          },
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: context.colorScheme.error,
                            ),
                            onPressed: () async {
                              final confirm = await _showDeleteConfirmation(
                                context,
                                student,
                              );
                              if (confirm == true && context.mounted) {
                                context.read<StudentBloc>().add(
                                  DeleteStudent(student.id, widget.groupId),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Élève supprimé'),
                                    backgroundColor:
                                        context.colorScheme.primary,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddStudentBottomSheet(context),
              child: const Icon(Icons.person_add),
            ),
          );
        },
      ),
    );
  }
}
