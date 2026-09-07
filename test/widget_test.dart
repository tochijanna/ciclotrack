import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const CicloTrackApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('CicloTrack'), findsOneWidget);
    expect(find.text('Bienvenido a CicloTrack'), findsOneWidget);
  });
}
