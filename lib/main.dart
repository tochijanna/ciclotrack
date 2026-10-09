import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/db/app_database_provider.dart';
import 'core/l10n/app_locale.dart';
import 'features/alerts/presentation/providers/alerts_providers.dart';
import 'features/profiles/presentation/screens/women_list_screen.dart';
import 'features/settings/presentation/providers/app_lock_provider.dart';
import 'features/settings/presentation/providers/reminder_providers.dart';
import 'features/settings/presentation/screens/app_lock_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const ProviderScope(child: CicloTrackApp()));
}

class CicloTrackApp extends ConsumerWidget {
  const CicloTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDatabaseProvider);
    ref.watch(alertsCoordinatorProvider);
    ref.watch(reminderCoordinatorProvider);
    final appLock = ref.watch(appLockProvider);
    final Widget home;
    if (!appLock.ready) {
      // Aún cargando la preferencia: pantalla neutra para no mostrar contenido
      // sensible antes de saber si el bloqueo está activado.
      home = const _LaunchGate();
    } else if (appLock.locked) {
      home = const AppLockScreen();
    } else {
      home = const WomenListScreen();
    }
    return MaterialApp(
      title: 'CicloTrack',
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: home,
    );
  }
}

/// Pantalla neutra mostrada mientras se resuelve la preferencia de bloqueo.
class _LaunchGate extends StatelessWidget {
  const _LaunchGate();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
