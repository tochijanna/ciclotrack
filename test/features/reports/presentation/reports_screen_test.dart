import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/reports/presentation/screens/reports_screen.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  final hoy = DateTime(2026, 9, 14);

  /// Ana con tres periodos (dos ciclos de 28 días), síntomas y encuentros.
  Future<int> seedAna(WidgetTester tester, AppDatabase db) async {
    final id = await seedWoman(tester, db, name: 'Ana');
    for (var i = 2; i >= 0; i--) {
      final inicio = DateTime(2026, 9, 1 - i * 28);
      await seedPeriod(
        tester,
        db,
        womanId: id,
        startDate: inicio,
        endDate: DateTime(inicio.year, inicio.month, inicio.day + 4),
      );
    }
    await seedSymptom(
      tester,
      db,
      womanId: id,
      date: DateTime(2026, 9, 10),
      type: 'Acné',
    );
    await seedSymptom(
      tester,
      db,
      womanId: id,
      date: DateTime(2026, 9, 12),
      type: 'Acné',
    );
    await seedSymptom(
      tester,
      db,
      womanId: id,
      date: DateTime(2026, 9, 11),
      type: 'Cansancio',
    );
    await seedEncounter(
      tester,
      db,
      womanIds: [id],
      encounterTime: DateTime(2026, 9, 14, 21),
      protection: 'Ninguno',
    );
    return id;
  }

  Future<void> pumpReports(WidgetTester tester, AppDatabase db) => pumpScreen(
    tester,
    db,
    const ReportsScreen(),
    overrides: [fixedClock(hoy)],
  );

  testWidgets('muestra los indicadores globales y los gráficos', (
    tester,
  ) async {
    final db = createTestDatabase();
    final ana = await seedAna(tester, db);
    final bea = await seedWoman(tester, db, name: 'Bea');
    await seedPeriod(
      tester,
      db,
      womanId: bea,
      startDate: DateTime(2026, 9, 10),
      endDate: DateTime(2026, 9, 14),
    );
    await seedEncounter(
      tester,
      db,
      womanIds: [ana, bea],
      encounterTime: DateTime(2026, 9, 13, 21),
      protection: 'Condón',
    );

    await pumpReports(tester, db);

    expect(find.text('Global'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Ana'), findsOneWidget);
    expect(find.text('Perfiles'), findsOneWidget);
    expect(find.text('Ciclos registrados'), findsOneWidget);
    expect(find.text('Encuentros'), findsWidgets);
    expect(find.text('50 %'), findsOneWidget);
    expect(find.text('Ana'), findsWidgets);

    expect(find.byType(BarChart), findsWidgets);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.textContaining('días fértiles'), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('al elegir una mujer muestra su informe', (tester) async {
    final db = createTestDatabase();
    await seedAna(tester, db);

    await pumpReports(tester, db);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ana'));
    await tester.pump();

    expect(find.text('Global'), findsNothing);
    expect(find.text('Evolución del ciclo'), findsOneWidget);
    expect(find.text('Síntomas recurrentes'), findsOneWidget);
    expect(find.text('Próximo periodo'), findsOneWidget);
    expect(find.text('29 sept'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(BarChart), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('con un solo ciclo avisa de que faltan datos para la línea', (
    tester,
  ) async {
    final db = createTestDatabase();
    final id = await seedWoman(tester, db, name: 'Sol');
    await seedPeriod(
      tester,
      db,
      womanId: id,
      startDate: DateTime(2026, 9, 10),
      endDate: DateTime(2026, 9, 14),
    );

    await pumpReports(tester, db);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sol'));
    await tester.pump();

    expect(
      find.textContaining('Hacen falta al menos dos ciclos'),
      findsOneWidget,
    );
    expect(find.byType(LineChart), findsNothing);

    await closeTestDatabase(tester, db);
  });

  testWidgets('sin datos avisa en síntomas y protección', (tester) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Sol');

    await pumpReports(tester, db);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sol'));
    await tester.pump();

    expect(
      find.text('Sin síntomas registrados en los últimos 12 meses.'),
      findsOneWidget,
    );
    expect(
      find.text('Sin encuentros registrados en los últimos 12 meses.'),
      findsOneWidget,
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('sin perfiles muestra el estado vacío', (tester) async {
    final db = createTestDatabase();

    await pumpReports(tester, db);

    expect(
      find.text('Sin perfiles. Crea uno para ver los reportes.'),
      findsOneWidget,
    );

    await closeTestDatabase(tester, db);
  });
}
