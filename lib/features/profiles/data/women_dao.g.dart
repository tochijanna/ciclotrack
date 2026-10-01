// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'women_dao.dart';

// ignore_for_file: type=lint
mixin _$WomenDaoMixin on DatabaseAccessor<AppDatabase> {
  $WomenTable get women => attachedDatabase.women;
  $TagsTable get tags => attachedDatabase.tags;
  $WomanTagsTable get womanTags => attachedDatabase.womanTags;
  $PeriodLogsTable get periodLogs => attachedDatabase.periodLogs;
  $OvulationLogsTable get ovulationLogs => attachedDatabase.ovulationLogs;
  $SymptomsTable get symptoms => attachedDatabase.symptoms;
  $EncountersTable get encounters => attachedDatabase.encounters;
  $EncounterWomenTable get encounterWomen => attachedDatabase.encounterWomen;
  $RemindersTable get reminders => attachedDatabase.reminders;
  WomenDaoManager get managers => WomenDaoManager(this);
}

class WomenDaoManager {
  final _$WomenDaoMixin _db;
  WomenDaoManager(this._db);
  $$WomenTableTableManager get women =>
      $$WomenTableTableManager(_db.attachedDatabase, _db.women);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$WomanTagsTableTableManager get womanTags =>
      $$WomanTagsTableTableManager(_db.attachedDatabase, _db.womanTags);
  $$PeriodLogsTableTableManager get periodLogs =>
      $$PeriodLogsTableTableManager(_db.attachedDatabase, _db.periodLogs);
  $$OvulationLogsTableTableManager get ovulationLogs =>
      $$OvulationLogsTableTableManager(_db.attachedDatabase, _db.ovulationLogs);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db.attachedDatabase, _db.symptoms);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db.attachedDatabase, _db.encounters);
  $$EncounterWomenTableTableManager get encounterWomen =>
      $$EncounterWomenTableTableManager(
        _db.attachedDatabase,
        _db.encounterWomen,
      );
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
}
