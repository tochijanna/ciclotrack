import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/woman_draft.dart';
import 'women_dao.dart';

/// Perfil con sus etiquetas para presentación en UI.
class WomanProfile {
  const WomanProfile({required this.woman, required this.tags});

  final Woman woman;
  final List<String> tags;
}

/// Repositorio que orquesta acceso a perfiles y etiquetas.
class WomenRepository {
  WomenRepository(this._dao);

  final WomenDao _dao;

  // --- Observación ---

  /// Stream de todos los perfiles ordenados con sus etiquetas.
  Stream<List<WomanProfile>> watchAllProfiles() {
    return _dao.watchAllWithTags().map((rows) {
      final profiles = <int, WomanProfile>{};
      for (final row in rows) {
        final current = profiles[row.woman.id];
        if (current == null) {
          profiles[row.woman.id] = WomanProfile(
            woman: row.woman,
            tags: row.tag == null ? [] : [row.tag!.name],
          );
        } else if (row.tag != null) {
          profiles[row.woman.id] = WomanProfile(
            woman: current.woman,
            tags: [...current.tags, row.tag!.name],
          );
        }
      }
      return profiles.values.toList();
    });
  }

  /// Stream de todas las etiquetas disponibles.
  Stream<List<Tag>> watchAllTags() => _dao.watchAllTags();

  // --- CRUD ---

  /// Crea un perfil nuevo. Devuelve el id asignado.
  Future<int> create(WomanDraft draft) async {
    final id = await _dao.insert(
      WomenCompanion.insert(
        name: draft.name,
        initials: draft.initials,
        emoji: Value(draft.emoji),
        color: Value(draft.color),
        privateNotes: Value(draft.privateNotes),
        sortOrder: Value(draft.sortOrder),
        createdAt: DateTime.now(),
      ),
    );
    await _dao.replaceTags(id, draft.tags);
    return id;
  }

  /// Actualiza un perfil existente.
  Future<void> update(int id, WomanDraft draft) async {
    final existing = await _dao.getById(id);
    if (existing == null) return;
    await _dao.updateWoman(
      existing.copyWith(
        name: draft.name,
        initials: draft.initials,
        emoji: draft.emoji,
        color: draft.color,
        privateNotes: draft.privateNotes,
      ),
    );
    await _dao.replaceTags(id, draft.tags);
  }

  /// Elimina un perfil y todos sus datos dependientes de forma transaccional.
  Future<void> delete(int id) => _dao.deleteWomanCascade(id);

  /// Reordena perfiles persistiendo sortOrder según el orden de la lista.
  Future<void> reorder(List<Woman> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      if (ordered[i].sortOrder != i) {
        await _dao.updateOrder(ordered[i].id, i);
      }
    }
  }
}
