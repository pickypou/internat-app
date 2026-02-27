import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import '../../../../shared/theme/group_theme.dart';
import '../../../../shared/theme/theme_ext.dart';
import '../../../../shared/widgets/custom_button.dart';

class CreateGroupForm extends StatefulWidget {
  const CreateGroupForm({super.key});

  @override
  State<CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColorIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_nameController.text.trim().isEmpty) return;

    final selectedColor = GroupTheme.accentColors[_selectedColorIndex];
    // .toARGB32() returns the 32bit int representation which replaces .value getter.
    final selectedHex = selectedColor
        .toARGB32()
        .toRadixString(16)
        .substring(2)
        .toUpperCase();

    context.read<GroupBloc>().add(
      CreateGroup(name: _nameController.text.trim(), color: selectedHex),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colors = GroupTheme.accentColors;

    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is GroupsLoaded) {
          Navigator.of(context).pop();
        } else if (state is GroupsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colorScheme.error,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nouveau Groupe',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Nom du groupe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.colorScheme.surface,
              ),
              // Ensure we trigger a re-build when text changes to validate the button
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text(
              'Couleur d\'accentuation',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(colors.length, (index) {
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorIndex = index;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colors[index].withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            BlocBuilder<GroupBloc, GroupState>(
              builder: (context, state) {
                final isLoading = state is GroupsLoading;
                final bool isDisabled = _nameController.text.trim().isEmpty;

                return CustomButton(
                  text: 'Créer',
                  onPressed: isDisabled || isLoading
                      ? null
                      : () => _submit(context),
                  isLoading: isLoading,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
