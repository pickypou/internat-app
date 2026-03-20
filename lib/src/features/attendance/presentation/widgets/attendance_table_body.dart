import 'package:flutter/material.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import 'attendance_table_widget.dart';

class AttendanceTableBody extends StatefulWidget {
  final List<StudentEntity> students;
  final List<AttendanceEntity> attendances;
  final Color groupColor;
  final DateTime selectedDate;
  final List<TableColumn> columns;
  final Set<TableColumn> expandedColumns;
  final bool sortByClass;
  final bool isPoleSup;
  final void Function(TableColumn, StudentEntity) onCellTap;
  final void Function(StudentEntity) onNameTap;
  final void Function(int, int) onReorder;
  final void Function(TableColumn) onColumnToggle;

  const AttendanceTableBody({
    super.key,
    required this.students,
    required this.attendances,
    required this.groupColor,
    required this.selectedDate,
    required this.columns,
    required this.expandedColumns,
    this.sortByClass = false,
    this.isPoleSup = false,
    required this.onCellTap,
    required this.onNameTap,
    required this.onReorder,
    required this.onColumnToggle,
  });

  @override
  State<AttendanceTableBody> createState() => _AttendanceTableBodyState();
}

class _AttendanceTableBodyState extends State<AttendanceTableBody> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _leftVerticalController = ScrollController();
  final ScrollController _rightVerticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Link vertical controllers
    _leftVerticalController.addListener(() {
      if (_rightVerticalController.hasClients && _rightVerticalController.offset != _leftVerticalController.offset) {
        _rightVerticalController.jumpTo(_leftVerticalController.offset);
      }
    });
    _rightVerticalController.addListener(() {
      if (_leftVerticalController.hasClients && _leftVerticalController.offset != _rightVerticalController.offset) {
        _leftVerticalController.jumpTo(_rightVerticalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _leftVerticalController.dispose();
    _rightVerticalController.dispose();
    super.dispose();
  }

  double _getColumnWidth(TableColumn col) {
    if (col == TableColumn.classe) return 80;
    if (col == TableColumn.chambre) return 70;
    if (col == TableColumn.note) return 120;
    return widget.expandedColumns.contains(col) ? 60.0 : 20.0;
  }

  bool _isColumnMatchingDay(TableColumn col, DateTime date) {
    if (col == TableColumn.lundi && date.weekday == DateTime.monday) return true;
    if (col == TableColumn.mardi && date.weekday == DateTime.tuesday) return true;
    if (col == TableColumn.mercredi && date.weekday == DateTime.wednesday) return true;
    if (col == TableColumn.jeudi && date.weekday == DateTime.thursday) return true;
    if (col == TableColumn.vendredi && date.weekday == DateTime.friday) return true;
    if (col == TableColumn.samedi && date.weekday == DateTime.saturday) return true;
    if (col == TableColumn.dimanche && date.weekday == DateTime.sunday) return true;
    return false;
  }

  Widget _buildCellContent(TableColumn col, StudentEntity student, AttendanceEntity? attendance) {
    if (col == TableColumn.classe) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(student.className, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
      );
    }
    if (col == TableColumn.chambre) {
      return Text(student.roomNumber);
    }
    if (col == TableColumn.note) {
      final text = attendance?.note ?? '';
      if (text.isEmpty) return const SizedBox.shrink();
      final display = text.length > 15 ? '${text.substring(0, 15)}...' : text;
      return Text(display, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12));
    }
    if (_isColumnMatchingDay(col, widget.selectedDate)) {
      final status = attendance?.computedStatus;
      if (status == 'Présent') return const Icon(Icons.check, color: Colors.white, size: 20);
      if (status == 'Absent') return const Icon(Icons.close, color: Colors.white, size: 20);
      if (status == 'Absent Justifié') return const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18);
      if (status == 'Stage') return const Icon(Icons.work_outline, color: Colors.white, size: 18);
    }
    return const SizedBox.shrink();
  }

  final Map<String, bool> _expansionStates = {};

  Color _getSectionColor(String key) {
    if (key == 'BTS') return const Color(0xFF1976D2); // Blue
    if (key == 'ALT 1') return const Color(0xFF388E3C); // Green
    if (key == 'ALT 2') return const Color(0xFF7B1FA2); // Purple
    return widget.groupColor;
  }

  @override
  Widget build(BuildContext context) {
    // Group students
    final Map<String, List<StudentEntity>> sections = {};
    List<String> sortedKeys = [];

    if (widget.isPoleSup) {
      // Pôle-Sup logic: Group by 'Alt'
      const catBTS = 'BTS';
      const catAlt1 = 'ALT 1';
      const catAlt2 = 'ALT 2';

      sections[catBTS] = [];
      sections[catAlt1] = [];
      sections[catAlt2] = [];

      for (var s in widget.students) {
        final alt = s.alt?.trim();
        if (alt == 'Alt1') {
          sections[catAlt1]!.add(s);
        } else if (alt == 'Alt2') {
          sections[catAlt2]!.add(s);
        } else {
          sections[catBTS]!.add(s);
        }
      }
      // Sort within each group by Name
      for (var key in sections.keys) {
        sections[key]!.sort((a, b) => a.lastName.compareTo(b.lastName));
      }
      sortedKeys = [catBTS, catAlt1, catAlt2];
    } else if (widget.sortByClass) {
      for (var s in widget.students) {
        final key = s.className.isEmpty ? 'Sans classe' : s.className;
        sections.putIfAbsent(key, () => []).add(s);
      }
      sortedKeys = sections.keys.toList()..sort();
    } else {
      sections['Tous les élèves'] = widget.students;
      sortedKeys = ['Tous les élèves'];
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Left Column: Fixed Header + Names ---
        SizedBox(
          width: 140,
          child: Column(
            children: [
              _buildLeftHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _leftVerticalController,
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, idx) {
                    final key = sortedKeys[idx];
                    final students = sections[key]!;
                    if (students.isEmpty) return const SizedBox.shrink();

                    if (widget.isPoleSup) {
                      final isExpanded = _expansionStates[key] ?? true;
                      final sectionColor = _getSectionColor(key);
                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: ValueKey('left_${key}_$isExpanded'),
                          initiallyExpanded: isExpanded,
                          onExpansionChanged: (val) => setState(() => _expansionStates[key] = val),
                          title: SizedBox(
                            height: 20,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(key, style: TextStyle(fontWeight: FontWeight.bold, color: sectionColor, fontSize: 12)),
                            ),
                          ),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                          children: students.map((s) => _buildNameCell(s)).toList(),
                        ),
                      );
                    }
                    return _buildLeftSection(key, students);
                  },
                ),
              ),
            ],
          ),
        ),
        
        // --- Right Columns: Scrollable Header Matrix + Cell Matrix ---
        Expanded(
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: widget.columns.fold<double>(0.0, (sum, col) => sum + _getColumnWidth(col)),
              child: Column(
                children: [
                  _buildRightHeader(),
                  Expanded(
                    child: ListView.builder(
                      controller: _rightVerticalController,
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, idx) {
                        final key = sortedKeys[idx];
                        final students = sections[key]!;
                        if (students.isEmpty) return const SizedBox.shrink();

                    if (widget.isPoleSup) {
                      final isExpanded = _expansionStates[key] ?? true;
                      final sectionColor = _getSectionColor(key);
                      // Summary data for section
                      final studentIds = students.map((s) => s.id).toSet();
                      final sectionAttendances = widget.attendances.where((a) => studentIds.contains(a.studentId)).toList();
                      final presentCount = sectionAttendances.where((a) => a.isPresentEvening).length;

                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: ValueKey('right_${key}_$isExpanded'),
                          initiallyExpanded: isExpanded,
                          onExpansionChanged: (val) => setState(() => _expansionStates[key] = val),
                          title: SizedBox(
                            height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: sectionColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('$presentCount / ${students.length}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sectionColor)),
                                ),
                              ],
                            ),
                          ),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                          visualDensity: VisualDensity.compact,
                          children: students.map((s) => _buildMatrixRow(s)).toList(),
                        ),
                      );
                    }
                        return _buildRightSection(key, students);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftHeader() {
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: widget.groupColor.withValues(alpha: 0.1),
        border: Border(
          right: BorderSide(color: widget.groupColor.withValues(alpha: 0.8), width: 1.5),
          bottom: BorderSide(color: widget.groupColor.withValues(alpha: 0.8), width: 1.5),
        ),
      ),
      child: const Text('Élève', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRightHeader() {
    return SizedBox(
      height: 50,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        itemCount: widget.columns.length,
        onReorder: widget.onReorder,
        itemBuilder: (context, index) {
          final col = widget.columns[index];
          final width = _getColumnWidth(col);
          return ReorderableDragStartListener(
            key: ValueKey(col),
            index: index,
            child: GestureDetector(
              onTap: () => widget.onColumnToggle(col),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.groupColor.withValues(alpha: 0.1),
                  border: Border(
                    right: BorderSide(color: widget.groupColor.withValues(alpha: 0.8), width: 1.5),
                    bottom: BorderSide(color: widget.groupColor.withValues(alpha: 0.8), width: 1.5),
                  ),
                ),
                child: Text(col.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftSection(String title, List<StudentEntity> students) {
    return Column(
      children: [
        // Section Header
        Container(
          height: 36,
          color: widget.groupColor.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: widget.groupColor, fontSize: 12)),
        ),
        // Student Names
        ...students.map((s) => _buildNameCell(s)),
      ],
    );
  }

  Widget _buildRightSection(String title, List<StudentEntity> students) {
    // Summary data for section
    final studentIds = students.map((s) => s.id).toSet();
    final sectionAttendances = widget.attendances.where((a) => studentIds.contains(a.studentId)).toList();
    final presentCount = sectionAttendances.where((a) => a.isPresentEvening).length;

    return Column(
      children: [
        // Section Header Summary
        Container(
          height: 36,
          color: widget.groupColor.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: widget.groupColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$presentCount / ${students.length}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.groupColor)),
          ),
        ),
        // Student Matrix Rows
        ...students.map((s) => _buildMatrixRow(s)),
      ],
    );
  }

  Widget _buildNameCell(StudentEntity student) {
    return Container(
      key: ValueKey('name_${student.id}'),
      height: 60,
      padding: const EdgeInsets.only(left: 10, right: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: widget.groupColor, width: 3),
          bottom: BorderSide(color: widget.groupColor.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: () => widget.onNameTap(student),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${student.lastName.toUpperCase()} ${student.firstName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            if (widget.isPoleSup && student.className.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: widget.groupColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(student.className, style: TextStyle(fontSize: 9, color: widget.groupColor, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixRow(StudentEntity student) {
    final todayAtt = widget.attendances.where((a) => a.studentId == student.id).firstOrNull;
    return Row(
      key: ValueKey('row_${student.id}'),
      children: widget.columns.map((col) {
        Color cellColor = Colors.transparent;
        final String? status = todayAtt?.computedStatus;
        final isMatch = _isColumnMatchingDay(col, widget.selectedDate);

        if (status != null && status != 'Absent' && isMatch) {
          if (status == 'Présent') {
            cellColor = Colors.green.withValues(alpha: 0.7);
          } else if (status == 'Stage') {
            cellColor = Colors.blue;
          } else if (status == 'Absent Justifié') {
            cellColor = Colors.orange;
          }
        } else if (status == 'Absent' && isMatch) {
          cellColor = Colors.red.withValues(alpha: 0.8);
        }

        return GestureDetector(
          onTap: () => widget.onCellTap(col, student),
          child: Container(
            width: _getColumnWidth(col),
            height: 60,
            decoration: BoxDecoration(
              color: cellColor,
              border: Border(
                right: BorderSide(color: widget.groupColor.withValues(alpha: 0.8), width: 1.5),
                bottom: BorderSide(color: widget.groupColor.withValues(alpha: 0.3), width: 1),
              ),
            ),
            alignment: Alignment.center,
            child: _buildCellContent(col, student, todayAtt),
          ),
        );
      }).toList(),
    );
  }
}
