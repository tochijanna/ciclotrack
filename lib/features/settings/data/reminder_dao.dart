import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Stream<List<Reminder>> watchAll() =>
      (select(reminders)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

  Stream<List<Reminder>> watchByWoman(int womanId) =>
      (select(reminders)
            ..where((t) => t.womanId.equals(womanId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<int> insert(RemindersCompanion entry) => into(reminders).insert(entry);

  Future<void> updateReminder(Reminder entry) =>
      update(reminders).replace(entry);

  Future<void> deleteReminder(int id) =>
      (delete(reminders)..where((t) => t.id.equals(id))).go();
}
