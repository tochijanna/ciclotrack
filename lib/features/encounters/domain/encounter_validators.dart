import 'encounter_draft.dart';
import 'encounter_options.dart';

/// Errores de validación devueltos por [validateEncounterDraft].
class EncounterValidationErrors {
  const EncounterValidationErrors({
    this.encounterTime,
    this.protection,
    this.participants,
    this.outcome,
    this.relationshipType,
  });

  final String? encounterTime;
  final String? protection;
  final String? participants;
  final String? outcome;
  final String? relationshipType;

  bool get isValid =>
      encounterTime == null &&
      protection == null &&
      participants == null &&
      outcome == null &&
      relationshipType == null;
}

/// Valida un borrador de encuentro.
EncounterValidationErrors validateEncounterDraft(EncounterDraft draft) {
  String? timeError;
  String? protectionError;
  String? participantsError;
  String? outcomeError;
  String? relTypeError;

  if (draft.encounterTime.isAfter(DateTime.now())) {
    timeError = 'La fecha no puede ser futura';
  }

  if (!protectionOptions.contains(draft.protection)) {
    protectionError = 'Protección no válida';
  }

  if (draft.participants.isEmpty) {
    participantsError = 'Debe haber al menos una participante';
  } else {
    final ids = draft.participants.map((p) => p.womanId).toSet();
    if (ids.length != draft.participants.length) {
      participantsError = 'No se pueden repetir participantes';
    }
    for (final p in draft.participants) {
      if (!relationshipTypeOptions.contains(p.relationshipType)) {
        relTypeError = 'Tipo de relación no válido';
        break;
      }
    }
  }

  if (draft.outcome != null && !outcomeOptions.contains(draft.outcome)) {
    outcomeError = 'Resultado no válido';
  }

  return EncounterValidationErrors(
    encounterTime: timeError,
    protection: protectionError,
    participants: participantsError,
    outcome: outcomeError,
    relationshipType: relTypeError,
  );
}
