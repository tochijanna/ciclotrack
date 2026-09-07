// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter_dao.dart';

// ignore_for_file: type=lint
mixin _$EncounterDaoMixin on DatabaseAccessor<AppDatabase> {
  $EncountersTable get encounters => attachedDatabase.encounters;
  $WomenTable get women => attachedDatabase.women;
  $EncounterWomenTable get encounterWomen => attachedDatabase.encounterWomen;
  EncounterDaoManager get managers => EncounterDaoManager(this);
}

class EncounterDaoManager {
  final _$EncounterDaoMixin _db;
  EncounterDaoManager(this._db);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db.attachedDatabase, _db.encounters);
  $$WomenTableTableManager get women =>
      $$WomenTableTableManager(_db.attachedDatabase, _db.women);
  $$EncounterWomenTableTableManager get encounterWomen =>
      $$EncounterWomenTableTableManager(
        _db.attachedDatabase,
        _db.encounterWomen,
      );
}
