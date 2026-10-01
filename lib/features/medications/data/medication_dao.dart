import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'medication_dao.g.dart';

@DriftAccessor(tables: [Medications])
class MedicationDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationDaoMixin {
  MedicationDao(super.db);

  Stream<List<Medication>> watchAll() =>
      (select(medications)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

  Stream<List<Medication>> watchByWoman(int womanId) =>
      (select(medications)
            ..where((t) => t.womanId.equals(womanId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Stream<List<Medication>> watchEnabledByWoman(int womanId) =>
      (select(medications)
            ..where((t) => t.womanId.equals(womanId) & t.enabled.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<int> insert(MedicationsCompanion entry) =>
      into(medications).insert(entry);

  Future<void> updateMedication(Medication entry) =>
      update(medications).replace(entry);

  Future<void> deleteMedication(int id) =>
      (delete(medications)..where((t) => t.id.equals(id))).go();
}
