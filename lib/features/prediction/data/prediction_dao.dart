import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'prediction_dao.g.dart';

/// DAO de solo lectura para obtener registros de periodo necesarios
/// para la predicción.
@DriftAccessor(tables: [PeriodLogs])
class PredictionDao extends DatabaseAccessor<AppDatabase>
    with _$PredictionDaoMixin {
  PredictionDao(super.db);

  /// Stream de registros de periodo de una mujer, ordenados por fecha
  /// de inicio ascendente (necesario para el cálculo de ciclos).
  Stream<List<PeriodLog>> watchPeriodLogsByWoman(int womanId) =>
      (select(periodLogs)
            ..where((t) => t.womanId.equals(womanId))
            ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
          .watch();
}
