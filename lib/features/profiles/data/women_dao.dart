import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'women_dao.g.dart';

@DriftAccessor(tables: [Women])
class WomenDao extends DatabaseAccessor<AppDatabase> with _$WomenDaoMixin {
  WomenDao(super.db);

  Stream<List<Woman>> watchAllOrdered() =>
      (select(women)..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
          .watch();

  Stream<List<Woman>> watchByTag(String tag) =>
      (select(women)
            ..where((t) => t.tag.equals(tag))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  Future<Woman?> getById(int id) =>
      (select(women)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insert(WomenCompanion entry) => into(women).insert(entry);

  Future<void> updateWoman(Woman entry) => update(women).replace(entry);

  Future<void> updateOrder(int id, int sortOrder) =>
      (update(women)..where((t) => t.id.equals(id))).write(
        WomenCompanion(sortOrder: Value(sortOrder)),
      );

  Future<void> deleteWoman(int id) =>
      (delete(women)..where((t) => t.id.equals(id))).go();
}
