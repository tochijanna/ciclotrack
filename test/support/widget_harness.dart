import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_draft.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_options.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';

/// Andamiaje común de los tests de widget: base en memoria, montaje de la
/// pantalla con `appDatabaseProvider` overridado y siembra de datos.
///
/// La base se cierra SIEMPRE con [closeTestDatabase] dentro del cuerpo del
/// test. `addTearDown(db.close)` deja un `Timer` de drift pendiente
/// (`drift/src/runtime/executor/stream_queries.dart`) porque el cierre se
/// ejecuta cuando el `FakeAsync` del test ya ha terminado; Flutter lo detecta
/// como `A Timer is still pending even after the widget tree was disposed`.
AppDatabase createTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());

/// Ejecuta [body] con el reloj real, necesario para las escrituras y lecturas
/// de drift que no deben depender del `FakeAsync` del test.
Future<T> runReal<T>(WidgetTester tester, Future<T> Function() body) async {
  final value = await tester.runAsync(body);
  if (value == null) {
    throw StateError('runReal no admite Future<void>; devolvió null');
  }
  return value;
}

/// Monta [child] dentro de un `ProviderScope` con la base de test y deja
/// avanzar el primer frame y las consultas de los streams.
Future<void> pumpScreen(
  WidgetTester tester,
  AppDatabase db,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db), ...overrides],
      child: MaterialApp(home: child),
    ),
  );
  await settleProviders(tester);
}

/// Deja completar las consultas de drift que no dependen del reloj falso
/// (por ejemplo los `FutureProvider` que esperan a un repo) y repinta con el
/// resultado.
Future<void> settleProviders(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 10)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Deja avanzar el frame y las consultas ya emitidas por drift.
Future<void> pumpStreams(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Cierra la base dentro del reloj real del test.
Future<void> closeTestDatabase(WidgetTester tester, AppDatabase db) async {
  await tester.runAsync(() async {
    await db.close();
  });
}

/// Inserta una mujer y devuelve su perfil con etiquetas.
Future<WomanProfile> seedProfile(
  WidgetTester tester,
  AppDatabase db, {
  required String name,
  String initials = 'MR',
  List<String> tags = const [],
  String emoji = '👩',
  int color = 0xFFE91E63,
}) {
  return runReal(tester, () async {
    final repo = WomenRepository(WomenDao(db));
    final id = await repo.create(
      WomanDraft(
        name: name,
        initials: initials,
        tags: tags,
        emoji: emoji,
        color: color,
      ),
    );
    final profiles = await repo.watchAllProfiles().first;
    return profiles.firstWhere((profile) => profile.woman.id == id);
  });
}

/// Inserta una mujer y devuelve su id.
Future<int> seedWoman(
  WidgetTester tester,
  AppDatabase db, {
  required String name,
  String initials = 'MR',
  List<String> tags = const [],
  String emoji = '👩',
  int color = 0xFFE91E63,
}) async {
  final profile = await seedProfile(
    tester,
    db,
    name: name,
    initials: initials,
    tags: tags,
    emoji: emoji,
    color: color,
  );
  return profile.woman.id;
}

/// Inserta un encuentro con las participantes indicadas y devuelve su id.
Future<int> seedEncounter(
  WidgetTester tester,
  AppDatabase db, {
  required List<int> womanIds,
  DateTime? encounterTime,
  String? protection,
}) {
  return runReal(
    tester,
    () => EncounterRepository(EncounterDao(db)).create(
      EncounterDraft(
        encounterTime: encounterTime ?? DateTime(2026, 9, 5, 21, 30),
        protection: protection ?? protectionOptions.first,
        participants: womanIds
            .map(
              (id) => EncounterParticipantDraft(
                womanId: id,
                relationshipType: relationshipTypeOptions.first,
              ),
            )
            .toList(),
      ),
    ),
  );
}

/// Inserta un periodo y devuelve su id.
Future<int> seedPeriod(
  WidgetTester tester,
  AppDatabase db, {
  required int womanId,
  required DateTime startDate,
  DateTime? endDate,
}) {
  return runReal(
    tester,
    () => TrackingRepository(TrackingDao(db)).createPeriod(
      womanId,
      PeriodDraft(startDate: startDate, endDate: endDate),
    ),
  );
}

/// Crea la fila singleton de ajustes de alerta con el maestro indicado.
Future<void> seedAlertSettings(
  WidgetTester tester,
  AppDatabase db, {
  bool masterEnabled = false,
}) async {
  await tester.runAsync(() async {
    final dao = AlertSettingsDao(db);
    final row = await dao.getOrCreate();
    await dao.updateSettings(row.copyWith(masterEnabled: masterEnabled));
  });
}
