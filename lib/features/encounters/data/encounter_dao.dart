import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'encounter_dao.g.dart';

@DriftAccessor(tables: [Encounters, EncounterWomen])
class EncounterDao extends DatabaseAccessor<AppDatabase>
    with _$EncounterDaoMixin {
  EncounterDao(super.db);

  Future<int> insertEncounter(EncountersCompanion entry) =>
      into(encounters).insert(entry);

  Future<int> insertEncounterWoman(EncounterWomenCompanion entry) =>
      into(encounterWomen).insert(entry);

  Future<int> insertEncounterWithWomen(
    EncountersCompanion encounter,
    List<EncounterWomenCompanion> women,
  ) {
    return transaction(() async {
      final encounterId = await into(encounters).insert(encounter);
      for (final entry in women) {
        await into(
          encounterWomen,
        ).insert(entry.copyWith(encounterId: Value(encounterId)));
      }
      return encounterId;
    });
  }

  Future<void> deleteEncounter(int id) => transaction(() async {
    await (delete(encounterWomen)..where((t) => t.encounterId.equals(id))).go();
    await (delete(encounters)..where((t) => t.id.equals(id))).go();
  });

  Stream<List<Encounter>> watchAll() => (select(
    encounters,
  )..orderBy([(t) => OrderingTerm.desc(t.encounterTime)])).watch();

  Stream<List<Encounter>> watchEncountersByWoman(int womanId) {
    final query =
        select(encounters).join([
            innerJoin(
              encounterWomen,
              encounterWomen.encounterId.equalsExp(encounters.id),
            ),
          ])
          ..where(encounterWomen.womanId.equals(womanId))
          ..orderBy([OrderingTerm.desc(encounters.encounterTime)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(encounters)).toList(),
    );
  }

  Future<Encounter?> getById(int id) =>
      (select(encounters)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<EncounterWoman>> watchWomenOfEncounter(int encounterId) =>
      (select(
        encounterWomen,
      )..where((t) => t.encounterId.equals(encounterId))).watch();
}
