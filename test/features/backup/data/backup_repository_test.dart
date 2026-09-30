import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/backup/data/backup_repository.dart';
import 'package:ciclotrack/features/backup/domain/backup_document.dart';
import 'package:ciclotrack/features/calendar/domain/calendar_board.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_draft.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_options.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_timeline.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_calculator.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/reports/domain/report_builder.dart';
import 'package:ciclotrack/features/reports/domain/report_models.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';

void main() {
  final now = DateTime(2026, 9, 30, 21, 15);
  final hoy = DateTime(2026, 9, 30);

  late AppDatabase db;
  late BackupRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BackupRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<int>> seedAll(AppDatabase target) async {
    final women = WomenRepository(WomenDao(target));
    final tracking = TrackingRepository(TrackingDao(target));
    final encounters = EncounterRepository(EncounterDao(target));

    final ana = await women.create(
      WomanDraft(name: 'Ana', initials: 'AN', tags: ['Pareja']),
    );
    final bea = await women.create(WomanDraft(name: 'Bea', initials: 'BE'));
    await tracking.createPeriod(
      ana,
      PeriodDraft(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 5),
      ),
    );
    await encounters.create(
      EncounterDraft(
        encounterTime: DateTime(2026, 9, 5, 21, 30),
        protection: protectionOptions.first,
        participants: [
          EncounterParticipantDraft(
            womanId: ana,
            relationshipType: relationshipTypeOptions.first,
          ),
          EncounterParticipantDraft(
            womanId: bea,
            relationshipType: relationshipTypeOptions.first,
          ),
        ],
      ),
    );
    return [ana, bea];
  }

  /// Tablero mínimo para el informe: una mujer con un periodo.
  ReportsBoard tablero() {
    final woman = CalendarWoman(
      id: 1,
      name: 'Ana',
      initials: 'AN',
      emoji: '👩',
      color: 0xFFE91E63,
    );
    final periodos = [
      PeriodLogInput(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 5),
      ),
    ];
    return buildReports(
      CalendarBoard(
        women: [
          WomanCalendar(
            woman: woman,
            timeline: CycleTimeline.from(
              logs: periodos,
              horizonte: DateTime(2028, 1, 1),
            ),
            eventos: const [],
            periodos: periodos,
          ),
        ],
        encuentros: const [],
      ),
      today: hoy,
    );
  }

  test('exportJson nombra el fichero con la marca y vuelca la base', () async {
    await seedAll(db);
    final esperado = await repo.dump(now: now);

    final file = await repo.exportJson(now: now);

    expect(file.name, 'ciclotrack-backup-20260930-211500.json');
    final leido = BackupDocument.fromBytes(file.bytes);
    expect(leido.exportedAt, now);
    expect(leido.tables, esperado.tables);
    expect(leido.rows('women'), hasLength(2));
    expect(leido.rows('period_logs'), hasLength(1));
    expect(leido.rows('encounters'), hasLength(1));
    expect(leido.rows('encounter_women'), hasLength(2));
  });

  test('exportCsv devuelve un ZIP con las diez tablas', () async {
    await seedAll(db);

    final file = await repo.exportCsv(now: now);

    expect(file.name, 'ciclotrack-csv-20260930-211500.zip');
    expect(String.fromCharCodes(file.bytes.take(2)), 'PK');
    final archive = ZipDecoder().decodeBytes(file.bytes);
    expect(archive.files.map((f) => f.name).toSet(), {
      'manifest.json',
      for (final table in backupTables) '$table.csv',
    });
  });

  test('exportPdf devuelve un informe A4', () async {
    await seedAll(db);

    final file = await repo.exportPdf(board: tablero(), now: now);

    expect(file.name, 'ciclotrack-informe-20260930-211500.pdf');
    expect(String.fromCharCodes(file.bytes.take(5)), '%PDF-');
    expect(file.bytes.length, greaterThan(1000));
  });

  test('importJson sustituye los datos y devuelve el resumen', () async {
    await seedAll(db);
    final doc = await repo.dump(now: now);

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    final destinoRepo = BackupRepository(destino);
    await WomenRepository(
      WomenDao(destino),
    ).create(WomanDraft(name: 'Zoe', initials: 'ZO'));

    final resumen = await destinoRepo.importJson(doc);

    expect(resumen.counts['women'], 2);
    expect(resumen.counts['period_logs'], 1);
    expect(resumen.counts['encounters'], 1);
    final nombres = [
      for (final mujer in await destino.select(destino.women).get()) mujer.name,
    ];
    expect(nombres, ['Ana', 'Bea']);
    expect(nombres, isNot(contains('Zoe')));
    expect((await destino.select(destino.encounterWomen).get()), hasLength(2));

    await destino.close();
  });

  test('importJson revierte si la copia es inconsistente', () async {
    final ids = await seedAll(db);
    final doc = await repo.dump(now: now);
    doc.tables['woman_tags'] = [
      {'id': 1, 'woman_id': ids.first, 'tag_id': 4242},
    ];

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    await WomenRepository(
      WomenDao(destino),
    ).create(WomanDraft(name: 'Zoe', initials: 'ZO'));

    await expectLater(
      BackupRepository(destino).importJson(doc),
      throwsA(isA<Exception>()),
    );

    final mujeres = await destino.select(destino.women).get();
    expect(mujeres.single.name, 'Zoe');
    expect(await destino.select(destino.womanTags).get(), isEmpty);

    await destino.close();
  });

  test('importJson de una copia vacía deja la base limpia', () async {
    await seedAll(db);
    final vacia = AppDatabase.forTesting(NativeDatabase.memory());
    final doc = await BackupRepository(vacia).dump(now: now);

    await repo.importJson(doc);

    expect(await db.select(db.women).get(), isEmpty);
    expect(await db.select(db.encounters).get(), isEmpty);
    expect(await db.select(db.tags).get(), isEmpty);

    await vacia.close();
  });

  test(
    'la marca de tiempo del nombre no lleva caracteres reservados',
    () async {
      final file = await repo.exportJson(now: now);

      expect(file.name, matches(RegExp(r'^[\w\-.]+$')));
      expect(utf8.decode(file.bytes.take(1).toList()), '{');
    },
  );
}
