import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';
import 'package:ciclotrack/features/reports/presentation/screens/reports_screen.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  testWidgets('abre los reportes desde la lista de perfiles', (tester) async {
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

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Reportes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ReportsScreen), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Global'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });
}
