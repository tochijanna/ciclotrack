import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/app_database_provider.dart';
import '../../../profiles/data/women_repository.dart';
import '../../../profiles/presentation/providers/women_providers.dart';
import '../../data/medication_dao.dart';
import '../../data/medication_repository.dart';

final medicationDaoProvider = Provider<MedicationDao>(
  (ref) => MedicationDao(ref.watch(appDatabaseProvider)),
);
final medicationRepositoryProvider = Provider<MedicationRepository>(
  (ref) => MedicationRepository(ref.watch(medicationDaoProvider)),
);
final medicationsProvider = StreamProvider.autoDispose<List<Medication>>(
  (ref) => ref.watch(medicationRepositoryProvider).watchAll(),
);
final medicationsByWomanProvider = StreamProvider.autoDispose
    .family<List<Medication>, int>(
      (ref, id) => ref.watch(medicationRepositoryProvider).watchByWoman(id),
    );
final enabledMedicationsByWomanProvider = StreamProvider.autoDispose
    .family<List<Medication>, int>(
      (ref, id) =>
          ref.watch(medicationRepositoryProvider).watchEnabledByWoman(id),
    );
final medicationWomenProvider = StreamProvider.autoDispose<List<WomanProfile>>(
  (ref) => ref.watch(womenRepositoryProvider).watchAllProfiles(),
);
