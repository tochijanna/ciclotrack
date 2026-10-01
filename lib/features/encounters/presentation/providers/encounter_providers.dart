import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database_provider.dart';
import '../../../profiles/data/women_dao.dart';
import '../../../profiles/data/women_repository.dart';
import '../../data/encounter_dao.dart';
import '../../data/encounter_repository.dart';
import '../../domain/encounter_event.dart';

// --- Providers base ---

final encounterDaoProvider = Provider<EncounterDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return EncounterDao(db);
});

final encounterRepositoryProvider = Provider<EncounterRepository>((ref) {
  final dao = ref.watch(encounterDaoProvider);
  return EncounterRepository(dao);
});

// --- Lista global ---

final allEncountersProvider =
    StreamProvider.autoDispose<List<EncounterWithWomen>>((ref) {
      final repo = ref.watch(encounterRepositoryProvider);
      return repo.watchAll();
    });

// --- Lista filtrada por mujer ---

final encountersByWomanProvider = StreamProvider.autoDispose
    .family<List<EncounterWithWomen>, int>((ref, womanId) {
      final repo = ref.watch(encounterRepositoryProvider);
      return repo.watchByWoman(womanId);
    });

// --- Mujeres disponibles para el formulario ---

final availableWomenForEncounterProvider =
    FutureProvider.autoDispose<List<WomanProfile>>((ref) async {
      final db = ref.watch(appDatabaseProvider);
      final repo = WomenRepository(WomenDao(db));
      return repo.watchAllProfiles().first;
    });
