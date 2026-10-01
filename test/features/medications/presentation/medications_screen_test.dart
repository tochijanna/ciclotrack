import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/medications/presentation/screens/medication_form_screen.dart';
import 'package:ciclotrack/features/medications/presentation/screens/medications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

void main() {
  testWidgets('agrupa por mujer, desactiva y borra medicamentos', (
    tester,
  ) async {
    final db = createTestDatabase();
    try {
      final ana = await seedWoman(tester, db, name: 'Ana');
      final bea = await seedWoman(tester, db, name: 'Bea');
      await tester.runAsync(() async {
        await db
            .into(db.medications)
            .insert(
              MedicationsCompanion.insert(
                womanId: ana,
                name: 'Hierro',
                hour: 23,
                minute: 59,
              ),
            );
        await db
            .into(db.medications)
            .insert(
              MedicationsCompanion.insert(
                womanId: bea,
                name: 'Vitamina',
                hour: 8,
                minute: 5,
              ),
            );
      });
      await pumpScreen(
        tester,
        db,
        const MedicationsScreen(),
        overrides: [fixedClock(DateTime(2026, 9, 10))],
      );
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Bea'), findsOneWidget);
      expect(find.text('Hierro'), findsOneWidget);
      expect(find.text('23:59 · Activo'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Ana')).dy,
        lessThan(tester.getTopLeft(find.text('Hierro')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Hierro')).dy,
        lessThan(tester.getTopLeft(find.text('Bea')).dy),
      );

      await tester.tap(find.byKey(const ValueKey('enabled_1')));
      await settleProviders(tester);
      expect(find.text('23:59 · Inactivo'), findsOneWidget);
      final enabled = await runReal(
        tester,
        () async => (await db.select(db.medications).get()).first.enabled,
      );
      expect(enabled, false);

      await tester.tap(find.byTooltip('Eliminar medicamento').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await settleProviders(tester);
      expect(find.text('Hierro'), findsNothing);
      expect(find.text('Vitamina'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      await closeTestDatabase(tester, db);
    }
  });

  testWidgets('formulario valida, crea y edita con repositorio', (
    tester,
  ) async {
    final db = createTestDatabase();
    try {
      await seedWoman(tester, db, name: 'María');
      await pumpScreen(tester, db, const MedicationsScreen());
      await tester.tap(find.byTooltip('Añadir medicamento'));
      await settleProviders(tester);
      await tester.tap(find.text('Guardar'));
      await tester.pump();
      expect(find.text('Selecciona una mujer'), findsOneWidget);
      expect(find.text('Introduce el nombre del medicamento'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('María').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Hierro');
      await tester.enterText(find.byType(TextFormField).at(1), '20 mg');
      await tester.tap(find.text('Guardar'));
      await settleProviders(tester);
      await tester.pumpAndSettle();
      expect(find.byType(MedicationFormScreen), findsNothing);
      expect(find.text('Hierro'), findsOneWidget);
      await tester.tap(find.text('Hierro'));
      await settleProviders(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'Vitamina');
      await tester.tap(find.text('Guardar'));
      await settleProviders(tester);
      await tester.pumpAndSettle();
      expect(find.text('Vitamina'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      await closeTestDatabase(tester, db);
    }
  });
}
