import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
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

import 'attendance_table_body.dart';

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
  final List<TableColumn> _columns = TableColumn.values.toList();
  final Set<TableColumn> _expandedColumns = {};
  List<StagePeriodEntity> _periods = [];
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<AttendanceBloc>();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      if (widget.students == null || widget.attendances == null) {
        _bloc.add(LoadAttendance(widget.groupId, widget.selectedDate));
      }
    }
  }

  @override
  void didUpdateWidget(covariant AttendanceTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.selectedDate != oldWidget.selectedDate ||
            widget.reloadTrigger != oldWidget.reloadTrigger) &&
        (widget.students == null || widget.attendances == null)) {
      context.read<AttendanceBloc>().add(LoadAttendance(widget.groupId, widget.selectedDate));
    }
  }

  Future<void> _loadPeriods() async {
    try {
      final periods = await getIt<GetStagePeriodsUseCase>()();
      if (mounted) setState(() => _periods = periods);
    } catch (_) {}
  }

  @override
  void dispose() {
    // Note: Do NOT close _bloc here as it's provided by an ancestor BlocProvider
    super.dispose();
  }

  void _onCellTap(TableColumn col, StudentEntity student, List<AttendanceEntity> attendances, Color color) {
    if (col == TableColumn.note) {
      _showNoteModal(context, student, attendances, color);
    } else if (col != TableColumn.chambre && col != TableColumn.classe) {
      _showStatusModal(context, student, attendances);
    }
  }

  void _showStatusModal(BuildContext context, StudentEntity student, List<AttendanceEntity> attendances) {
    final todayAttendance = attendances.where((a) => a.studentId == student.id).firstOrNull;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _bloc,
        child: StatusModal(
          student: student,
          currentAttendance: todayAttendance,
          groupId: student.groupId,
          date: widget.selectedDate,
          isPoleSup: widget.isPoleSup,
        ),
      ),
    );
  }

  void _showNoteModal(BuildContext context, StudentEntity student, List<AttendanceEntity> attendances, Color groupColor) {
    final todayAtt = attendances.where((a) => a.studentId == student.id).firstOrNull;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _bloc,
        child: StudentEditSheet(
          student: student,
          currentAttendance: todayAtt,
          groupId: student.groupId,
          date: widget.selectedDate,
          groupColor: groupColor,
          isPoleSup: widget.isPoleSup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color parsedColor = Colors.blueGrey;
    if (widget.groupColorHex?.isNotEmpty ?? false) {
      try {
        final hex = widget.groupColorHex!.replaceAll('#', '');
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
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

          final listItems = students.where((student) {
            if (widget.showAll || _periods.isEmpty) return true;
            final status = StagePeriodService.classStatusOn(
              student.className.isEmpty ? 'Sans classe' : student.className,
              widget.selectedDate,
              _periods,
            );
            return status != 'STAGE';
          }).toList()..sort((a, b) {
            if (widget.sortByClass) {
              final classA = a.className.isEmpty ? 'ZZZ' : a.className;
              final classB = b.className.isEmpty ? 'ZZZ' : b.className;
              final comp = classA.compareTo(classB);
              if (comp != 0) return comp;
            }
            final last = a.lastName.compareTo(b.lastName);
            return last != 0 ? last : a.firstName.compareTo(b.firstName);
          });

          if (listItems.isEmpty) return const Center(child: Text('Aucun élève à afficher'));

          return AttendanceTableBody(
            students: listItems,
            attendances: attendances,
            groupColor: parsedColor,
            selectedDate: widget.selectedDate,
            columns: _columns,
            expandedColumns: _expandedColumns,
            sortByClass: widget.sortByClass,
            isPoleSup: widget.isPoleSup,
            onCellTap: (col, s) => _onCellTap(col, s, attendances, parsedColor),
            onNameTap: (s) => _showNoteModal(context, s, attendances, parsedColor),
            onColumnToggle: (col) => setState(() {
              if (_expandedColumns.contains(col)) {
                _expandedColumns.remove(col);
              } else {
                _expandedColumns.add(col);
              }
            }),
            onReorder: (oldIndex, newIndex) => setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _columns.removeAt(oldIndex);
              _columns.insert(newIndex, item);
            }),
          );
        },
      ),
    );
  }
}
