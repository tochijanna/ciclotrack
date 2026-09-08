// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_settings_dao.dart';

// ignore_for_file: type=lint
mixin _$AlertSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AlertSettingsTable get alertSettings => attachedDatabase.alertSettings;
  AlertSettingsDaoManager get managers => AlertSettingsDaoManager(this);
}

class AlertSettingsDaoManager {
  final _$AlertSettingsDaoMixin _db;
  AlertSettingsDaoManager(this._db);
  $$AlertSettingsTableTableManager get alertSettings =>
      $$AlertSettingsTableTableManager(_db.attachedDatabase, _db.alertSettings);
}
