import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/tracking/presentation/screens/tracking_screen.dart';

import '../../../support/widget_harness.dart';

void main() {
  late AppDatabase db;

  testWidgets('TrackingScreen renders prediction card and empty timeline', (
    tester,
  ) async {
    db = createTestDatabase();
    final profile = await seedProfile(tester, db, name: 'María');

    await pumpScreen(tester, db, TrackingScreen(profile: profile));

    expect(find.text('María'), findsWidgets);
    expect(find.text('Sin registros'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('TrackingScreen shows prediction and period in timeline', (
    tester,
  ) async {
    db = createTestDatabase();
    final profile = await seedProfile(tester, db, name: 'Ana');
    await seedPeriod(
      tester,
      db,
      womanId: profile.woman.id,
      startDate: DateTime(2026, 9, 1),
    );

    await pumpScreen(tester, db, TrackingScreen(profile: profile));

    expect(find.textContaining('Periodo'), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('TrackingScreen deletes an event after confirmation', (
    tester,
  ) async {
    db = createTestDatabase();
    final profile = await seedProfile(tester, db, name: 'Sofía');
    await seedPeriod(
      tester,
      db,
      womanId: profile.woman.id,
      startDate: DateTime(2026, 9, 1),
    );

    await pumpScreen(tester, db, TrackingScreen(profile: profile));

    // El card de predicción puede empujar el evento fuera de pantalla.
    final periodoFinder = find.text('Periodo');
    if (periodoFinder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        periodoFinder,
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
    }
    await tester.longPress(periodoFinder);
    await pumpStreams(tester);
    expect(find.text('Eliminar registro'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await pumpStreams(tester);

    expect(find.text('Sin registros'), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.periodLogs).get()),
      isEmpty,
    );

    await closeTestDatabase(tester, db);
  });
}
