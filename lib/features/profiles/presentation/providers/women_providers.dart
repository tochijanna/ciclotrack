import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/app_database_provider.dart';
import '../../data/women_dao.dart';
import '../../data/women_repository.dart';
import '../../domain/woman_draft.dart';

// --- Providers base ---

final womenDaoProvider = Provider<WomenDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WomenDao(db);
});

final womenRepositoryProvider = Provider<WomenRepository>((ref) {
  final dao = ref.watch(womenDaoProvider);
  return WomenRepository(dao);
});

// --- Filtro de etiquetas ---

/// Estado del filtro: null = todas, String = etiqueta concreta.
class WomenFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? tag) => state = tag;
  void clear() => state = null;
}

final womenFilterProvider = NotifierProvider<WomenFilterNotifier, String?>(
  WomenFilterNotifier.new,
);

// --- Lista de perfiles ---

class WomenListNotifier extends AsyncNotifier<List<WomanProfile>> {
  @override
  Future<List<WomanProfile>> build() async {
    final repo = ref.watch(womenRepositoryProvider);
    final filter = ref.watch(womenFilterProvider);

    // Escuchamos el stream base y aplicamos filtro en memoria.
    final profiles = await repo.watchAllProfiles().first;

    if (filter == null || filter.isEmpty) return profiles;

    return profiles.where((p) => p.tags.contains(filter)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<int> create(WomanDraft draft) async {
    final repo = ref.read(womenRepositoryProvider);
    final id = await repo.create(draft);
    await refresh();
    return id;
  }

  Future<void> updateProfile(int id, WomanDraft draft) async {
    final repo = ref.read(womenRepositoryProvider);
    await repo.update(id, draft);
    await refresh();
  }

  Future<void> deleteProfile(int id) async {
    final repo = ref.read(womenRepositoryProvider);
    await repo.delete(id);
    await refresh();
  }

  Future<void> reorder(List<Woman> ordered) async {
    final repo = ref.read(womenRepositoryProvider);
    await repo.reorder(ordered);
    await refresh();
  }
}

final womenListProvider =
    AsyncNotifierProvider<WomenListNotifier, List<WomanProfile>>(
      WomenListNotifier.new,
    );

// --- Etiquetas disponibles ---

final availableTagsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(womenRepositoryProvider);
  final tags = await repo.watchAllTags().first;
  return tags.map((t) => t.name).toList();
});
