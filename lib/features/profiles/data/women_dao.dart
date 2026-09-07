import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'women_dao.g.dart';

@DriftAccessor(tables: [Women, Tags, WomanTags])
class WomenDao extends DatabaseAccessor<AppDatabase> with _$WomenDaoMixin {
  WomenDao(super.db);

  // --- Women CRUD ---

  Stream<List<Woman>> watchAllOrdered() =>
      (select(women)..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
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

  // --- Tags ---

  Stream<List<Tag>> watchAllTags() => select(tags).get().asStream();

  Future<List<Tag>> allTags() => select(tags).get();

  Future<Tag?> tagByName(String name) =>
      (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();

  Future<int> insertTag(String name) =>
      into(tags).insert(TagsCompanion.insert(name: name));

  Future<int> getOrCreateTag(String name) async {
    final existing = await tagByName(name);
    if (existing != null) return existing.id;
    return insertTag(name);
  }

  // --- Woman ↔ Tag links ---

  Stream<List<Tag>> watchTagsForWoman(int womanId) {
    final query = select(tags).join([
      innerJoin(womanTags, womanTags.tagId.equalsExp(tags.id)),
    ])..where(womanTags.womanId.equals(womanId));
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(tags)).toList(),
    );
  }

  Future<void> replaceTags(int womanId, List<String> tagNames) async {
    await (delete(womanTags)..where((t) => t.womanId.equals(womanId))).go();
    for (final name in tagNames) {
      final tagId = await getOrCreateTag(name);
      await into(
        womanTags,
      ).insert(WomanTagsCompanion.insert(womanId: womanId, tagId: tagId));
    }
  }

  Future<void> unlinkAllTags(int womanId) =>
      (delete(womanTags)..where((t) => t.womanId.equals(womanId))).go();
}
