import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'encounter_dao.g.dart';

@DriftAccessor(tables: [Encounters, EncounterWomen, Women])
class EncounterDao extends DatabaseAccessor<AppDatabase>
    with _$EncounterDaoMixin {
  EncounterDao(super.db);

  // --- Lectura ---

  Future<Encounter?> getById(int id) =>
      (select(encounters)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Encounter>> watchAll() => (select(
    encounters,
  )..orderBy([(t) => OrderingTerm.desc(t.encounterTime)])).watch();

  Stream<List<Encounter>> watchByWoman(int womanId) {
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

  Stream<List<EncounterWoman>> watchWomenOfEncounter(int encounterId) =>
      (select(
        encounterWomen,
      )..where((t) => t.encounterId.equals(encounterId))).watch();

  /// Devuelve los participantes de un encuentro con datos de la mujer.
  Stream<List<ParticipantRow>> watchParticipantsWithWoman(int encounterId) {
    final query = select(encounterWomen).join([
      innerJoin(women, women.id.equalsExp(encounterWomen.womanId)),
    ])..where(encounterWomen.encounterId.equals(encounterId));
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ParticipantRow(
              encounterWoman: row.readTable(encounterWomen),
              woman: row.readTable(women),
            ),
          )
          .toList(),
    );
  }

  // --- Escritura ---

  Future<int> insertEncounter(EncountersCompanion entry) =>
      into(encounters).insert(entry);

  Future<void> updateEncounter(Encounter entry) =>
      update(encounters).replace(entry);

  Future<int> insertEncounterWoman(EncounterWomenCompanion entry) =>
      into(encounterWomen).insert(entry);

  /// Crea un encuentro con sus participantes en una transacción.
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

  /// Actualiza un encuentro y reemplaza sus participantes en una transacción.
  Future<void> updateEncounterWithWomen(
    Encounter encounter,
    List<EncounterWomenCompanion> women,
  ) {
    return transaction(() async {
      await update(encounters).replace(encounter);
      await (delete(
        encounterWomen,
      )..where((t) => t.encounterId.equals(encounter.id))).go();
      for (final entry in women) {
        await into(encounterWomen).insert(entry);
      }
    });
  }

  /// Elimina un encuentro y sus participantes en una transacción.
  Future<void> deleteEncounter(int id) => transaction(() async {
    await (delete(encounterWomen)..where((t) => t.encounterId.equals(id))).go();
    await (delete(encounters)..where((t) => t.id.equals(id))).go();
  });
}

/// Fila de participante con datos de la mujer asociada.
class ParticipantRow {
  const ParticipantRow({required this.encounterWoman, required this.woman});

  final EncounterWoman encounterWoman;
  final Woman woman;
}
