import 'package:drift/drift.dart';

@DataClassName('Woman')
class Women extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get initials => text()();
  TextColumn get emoji => text().withDefault(const Constant('👩'))();
  IntColumn get color => integer().withDefault(const Constant(0xFFE91E63))();
  TextColumn get privateNotes => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [];
}

@DataClassName('Tag')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
  ];
}

@DataClassName('WomanTag')
class WomanTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId =>
      integer().references(Women, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {womanId, tagId},
  ];
}

@DataClassName('PeriodLog')
class PeriodLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId =>
      integer().references(Women, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get flowLevel => integer().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('OvulationLog')
class OvulationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId =>
      integer().references(Women, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  RealColumn get temperature => real().nullable()();
  TextColumn get cervicalMucus => text().nullable()();
  BoolColumn get lhTest => boolean().nullable()();
}

@DataClassName('SymptomLog')
class Symptoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId =>
      integer().references(Women, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()();
  IntColumn get severity => integer().withDefault(const Constant(1))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('Encounter')
class Encounters extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get encounterTime => dateTime().named('date_time')();
  TextColumn get protection => text()();
  TextColumn get outcome => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('EncounterWoman')
class EncounterWomen extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get encounterId => integer().references(Encounters, #id)();
  IntColumn get womanId =>
      integer().references(Women, #id, onDelete: KeyAction.cascade)();
  TextColumn get relationshipType => text().withDefault(const Constant(''))();
}

@DataClassName('Reminder')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId =>
      integer().references(Women, #id, onDelete: KeyAction.cascade)();
  IntColumn get cycleDayStart => integer()();
  IntColumn get cycleDayEnd => integer()();
  TextColumn get message => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

/// Ajustes de alertas (fila singleton, id=1).
@DataClassName('AlertSetting')
class AlertSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get masterEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get notifyHour => integer().withDefault(const Constant(9))();
  IntColumn get notifyMinute => integer().withDefault(const Constant(0))();
  TextColumn get enabledTypes => text().withDefault(const Constant(''))();
  IntColumn get horizonDays => integer().withDefault(const Constant(7))();
}
