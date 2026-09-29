import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:ciclotrack/features/calendar/domain/day_mark.dart';
import 'package:ciclotrack/features/calendar/presentation/screens/calendar_home_screen.dart';
import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  testWidgets('abre las vistas consolidadas desde la lista de perfiles', (
    tester,
  ) async {
    final db = createTestDatabase();
    final id = await seedWoman(tester, db, name: 'Ana');
    await seedPeriod(
      tester,
      db,
      womanId: id,
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 5),
    );

    await pumpScreen(
      tester,
      db,
      const WomenListScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 14))],
    );

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CalendarHomeScreen), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Mes'), findsOneWidget);
    expect(find.text('Fertilidad'), findsOneWidget);
    expect(find.text('Encuentros'), findsOneWidget);
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
}
