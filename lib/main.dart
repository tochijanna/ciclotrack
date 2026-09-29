import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/db/app_database_provider.dart';
import 'features/alerts/presentation/providers/alerts_providers.dart';
import 'features/profiles/presentation/screens/women_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  runApp(const ProviderScope(child: CicloTrackApp()));
}

class CicloTrackApp extends ConsumerWidget {
  const CicloTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDatabaseProvider);
    ref.watch(alertsCoordinatorProvider);
    return MaterialApp(
      title: 'CicloTrack',
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WomenListScreen(),
    );
  }
}
