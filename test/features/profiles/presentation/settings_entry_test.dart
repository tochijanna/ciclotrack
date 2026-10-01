import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ciclotrack/features/profiles/presentation/screens/women_list_screen.dart';
import 'package:ciclotrack/features/settings/presentation/screens/settings_screen.dart';

import '../../../support/widget_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  testWidgets('abre los ajustes desde la lista de perfiles', (tester) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Ana');

    await pumpScreen(
      tester,
      db,
      const WomenListScreen(),
      overrides: [fixedClock(DateTime(2026, 10, 1))],
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.actions, hasLength(2));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Alertas'), findsOneWidget);
    expect(find.text('Copia de seguridad'), findsOneWidget);
    expect(find.text('Informes'), findsOneWidget);
    expect(find.text('Vistas'), findsOneWidget);
    expect(find.text('CicloTrack'), findsOneWidget);
    expect(find.text('Versión 1.0.0+1'), findsOneWidget);
    expect(find.text('100 % local y sin nube'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('el menú de la lista de perfiles reúne el resto de accesos', (
    tester,
  ) async {
    final db = createTestDatabase();
    await seedWoman(tester, db, name: 'Ana');

    await pumpScreen(
      tester,
      db,
      const WomenListScreen(),
      overrides: [fixedClock(DateTime(2026, 10, 1))],
    );

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Vistas'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Copia de seguridad'), findsOneWidget);
    expect(find.text('Alertas'), findsOneWidget);
    expect(find.text('Actualizar'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });
}
