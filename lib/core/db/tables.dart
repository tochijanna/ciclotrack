import 'package:drift/drift.dart';

@DataClassName('Woman')
class Women extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get initials => text()();
  TextColumn get emoji => text().withDefault(const Constant('👩'))();
  IntColumn get color => integer().withDefault(const Constant(0xFFE91E63))();
  TextColumn get tag => text().withDefault(const Constant(''))();
  TextColumn get privateNotes => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('PeriodLog')
class PeriodLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId => integer().references(Women, #id)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get flowLevel => integer().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('OvulationLog')
class OvulationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId => integer().references(Women, #id)();
  DateTimeColumn get date => dateTime()();
  RealColumn get temperature => real().nullable()();
  TextColumn get cervicalMucus => text().nullable()();
  BoolColumn get lhTest => boolean().nullable()();
}

@DataClassName('SymptomLog')
class Symptoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId => integer().references(Women, #id)();
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
  IntColumn get womanId => integer().references(Women, #id)();
  TextColumn get relationshipType => text().withDefault(const Constant(''))();
}

@DataClassName('Reminder')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get womanId => integer().references(Women, #id)();
  IntColumn get cycleDayStart => integer()();
  IntColumn get cycleDayEnd => integer()();
  TextColumn get message => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}
