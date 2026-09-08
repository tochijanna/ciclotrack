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
    return _dao.watchAll().asyncMap(_enrichEncounters);
  }

  /// Stream de encuentros de una mujer concreta.
  Stream<List<EncounterWithWomen>> watchByWoman(int womanId) {
    return _dao.watchByWoman(womanId).asyncMap(_enrichEncounters);
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

  Future<List<EncounterWithWomen>> _enrichEncounters(
    List<Encounter> encounters,
  ) async {
    final result = <EncounterWithWomen>[];
    for (final e in encounters) {
      final participants = await _dao.watchParticipantsWithWoman(e.id).first;
      result.add(_mapEncounter(e, participants));
    }
    return result;
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
