import 'package:ciclotrack/l10n/app_localizations.dart';

import '../domain/encounter_validators.dart';

/// Mensaje localizado de un error de validación de encuentro.
String encounterErrorText(AppLocalizations l10n, EncounterFieldError error) {
  switch (error) {
    case EncounterFieldError.futureDate:
      return l10n.encounterTimeFuture;
    case EncounterFieldError.invalidProtection:
      return l10n.encounterProtectionInvalid;
    case EncounterFieldError.participantsRequired:
      return l10n.encounterParticipantsRequired;
    case EncounterFieldError.duplicateParticipants:
      return l10n.encounterParticipantsDuplicate;
    case EncounterFieldError.invalidRelationship:
      return l10n.encounterRelationshipInvalid;
    case EncounterFieldError.invalidOutcome:
      return l10n.encounterOutcomeInvalid;
  }
}

/// Etiqueta localizada de un tipo de protección persistido.
String localizedProtection(AppLocalizations l10n, String value) {
  switch (value) {
    case 'Condón':
      return l10n.protectionCondom;
    case 'Pastilla':
      return l10n.protectionPill;
    case 'Natural':
      return l10n.protectionNatural;
    case 'Ninguno':
      return l10n.protectionNone;
    default:
      return value;
  }
}

/// Etiqueta localizada de un tipo de relación persistido.
String localizedRelationship(AppLocalizations l10n, String value) {
  switch (value) {
    case 'Vaginal':
      return l10n.relationshipVaginal;
    case 'Oral':
      return l10n.relationshipOral;
    case 'Anal':
      return l10n.relationshipAnal;
    case 'Otro':
      return l10n.relationshipOther;
    default:
      return value;
  }
}

/// Etiqueta localizada de un resultado de encuentro persistido.
String localizedOutcome(AppLocalizations l10n, String? value) {
  switch (value) {
    case 'Nada':
      return l10n.outcomeNothing;
    case 'Embarazo':
      return l10n.outcomePregnancy;
    case 'Aborto':
      return l10n.outcomeAbortion;
    case 'Desconocido':
      return l10n.outcomeUnknown;
    default:
      return value ?? '';
  }
}
