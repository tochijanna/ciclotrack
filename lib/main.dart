import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/app_database_provider.dart';
import 'features/profiles/presentation/screens/women_list_screen.dart';

void main() {
  runApp(const ProviderScope(child: CicloTrackApp()));
}

class CicloTrackApp extends ConsumerWidget {
  const CicloTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDatabaseProvider);
    return MaterialApp(
      title: 'CicloTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WomenListScreen(),
    );
  }
}
