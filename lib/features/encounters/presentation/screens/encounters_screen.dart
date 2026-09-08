import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/encounter_providers.dart';
import '../widgets/encounter_card.dart';
import 'encounter_form_screen.dart';

class EncountersScreen extends ConsumerWidget {
  const EncountersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encountersAsync = ref.watch(allEncountersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuentros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allEncountersProvider),
          ),
        ],
      ),
      body: encountersAsync.when(
        data: (encounters) {
          if (encounters.isEmpty) {
            return EmptyEncountersView(onAdd: () => _navigateToForm(context));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allEncountersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: encounters.length,
              itemBuilder: (context, index) {
                final encounter = encounters[index];
                return EncounterCard(
                  key: ValueKey(encounter.encounterId),
                  encounter: encounter,
                  onTap: () => _navigateToForm(
                    context,
                    encounterId: encounter.encounterId,
                  ),
                  onLongPress: () =>
                      _confirmDelete(context, ref, encounter.encounterId),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {int? encounterId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EncounterFormScreen(encounterId: encounterId),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int encounterId) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar encuentro'),
        content: const Text('¿Eliminar este encuentro?'),
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
    ).then((confirmed) async {
      if (confirmed != true) return;
      final repo = ref.read(encounterRepositoryProvider);
      await repo.delete(encounterId);
      ref.invalidate(allEncountersProvider);
    });
  }
}
