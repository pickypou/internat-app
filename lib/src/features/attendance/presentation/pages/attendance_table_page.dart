import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../widgets/attendance_table_widget.dart';
import '../../../students/presentation/widgets/add_student_form.dart';
import '../../../students/presentation/bloc/student_bloc.dart';

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
  late DateTime _selectedDate;
  bool _showAll = false;
  int _reloadTrigger = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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

    final String formattedDate = DateFormat(
      "'Aujourd''hui,' EEEE d MMMM",
      'fr_FR',
    ).format(DateTime.now());

    return Scaffold(
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
          const SizedBox(width: 8),
          const SizedBox(width: 8),
        ],
      ),
      body: AttendanceTableWidget(
        groupId: widget.groupId,
        groupName: widget.groupName,
        groupColorHex: widget.groupColorHex,
        selectedDate: _selectedDate,
        showAll: _showAll,
        sortByClass: false,
        reloadTrigger: _reloadTrigger,
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
            if (context.mounted) {
              setState(() {
                _reloadTrigger++;
              });
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
    );
  }
}
