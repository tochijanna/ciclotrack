import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../calendar/presentation/screens/calendar_home_screen.dart';
import '../../../medications/presentation/screens/medications_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';

/// Versión publicada en `pubspec.yaml`; se actualiza a la vez que aquella.
const appVersion = '1.0.0+1';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          const _SectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.medication_outlined),
            title: const Text('Medicación'),
            subtitle: const Text('Pastillas y horas de aviso, por mujer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const MedicationsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Alertas'),
            subtitle: const Text('Avisos locales y hora de notificación'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const AlertsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Copia de seguridad'),
            subtitle: const Text('Exportar y restaurar los datos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const BackupScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('Informes'),
            subtitle: const Text('Estadísticas y gráficos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const ReportsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Vistas'),
            subtitle: const Text('Calendario, fertilidad y encuentros'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const CalendarHomeScreen()),
          ),
          const Divider(),
          const _SectionHeader('Acerca de'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('CicloTrack'),
            subtitle: Text('Versión $appVersion'),
          ),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('100 % local y sin nube'),
            subtitle: Text(
              'Todos los datos se guardan solo en este dispositivo: '
              'no hay cuentas, sincronización ni servidores.',
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
