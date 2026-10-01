import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../providers/medication_providers.dart';
import 'medication_form_screen.dart';

String medicationTime(Medication medication) =>
    '${medication.hour.toString().padLeft(2, '0')}:${medication.minute.toString().padLeft(2, '0')}';

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  Future<void> _action(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el cambio')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationsProvider);
    final women = ref.watch(medicationWomenProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Medicación')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir medicamento',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MedicationFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: women.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudieron cargar los perfiles')),
        data: (profiles) => medications.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('No se pudo cargar la medicación')),
          data: (items) {
            if (profiles.isEmpty) {
              return const Center(
                child: Text('Crea un perfil para añadir medicación'),
              );
            }
            if (items.isEmpty) {
              return const Center(
                child: Text('No hay medicamentos registrados'),
              );
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final profile in profiles)
                  if (items.any((m) => m.womanId == profile.woman.id)) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        profile.woman.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    for (final medication in items.where(
                      (m) => m.womanId == profile.woman.id,
                    ))
                      ListTile(
                        key: ValueKey('medication_${medication.id}'),
                        title: Text(medication.name),
                        subtitle: Text(
                          [
                            if (medication.dose.isNotEmpty) medication.dose,
                            medicationTime(medication),
                            medication.enabled ? 'Activo' : 'Inactivo',
                          ].join(' · '),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                MedicationFormScreen(medication: medication),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              key: ValueKey('enabled_${medication.id}'),
                              value: medication.enabled,
                              onChanged: (value) => _action(
                                context,
                                () => ref
                                    .read(medicationRepositoryProvider)
                                    .setEnabled(medication, value),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Eliminar medicamento',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar medicamento'),
                                    content: Text(
                                      '¿Eliminar ${medication.name}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && context.mounted) {
                                  await _action(
                                    context,
                                    () => ref
                                        .read(medicationRepositoryProvider)
                                        .delete(medication.id),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}
