// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_dao.dart';

// ignore_for_file: type=lint
mixin _$TrackingDaoMixin on DatabaseAccessor<AppDatabase> {
  $WomenTable get women => attachedDatabase.women;
  $PeriodLogsTable get periodLogs => attachedDatabase.periodLogs;
  $OvulationLogsTable get ovulationLogs => attachedDatabase.ovulationLogs;
  $SymptomsTable get symptoms => attachedDatabase.symptoms;
  TrackingDaoManager get managers => TrackingDaoManager(this);
}

class TrackingDaoManager {
  final _$TrackingDaoMixin _db;
  TrackingDaoManager(this._db);
  $$WomenTableTableManager get women =>
      $$WomenTableTableManager(_db.attachedDatabase, _db.women);
  $$PeriodLogsTableTableManager get periodLogs =>
      $$PeriodLogsTableTableManager(_db.attachedDatabase, _db.periodLogs);
  $$OvulationLogsTableTableManager get ovulationLogs =>
      $$OvulationLogsTableTableManager(_db.attachedDatabase, _db.ovulationLogs);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db.attachedDatabase, _db.symptoms);
}
