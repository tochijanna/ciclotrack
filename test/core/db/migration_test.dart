import 'dart:io';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Volcado estructural de un archivo SQLite: tablas → columnas y FKs.
/// Compara nombre/tipo/nullabilidad/pk y FKs (tabla, columna, destino,
/// on_delete), nunca el literal `sql` de sqlite_master (SQLite conserva el
/// formato original del CREATE TABLE, que difiere entre eras).
Map<String, Map<String, List<Map<String, Object?>>>> _dumpSchema(
  sqlite3.Database db,
) {
  final tables = [
    for (final row in db.select(
      "SELECT name FROM sqlite_master "
      "WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    ))
      row['name'] as String,
  ];
  return {
    for (final table in tables)
      table: {
        'columns': [
          for (final c in db.select('PRAGMA table_info($table)'))
            {
              'name': c['name'],
              'type': c['type'],
              'notnull': c['notnull'],
              'pk': c['pk'],
            },
        ],
        'fks': [
          for (final fk in db.select('PRAGMA foreign_key_list($table)'))
            {
              'table': fk['table'],
              'from': fk['from'],
              'to': fk['to'],
              'on_delete': fk['on_delete'],
            },
        ],
      },
  };
}

void main() {
  late AppDatabase db;
  late WomenDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = WomenDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('schema v4', () {
    test('schemaVersion is 4', () {
      expect(db.schemaVersion, 4);
    });

    test('alert_settings table exists', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();
      expect(tableNames, contains('alert_settings'));
      expect(tableNames.length, 11);
    });
  });

  // Fixtures históricas reales creadas con el drift de cada versión
  // (ver fixtures/README.md para la receta de regeneración):
  //   v1 → de64402 (7 tablas, women.tag, FKs sin cascade)
  //   v2 → 7479fce (+ tags/woman_tags)
  //   v3 → 0c86d66 (+ alert_settings)
  group('fixtures históricas v1/v2/v3', () {
    const fixtures = [
      (file: 'v1', commit: 'de64402', version: 1),
      (file: 'v2', commit: '7479fce', version: 2),
      (file: 'v3', commit: '0c86d66', version: 3),
    ];

    for (final fixture in fixtures) {
      group('fixture ${fixture.file} (${fixture.commit})', () {
        late Directory directory;
        late File file;
        late AppDatabase upgraded;

        setUp(() async {
          await db.close();
          directory = await Directory.systemTemp.createTemp(
            'toc16_${fixture.file}_',
          );
          file = File('${directory.path}/${fixture.file}.sqlite');
          await File(
            'test/core/db/fixtures/${fixture.file}.sqlite',
          ).copy(file.path);

          // La copia debe seguir en su versión original antes de abrir.
          final raw = sqlite3.sqlite3.open(file.path);
          expect(
            raw.select('PRAGMA user_version').first['user_version'],
            fixture.version,
            reason:
                'la fixture debe estar en schemaVersion '
                '${fixture.version} antes de migrar',
          );
          raw.close();

          upgraded = AppDatabase.forTesting(NativeDatabase(file));
        });

        tearDown(() async {
          await upgraded.close();
          await directory.delete(recursive: true);
        });

        test('migra a v4 conservando datos y relaciones', () async {
          expect(upgraded.schemaVersion, 4);

          final women = await upgraded.select(upgraded.women).get();
          expect(women.map((w) => w.name).toList(), ['Ana', 'Berta', 'Clara']);
          final berta = women[1];
          expect(berta.emoji, '🌸');
          expect(berta.color, 0xFF2196F3);
          expect(berta.privateNotes, 'privado');
          expect(berta.sortOrder, 3);
          expect(berta.createdAt, DateTime(2026, 1, 6));
          expect(women[0].createdAt, DateTime(2026, 1, 5));

          final periods = await upgraded.select(upgraded.periodLogs).get();
          expect(periods, hasLength(4));
          final first = periods.firstWhere((p) => p.id == 1);
          expect(first.womanId, 1);
          expect(first.startDate, DateTime(2026, 1, 10));
          expect(first.endDate, DateTime(2026, 1, 15));
          expect(first.flowLevel, 3);
          expect(first.notes, 'flujo alto');
          final openPeriod = periods.firstWhere((p) => p.id == 2);
          expect(openPeriod.endDate, isNull);
          expect(openPeriod.flowLevel, isNull);

          final ovulations = await upgraded
              .select(upgraded.ovulationLogs)
              .get();
          expect(ovulations, hasLength(2));
          final ovulation = ovulations.firstWhere((o) => o.id == 1);
          expect(ovulation.date, DateTime(2026, 1, 24));
          expect(ovulation.temperature, closeTo(36.7, 0.0001));
          expect(ovulation.cervicalMucus, 'elastica');
          expect(ovulation.lhTest, isTrue);

          final symptoms = await upgraded.select(upgraded.symptoms).get();
          expect(symptoms, hasLength(2));
          expect(symptoms.map((s) => s.type), containsAll(['dolor', 'acne']));

          final encounters = await upgraded.select(upgraded.encounters).get();
          expect(
            encounters.single.encounterTime,
            DateTime(2026, 1, 25, 22, 30),
          );
          expect(encounters.single.protection, 'preservativo');

          final links = await upgraded.select(upgraded.encounterWomen).get();
          expect(links.map((l) => (l.encounterId, l.womanId)).toSet(), {
            (1, 1),
            (1, 2),
          });
          expect(
            links.firstWhere((l) => l.womanId == 1).relationshipType,
            'pareja',
          );

          final reminders = await upgraded.select(upgraded.reminders).get();
          expect(reminders, hasLength(2));
          expect(reminders.firstWhere((r) => r.id == 2).enabled, isFalse);

          // La columna women.tag solo puede existir en la fixture v1 y la
          // migración v1→v2 debe eliminarla.
          final columns = await upgraded
              .customSelect('PRAGMA table_info(women)')
              .get();
          expect(
            columns.map((row) => row.data['name']),
            isNot(contains('tag')),
          );
        });

        test('tags y alert_settings según la versión de origen', () async {
          final tags = await upgraded.select(upgraded.tags).get();
          final womanTags = await upgraded.select(upgraded.womanTags).get();
          final pairs = womanTags.map((wt) => (wt.womanId, wt.tagId)).toSet();

          if (fixture.version == 1) {
            // Backfill v1→v2: 'Amiga' compartido por Ana y Berta (un solo
            // tag, dos vínculos); Clara tenía tag vacío → sin vínculos.
            expect(tags.map((t) => t.name).toList(), ['Amiga']);
            expect(pairs, {(1, 1), (2, 1)});
          } else {
            expect(tags.map((t) => t.name).toList(), ['Amiga', 'Familia']);
            expect(pairs, {(1, 1), (2, 1), (3, 2)});
          }

          final settings = await upgraded.select(upgraded.alertSettings).get();
          if (fixture.version == 3) {
            // La fila con valores no default debe llegar intacta.
            final setting = settings.single;
            expect(setting.id, 1);
            expect(setting.masterEnabled, isFalse);
            expect(setting.notifyHour, 21);
            expect(setting.notifyMinute, 30);
            expect(setting.enabledTypes, 'periodo,ovulacion');
            expect(setting.horizonDays, 14);
          } else {
            expect(settings, isEmpty);
          }
        });

        test('medications queda vacía y operativa tras migrar', () async {
          expect(await upgraded.select(upgraded.medications).get(), isEmpty);

          await upgraded
              .into(upgraded.medications)
              .insert(
                MedicationsCompanion.insert(
                  womanId: 1,
                  name: 'Hierro',
                  hour: 8,
                  minute: 30,
                ),
              );
          final medications = await upgraded.select(upgraded.medications).get();
          expect(medications.single.name, 'Hierro');
          expect(medications.single.dose, '');
        });

        test('esquema migrado coincide con v4 (columnas y FKs)', () async {
          // Fuerza la migración (queda commiteada en el archivo aunque la
          // conexión drift siga abierta).
          await upgraded.customSelect('SELECT count(*) FROM women').get();

          // Referencia: una v4 fresca creada por drift hoy.
          final refDir = await Directory.systemTemp.createTemp('toc16_ref_');
          addTearDown(() async => refDir.delete(recursive: true));
          final refFile = File('${refDir.path}/ref.sqlite');
          final reference = AppDatabase.forTesting(NativeDatabase(refFile));
          await reference.customSelect('SELECT 1').get();
          await reference.close();

          final migratedDb = sqlite3.sqlite3.open(file.path);
          final referenceDb = sqlite3.sqlite3.open(refFile.path);
          addTearDown(migratedDb.close);
          addTearDown(referenceDb.close);

          // Sin filas huérfanas: las relaciones quedan íntegras.
          expect(migratedDb.select('PRAGMA foreign_key_check'), isEmpty);

          final migrated = _dumpSchema(migratedDb);
          final referenceSchema = _dumpSchema(referenceDb);

          expect(
            migrated.keys,
            unorderedEquals(referenceSchema.keys),
            reason: 'mismo conjunto de 11 tablas',
          );

          // Tablas heredadas de una base v1: el commit 7479fce dejó
          // documentado que el ON DELETE CASCADE de v2 solo aplica a
          // instalaciones nuevas, así que estas conservan FKs sin cascade.
          const legacyTables = {
            'period_logs',
            'ovulation_logs',
            'symptoms',
            'encounter_women',
            'reminders',
          };

          for (final table in referenceSchema.keys) {
            final expected = referenceSchema[table]!;
            expect(
              migrated[table]!['columns'],
              expected['columns'],
              reason: 'columnas de $table',
            );

            final expectedFks =
                fixture.version == 1 && legacyTables.contains(table)
                ? [
                    for (final fk in expected['fks']!)
                      {...fk, 'on_delete': 'NO ACTION'},
                  ]
                : expected['fks'];
            expect(
              migrated[table]!['fks'],
              expectedFks,
              reason: 'FKs de $table',
            );
          }
        });
      });
    }
  });

  group('alert_settings', () {
    test('getOrCreate creates singleton row', () async {
      final settingsDao = AlertSettingsDao(db);
      final settings = await settingsDao.getOrCreate();
      expect(settings.id, 1);
      expect(settings.masterEnabled, false);
      expect(settings.notifyHour, 9);
      expect(settings.notifyMinute, 0);
      expect(settings.horizonDays, 7);
    });

    test('getOrCreate returns existing row on second call', () async {
      final settingsDao = AlertSettingsDao(db);
      final first = await settingsDao.getOrCreate();
      await settingsDao.updateSettings(first.copyWith(masterEnabled: false));
      final second = await settingsDao.getOrCreate();
      expect(second.masterEnabled, false);
    });

    test('watchSettings emits updates', () async {
      final settingsDao = AlertSettingsDao(db);
      await settingsDao.ensureCreated();

      final values = <bool>[];
      final sub = settingsDao.watchSettings().listen((s) {
        if (s != null) values.add(s.masterEnabled);
      });

      await settingsDao.updateSettings(
        (await settingsDao.getOrCreate()).copyWith(masterEnabled: false),
      );
      await pumpEventQueue();

      await sub.cancel();
      expect(values, contains(false));
    });
  });

  group('tags N:M', () {
    test('create and link tags to a woman', () async {
      final womanId = await dao.insert(
        WomenCompanion.insert(
          name: 'María',
          initials: 'MR',
          createdAt: DateTime(2026, 9, 1),
        ),
      );

      await dao.replaceTags(womanId, ['Amiga', 'Relacionada']);

      final tags = await dao.watchTagsForWoman(womanId).first;
      final names = tags.map((t) => t.name).toList();
      expect(names, containsAll(['Amiga', 'Relacionada']));
    });

    test('replaceTags replaces existing links', () async {
      final womanId = await dao.insert(
        WomenCompanion.insert(
          name: 'Ana',
          initials: 'AN',
          createdAt: DateTime(2026, 9, 1),
        ),
      );

      await dao.replaceTags(womanId, ['Ex']);
      await dao.replaceTags(womanId, ['Amiga', 'Casual']);

      final tags = await dao.watchTagsForWoman(womanId).first;
      final names = tags.map((t) => t.name).toList();
      expect(names, containsAll(['Amiga', 'Casual']));
      expect(names, isNot(contains('Ex')));
    });

    test('getOrCreateTag reuses existing tag', () async {
      final id1 = await dao.getOrCreateTag('Amiga');
      final id2 = await dao.getOrCreateTag('Amiga');
      expect(id1, id2);

      final id3 = await dao.getOrCreateTag('Ex');
      expect(id3, isNot(id1));
    });

    test('delete woman cascades to woman_tags', () async {
      final womanId = await dao.insert(
        WomenCompanion.insert(
          name: 'Borrar',
          initials: 'BR',
          createdAt: DateTime(2026, 9, 1),
        ),
      );
      await dao.replaceTags(womanId, ['Amiga']);

      await dao.deleteWoman(womanId);

      final tags = await dao.watchTagsForWoman(womanId).first;
      expect(tags, isEmpty);

      // Tag itself still exists.
      final allTags = await dao.allTags();
      expect(allTags.map((t) => t.name), contains('Amiga'));
    });
  });
}
