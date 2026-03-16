import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_state.dart';
import '../bloc/group_event.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/theme/theme_ext.dart';
import 'package:go_router/go_router.dart';
import '../../../students/domain/usecases/get_all_students_usecase.dart';

class GroupSelectionView extends StatelessWidget {
  const GroupSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            // ── En-tête : logo + titre (scrolle avec le reste) ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Image.asset(
                        'assets/images/inb.png',
                        height: 120,
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
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── États loading / error ──
            if (state is GroupsLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is GroupsError)
              SliverFillRemaining(
                child: Center(
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
                        onPressed: () =>
                            context.read<GroupBloc>().add(LoadGroups()),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              )
            else if (state is GroupsLoaded) ...[
              if (state.groups.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucun groupe disponible',
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                )
              else ...[
                // ── Carte spéciale Appel Dimanche ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GroupCard(
                        name: '🌙 Appel Dimanche',
                        colorHex: 'FF6D00',
                        groupId: kAppelDimancheGroupId,
                        onTap: () {
                          context.push(
                            '/group/$kAppelDimancheGroupId',
                            extra: {
                              'name': 'Appel Dimanche',
                              'color': 'FF6D00',
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ── Navigation Principale (Lycée / Pôle-Sup) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height:
                              140, // Match the height roughly of childAspectRatio 1.1 but full width
                          child: _GroupCard(
                            name: '🏫 Lycée',
                            colorHex: '1976D2', // Un bleu standard
                            onTap: () {
                              context.push('/lycee');
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: _GroupCard(
                            name: '🎓 Pôle-Sup',
                            colorHex: '388E3C', // Un vert pour Pôle-Sup
                            onTap: () {
                              context.push('/pole-sup');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String name;
  final String colorHex;
  final VoidCallback onTap;
  final String? groupId; // null for virtual groups without a real DB id

  const _GroupCard({
    required this.name,
    required this.colorHex,
    required this.onTap,
    this.groupId,
  });

  void _showManagementSheet(BuildContext context, Color cardColor) {
    final isVirtual = groupId == null || groupId == kAppelDimancheGroupId;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: cardColor,
                  ),
                ),
              ),
              if (!isVirtual)
                ListTile(
                  leading: Icon(Icons.edit, color: cardColor),
                  title: const Text('Renommer le groupe'),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    final controller = TextEditingController(text: name);
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Renommer le groupe'),
                        content: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Nouveau nom',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(controller.text.trim()),
                            child: const Text('Renommer'),
                          ),
                        ],
                      ),
                    );
                    if (newName != null &&
                        newName.isNotEmpty &&
                        context.mounted) {
                      context.read<GroupBloc>().add(
                        RenameGroup(groupId!, newName),
                      );
                    }
                  },
                ),
              if (!isVirtual)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Supprimer le groupe',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Supprimer ce groupe ?'),
                        content: Text(
                          'Le groupe "$name" sera supprimé définitivement (les élèves seront conservés).',
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
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      context.read<GroupBloc>().add(DeleteGroup(groupId!));
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

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
      onLongPress: () => _showManagementSheet(context, cardColor),
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
