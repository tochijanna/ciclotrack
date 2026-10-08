import 'encounter_draft.dart';
import 'encounter_options.dart';

/// Errores de validación de un encuentro, independientes del idioma.
enum EncounterFieldError {
  futureDate,
  invalidProtection,
  participantsRequired,
  duplicateParticipants,
  invalidRelationship,
  invalidOutcome,
}

/// Errores de validación devueltos por [validateEncounterDraft].
class EncounterValidationErrors {
  const EncounterValidationErrors({
    this.encounterTime,
    this.protection,
    this.participants,
    this.outcome,
    this.relationshipType,
  });

  final EncounterFieldError? encounterTime;
  final EncounterFieldError? protection;
  final EncounterFieldError? participants;
  final EncounterFieldError? outcome;
  final EncounterFieldError? relationshipType;

  bool get isValid =>
      encounterTime == null &&
      protection == null &&
      participants == null &&
      outcome == null &&
      relationshipType == null;
}

/// Valida un borrador de encuentro.
EncounterValidationErrors validateEncounterDraft(EncounterDraft draft) {
  EncounterFieldError? timeError;
  EncounterFieldError? protectionError;
  EncounterFieldError? participantsError;
  EncounterFieldError? outcomeError;
  EncounterFieldError? relTypeError;

  if (draft.encounterTime.isAfter(DateTime.now())) {
    timeError = EncounterFieldError.futureDate;
  }

  if (!protectionOptions.contains(draft.protection)) {
    protectionError = EncounterFieldError.invalidProtection;
  }

  if (draft.participants.isEmpty) {
    participantsError = EncounterFieldError.participantsRequired;
  } else {
    final ids = draft.participants.map((p) => p.womanId).toSet();
    if (ids.length != draft.participants.length) {
      participantsError = EncounterFieldError.duplicateParticipants;
    }
    for (final p in draft.participants) {
      if (!relationshipTypeOptions.contains(p.relationshipType)) {
        relTypeError = EncounterFieldError.invalidRelationship;
        break;
      }
    }
  }

  if (draft.outcome != null && !outcomeOptions.contains(draft.outcome)) {
    outcomeError = EncounterFieldError.invalidOutcome;
  }

  return EncounterValidationErrors(
    encounterTime: timeError,
    protection: protectionError,
    participants: participantsError,
    outcome: outcomeError,
    relationshipType: relTypeError,
  );
}
