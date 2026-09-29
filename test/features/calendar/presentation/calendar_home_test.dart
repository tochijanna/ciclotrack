import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/calendar/domain/day_mark.dart';
import 'package:ciclotrack/features/calendar/presentation/screens/calendar_home_screen.dart';
import 'package:ciclotrack/features/calendar/presentation/widgets/day_marks.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  Future<int> seedAnaConPeriodo(WidgetTester tester, AppDatabase db) async {
    final id = await seedWoman(tester, db, name: 'Ana');
    await seedPeriod(
      tester,
      db,
      womanId: id,
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 5),
    );
    return id;
  }

  DayMarks marksOf(WidgetTester tester, DateTime day) => tester
      .widgetList<DayMarks>(find.byType(DayMarks))
      .firstWhere(
        (widget) =>
            widget.day.year == day.year &&
            widget.day.month == day.month &&
            widget.day.day == day.day,
      );

  testWidgets('renderiza las pestañas Semana y Mes con la cuadrícula', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await pumpScreen(
      tester,
      db,
      const CalendarHomeScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 14))],
    );

    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Mes'), findsOneWidget);
    expect(
      tester
          .widgetList<TableCalendar<DayMark>>(
            find.byType(TableCalendar<DayMark>),
          )
          .map((calendar) => calendar.calendarFormat),
      contains(CalendarFormat.week),
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('marca la menstruación de la semana visible', (tester) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await pumpScreen(
      tester,
      db,
      const CalendarHomeScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 3))],
    );

    expect(
      marksOf(tester, DateTime(2026, 9, 1)).marks.single.kind,
      DayMarkKind.menstruacion,
    );
    expect(
      marksOf(tester, DateTime(2026, 9, 1)).marks.single.esEstimado,
      isFalse,
    );
    expect(find.text('Menstruación'), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('marca la ovulación estimada de hoy', (tester) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await pumpScreen(
      tester,
      db,
      const CalendarHomeScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 14))],
    );

    expect(
      marksOf(tester, DateTime(2026, 9, 14)).marks.single.kind,
      DayMarkKind.ovulacion,
    );
    expect(find.text('Ovulación'), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('el panel sigue al día seleccionado', (tester) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await pumpScreen(
      tester,
      db,
      const CalendarHomeScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 14))],
    );

    await tester.tap(find.text('16'));
    await tester.pump();

    expect(find.text('Ventana fértil'), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('la pestaña Mes usa el formato mensual y el mes en español', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedAnaConPeriodo(tester, db);

    await pumpScreen(
      tester,
      db,
      const CalendarHomeScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 14))],
    );

    await tester.tap(find.text('Mes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester
          .widgetList<TableCalendar<DayMark>>(
            find.byType(TableCalendar<DayMark>),
          )
          .map((calendar) => calendar.calendarFormat),
      contains(CalendarFormat.month),
    );
    expect(find.textContaining('septiembre'), findsWidgets);

    await closeTestDatabase(tester, db);
  });

  testWidgets('sin perfiles muestra el estado vacío', (tester) async {
    final db = createTestDatabase();

    await pumpScreen(
      tester,
      db,
      const CalendarHomeScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 14))],
    );

    expect(
      find.text('Sin perfiles. Crea uno para ver el calendario.'),
      findsWidgets,
    );

    await closeTestDatabase(tester, db);
  });
}
