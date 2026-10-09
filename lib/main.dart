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
    final Widget? gate;
    if (!appLock.ready) {
      // Aún cargando la preferencia: pantalla neutra para no mostrar contenido
      // sensible antes de saber si el bloqueo está activado.
      gate = const _LaunchGate();
    } else if (appLock.enabled && !appLock.unlocked) {
      gate = const AppLockScreen();
    } else {
      gate = null;
    }
    return MaterialApp(
      title: 'CicloTrack',
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WomenListScreen(),
      // La puerta va por encima del `Navigator` para tapar también las rutas
      // abiertas (PRIV-02); `Offstage` conserva su estado sin pintarlas ni
      // exponerlas a los lectores de pantalla.
      // ponytail: el botón Atrás aún cierra la ruta oculta de debajo (no se ve
      // nada); interceptarlo exige un `Router`, hacerlo si molesta en uso real.
      builder: (context, child) => Stack(
        children: [
          Offstage(offstage: gate != null, child: child),
          ?gate,
        ],
      ),
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
