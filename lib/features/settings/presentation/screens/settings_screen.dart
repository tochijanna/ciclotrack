import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../calendar/presentation/screens/calendar_home_screen.dart';
import '../../../medications/presentation/screens/medications_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../providers/app_lock_provider.dart';
import '../providers/discreet_notices_provider.dart';

/// Versión publicada en `pubspec.yaml`; se actualiza a la vez que aquella.
const appVersion = '1.2.0+4';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appLock = ref.watch(appLockProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(l10n.settingsSectionGeneral),
          ListTile(
            leading: const Icon(Icons.medication_outlined),
            title: Text(l10n.settingsMedication),
            subtitle: Text(l10n.settingsMedicationSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const MedicationsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsAlerts),
            subtitle: Text(l10n.settingsAlertsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const AlertsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.settingsBackup),
            subtitle: Text(l10n.settingsBackupSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const BackupScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: Text(l10n.settingsReports),
            subtitle: Text(l10n.settingsReportsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const ReportsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(l10n.settingsViews),
            subtitle: Text(l10n.settingsViewsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const CalendarHomeScreen()),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsSectionSecurity),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: Text(l10n.settingsAppLockTitle),
            subtitle: Text(
              appLock.supported
                  ? l10n.settingsAppLockSupported
                  : l10n.settingsAppLockUnavailable,
            ),
            value: appLock.enabled,
            onChanged: appLock.supported
                ? (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    final saved = await ref
                        .read(appLockProvider.notifier)
                        .setEnabled(value);
                    if (!saved) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.settingsAppLockSaveError)),
                      );
                    }
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: Text(l10n.settingsDiscreetNoticesTitle),
            subtitle: Text(l10n.settingsDiscreetNoticesSubtitle),
            value: ref.watch(discreetNoticesProvider),
            onChanged: (value) =>
                ref.read(discreetNoticesProvider.notifier).setEnabled(value),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('CicloTrack'),
            subtitle: Text(l10n.settingsVersion(appVersion)),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.settingsLocalTitle),
            subtitle: Text(l10n.settingsLocalSubtitle),
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
