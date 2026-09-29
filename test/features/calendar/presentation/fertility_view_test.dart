import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/calendar/presentation/screens/calendar_home_screen.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  Future<void> seedAnaConPeriodo(WidgetTester tester, AppDatabase db) async {
    final id = await seedWoman(tester, db, name: 'Ana');
    await seedPeriod(
      tester,
      db,
      womanId: id,
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 5),
    );
  }

  Future<void> openFertility(
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
    await tester.tap(find.text('Fertilidad'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('lista la ventana fértil que intersecta la semana en curso', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await openFertility(tester, db, DateTime(2026, 9, 14));

    expect(find.textContaining('Semana del'), findsOneWidget);
    expect(find.text('Ana'), findsWidgets);
    expect(find.textContaining('9 sept'), findsWidgets);
    expect(find.textContaining('Ovulación: 14 sept'), findsOneWidget);
    expect(find.textContaining('En curso, termina en 2 días'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('avisa cuando la ventana aún no ha empezado', (tester) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await openFertility(tester, db, DateTime(2026, 9, 8));

    expect(find.textContaining('Empieza mañana'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('muestra el estado vacío si no hay ventana esta semana', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await openFertility(tester, db, DateTime(2026, 9, 21));

    expect(
      find.text('Ninguna mujer en ventana fértil esta semana.'),
      findsOneWidget,
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('marca como estimada la ventana de un ciclo proyectado', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await openFertility(tester, db, DateTime(2026, 10, 5));

    expect(find.text('estimada'), findsOneWidget);
    expect(find.textContaining('7 oct'), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('no lista mujeres sin registros', (tester) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Bea');

    await openFertility(tester, db, DateTime(2026, 9, 14));

    expect(
      find.text('Ninguna mujer en ventana fértil esta semana.'),
      findsOneWidget,
    );

    await closeTestDatabase(tester, db);
  });
}
