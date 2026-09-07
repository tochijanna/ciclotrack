import 'woman_draft.dart';

/// Errores de validación devueltos por [validateWomanDraft].
class WomanValidationErrors {
  const WomanValidationErrors({this.name, this.initials});

  final String? name;
  final String? initials;

  bool get isValid => name == null && initials == null;
}

/// Valida un borrador de perfil.
WomanValidationErrors validateWomanDraft(WomanDraft draft) {
  String? nameError;
  String? initialsError;

  final trimmedName = draft.name.trim();
  if (trimmedName.isEmpty) {
    nameError = 'El nombre es obligatorio';
  } else if (trimmedName.length < 2) {
    nameError = 'El nombre debe tener al menos 2 caracteres';
  }

  final trimmedInitials = draft.initials.trim();
  if (trimmedInitials.isEmpty) {
    initialsError = 'Las iniciales son obligatorias';
  } else if (trimmedInitials.length > 4) {
    initialsError = 'Las iniciales no pueden tener más de 4 caracteres';
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
