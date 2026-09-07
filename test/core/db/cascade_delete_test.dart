import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';

void main() {
  late AppDatabase db;
  late WomenDao dao;
  late WomenRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = WomenDao(db);
    repo = WomenRepository(dao);
  });

  tearDown(() async {
    await db.close();
  });

  test('deleteWomanCascade removes all dependent data', () async {
    final womanId = await repo.create(
      const WomanDraft(name: 'María', initials: 'MR', tags: ['Amiga']),
    );

    // Datos dependientes en las distintas tablas.
    await db
        .into(db.periodLogs)
        .insert(
          PeriodLogsCompanion.insert(
            womanId: womanId,
            startDate: DateTime(2026, 9, 1),
          ),
        );
    await db
        .into(db.ovulationLogs)
        .insert(
          OvulationLogsCompanion.insert(
            womanId: womanId,
            date: DateTime(2026, 9, 14),
          ),
        );
    await db
        .into(db.symptoms)
        .insert(
          SymptomsCompanion.insert(
            womanId: womanId,
            date: DateTime(2026, 9, 10),
            type: 'Acné',
          ),
        );
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            womanId: womanId,
            cycleDayStart: 5,
            cycleDayEnd: 7,
            message: 'Evitar',
          ),
        );
    final encounterId = await db
        .into(db.encounters)
        .insert(
          EncountersCompanion.insert(
            encounterTime: DateTime(2026, 9, 5),
            protection: 'condom',
          ),
        );
    await db
        .into(db.encounterWomen)
        .insert(
          EncounterWomenCompanion.insert(
            encounterId: encounterId,
            womanId: womanId,
            relationshipType: const Value('vaginal'),
          ),
        );

    // La etiqueta 'Amiga' debe seguir existiendo en la tabla global.
    final tagBefore = await dao.tagByName('Amiga');
    expect(tagBefore, isNotNull);

    await repo.delete(womanId);

    expect(await dao.getById(womanId), isNull);
    expect(await db.select(db.periodLogs).get(), isEmpty);
    expect(await db.select(db.ovulationLogs).get(), isEmpty);
    expect(await db.select(db.symptoms).get(), isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
    expect(await db.select(db.encounterWomen).get(), isEmpty);
    // El encuentro en sí no se elimina (no depende de la mujer).
    expect(await db.select(db.encounters).get(), hasLength(1));
    // La etiqueta global sobrevive aunque el vínculo se borre.
    expect(await dao.tagByName('Amiga'), isNotNull);
  });

  test('deleteWomanCascade is transactional on failure', () async {
    final womanId = await repo.create(
      const WomanDraft(name: 'Ana', initials: 'AN'),
    );
    await db
        .into(db.periodLogs)
        .insert(
          PeriodLogsCompanion.insert(
            womanId: womanId,
            startDate: DateTime(2026, 9, 1),
          ),
        );

    await repo.delete(womanId);

    expect(await dao.getById(womanId), isNull);
    expect(await db.select(db.periodLogs).get(), isEmpty);
  });
}
