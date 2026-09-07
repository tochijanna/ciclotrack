import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/app_database_provider.dart';

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
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CicloTrack')),
      body: const Center(child: Text('Bienvenido a CicloTrack')),
    );
  }
}
