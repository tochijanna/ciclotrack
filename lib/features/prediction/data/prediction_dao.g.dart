// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_dao.dart';

// ignore_for_file: type=lint
mixin _$PredictionDaoMixin on DatabaseAccessor<AppDatabase> {
  $WomenTable get women => attachedDatabase.women;
  $PeriodLogsTable get periodLogs => attachedDatabase.periodLogs;
  PredictionDaoManager get managers => PredictionDaoManager(this);
}

class PredictionDaoManager {
  final _$PredictionDaoMixin _db;
  PredictionDaoManager(this._db);
  $$WomenTableTableManager get women =>
      $$WomenTableTableManager(_db.attachedDatabase, _db.women);
  $$PeriodLogsTableTableManager get periodLogs =>
      $$PeriodLogsTableTableManager(_db.attachedDatabase, _db.periodLogs);
}
