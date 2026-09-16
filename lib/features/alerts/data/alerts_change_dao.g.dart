// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_change_dao.dart';

// ignore_for_file: type=lint
mixin _$AlertsChangeDaoMixin on DatabaseAccessor<AppDatabase> {
  $WomenTable get women => attachedDatabase.women;
  $PeriodLogsTable get periodLogs => attachedDatabase.periodLogs;
  $EncountersTable get encounters => attachedDatabase.encounters;
  $EncounterWomenTable get encounterWomen => attachedDatabase.encounterWomen;
  $AlertSettingsTable get alertSettings => attachedDatabase.alertSettings;
  AlertsChangeDaoManager get managers => AlertsChangeDaoManager(this);
}

class AlertsChangeDaoManager {
  final _$AlertsChangeDaoMixin _db;
  AlertsChangeDaoManager(this._db);
  $$WomenTableTableManager get women =>
      $$WomenTableTableManager(_db.attachedDatabase, _db.women);
  $$PeriodLogsTableTableManager get periodLogs =>
      $$PeriodLogsTableTableManager(_db.attachedDatabase, _db.periodLogs);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db.attachedDatabase, _db.encounters);
  $$EncounterWomenTableTableManager get encounterWomen =>
      $$EncounterWomenTableTableManager(
        _db.attachedDatabase,
        _db.encounterWomen,
      );
  $$AlertSettingsTableTableManager get alertSettings =>
      $$AlertSettingsTableTableManager(_db.attachedDatabase, _db.alertSettings);
}
