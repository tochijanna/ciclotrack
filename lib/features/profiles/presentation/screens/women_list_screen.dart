import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/women_repository.dart';
import '../providers/women_providers.dart';
import '../widgets/woman_card.dart';
import 'woman_form_screen.dart';
import '../../../tracking/presentation/screens/tracking_screen.dart';
import '../../../encounters/presentation/screens/encounter_form_screen.dart';
import '../../../encounters/presentation/screens/encounters_screen.dart';

class WomenListScreen extends ConsumerWidget {
  const WomenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(womenListProvider);
    final filter = ref.watch(womenFilterProvider);
    final tagsAsync = ref.watch(availableTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CicloTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(womenListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por etiquetas
          tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('Todas'),
                        selected: filter == null,
                        onSelected: (_) =>
                            ref.read(womenFilterProvider.notifier).clear(),
                      ),
                    ),
                    ...tags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(tag),
                          selected: filter == tag,
                          onSelected: (_) => ref
                              .read(womenFilterProvider.notifier)
                              .setFilter(tag),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Lista de perfiles
          Expanded(
            child: profilesAsync.when(
              data: (profiles) {
                if (profiles.isEmpty) {
                  return EmptyWomenView(
                    onAdd: () => _navigateToForm(context, ref),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(womenListProvider.notifier).refresh(),
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: profiles.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final ordered = profiles.map((p) => p.woman).toList();
                      final item = ordered.removeAt(oldIndex);
                      ordered.insert(newIndex, item);
                      ref.read(womenListProvider.notifier).reorder(ordered);
                    },
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      return WomanCard(
                        key: ValueKey(profile.woman.id),
                        profile: profile,
                        onTap: () => _navigateToTracking(context, profile),
                        onEdit: () =>
                            _navigateToForm(context, ref, profile: profile),
                        onLongPress: () =>
                            _confirmDelete(context, ref, profile),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  void _showAddMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Nuevo perfil'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToForm(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Nuevo encuentro'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EncounterFormScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Ver encuentros'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EncountersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(
    BuildContext context,
    WidgetRef ref, {
    WomanProfile? profile,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WomanFormScreen(profile: profile)),
    );
  }

  void _navigateToTracking(BuildContext context, WomanProfile profile) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrackingScreen(profile: profile)));
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WomanProfile profile,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text(
          '¿Eliminar a ${profile.woman.name}? Se borrarán todos sus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(womenListProvider.notifier).deleteProfile(profile.woman.id);
      }
    });
  }
}
