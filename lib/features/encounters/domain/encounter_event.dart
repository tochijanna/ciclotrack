/// Participante de un encuentro con datos de presentación.
class EncounterParticipant {
  const EncounterParticipant({
    required this.womanId,
    required this.womanName,
    required this.womanInitials,
    required this.womanEmoji,
    required this.womanColor,
    required this.relationshipType,
  });

  final int womanId;
  final String womanName;
  final String womanInitials;
  final String womanEmoji;
  final int womanColor;
  final String relationshipType;
}

/// Encuentro completo con participantes para presentación en UI.
class EncounterWithWomen {
  const EncounterWithWomen({
    required this.encounterId,
    required this.encounterTime,
    required this.protection,
    required this.participants,
    this.outcome,
    this.notes = '',
  });

  final int encounterId;
  final DateTime encounterTime;
  final String protection;
  final List<EncounterParticipant> participants;
  final String? outcome;
  final String notes;

  /// Nombres de las participantes separados por coma.
  String get participantNames =>
      participants.map((p) => p.womanName).join(', ');
}
