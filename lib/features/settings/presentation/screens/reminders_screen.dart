import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reminder_text.dart';
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
    final l10n = AppLocalizations.of(context);
    final remindersAsync = ref.watch(remindersByWomanProvider(womanId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersOf(womanName))),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) return const _EmptyRemindersView();
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final range = reminderRangeLabel(l10n, reminder);
              return ListTile(
                key: ValueKey('reminder_${reminder.id}'),
                title: Text(reminder.message),
                subtitle: Text(
                  reminder.enabled
                      ? range
                      : '$range · ${l10n.reminderDisabled}',
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
                      tooltip: l10n.delete,
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
        error: (_, _) => Center(child: Text(l10n.remindersLoadError)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.remindersNew),
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
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(reminderRepositoryProvider).setEnabled(reminder, enabled);
    if (enabled) await ensureReminderPermission(ref, messenger, l10n);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CycleReminder reminder,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.remindersDeleteTitle),
        content: Text(l10n.remindersDeleteBody(reminder.message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context);
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
              l10n.remindersEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.remindersEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
