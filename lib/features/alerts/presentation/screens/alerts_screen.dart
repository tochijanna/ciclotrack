import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/alert_settings.dart';
import '../../domain/alert_types.dart';
import '../providers/alerts_providers.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(alertSettingsStreamProvider);
    final upcomingAsync = ref.watch(upcomingAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
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
                title: const Text('Alertas activadas'),
                subtitle: const Text(
                  'Activa o desactiva todas las notificaciones',
                ),
                value: settings.masterEnabled,
                onChanged: (v) async {
                  if (v) {
                    final granted = await ref
                        .read(notificationSchedulerProvider)
                        .requestPermission();
                    if (!granted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Permiso de notificaciones no concedido',
                            ),
                          ),
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
                  title: const Text('Hora de notificación'),
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
                    'Tipos de alerta',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...allAlertTypes.map((type) {
                  final enabled = enabledTypes.contains(type);
                  return CheckboxListTile(
                    title: Text(alertTypeLabel(type)),
                    subtitle: Text(
                      alertTypeDescription(type),
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
                    'Próximas alertas',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                upcomingAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay alertas programadas para los próximos 7 días',
                          style: TextStyle(
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
                          title: Text(item.title),
                          subtitle: Text(item.body),
                          dense: true,
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
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
                          const SnackBar(content: Text('Alertas recalculadas')),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recalcular ahora'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Set<AlertType> _parseEnabledTypes(String csv) {
    return AlertSettings.enabledTypesFromCsv(csv);
  }
}
