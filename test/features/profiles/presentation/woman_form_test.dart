import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/profiles/domain/woman_options.dart';
import 'package:ciclotrack/features/profiles/presentation/providers/women_providers.dart';
import 'package:ciclotrack/features/profiles/presentation/screens/woman_form_screen.dart';

import '../../../support/widget_harness.dart';

/// Repositorio que falla al crear perfiles, para cubrir el camino de error.
class _FailingWomenRepository extends WomenRepository {
  _FailingWomenRepository(AppDatabase db) : super(WomenDao(db));

  @override
  Future<int> create(WomanDraft draft) async {
    throw Exception('fallo simulado del repositorio');
  }
}

Future<Finder> _saveButton(WidgetTester tester) async {
  final button = find.ancestor(
    of: find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.text('Crear perfil'),
    ),
    matching: find.byWidgetPredicate((widget) => widget is FilledButton),
  );
  await tester.ensureVisible(button);
  await tester.pump();
  return button;
}

void main() {
  late AppDatabase db;

  testWidgets('woman form creates a profile with generated initials', (
    tester,
  ) async {
    db = createTestDatabase();
    await pumpScreen(tester, db, const WomanFormScreen());

    await tester.enterText(find.byType(TextFormField).first, 'María');
    await tester.tap(await _saveButton(tester));
    await settleProviders(tester);

    final women = await runReal(tester, () => db.select(db.women).get());
    expect(women, hasLength(1));
    expect(women.single.name, 'María');
    expect(women.single.initials, 'M');

    await closeTestDatabase(tester, db);
  });

  testWidgets('woman form links the selected tags', (tester) async {
    db = createTestDatabase();
    await pumpScreen(tester, db, const WomanFormScreen());

    await tester.enterText(find.byType(TextFormField).first, 'María');
    final chip = find.text(suggestedTags.first);
    await tester.ensureVisible(chip);
    await tester.pump();
    await tester.tap(chip);
    await tester.pump();
    await tester.tap(await _saveButton(tester));
    await settleProviders(tester);

    final links = await runReal(tester, () => db.select(db.womanTags).get());
    expect(links, hasLength(1));
    final tags = await runReal(tester, () => db.select(db.tags).get());
    expect(tags.single.name, suggestedTags.first);

    await closeTestDatabase(tester, db);
  });

  testWidgets('woman form shows validation errors and does not insert', (
    tester,
  ) async {
    db = createTestDatabase();
    await pumpScreen(tester, db, const WomanFormScreen());

    await tester.tap(await _saveButton(tester));
    await settleProviders(tester);

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.byType(WomanFormScreen), findsOneWidget);
    expect(await runReal(tester, () => db.select(db.women).get()), isEmpty);

    await closeTestDatabase(tester, db);
  });

  testWidgets('woman form inserts a single profile on a double tap', (
    tester,
  ) async {
    db = createTestDatabase();
    await pumpScreen(tester, db, const WomanFormScreen());

    await tester.enterText(find.byType(TextFormField).first, 'María');
    final button = await _saveButton(tester);
    await tester.tap(button);
    await tester.tap(button, warnIfMissed: false);
    await settleProviders(tester);

    expect(
      await runReal(tester, () => db.select(db.women).get()),
      hasLength(1),
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('woman form keeps the form and warns when the repository fails', (
    tester,
  ) async {
    db = createTestDatabase();
    await pumpScreen(
      tester,
      db,
      const WomanFormScreen(),
      overrides: [
        womenRepositoryProvider.overrideWithValue(_FailingWomenRepository(db)),
      ],
    );

    await tester.enterText(find.byType(TextFormField).first, 'María');
    await tester.tap(await _saveButton(tester));
    await settleProviders(tester);

    expect(find.text('No se pudo guardar el perfil'), findsOneWidget);
    expect(find.byType(WomanFormScreen), findsOneWidget);
    expect(await runReal(tester, () => db.select(db.women).get()), isEmpty);

    await closeTestDatabase(tester, db);
  });
}
