import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ciclotrack/features/backup/presentation/screens/backup_screen.dart';
import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  testWidgets('abre la copia de seguridad desde la lista de perfiles', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Ana');

    await pumpScreen(
      tester,
      db,
      const WomenListScreen(),
      overrides: [fixedClock(DateTime(2026, 9, 30, 21, 15))],
    );

    await tester.tap(find.byIcon(Icons.backup_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(BackupScreen), findsOneWidget);
    expect(find.text('Copia de seguridad'), findsOneWidget);
    expect(find.text('Restaurar desde JSON'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });
}
