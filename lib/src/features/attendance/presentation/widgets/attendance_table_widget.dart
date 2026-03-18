import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import 'status_modal.dart';
import '../../../students/presentation/widgets/student_edit_sheet.dart';
import '../../../stages/domain/entities/stage_period_entity.dart';
import '../../../stages/domain/services/stage_period_service.dart';
import '../../../stages/domain/usecases/get_stage_periods_usecase.dart';

enum TableColumn {
  classe('Classe'),
  chambre('Chambre'),
  lundi('Lun'),
  mardi('Mar'),
  mercredi('Mer'),
  jeudi('Jeu'),
  vendredi('Ven'),
  samedi('Sam'),
  dimanche('Dim'),
  note('Note');

  final String label;
  const TableColumn(this.label);
}

class AttendanceTableWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupColorHex;
  final DateTime selectedDate;
  final bool showAll;
  final bool sortByClass;
  final int reloadTrigger;
  final bool isPoleSup;

  const AttendanceTableWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupColorHex,
    required this.selectedDate,
    this.showAll = false,
    this.sortByClass = false,
    this.reloadTrigger = 0,
    this.isPoleSup = false,
    this.students,
    this.attendances,
  });

  final List<StudentEntity>? students;
  final List<AttendanceEntity>? attendances;

  @override
  State<AttendanceTableWidget> createState() => _AttendanceTableWidgetState();
}

class _AttendanceTableWidgetState extends State<AttendanceTableWidget> {
  late AttendanceBloc _bloc;

  final ScrollController _leftScrollController = ScrollController();
  final ScrollController _rightScrollController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  bool _isScrolling = false;

  final List<TableColumn> _columns = TableColumn.values.toList();
  final Set<TableColumn> _expandedColumns = {};
  List<StagePeriodEntity> _periods = [];

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AttendanceBloc>();
    if (widget.students == null || widget.attendances == null) {
      _bloc.add(LoadAttendance(widget.groupId, widget.selectedDate));
    }
    _loadPeriods();

    _leftScrollController.addListener(() {
      if (_isScrolling) return;
      _isScrolling = true;
      if (_rightScrollController.hasClients) {
        _rightScrollController.jumpTo(_leftScrollController.offset);
      }
      _isScrolling = false;
    });

    _rightScrollController.addListener(() {
      if (_isScrolling) return;
      _isScrolling = true;
      if (_leftScrollController.hasClients) {
        _leftScrollController.jumpTo(_rightScrollController.offset);
      }
      _isScrolling = false;
    });
  }

  @override
  void didUpdateWidget(covariant AttendanceTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.selectedDate != oldWidget.selectedDate ||
            widget.reloadTrigger != oldWidget.reloadTrigger) &&
        (widget.students == null || widget.attendances == null)) {
      _bloc.add(LoadAttendance(widget.groupId, widget.selectedDate));
    }
  }

  Future<void> _loadPeriods() async {
    try {
      final periods = await getIt<GetStagePeriodsUseCase>()();
      if (mounted) setState(() => _periods = periods);
    } catch (_) {
      // Pas bloquant — on continue sans filtrage
    }
  }

  @override
  void dispose() {
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    _horizontalController.dispose();
    _bloc.close();
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
          value: _bloc,
          child: StatusModal(
            student: student,
            currentAttendance: todayAttendance,
            groupId: student.groupId, // Use real student group ID
            date: widget.selectedDate,
            isPoleSup: widget.isPoleSup,
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
          value: _bloc,
          child: StudentEditSheet(
            student: student,
            currentAttendance: todayAtt,
            groupId: student.groupId, // Use real student group ID
            date: widget.selectedDate,
            groupColor: groupColor,
            isPoleSup: widget.isPoleSup,
          ),
        );
      },
    );
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
          Expanded(
            child: ListView.builder(
              controller: _leftScrollController,
              itemCount: listItems.length,
              itemExtent: 60,
              itemBuilder: (context, index) {
                final item = listItems[index];

                if (item is StudentEntity) {
                  return Container(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: groupColor, width: 3),
                        bottom: BorderSide(
                          color: groupColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _showNoteModal(
                        context,
                        item,
                        attendances,
                        groupColor,
                      ),
                      child: Text(
                        '${item.lastName.toUpperCase()} ${item.firstName}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
              Expanded(
                child: ListView.builder(
                  controller: _rightScrollController,
                  itemCount: listItems.length,
                  itemExtent: 60,
                  itemBuilder: (context, index) {
                    final item = listItems[index];

                    if (item is StudentEntity) {
                      final student = item;
                      final todayAtt = attendances
                          .where((a) => a.studentId == student.id)
                          .firstOrNull;

                      return Row(
                        children: _columns.map((col) {
                          Color cellColor = Colors.transparent;
                          final String? status = todayAtt?.computedStatus;

                          if (status != null &&
                              status != 'Absent' &&
                              _isColumnMatchingDay(col, widget.selectedDate)) {
                            if (status == 'Présent') {
                              cellColor = Colors.green.shade700;
                            } else if (status == 'Stage') {
                              cellColor = Colors.blue.shade700;
                            } else if (status == 'Absent Justifié') {
                              cellColor = Colors.orange.shade700;
                            }
                          } else if (status == 'Absent' &&
                              _isColumnMatchingDay(col, widget.selectedDate)) {
                            cellColor = Colors.red.shade700;
                          }

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
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
    return _expandedColumns.contains(col) ? 60.0 : 20.0;
  }

  Widget _buildCellContent(
    TableColumn col,
    StudentEntity student,
    AttendanceEntity? attendance,
  ) {
    if (col == TableColumn.classe) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          student.className,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
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
    if (_isColumnMatchingDay(col, widget.selectedDate)) {
      final status = attendance?.computedStatus;
      if (status == 'Présent') {
        return const Icon(Icons.check, color: Colors.white, size: 20);
      } else if (status == 'Absent') {
        return const Icon(Icons.close, color: Colors.white, size: 20);
      } else if (status == 'Absent Justifié') {
        return const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
          size: 18,
        );
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
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        try {
          parsedColor = Color(
            int.parse('0xFF${widget.groupColorHex!.replaceAll("#", "")}'),
          );
        } catch (_) {}
      }
    }

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          List<StudentEntity> students;
          List<AttendanceEntity> attendances;

          if (widget.students != null && widget.attendances != null) {
            students = widget.students!;
            attendances = widget.attendances!;
          } else if (state is AttendanceLoaded) {
            students = state.students;
            attendances = state.attendances;
          } else if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }

          final List<StudentEntity> listItems = students.where((student) {
            if (widget.showAll || _periods.isEmpty) return true;
            final status = StagePeriodService.classStatusOn(
              student.className.isEmpty ? 'Sans classe' : student.className,
              widget.selectedDate,
              _periods,
            );
            return status != 'STAGE';
          }).toList()
            ..sort((a, b) {
              if (widget.sortByClass) {
                final classA = a.className.isEmpty ? 'ZZZ' : a.className;
                final classB = b.className.isEmpty ? 'ZZZ' : b.className;
                final classCompare = classA.compareTo(classB);
                if (classCompare != 0) return classCompare;
              }
              final last = a.lastName.compareTo(b.lastName);
              return last != 0 ? last : a.firstName.compareTo(b.firstName);
            });

          if (listItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Aucun élève à afficher',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return Row(
            children: [
              _buildLeftColumn(
                context,
                listItems,
                attendances,
                parsedColor,
              ),
              _buildRightColumns(
                context,
                listItems,
                attendances,
                parsedColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
