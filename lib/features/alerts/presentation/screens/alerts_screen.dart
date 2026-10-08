import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../medications/presentation/screens/medications_screen.dart';
import '../../data/alert_text.dart';
import '../../domain/alert_settings.dart';
import '../../domain/alert_types.dart';
import '../providers/alerts_providers.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(alertSettingsStreamProvider);
    final upcomingAsync = ref.watch(upcomingAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alertsTitle),
        actions: [
          IconButton(
            tooltip: l10n.alertsMedicationTooltip,
            icon: const Icon(Icons.medication_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MedicationsScreen(),
                ),
              );
              if (context.mounted) ref.invalidate(upcomingAlertsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final repo = ref.read(alertsRepositoryProvider);
              await repo.refreshAlerts();
              ref.invalidate(upcomingAlertsProvider);
            },
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final enabledTypes = _parseEnabledTypes(settings.enabledTypes);
          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // Toggle maestro
              SwitchListTile(
                title: Text(l10n.alertsEnabled),
                subtitle: Text(l10n.alertsEnabledSubtitle),
                value: settings.masterEnabled,
                onChanged: (v) async {
                  if (v) {
                    final granted = await ref
                        .read(notificationSchedulerProvider)
                        .requestPermission();
                    if (!granted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.alertsPermissionDenied)),
                        );
                      }
                      return;
                    }
                  }
                  await ref
                      .read(alertsRepositoryProvider)
                      .updateMasterEnabled(v);
                  await ref.read(alertsCoordinatorProvider).refreshNow();
                  ref.invalidate(upcomingAlertsProvider);
                },
              ),
              if (settings.masterEnabled) ...[
                const Divider(),
                // Hora de notificación
                ListTile(
                  title: Text(l10n.alertsNotifyTime),
                  subtitle: Text(
                    '${settings.notifyHour.toString().padLeft(2, '0')}:${settings.notifyMinute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.notifyHour,
                        minute: settings.notifyMinute,
                      ),
                    );
                    if (time != null) {
                      await ref
                          .read(alertsRepositoryProvider)
                          .updateNotifyTime(time.hour, time.minute);
                      await ref.read(alertsCoordinatorProvider).refreshNow();
                      ref.invalidate(upcomingAlertsProvider);
                    }
                  },
                ),
                const Divider(),
                // Toggles por tipo
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    l10n.alertsTypesTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...allAlertTypes.map((type) {
                  final enabled = enabledTypes.contains(type);
                  return CheckboxListTile(
                    title: Text(alertTypeLabel(l10n, type)),
                    subtitle: Text(
                      alertTypeDescription(l10n, type),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: enabled,
                    onChanged: (v) async {
                      final updated = Set<AlertType>.from(enabledTypes);
                      if (v == true) {
                        updated.add(type);
                      } else {
                        updated.remove(type);
                      }
                      await ref
                          .read(alertsRepositoryProvider)
                          .updateEnabledTypes(updated);
                      await ref.read(alertsCoordinatorProvider).refreshNow();
                      ref.invalidate(upcomingAlertsProvider);
                    },
                  );
                }),
                const Divider(),
                // Próximas alertas
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    l10n.alertsUpcomingTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                upcomingAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.alertsUpcomingEmpty,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: items.map((item) {
                        return ListTile(
                          leading: const Text(
                            '⚠️',
                            style: TextStyle(fontSize: 20),
                          ),
                          title: Text(alertTypeLabel(l10n, item.type)),
                          subtitle: Text(alertBody(l10n, item.message)),
                          dense: true,
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('${l10n.errorLabel}: $e'),
                ),
                const SizedBox(height: 16),
                // Botón recalcular
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.icon(
                    onPressed: () async {
                      final repo = ref.read(alertsRepositoryProvider);
                      await repo.refreshAlerts();
                      ref.invalidate(upcomingAlertsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.alertsRecalculated)),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.alertsRecalculate),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorLabel}: $e')),
      ),
    );
  }

  Set<AlertType> _parseEnabledTypes(String csv) {
    return AlertSettings.enabledTypesFromCsv(csv);
  }
}
