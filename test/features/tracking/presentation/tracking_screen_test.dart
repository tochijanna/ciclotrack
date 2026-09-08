import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';
import 'package:ciclotrack/features/tracking/presentation/screens/tracking_screen.dart';

void main() {
  testWidgets('TrackingScreen renders prediction card and empty timeline',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    final profile = (await tester.runAsync(() => _createProfile(db, 'María')))!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: TrackingScreen(profile: profile)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('María'), findsWidgets);
    expect(find.text('Sin registros'), findsOneWidget);

    await tester.runAsync(() async {
      await db.close();
    });
  });

  testWidgets('TrackingScreen shows prediction and period in timeline',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final profile = (await tester.runAsync(() => _createProfile(db, 'Ana')))!;

    await tester.runAsync(() async {
      final repo = TrackingRepository(TrackingDao(db));
      await repo.createPeriod(
        profile.woman.id,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: TrackingScreen(profile: profile)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Prediction card should show (periodo en curso or similar)
    expect(find.textContaining('Periodo'), findsWidgets);

    await tester.runAsync(() async {
      await db.close();
    });
  });

  testWidgets('TrackingScreen deletes an event after confirmation',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final profile = (await tester.runAsync(() async {
      final p = await _createProfile(db, 'Sofía');
      final repo = TrackingRepository(TrackingDao(db));
      await repo.createPeriod(
        p.woman.id,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      return p;
    }))!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: TrackingScreen(profile: profile)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Find the tracking event card's "Periodo" text and long-press it.
    // The prediction card may push it off-screen, so scroll if needed.
    final periodoFinder = find.text('Periodo');
    if (periodoFinder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        periodoFinder,
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
    }
    await tester.longPress(periodoFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Eliminar registro'), findsOneWidget);
    await tester.tap(find.text('Eliminar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sin registros'), findsOneWidget);

    await tester.runAsync(() async {
      await db.close();
    });
  });
}

Future<WomanProfile> _createProfile(AppDatabase db, String name) async {
  final repo = WomenRepository(WomenDao(db));
  final id = await repo.create(WomanDraft(name: name, initials: 'X'));
  final women = await repo.watchAllProfiles().first;
  return women.firstWhere((p) => p.woman.id == id);
}
