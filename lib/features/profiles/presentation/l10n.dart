import 'package:ciclotrack/l10n/app_localizations.dart';

import '../domain/woman_validator.dart';

/// Mensaje localizado de un error de validación de perfil.
String womanFieldErrorText(AppLocalizations l10n, WomanFieldError error) {
  switch (error) {
    case WomanFieldError.nameRequired:
      return l10n.womanNameRequired;
    case WomanFieldError.nameTooShort:
      return l10n.womanNameTooShort;
    case WomanFieldError.initialsRequired:
      return l10n.womanInitialsRequired;
    case WomanFieldError.initialsTooLong:
      return l10n.womanInitialsTooLong;
  }
}

/// Etiqueta localizada para una etiqueta estable. Devuelve la etiqueta
/// localizada de las 6 sugeridas y, para cualquier otro valor (etiqueta
/// personalizada), devuelve [stableKey] tal cual.
String suggestedTagLabel(AppLocalizations l10n, String stableKey) {
  switch (stableKey) {
    case 'Relacionada':
      return l10n.tagRelated;
    case 'Amiga':
      return l10n.tagFriend;
    case 'Ex':
      return l10n.tagEx;
    case 'Compañera':
      return l10n.tagCoworker;
    case 'Casual':
      return l10n.tagCasual;
    case 'Otro':
      return l10n.tagOther;
    default:
      return stableKey;
  }
}
