import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_draft.dart';
import 'package:ciclotrack/features/encounters/presentation/providers/encounter_providers.dart';
import 'package:ciclotrack/features/encounters/presentation/screens/encounter_form_screen.dart';
import 'package:ciclotrack/features/encounters/presentation/screens/encounters_screen.dart';
import 'package:ciclotrack/features/encounters/presentation/widgets/encounter_card.dart';

import '../../../support/widget_harness.dart';

/// Repositorio que falla al crear encuentros, para cubrir el camino de error.
class _FailingEncounterRepository extends EncounterRepository {
  _FailingEncounterRepository(AppDatabase db) : super(EncounterDao(db));

  @override
  Future<int> create(EncounterDraft draft) async {
    throw Exception('fallo simulado del repositorio');
  }
}

/// Pulsa el botón de guardado del cuerpo del formulario.
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

Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(await _saveButton(tester, 'Registrar encuentro'));
  await pumpStreams(tester);
}

void main() {
  late AppDatabase db;

  testWidgets('encounters screen renders the empty state', (tester) async {
    db = createTestDatabase();
    await pumpScreen(tester, db, const EncountersScreen());

    expect(find.text('Sin encuentros'), findsOneWidget);
    expect(find.text('Registrar encuentro'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('encounters screen lists the encounter with its participants', (
    tester,
  ) async {
    db = createTestDatabase();
    final first = await seedWoman(tester, db, name: 'María');
    final second = await seedWoman(tester, db, name: 'Ana');
    await seedEncounter(tester, db, womanIds: [first, second]);

    await pumpScreen(tester, db, const EncountersScreen());

    expect(find.byType(EncounterCard), findsOneWidget);
    expect(find.textContaining('María'), findsWidgets);
    expect(find.textContaining('Ana'), findsWidgets);
    expect(find.text('Condón'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('encounters screen deletes an encounter after confirmation', (
    tester,
  ) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await seedEncounter(tester, db, womanIds: [womanId]);

    await pumpScreen(tester, db, const EncountersScreen());
    await tester.longPress(find.byType(EncounterCard));
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar este encuentro?'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await pumpStreams(tester);

    expect(find.text('Sin encuentros'), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.encounters).get()),
      isEmpty,
    );
    expect(
      await runReal(tester, () => db.select(db.encounterWomen).get()),
      isEmpty,
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('encounters screen keeps the encounter when deletion is '
      'cancelled', (tester) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await seedEncounter(tester, db, womanIds: [womanId]);

    await pumpScreen(tester, db, const EncountersScreen());
    await tester.longPress(find.byType(EncounterCard));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await pumpStreams(tester);

    expect(find.byType(EncounterCard), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.encounters).get()),
      hasLength(1),
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('encounter form saves multiple participants', (tester) async {
    db = createTestDatabase();
    await seedWoman(tester, db, name: 'María');
    await seedWoman(tester, db, name: 'Ana');
    await pumpScreen(tester, db, const EncounterFormScreen());

    await tester.tap(find.textContaining('María'));
    await tester.tap(find.textContaining('Ana'));
    await tester.pump();
    await _tapSave(tester);

    expect(
      await runReal(tester, () => db.select(db.encounters).get()),
      hasLength(1),
    );
    expect(
      await runReal(tester, () => db.select(db.encounterWomen).get()),
      hasLength(2),
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('encounter form requires at least one participant', (
    tester,
  ) async {
    db = createTestDatabase();
    await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, const EncounterFormScreen());

    await _tapSave(tester);

    expect(
      find.textContaining('Debe haber al menos una participante'),
      findsOneWidget,
    );
    expect(find.byType(EncounterFormScreen), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.encounters).get()),
      isEmpty,
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('encounter form inserts a single encounter on a double tap', (
    tester,
  ) async {
    db = createTestDatabase();
    await seedWoman(tester, db, name: 'María');
    await pumpScreen(tester, db, const EncounterFormScreen());

    await tester.tap(find.textContaining('María'));
    await tester.pump();

    final button = await _saveButton(tester, 'Registrar encuentro');
    await tester.tap(button);
    await tester.tap(button, warnIfMissed: false);
    await pumpStreams(tester);

    expect(
      await runReal(tester, () => db.select(db.encounters).get()),
      hasLength(1),
    );
    expect(
      await runReal(tester, () => db.select(db.encounterWomen).get()),
      hasLength(1),
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('encounter form keeps the form and warns when the repository '
      'fails', (tester) async {
    db = createTestDatabase();
    await seedWoman(tester, db, name: 'María');
    await pumpScreen(
      tester,
      db,
      const EncounterFormScreen(),
      overrides: [
        encounterRepositoryProvider.overrideWithValue(
          _FailingEncounterRepository(db),
        ),
      ],
    );

    await tester.tap(find.textContaining('María'));
    await tester.pump();
    await _tapSave(tester);

    expect(find.text('No se pudo guardar el encuentro'), findsOneWidget);
    expect(find.byType(EncounterFormScreen), findsOneWidget);
    expect(
      await runReal(tester, () => db.select(db.encounters).get()),
      isEmpty,
    );

    await closeTestDatabase(tester, db);
  });
}
