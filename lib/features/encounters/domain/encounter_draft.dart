/// Participante individual de un encuentro.
class EncounterParticipantDraft {
  const EncounterParticipantDraft({
    required this.womanId,
    required this.relationshipType,
  });

  final int womanId;
  final String relationshipType;

  EncounterParticipantDraft copyWith({int? womanId, String? relationshipType}) {
    return EncounterParticipantDraft(
      womanId: womanId ?? this.womanId,
      relationshipType: relationshipType ?? this.relationshipType,
    );
  }
}

/// Modelo inmutable para crear/editar un encuentro.
class EncounterDraft {
  const EncounterDraft({
    required this.encounterTime,
    required this.protection,
    required this.participants,
    this.outcome,
    this.notes = '',
  });

  final DateTime encounterTime;
  final String protection;
  final List<EncounterParticipantDraft> participants;
  final String? outcome;
  final String notes;

  EncounterDraft copyWith({
    DateTime? encounterTime,
    String? protection,
    List<EncounterParticipantDraft>? participants,
    String? outcome,
    String? notes,
  }) {
    return EncounterDraft(
      encounterTime: encounterTime ?? this.encounterTime,
      protection: protection ?? this.protection,
      participants: participants ?? this.participants,
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
    );
  }
}
