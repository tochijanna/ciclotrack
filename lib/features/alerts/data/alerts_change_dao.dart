import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'alerts_change_dao.g.dart';

/// Stream ligero que se activa cuando cambian datos relevantes para alertas.
@DriftAccessor(
  tables: [Women, PeriodLogs, Encounters, EncounterWomen, AlertSettings],
)
class AlertsChangeDao extends DatabaseAccessor<AppDatabase>
    with _$AlertsChangeDaoMixin {
  AlertsChangeDao(super.db);

  Stream<void> watchRelevantChanges() {
    return customSelect(
      'SELECT 1 AS change_id',
      readsFrom: {women, periodLogs, encounters, encounterWomen, alertSettings},
    ).watch().map((_) {});
  }
}
