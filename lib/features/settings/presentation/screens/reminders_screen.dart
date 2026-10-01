import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/reminder_validators.dart';
import '../providers/reminder_providers.dart';
import 'reminder_form_screen.dart';

/// Recordatorios personalizados de una mujer.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({
    super.key,
    required this.womanId,
    required this.womanName,
  });

  final int womanId;
  final String womanName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersByWomanProvider(womanId));

    return Scaffold(
      appBar: AppBar(title: Text('Recordatorios de $womanName')),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) return const _EmptyRemindersView();
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return ListTile(
                key: ValueKey('reminder_${reminder.id}'),
                title: Text(reminder.message),
                subtitle: Text(
                  reminder.enabled
                      ? reminder.rangeLabel
                      : '${reminder.rangeLabel} · Desactivado',
                ),
                onTap: () => _openForm(context, reminder: reminder),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: reminder.enabled,
                      onChanged: (value) =>
                          _toggle(context, ref, reminder, value),
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, reminder),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('No se pudieron cargar los recordatorios'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo recordatorio'),
      ),
    );
  }

  void _openForm(BuildContext context, {CycleReminder? reminder}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ReminderFormScreen(womanId: womanId, reminder: reminder),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    CycleReminder reminder,
    bool enabled,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(reminderRepositoryProvider).setEnabled(reminder, enabled);
    if (enabled) await ensureReminderPermission(ref, messenger);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CycleReminder reminder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: Text('¿Eliminar "${reminder.message}"?'),
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
    );
    if (confirmed != true) return;
    await ref.read(reminderRepositoryProvider).delete(reminder.id);
  }
}

class _EmptyRemindersView extends StatelessWidget {
  const _EmptyRemindersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_repeat_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin recordatorios',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea un aviso para unos días concretos del ciclo',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
