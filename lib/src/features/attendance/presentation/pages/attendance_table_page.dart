import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/preferences/preferences_service.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/status_modal.dart';
import '../../../students/presentation/widgets/add_student_form.dart';
import '../../../students/presentation/widgets/bulk_import_students_sheet.dart';
import '../../../students/presentation/widgets/student_edit_sheet.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/domain/usecases/delete_students_by_group_usecase.dart';
import '../../../stages/domain/entities/stage_period_entity.dart';
import '../../../stages/domain/services/stage_period_service.dart';
import '../../../stages/domain/usecases/get_stage_periods_usecase.dart';

enum TableColumn {
  classe('Classe'),
  lundi('Lun'),
  mardi('Mar'),
  mercredi('Mer'),
  jeudi('Jeu'),
  vendredi('Ven'),
  samedi('Sam'),
  dimanche('Dim'),
  chambre('Chambre'),
  note('Note');
  // checkbox('Bus');

  final String label;
  const TableColumn(this.label);
}

class AttendanceTablePage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupColorHex;

  const AttendanceTablePage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupColorHex,
  });

  @override
  State<AttendanceTablePage> createState() => _AttendanceTablePageState();
}

class _AttendanceTablePageState extends State<AttendanceTablePage> {
  final ScrollController _leftScrollController = ScrollController();
  final ScrollController _rightScrollController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  bool _isScrolling = false;
  late DateTime _selectedDate;

  List<TableColumn> _columns = TableColumn.values.toList();
  final Set<TableColumn> _expandedColumns = {};
  final Map<String, bool> _expandedClasses = {};

  // ── Calendrier (periods) ──────────────────────────────────────────────────
  List<StagePeriodEntity> _periods = [];
  bool _showAll = false; // override: show all students regardless of period

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadColumnOrder();
    _loadPeriods();

    _leftScrollController.addListener(() {
      if (_isScrolling) return;
      _isScrolling = true;
      _rightScrollController.jumpTo(_leftScrollController.offset);
      _isScrolling = false;
    });

    _rightScrollController.addListener(() {
      if (_isScrolling) return;
      _isScrolling = true;
      _leftScrollController.jumpTo(_rightScrollController.offset);
      _isScrolling = false;
    });
  }

  Future<void> _loadPeriods() async {
    try {
      final periods = await getIt<GetStagePeriodsUseCase>()();
      if (mounted) setState(() => _periods = periods);
    } catch (_) {
      // Pas bloquant — on continue sans filtrage
    }
  }

  Future<void> _loadColumnOrder() async {
    final prefs = getIt<PreferencesService>();
    final saved = await prefs.getColumnOrder();
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _columns = saved
            .map((name) => TableColumn.values.firstWhere((e) => e.name == name))
            .toList();
      });
    }
  }

  Future<void> _saveColumnOrder() async {
    final prefs = getIt<PreferencesService>();
    await prefs.saveColumnOrder(_columns.map((e) => e.name).toList());
  }

  @override
  void dispose() {
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _showStatusModal(
    BuildContext context,
    StudentEntity student,
    List<AttendanceEntity> attendances,
  ) {
    final todayAttendance = attendances
        .where((a) => a.studentId == student.id)
        .firstOrNull;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<AttendanceBloc>(),
          child: StatusModal(
            student: student,
            currentAttendance: todayAttendance,
            groupId: widget.groupId,
            date: _selectedDate,
          ),
        );
      },
    );
  }

  void _showNoteModal(
    BuildContext context,
    StudentEntity student,
    List<AttendanceEntity> attendances,
    Color groupColor,
  ) {
    final todayAtt = attendances
        .where((a) => a.studentId == student.id)
        .firstOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<AttendanceBloc>(),
          child: StudentEditSheet(
            student: student,
            currentAttendance: todayAtt,
            groupId: widget.groupId,
            date: _selectedDate,
            groupColor: groupColor,
          ),
        );
      },
    );
  }

  Future<void> _showBulkImportBottomSheet(
    BuildContext context,
    Color groupColor,
  ) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (context) => getIt<StudentBloc>(),
          child: BulkImportStudentsSheet(
            groupId: widget.groupId,
            groupColor: groupColor,
          ),
        );
      },
    );

    if (result != null && result > 0 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$result élèves ajoutés avec succès ✅'),
          backgroundColor: context.colorScheme.primary,
        ),
      );
      // Reload the table since new students are added
      context.read<AttendanceBloc>().add(
        LoadAttendance(widget.groupId, _selectedDate),
      );
    }
  }

  Widget _buildLeftColumn(
    BuildContext context,
    List<dynamic> listItems,
    List<AttendanceEntity> attendances,
    Color groupColor,
  ) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: groupColor.withValues(alpha: 0.1),
              border: Border(
                right: BorderSide(
                  color: groupColor.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                bottom: BorderSide(
                  color: groupColor.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
            ),
            child: const Text(
              'Élève',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Body
          Expanded(
            child: ListView.builder(
              controller: _leftScrollController,
              itemCount: listItems.length,
              itemExtent: 60,
              itemBuilder: (context, index) {
                final item = listItems[index];

                if (item is Map) {
                  // Class Header
                  final className = item['class'] as String;
                  final classStatus = item['status'] as String? ?? 'PRESENT';
                  final isExpanded = _expandedClasses[className] ?? true;
                  final badgeColor = classStatus == 'STAGE'
                      ? Colors.orange
                      : classStatus == 'HORS_QUINZAINE'
                      ? Colors.blue
                      : null;
                  final badgeLabel = classStatus == 'STAGE'
                      ? '🟠 STAGE'
                      : classStatus == 'HORS_QUINZAINE'
                      ? '🔵 HORS'
                      : null;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedClasses[className] = !isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: groupColor.withValues(alpha: 0.2),
                        border: Border(
                          right: BorderSide(
                            color: groupColor.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                          bottom: BorderSide(
                            color: groupColor.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            size: 18,
                          ),
                          Expanded(
                            child: Text(
                              className,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeLabel != null)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor?.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: badgeColor!),
                              ),
                              child: Text(
                                badgeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                } else if (item is StudentEntity) {
                  final student = item;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: groupColor.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        bottom: BorderSide(
                          color: groupColor.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      '${student.lastName.toUpperCase()} ${student.firstName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumns(
    BuildContext context,
    List<dynamic> listItems,
    List<AttendanceEntity> attendances,
    Color groupColor,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _columns.fold<double>(
            0.0,
            (sum, col) => sum + _getColumnWidth(col),
          ),
          child: Column(
            children: [
              // Header Row (Reorderable)
              SizedBox(
                height: 50,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: _columns.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _columns.removeAt(oldIndex);
                      _columns.insert(newIndex, item);
                    });
                    _saveColumnOrder();
                  },
                  itemBuilder: (context, index) {
                    final col = _columns[index];
                    final width = _getColumnWidth(col);
                    return ReorderableDragStartListener(
                      key: ValueKey(col),
                      index: index,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_expandedColumns.contains(col)) {
                              _expandedColumns.remove(col);
                            } else {
                              _expandedColumns.add(col);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: width,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: groupColor.withValues(alpha: 0.1),
                            border: Border(
                              right: BorderSide(
                                color: groupColor.withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                              bottom: BorderSide(
                                color: groupColor.withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Text(
                            col.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Body Rows
              Expanded(
                child: ListView.builder(
                  controller: _rightScrollController,
                  itemCount: listItems.length,
                  itemExtent: 60,
                  itemBuilder: (context, index) {
                    final item = listItems[index];

                    if (item is Map) {
                      // Class header row background
                      return Container(
                        decoration: BoxDecoration(
                          color: groupColor.withValues(alpha: 0.2),
                          border: Border(
                            bottom: BorderSide(
                              color: groupColor.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    } else if (item is StudentEntity) {
                      final student = item;
                      final todayAtt = attendances
                          .where((a) => a.studentId == student.id)
                          .firstOrNull;

                      return Row(
                        children: _columns.map((col) {
                          // Color the specific day column if it matches selected date weekday
                          // AND has a status. (For now simple matching).
                          Color cellColor = Colors.transparent;
                          final String? status = todayAtt?.computedStatus;

                          // We assume the selectedDate determines presence for the current column view,
                          // or we highlight the specific day column that matches _selectedDate.weekday
                          if (status != null &&
                              status != 'Absent' &&
                              _isColumnMatchingDay(col, _selectedDate)) {
                            if (status == 'Présent') {
                              cellColor = Colors.green.shade700; // Vivid Green
                            } else if (status == 'Stage') {
                              cellColor = Colors.blue.shade700; // Vivid Blue
                            }
                          } else if (status == 'Absent' &&
                              _isColumnMatchingDay(col, _selectedDate)) {
                            cellColor = Colors.red.shade700; // Vivid Red
                          }

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              // Only trigger status modal for Day columns, not the other structural ones
                              if (col == TableColumn.note) {
                                _showNoteModal(
                                  context,
                                  student,
                                  attendances,
                                  groupColor,
                                );
                                return;
                              }

                              if (col == TableColumn.chambre) {
                                return;
                              }

                              _showStatusModal(context, student, attendances);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _getColumnWidth(col),
                              decoration: BoxDecoration(
                                color: cellColor,
                                border: Border(
                                  right: BorderSide(
                                    color: groupColor.withValues(alpha: 0.8),
                                    width: 1.5,
                                  ),
                                  bottom: BorderSide(
                                    color: groupColor.withValues(alpha: 0.8),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _buildCellContent(col, student, todayAtt),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getColumnWidth(TableColumn col) {
    if (col == TableColumn.classe) return 80;
    if (col == TableColumn.chambre) return 70;
    if (col == TableColumn.note) return 120;
    // if (col == TableColumn.checkbox) return 80;
    // Days columns
    return _expandedColumns.contains(col) ? 60.0 : 20.0;
  }

  Widget _buildCellContent(
    TableColumn col,
    StudentEntity student,
    AttendanceEntity? attendance,
  ) {
    if (col == TableColumn.classe) {
      return Text(
        student.className,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      );
    }
    if (col == TableColumn.chambre) {
      return Text(student.roomNumber);
    }
    if (col == TableColumn.note) {
      final text = attendance?.note ?? '';
      if (text.isEmpty) return const SizedBox.shrink();
      final display = text.length > 15 ? '${text.substring(0, 15)}...' : text;
      return Text(
        display,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      );
    }
    // Days - Show high contrast icon if status is present
    if (_isColumnMatchingDay(col, _selectedDate)) {
      final status = attendance?.computedStatus;
      if (status == 'Présent') {
        return const Icon(Icons.check, color: Colors.white, size: 20);
      } else if (status == 'Absent') {
        return const Icon(Icons.close, color: Colors.white, size: 20);
      } else if (status == 'Stage') {
        return const Icon(Icons.work_outline, color: Colors.white, size: 18);
      }
    }
    return const SizedBox.shrink();
  }

  bool _isColumnMatchingDay(TableColumn col, DateTime date) {
    if (col == TableColumn.lundi && date.weekday == DateTime.monday) {
      return true;
    }
    if (col == TableColumn.mardi && date.weekday == DateTime.tuesday) {
      return true;
    }
    if (col == TableColumn.mercredi && date.weekday == DateTime.wednesday) {
      return true;
    }
    if (col == TableColumn.jeudi && date.weekday == DateTime.thursday) {
      return true;
    }
    if (col == TableColumn.vendredi && date.weekday == DateTime.friday) {
      return true;
    }
    if (col == TableColumn.samedi && date.weekday == DateTime.saturday) {
      return true;
    }
    if (col == TableColumn.dimanche && date.weekday == DateTime.sunday) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Color parsedColor = Colors.blueGrey;
    if (widget.groupColorHex != null && widget.groupColorHex!.isNotEmpty) {
      try {
        final hex = widget.groupColorHex!.replaceAll('#', '');
        // Try 'FF' + RRGGBB format (used by group_selection_view)
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        try {
          // Fallback: try 0xFF + RRGGBB format
          parsedColor = Color(
            int.parse('0xFF${widget.groupColorHex!.replaceAll("#", "")}'),
          );
        } catch (_) {
          // Keep default
        }
      }
    }

    final String formattedDate = DateFormat(
      "'Aujourd''hui,' EEEE d MMMM",
      'fr_FR',
    ).format(DateTime.now());

    return BlocProvider(
      create: (context) =>
          getIt<AttendanceBloc>()
            ..add(LoadAttendance(widget.groupId, _selectedDate)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Appel: ${widget.groupName}',
            style: TextStyle(color: parsedColor, fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                formattedDate,
                style: context.textTheme.titleMedium?.copyWith(
                  color: parsedColor,
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
            IconButton(
              icon: const Icon(Icons.file_upload),
              tooltip: 'Importation massive',
              onPressed: () => _showBulkImportBottomSheet(context, parsedColor),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'clear_students') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Vider la liste ?'),
                      content: Text(
                        'Tous les élèves du groupe "${widget.groupName}" seront supprimés définitivement. Cette action est irréversible.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Vider'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    try {
                      // Use getIt directly: StudentBloc is not in AttendanceTablePage tree
                      await getIt<DeleteStudentsByGroupUseCase>()(
                        widget.groupId,
                      );
                    } catch (_) {}
                    if (context.mounted) {
                      context.read<AttendanceBloc>().add(
                        LoadAttendance(widget.groupId, _selectedDate),
                      );
                    }
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'clear_students',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Vider les élèves',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AttendanceError) {
              return Center(child: Text(state.message));
            } else if (state is AttendanceLoaded) {
              // Group students by class, with period status
              final Map<String, List<StudentEntity>> studentsByClass = {};
              for (final student in state.students) {
                final cName = student.className.isEmpty
                    ? 'Sans classe'
                    : student.className;

                // Calendar filtering: skip if class is not PRESENT and not _showAll
                if (!_showAll && _periods.isNotEmpty) {
                  final status = StagePeriodService.classStatusOn(
                    cName,
                    _selectedDate,
                    _periods,
                  );
                  if (status == 'HORS_QUINZAINE' || status == 'STAGE') {
                    // Still add, but with badge — handled in header rendering
                  }
                }
                studentsByClass.putIfAbsent(cName, () => []).add(student);
              }
              final sortedClasses = studentsByClass.keys.toList()..sort();

              final List<dynamic> listItems = [];
              for (final cName in sortedClasses) {
                // Compute class status
                final classStatus = _periods.isEmpty
                    ? 'PRESENT'
                    : StagePeriodService.classStatusOn(
                        cName,
                        _selectedDate,
                        _periods,
                      );

                // Skip entire class if not showAll and class is hidden
                if (!_showAll &&
                    _periods.isNotEmpty &&
                    classStatus != 'PRESENT') {
                  // Don't add to listItems — class is hidden
                  continue;
                }

                // Pass a Map as header so we can render badge
                listItems.add({'class': cName, 'status': classStatus});
                final isExpanded = _expandedClasses[cName] ?? true;
                if (isExpanded) {
                  listItems.addAll(studentsByClass[cName]!);
                }
              }

              // Reset scroll controllers if needed, but best not to touch on rebuild
              return Row(
                children: [
                  _buildLeftColumn(
                    context,
                    listItems,
                    state.attendances,
                    parsedColor,
                  ),
                  _buildRightColumns(
                    context,
                    listItems,
                    state.attendances,
                    parsedColor,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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
                  child: AddStudentForm(groupId: widget.groupId),
                );
              },
            ).then((_) {
              // Reload students when sheet closes
              if (context.mounted) {
                context.read<AttendanceBloc>().add(
                  LoadAttendance(widget.groupId, _selectedDate),
                );
              }
            });
          },
          backgroundColor: parsedColor,
          child: Icon(
            Icons.person_add,
            color: parsedColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
