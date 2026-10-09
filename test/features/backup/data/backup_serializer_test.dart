import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/backup/data/backup_serializer.dart';
import 'package:ciclotrack/features/backup/domain/backup_document.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_draft.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_options.dart';
import 'package:ciclotrack/features/medications/data/medication_dao.dart';
import 'package:ciclotrack/features/medications/data/medication_repository.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 30, 21, 15);
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  WomenRepository womenOf(AppDatabase target) =>
      WomenRepository(WomenDao(target));

  TrackingRepository trackingOf(AppDatabase target) =>
      TrackingRepository(TrackingDao(target));

  /// Dos perfiles con etiquetas, periodos, ovulación, síntoma, un encuentro
  /// compartido y ajustes de alerta: las diez tablas con filas.
  Future<List<int>> seedAll(AppDatabase target) async {
    final women = womenOf(target);
    final tracking = trackingOf(target);
    final encounters = EncounterRepository(EncounterDao(target));

    final ana = await women.create(
      WomanDraft(
        name: 'Ana',
        initials: 'AN',
        emoji: '👩',
        privateNotes: 'Ñ, comas,\ny saltos',
        tags: ['Pareja', 'Amiga'],
      ),
    );
    final bea = await women.create(
      WomanDraft(name: 'Bea', initials: 'BE', tags: ['Pareja']),
    );

    await tracking.createPeriod(
      ana,
      PeriodDraft(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 5),
        flowLevel: 2,
        notes: 'flujo medio',
      ),
    );
    await tracking.createPeriod(
      bea,
      PeriodDraft(startDate: DateTime(2026, 9, 10)),
    );
    await tracking.createOvulation(
      ana,
      OvulationDraft(
        date: DateTime(2026, 9, 14),
        temperature: 36.6,
        cervicalMucus: 'Cristalino',
        lhTest: true,
      ),
    );
    await tracking.createSymptom(
      ana,
      SymptomDraft(
        date: DateTime(2026, 9, 12),
        type: 'Acné',
        severity: 3,
        notes: 'leve',
      ),
    );
    await encounters.create(
      EncounterDraft(
        encounterTime: DateTime(2026, 9, 5, 21, 30, 12),
        protection: protectionOptions.first,
        outcome: outcomeOptions.first,
        notes: 'sin incidencias',
        participants: [
          EncounterParticipantDraft(
            womanId: ana,
            relationshipType: relationshipTypeOptions.first,
          ),
          EncounterParticipantDraft(
            womanId: bea,
            relationshipType: relationshipTypeOptions.last,
          ),
        ],
      ),
    );

    final settings = AlertSettingsDao(target);
    final row = await settings.getOrCreate();
    await settings.updateSettings(
      row.copyWith(
        masterEnabled: true,
        notifyHour: 20,
        notifyMinute: 45,
        enabledTypes: 'fertilidadInminente',
        horizonDays: 10,
      ),
    );

    await MedicationRepository(MedicationDao(target)).save(
      womanId: ana,
      name: 'Hierro',
      dose: '20 mg',
      hour: 23,
      minute: 59,
      enabled: true,
    );
    return [ana, bea];
  }

  test('restaura v3 y vacía medicamentos existentes', () async {
    await seedAll(db);
    final json = (await dumpDatabase(db, now: now)).toJson()
      ..['schemaVersion'] = 3;
    (json['tables']! as Map<String, Object?>).remove('medications');
    await restoreDatabase(db, BackupDocument.fromJson(json));
    expect(await db.select(db.women).get(), hasLength(2));
    expect(await db.select(db.medications).get(), isEmpty);
  });

  test('el volcado reproduce las diez tablas', () async {
    await seedAll(db);

    final doc = await dumpDatabase(db, now: now);

    expect(doc.exportedAt, now);
    expect(doc.counts['women'], 2);
    expect(doc.counts['tags'], 2);
    expect(doc.counts['woman_tags'], 3);
    expect(doc.counts['period_logs'], 2);
    expect(doc.counts['ovulation_logs'], 1);
    expect(doc.counts['symptoms'], 1);
    expect(doc.counts['encounters'], 1);
    expect(doc.counts['encounter_women'], 2);
    expect(doc.counts['alert_settings'], 1);
    expect(doc.counts['reminders'], 0);

    final ana = doc.rows('women').first;
    expect(ana['emoji'], '👩');
    expect(ana['private_notes'], 'Ñ, comas,\ny saltos');
    expect(ana['created_at'], isA<DateTime>());
    expect(doc.rows('period_logs').first['start_date'], DateTime(2026, 9, 1));
    expect(doc.rows('period_logs').last['end_date'], isNull);
    expect(doc.rows('ovulation_logs').first['temperature'], 36.6);
    expect(doc.rows('ovulation_logs').first['lh_test'], isTrue);
    expect(doc.rows('encounters').first['outcome'], 'Nada');
    expect(
      doc.rows('encounters').first['date_time'],
      DateTime(2026, 9, 5, 21, 30, 12),
    );
  });

  test('restaurar en otra base deja las diez tablas idénticas', () async {
    await seedAll(db);
    final doc = await dumpDatabase(db, now: now);

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    await restoreDatabase(destino, doc);

    final copia = await dumpDatabase(destino, now: now);
    expect(copia.tables, doc.tables);

    // Comprobación tipada, independiente del propio volcado.
    final encuentro = (await destino.select(destino.encounters).get()).single;
    expect(encuentro.encounterTime, DateTime(2026, 9, 5, 21, 30, 12));
    expect(encuentro.protection, 'Condón');
    final mujer = (await destino.select(destino.women).get()).first;
    expect(mujer.privateNotes, 'Ñ, comas,\ny saltos');
    expect(
      (await destino.select(destino.alertSettings).get()).single.notifyHour,
      20,
    );

    await destino.close();
  });

  test('restaurar sobre datos distintos sustituye todo sin restos', () async {
    await seedAll(db);
    final doc = await dumpDatabase(db, now: now);

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    final zoe = await womenOf(
      destino,
    ).create(WomanDraft(name: 'Zoe', initials: 'ZO', tags: ['Otra']));
    await trackingOf(
      destino,
    ).createPeriod(zoe, PeriodDraft(startDate: DateTime(2026, 1, 1)));
    await EncounterRepository(EncounterDao(destino)).create(
      EncounterDraft(
        encounterTime: DateTime(2026, 1, 2, 20),
        protection: noProtection,
        participants: [
          EncounterParticipantDraft(
            womanId: zoe,
            relationshipType: relationshipTypeOptions.first,
          ),
        ],
      ),
    );

    await restoreDatabase(destino, doc);

    final copia = await dumpDatabase(destino, now: now);
    expect(copia.tables, doc.tables);
    final nombres = [for (final row in copia.rows('women')) row['name']];
    expect(nombres, ['Ana', 'Bea']);
    expect(copia.rows('tags').map((row) => row['name']), ['Pareja', 'Amiga']);

    await destino.close();
  });

  test('un enlace huérfano revierte la restauración completa', () async {
    final ids = await seedAll(db);
    final doc = await dumpDatabase(db, now: now);
    doc.tables['woman_tags'] = [
      {'id': 1, 'woman_id': ids.first, 'tag_id': 9999},
    ];

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    final zoe = await womenOf(
      destino,
    ).create(WomanDraft(name: 'Zoe', initials: 'ZO', tags: ['Otra']));
    await trackingOf(
      destino,
    ).createPeriod(zoe, PeriodDraft(startDate: DateTime(2026, 1, 1)));

    await expectLater(restoreDatabase(destino, doc), throwsA(isA<Exception>()));

    final mujeres = await destino.select(destino.women).get();
    expect(mujeres, hasLength(1));
    expect(mujeres.single.name, 'Zoe');
    expect(await destino.select(destino.periodLogs).get(), hasLength(1));
    expect((await destino.select(destino.tags).get()).single.name, 'Otra');

    await destino.close();
  });

  test('tras importar, un alta nueva recibe maxId + 1', () async {
    await seedAll(db);
    final doc = await dumpDatabase(db, now: now);
    final maxId = doc
        .rows('women')
        .map((row) => row['id']! as int)
        .reduce((a, b) => a > b ? a : b);

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    await restoreDatabase(destino, doc);

    final nueva = await womenOf(
      destino,
    ).create(WomanDraft(name: 'Ce', initials: 'CE'));
    expect(nueva, maxId + 1);

    await destino.close();
  });

  test('el documento de una base vacía restaura sin error', () async {
    final vacia = AppDatabase.forTesting(NativeDatabase.memory());
    final doc = await dumpDatabase(vacia, now: now);
    expect(doc.counts.values.every((n) => n == 0), isTrue);

    await restoreDatabase(db, doc);

    expect(await db.select(db.women).get(), isEmpty);
    expect(await db.select(db.tags).get(), isEmpty);
    final ajustes = (await db.select(db.alertSettings).get()).single;
    expect(ajustes.id, 1);
    expect(ajustes.masterEnabled, isFalse);
    expect(ajustes.notifyHour, 9);

    await vacia.close();
  });

  test(
    'ida y vuelta por JSON conserva las once tablas con medicamentos',
    () async {
      await seedAll(db);
      final doc = await dumpDatabase(db, now: now);
      expect(doc.counts['medications'], 1);

      final destino = AppDatabase.forTesting(NativeDatabase.memory());
      await restoreDatabase(
        destino,
        BackupDocument.fromBytes(doc.toUtf8Bytes()),
      );
      final vuelta = await dumpDatabase(destino, now: now);

      expect(vuelta.tables, doc.tables);

      await destino.close();
    },
  );

  test(
    'un volcado concurrente con escrituras sale referencialmente cerrado',
    () async {
      // Sin transacción, una escritura se cuela entre dos SELECT del volcado
      // (ambas tareas se entrelazan en los await) y la copia sale con huérfanos.
      for (var i = 0; i < 30; i++) {
        final resultados = await Future.wait([
          dumpDatabase(db, now: now),
          () async {
            final id = await womenOf(
              db,
            ).create(WomanDraft(name: 'Concurrente $i', initials: 'C$i'));
            await trackingOf(db).createPeriod(
              id,
              PeriodDraft(startDate: DateTime(2026, 1, 1 + i % 28)),
            );
          }(),
        ]);
        final doc = resultados.first as BackupDocument;

        final ids = <String, Set<int>>{
          for (final tabla in backupTables)
            tabla: {for (final fila in doc.rows(tabla)) fila['id']! as int},
        };
        void sinHuerfanos(String tabla, String columna, String objetivo) {
          for (final fila in doc.rows(tabla)) {
            expect(
              ids[objetivo],
              contains(fila[columna] as int),
              reason:
                  'vuelto $i: $tabla fila ${fila['id']} '
                  'apunta a $objetivo inexistente',
            );
          }
        }

        for (final tabla in const [
          'woman_tags',
          'period_logs',
          'ovulation_logs',
          'symptoms',
          'medications',
          'reminders',
        ]) {
          sinHuerfanos(tabla, 'woman_id', 'women');
        }
        sinHuerfanos('woman_tags', 'tag_id', 'tags');
        sinHuerfanos('encounter_women', 'encounter_id', 'encounters');
        sinHuerfanos('encounter_women', 'woman_id', 'women');
      }
    },
  );
}
