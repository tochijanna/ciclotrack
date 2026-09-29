import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/calendar/presentation/screens/calendar_home_screen.dart';
import 'package:ciclotrack/features/encounters/presentation/widgets/encounter_card.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  Future<void> openEncounters(
    WidgetTester tester,
    AppDatabase db,
    DateTime today,
  ) async {
    await pumpScreen(
      tester,
      db,
      const CalendarHomeScreen(),
      overrides: [fixedClock(today)],
    );
    await tester.ensureVisible(find.text('Encuentros'));
    await tester.tap(find.text('Encuentros'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('lista los encuentros y filtra por mujer', (tester) async {
    final db = createTestDatabase();
    final ana = await seedWoman(tester, db, name: 'Ana');
    final bea = await seedWoman(tester, db, name: 'Bea');
    final ambos = await seedEncounter(
      tester,
      db,
      womanIds: [ana, bea],
      encounterTime: DateTime(2026, 9, 14, 21, 30),
      protection: 'Condón',
    );
    final soloAna = await seedEncounter(
      tester,
      db,
      womanIds: [ana],
      encounterTime: DateTime(2026, 10, 5, 20),
      protection: 'Ninguno',
    );

    await openEncounters(tester, db, DateTime(2026, 9, 14));

    expect(find.byType(EncounterCard), findsNWidgets(2));
    expect(find.text('Todas (2)'), findsOneWidget);
    expect(find.text('Ana (2)'), findsOneWidget);
    expect(find.text('Bea (1)'), findsOneWidget);
    expect(
      tester
          .widgetList<EncounterCard>(find.byType(EncounterCard))
          .map((card) => card.encounter.encounterId),
      [soloAna, ambos],
    );

    await tester.tap(find.text('Bea (1)'));
    await tester.pump();

    final filtrado = tester.widget<EncounterCard>(find.byType(EncounterCard));
    expect(filtrado.encounter.encounterId, ambos);
    expect(
      filtrado.encounter.participants.map((p) => p.womanName),
      contains('Bea'),
    );

    await tester.tap(find.text('Todas (2)'));
    await tester.pump();
    expect(find.byType(EncounterCard), findsNWidgets(2));

    await closeTestDatabase(tester, db);
  });

  testWidgets('muestra la protección y las participantes de cada encuentro', (
    tester,
  ) async {
    final db = createTestDatabase();
    final ana = await seedWoman(tester, db, name: 'Ana');
    final bea = await seedWoman(tester, db, name: 'Bea');
    await seedEncounter(
      tester,
      db,
      womanIds: [ana, bea],
      encounterTime: DateTime(2026, 9, 14, 21, 30),
      protection: 'Condón',
    );

    await openEncounters(tester, db, DateTime(2026, 9, 14));

    expect(find.text('Ana: Vaginal'), findsOneWidget);
    expect(find.text('Bea: Vaginal'), findsOneWidget);
    expect(find.text('Condón'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('avisa cuando la mujer filtrada no tiene encuentros', (
    tester,
  ) async {
    final db = createTestDatabase();
    final ana = await seedWoman(tester, db, name: 'Ana');
    await seedWoman(tester, db, name: 'Bea');
    await seedEncounter(
      tester,
      db,
      womanIds: [ana],
      encounterTime: DateTime(2026, 9, 14, 21, 30),
    );

    await openEncounters(tester, db, DateTime(2026, 9, 14));

    await tester.ensureVisible(find.text('Bea (0)'));
    await tester.tap(find.text('Bea (0)'));
    await tester.pump();

    expect(find.text('Sin encuentros con Bea.'), findsOneWidget);
    expect(find.byType(EncounterCard), findsNothing);

    await closeTestDatabase(tester, db);
  });

  testWidgets('sin encuentros muestra el estado vacío', (tester) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Ana');

    await openEncounters(tester, db, DateTime(2026, 9, 14));

    expect(find.text('Sin encuentros registrados.'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });
}
