import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_event.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_validators.dart';
import 'package:ciclotrack/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:ciclotrack/features/tracking/presentation/screens/ovulation_form_screen.dart';
import 'package:ciclotrack/features/tracking/presentation/screens/period_form_screen.dart';
import 'package:ciclotrack/features/tracking/presentation/screens/symptom_form_screen.dart';

import '../../../support/widget_harness.dart';

/// Repositorio que falla al crear periodos, para cubrir el camino de error.
class _FailingTrackingRepository extends TrackingRepository {
  _FailingTrackingRepository(AppDatabase db) : super(TrackingDao(db));

  @override
  Future<int> createPeriod(int womanId, PeriodDraft draft) async {
    throw Exception('fallo simulado del repositorio');
  }
}

/// Pulsa el botón Guardar del cuerpo de la pantalla.
///
/// El botón vive al final de un `SingleChildScrollView`: hay que asegurarlo,
/// dejar rehacer el layout y solo entonces pulsarlo, o el evento cae fuera de
/// la posición real del botón.
Future<Finder> _saveButton(WidgetTester tester, String label) async {
  final button = find.ancestor(
    of: find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.text(label),
    ),
    matching: find.byWidgetPredicate((widget) => widget is FilledButton),
  );
  await tester.ensureVisible(button);
  await tester.pump();
  return button;
}

Future<void> _tapSave(WidgetTester tester, String label) async {
  await tester.tap(await _saveButton(tester, label));
  await pumpStreams(tester);
}

void main() {
  late AppDatabase db;
  late int womanId;

  // --- Periodo ---

  testWidgets('period form saves one normalized period', (tester) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, PeriodFormScreen(womanId: womanId));

    await _tapSave(tester, 'Registrar periodo');

    final periods = await runReal(tester, () => db.select(db.periodLogs).get());
    expect(periods, hasLength(1));
    expect(periods.single.womanId, womanId);
    expect(periods.single.startDate, calendarDate(DateTime.now()));
    expect(periods.single.endDate, isNull);

    await closeTestDatabase(tester, db);
  });

  testWidgets('period form updates an existing period', (tester) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    final periodId = await seedPeriod(
      tester,
      db,
      womanId: womanId,
      startDate: DateTime(2026, 9, 1),
    );

    await pumpScreen(
      tester,
      db,
      PeriodFormScreen(
        womanId: womanId,
        event: TrackingEvent.period(
          id: periodId,
          womanId: womanId,
          startDate: DateTime(2026, 9, 1),
        ),
      ),
    );

    await _tapSave(tester, 'Guardar cambios');

    final periods = await runReal(tester, () => db.select(db.periodLogs).get());
    expect(periods, hasLength(1));
    expect(periods.single.id, periodId);
    expect(periods.single.startDate, DateTime(2026, 9, 1));

    await closeTestDatabase(tester, db);
  });

  testWidgets('period form inserts a single period on a double tap', (
    tester,
  ) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, PeriodFormScreen(womanId: womanId));

    final button = await _saveButton(tester, 'Registrar periodo');
    await tester.tap(button);
    await tester.tap(button, warnIfMissed: false);
    await pumpStreams(tester);

    final periods = await runReal(tester, () => db.select(db.periodLogs).get());
    expect(periods, hasLength(1));

    await closeTestDatabase(tester, db);
  });

  testWidgets(
    'period form keeps the form and warns when the repository fails',
    (tester) async {
      db = createTestDatabase();
      womanId = await seedWoman(tester, db, name: 'María');
      await pumpScreen(
        tester,
        db,
        PeriodFormScreen(womanId: womanId),
        overrides: [
          trackingRepositoryProvider.overrideWithValue(
            _FailingTrackingRepository(db),
          ),
        ],
      );

      await _tapSave(tester, 'Registrar periodo');

      expect(find.text('No se pudo guardar el periodo'), findsOneWidget);
      expect(find.byType(PeriodFormScreen), findsOneWidget);
      expect(
        await runReal(tester, () => db.select(db.periodLogs).get()),
        isEmpty,
      );

      await closeTestDatabase(tester, db);
    },
  );

  testWidgets('period form rejects an end date before the start date', (
    tester,
  ) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(
      tester,
      db,
      PeriodFormScreen(
        womanId: womanId,
        event: TrackingEvent.period(
          id: 1,
          womanId: womanId,
          startDate: DateTime(2026, 9, 10),
          endDate: DateTime(2026, 9, 5),
        ),
      ),
    );

    await _tapSave(tester, 'Guardar cambios');

    expect(
      find.text('La fecha de fin no puede ser anterior al inicio'),
      findsOneWidget,
    );
    expect(find.byType(PeriodFormScreen), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.periodLogs).get()),
      isEmpty,
    );

    await closeTestDatabase(tester, db);
  });

  // --- Ovulación ---

  testWidgets('ovulation form rejects invalid decimal input', (tester) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, OvulationFormScreen(womanId: womanId));

    await tester.enterText(find.byType(TextField).first, 'abc');
    await _tapSave(tester, 'Registrar ovulación');

    expect(find.textContaining('temperatura válida'), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.ovulationLogs).get()),
      isEmpty,
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('ovulation form accepts a comma decimal separator', (
    tester,
  ) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, OvulationFormScreen(womanId: womanId));

    await tester.enterText(find.byType(TextField).first, '36,5');
    await _tapSave(tester, 'Registrar ovulación');

    final logs = await runReal(tester, () => db.select(db.ovulationLogs).get());
    expect(logs.single.temperature, 36.5);

    await closeTestDatabase(tester, db);
  });

  testWidgets('ovulation form accepts a dot decimal separator', (tester) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, OvulationFormScreen(womanId: womanId));

    await tester.enterText(find.byType(TextField).first, '36.5');
    await _tapSave(tester, 'Registrar ovulación');

    final logs = await runReal(tester, () => db.select(db.ovulationLogs).get());
    expect(logs.single.temperature, 36.5);

    await closeTestDatabase(tester, db);
  });

  testWidgets('ovulation form stores an empty temperature as null', (
    tester,
  ) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, OvulationFormScreen(womanId: womanId));

    await _tapSave(tester, 'Registrar ovulación');

    final logs = await runReal(tester, () => db.select(db.ovulationLogs).get());
    expect(logs, hasLength(1));
    expect(logs.single.temperature, isNull);

    await closeTestDatabase(tester, db);
  });

  testWidgets('ovulation form rejects a temperature out of range', (
    tester,
  ) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, OvulationFormScreen(womanId: womanId));

    await tester.enterText(find.byType(TextField).first, '33');
    await _tapSave(tester, 'Registrar ovulación');

    expect(find.textContaining('temperatura válida'), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.ovulationLogs).get()),
      isEmpty,
    );

    await closeTestDatabase(tester, db);
  });

  // --- Síntomas ---

  testWidgets('symptom form saves the default symptom', (tester) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, SymptomFormScreen(womanId: womanId));

    await _tapSave(tester, 'Registrar síntoma');

    final symptoms = await runReal(tester, () => db.select(db.symptoms).get());
    expect(symptoms, hasLength(1));
    expect(symptoms.single.type, 'Acné');
    expect(symptoms.single.severity, 1);

    await closeTestDatabase(tester, db);
  });

  testWidgets('symptom form saves the selected type and notes', (tester) async {
    db = createTestDatabase();
    womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, SymptomFormScreen(womanId: womanId));

    await tester.tap(find.text('Cansancio'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Todo el día');
    await _tapSave(tester, 'Registrar síntoma');

    final symptoms = await runReal(tester, () => db.select(db.symptoms).get());
    expect(symptoms.single.type, 'Cansancio');
    expect(symptoms.single.notes, 'Todo el día');

    await closeTestDatabase(tester, db);
  });
}
