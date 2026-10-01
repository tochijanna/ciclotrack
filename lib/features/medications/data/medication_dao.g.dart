// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicationDaoMixin on DatabaseAccessor<AppDatabase> {
  $WomenTable get women => attachedDatabase.women;
  $MedicationsTable get medications => attachedDatabase.medications;
  MedicationDaoManager get managers => MedicationDaoManager(this);
}

class MedicationDaoManager {
  final _$MedicationDaoMixin _db;
  MedicationDaoManager(this._db);
  $$WomenTableTableManager get women =>
      $$WomenTableTableManager(_db.attachedDatabase, _db.women);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
}
