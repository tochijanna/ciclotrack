import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/encounter_draft.dart';
import '../domain/encounter_event.dart';
import 'encounter_dao.dart';

/// Repositorio que orquesta acceso a encuentros y participantes.
class EncounterRepository {
  EncounterRepository(this._dao);

  final EncounterDao _dao;

  // --- Observación ---

  /// Stream de todos los encuentros con participantes.
  Stream<List<EncounterWithWomen>> watchAll() {
    return _mapRows(_dao.watchAllWithParticipants());
  }

  /// Stream de encuentros de una mujer concreta.
  Stream<List<EncounterWithWomen>> watchByWoman(int womanId) {
    return _mapRows(_dao.watchByWomanWithParticipants(womanId));
  }

  /// Obtiene un encuentro con participantes por id.
  Future<EncounterWithWomen?> getById(int id) async {
    final encounter = await _dao.getById(id);
    if (encounter == null) return null;
    final participants = await _dao
        .watchParticipantsWithWoman(encounter.id)
        .first;
    return _mapEncounter(encounter, participants);
  }

  Stream<List<EncounterWithWomen>> _mapRows(
    Stream<List<EncounterWithParticipantRow>> source,
  ) {
    return source.map((rows) {
      final grouped = <int, EncounterWithWomen>{};
      for (final row in rows) {
        final current = grouped[row.encounter.id];
        final participant = EncounterParticipant(
          womanId: row.woman.id,
          womanName: row.woman.name,
          womanInitials: row.woman.initials,
          womanEmoji: row.woman.emoji,
          womanColor: row.woman.color,
          relationshipType: row.encounterWoman.relationshipType,
        );
        if (current == null) {
          grouped[row.encounter.id] = EncounterWithWomen(
            encounterId: row.encounter.id,
            encounterTime: row.encounter.encounterTime,
            protection: row.encounter.protection,
            outcome: row.encounter.outcome,
            notes: row.encounter.notes,
            participants: [participant],
          );
        } else {
          grouped[row.encounter.id] = EncounterWithWomen(
            encounterId: current.encounterId,
            encounterTime: current.encounterTime,
            protection: current.protection,
            outcome: current.outcome,
            notes: current.notes,
            participants: [...current.participants, participant],
          );
        }
      }
      return grouped.values.toList();
    });
  }

  EncounterWithWomen _mapEncounter(
    Encounter encounter,
    List<ParticipantRow> participants,
  ) {
    return EncounterWithWomen(
      encounterId: encounter.id,
      encounterTime: encounter.encounterTime,
      protection: encounter.protection,
      outcome: encounter.outcome,
      notes: encounter.notes,
      participants: participants
          .map(
            (p) => EncounterParticipant(
              womanId: p.woman.id,
              womanName: p.woman.name,
              womanInitials: p.woman.initials,
              womanEmoji: p.woman.emoji,
              womanColor: p.woman.color,
              relationshipType: p.encounterWoman.relationshipType,
            ),
          )
          .toList(),
    );
  }

  // --- CRUD ---

  /// Crea un encuentro con participantes. Devuelve el id.
  Future<int> create(EncounterDraft draft) => _dao.insertEncounterWithWomen(
    EncountersCompanion.insert(
      encounterTime: draft.encounterTime,
      protection: draft.protection,
      outcome: Value(draft.outcome),
      notes: Value(draft.notes),
    ),
    draft.participants
        .map(
          (p) => EncounterWomenCompanion.insert(
            encounterId: 0, // se sobreescribe en el DAO
            womanId: p.womanId,
            relationshipType: Value(p.relationshipType),
          ),
        )
        .toList(),
  );

  /// Actualiza un encuentro y reemplaza sus participantes.
  Future<void> update(int id, EncounterDraft draft) async {
    final existing = await _dao.getById(id);
    if (existing == null) return;
    await _dao.updateEncounterWithWomen(
      existing.copyWith(
        encounterTime: draft.encounterTime,
        protection: draft.protection,
        outcome: Value(draft.outcome),
        notes: draft.notes,
      ),
      draft.participants
          .map(
            (p) => EncounterWomenCompanion.insert(
              encounterId: id,
              womanId: p.womanId,
              relationshipType: Value(p.relationshipType),
            ),
          )
          .toList(),
    );
  }

  /// Elimina un encuentro y sus participantes.
  Future<void> delete(int id) => _dao.deleteEncounter(id);
}
