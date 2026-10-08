import 'woman_draft.dart';

/// Errores de validación de un perfil, independientes del idioma.
enum WomanFieldError {
  nameRequired,
  nameTooShort,
  initialsRequired,
  initialsTooLong,
}

/// Errores de validación devueltos por [validateWomanDraft].
class WomanValidationErrors {
  const WomanValidationErrors({this.name, this.initials});

  final WomanFieldError? name;
  final WomanFieldError? initials;

  bool get isValid => name == null && initials == null;
}

/// Valida un borrador de perfil.
WomanValidationErrors validateWomanDraft(WomanDraft draft) {
  WomanFieldError? nameError;
  WomanFieldError? initialsError;

  final trimmedName = draft.name.trim();
  if (trimmedName.isEmpty) {
    nameError = WomanFieldError.nameRequired;
  } else if (trimmedName.length < 2) {
    nameError = WomanFieldError.nameTooShort;
  }

  final trimmedInitials = draft.initials.trim();
  if (trimmedInitials.isEmpty) {
    initialsError = WomanFieldError.initialsRequired;
  } else if (trimmedInitials.length > 4) {
    initialsError = WomanFieldError.initialsTooLong;
  }

  return WomanValidationErrors(name: nameError, initials: initialsError);
}

/// Genera iniciales automáticas a partir del nombre (hasta 2 palabras, mayúsculas).
String initialsFrom(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

/// Normaliza una lista de etiquetas: trim, dedup, quitar vacías.
List<String> normalizeTags(List<String> tags) {
  final seen = <String>{};
  final result = <String>[];
  for (final tag in tags) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && seen.add(trimmed)) {
      result.add(trimmed);
    }
  }
  return result;
}

/// Aplica defaults a un borrador: iniciales automáticas si están vacías.
WomanDraft applyDefaults(WomanDraft draft) {
  final initials = draft.initials.trim().isEmpty
      ? initialsFrom(draft.name)
      : draft.initials;
  final tags = normalizeTags(draft.tags);
  return draft.copyWith(
    name: draft.name.trim(),
    initials: initials,
    tags: tags,
  );
}
