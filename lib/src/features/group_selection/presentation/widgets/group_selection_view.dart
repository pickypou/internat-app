import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_state.dart';
import '../bloc/group_event.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/theme/theme_ext.dart';

class GroupSelectionView extends StatelessWidget {
  const GroupSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/images/inb.png',
                height: 120, // Adjust size as appropriate for the logo
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mes groupes',
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez un groupe pour voir les élèves',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  if (state is GroupsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GroupsError) {
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
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GroupBloc>().add(LoadGroups());
                            },
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GroupsLoaded) {
                    if (state.groups.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun groupe disponible',
                          style: context.textTheme.bodyLarge,
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ), // Space for FAB
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                          ),
                      itemCount: state.groups.length,
                      itemBuilder: (context, index) {
                        final group = state.groups[index];
                        return _GroupCard(
                          name: group.name,
                          colorHex: group.color,
                          onTap: () {
                            // Navigation to group details will be added here
                          },
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
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String name;
  final String colorHex;
  final VoidCallback onTap;

  const _GroupCard({
    required this.name,
    required this.colorHex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    try {
      cardColor = Color(int.parse('FF$colorHex', radix: 16));
    } catch (e) {
      cardColor = context.colorScheme.primaryContainer;
    }

    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group, color: cardColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
