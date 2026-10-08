import 'package:ciclotrack/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.medicationSaveChangeError)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final medications = ref.watch(medicationsProvider);
    final women = ref.watch(medicationWomenProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicationTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.medicationAdd,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MedicationFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: women.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.medicationProfilesError)),
        data: (profiles) => medications.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.medicationLoadError)),
          data: (items) {
            if (profiles.isEmpty) {
              return Center(child: Text(l10n.medicationNoProfiles));
            }
            if (items.isEmpty) {
              return Center(child: Text(l10n.medicationEmpty));
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
                            medication.enabled ? l10n.active : l10n.inactive,
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
                              tooltip: l10n.medicationDeleteTitle,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(l10n.medicationDeleteTitle),
                                    content: Text(
                                      l10n.medicationDeleteBody(
                                        medication.name,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(l10n.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(l10n.delete),
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
