// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'women_dao.dart';

// ignore_for_file: type=lint
mixin _$WomenDaoMixin on DatabaseAccessor<AppDatabase> {
  $WomenTable get women => attachedDatabase.women;
  $TagsTable get tags => attachedDatabase.tags;
  $WomanTagsTable get womanTags => attachedDatabase.womanTags;
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
}
