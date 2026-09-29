import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'tracking_dao.g.dart';

@DriftAccessor(tables: [PeriodLogs, OvulationLogs, Symptoms])
class TrackingDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingDaoMixin {
  TrackingDao(super.db);

  Future<PeriodLog?> getPeriodLogById(int id) =>
      (select(periodLogs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertPeriodLog(PeriodLogsCompanion entry) =>
      into(periodLogs).insert(entry);

  Future<void> updatePeriodLog(PeriodLog entry) =>
      update(periodLogs).replace(entry);

  Future<void> deletePeriodLog(int id) =>
      (delete(periodLogs)..where((t) => t.id.equals(id))).go();

  Future<List<PeriodLog>> getPeriodLogsByWoman(int womanId) =>
      (select(periodLogs)..where((t) => t.womanId.equals(womanId))).get();

  Stream<List<PeriodLog>> watchPeriodLogsByWoman(int womanId) =>
      (select(periodLogs)
            ..where((t) => t.womanId.equals(womanId))
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .watch();

  Future<OvulationLog?> getOvulationLogById(int id) =>
      (select(ovulationLogs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOvulationLog(OvulationLogsCompanion entry) =>
      into(ovulationLogs).insert(entry);

  Future<void> updateOvulationLog(OvulationLog entry) =>
      update(ovulationLogs).replace(entry);

  Future<void> deleteOvulationLog(int id) =>
      (delete(ovulationLogs)..where((t) => t.id.equals(id))).go();

  Stream<List<OvulationLog>> watchOvulationLogsByWoman(int womanId) =>
      (select(ovulationLogs)
            ..where((t) => t.womanId.equals(womanId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<SymptomLog?> getSymptomLogById(int id) =>
      (select(symptoms)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertSymptomLog(SymptomsCompanion entry) =>
      into(symptoms).insert(entry);

  Future<void> updateSymptomLog(SymptomLog entry) =>
      update(symptoms).replace(entry);

  Future<void> deleteSymptomLog(int id) =>
      (delete(symptoms)..where((t) => t.id.equals(id))).go();

  Stream<List<SymptomLog>> watchSymptomLogsByWoman(int womanId) =>
      (select(symptoms)
            ..where((t) => t.womanId.equals(womanId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  // --- Lecturas globales (vistas consolidadas) ---
  //
  // Las vistas de calendario necesitan todos los registros de todas las
  // mujeres en un único stream; filtrar por rango se hace en memoria para no
  // re-suscribir la consulta al navegar entre meses.

  Stream<List<PeriodLog>> watchAllPeriodLogs() => (select(
    periodLogs,
  )..orderBy([(t) => OrderingTerm.asc(t.startDate)])).watch();

  Stream<List<OvulationLog>> watchAllOvulationLogs() => (select(
    ovulationLogs,
  )..orderBy([(t) => OrderingTerm.asc(t.date)])).watch();

  Stream<List<SymptomLog>> watchAllSymptomLogs() =>
      (select(symptoms)..orderBy([(t) => OrderingTerm.asc(t.date)])).watch();
}
