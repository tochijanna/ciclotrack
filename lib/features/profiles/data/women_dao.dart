import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'women_dao.g.dart';

@DriftAccessor(
  tables: [
    Women,
    Tags,
    WomanTags,
    PeriodLogs,
    OvulationLogs,
    Symptoms,
    Encounters,
    EncounterWomen,
    Reminders,
  ],
)
class WomenDao extends DatabaseAccessor<AppDatabase> with _$WomenDaoMixin {
  WomenDao(super.db);

  // --- Women CRUD ---

  Stream<List<Woman>> watchAllOrdered() =>
      (select(women)..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
          .watch();

  Stream<List<WomanWithTag>> watchAllWithTags() {
    final query =
        select(women).join([
          leftOuterJoin(womanTags, womanTags.womanId.equalsExp(women.id)),
          leftOuterJoin(tags, tags.id.equalsExp(womanTags.tagId)),
        ])..orderBy([
          OrderingTerm(expression: women.sortOrder),
          OrderingTerm(expression: women.name),
        ]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => WomanWithTag(
              woman: row.readTable(women),
              tag: row.readTableOrNull(tags),
            ),
          )
          .toList(),
    );
  }

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

  /// Elimina una mujer y todos sus datos dependientes en una única
  /// transacción. Compatible tanto con bases nuevas (ON DELETE CASCADE) como
  /// con bases migradas desde v1 que conservan las restricciones antiguas.
  Future<void> deleteWomanCascade(int id) {
    return transaction(() async {
      await (delete(womanTags)..where((t) => t.womanId.equals(id))).go();
      await (delete(periodLogs)..where((t) => t.womanId.equals(id))).go();
      await (delete(ovulationLogs)..where((t) => t.womanId.equals(id))).go();
      await (delete(symptoms)..where((t) => t.womanId.equals(id))).go();
      final linked = await (select(
        encounterWomen,
      )..where((t) => t.womanId.equals(id))).get();
      for (final link in linked) {
        final participants = await (select(
          encounterWomen,
        )..where((t) => t.encounterId.equals(link.encounterId))).get();
        if (participants.length <= 1) {
          await (delete(
            encounterWomen,
          )..where((t) => t.encounterId.equals(link.encounterId))).go();
          await (delete(
            encounters,
          )..where((t) => t.id.equals(link.encounterId))).go();
        } else {
          await (delete(encounterWomen)..where(
                (t) =>
                    t.encounterId.equals(link.encounterId) &
                    t.womanId.equals(id),
              ))
              .go();
        }
      }
      await (delete(reminders)..where((t) => t.womanId.equals(id))).go();
      await (delete(women)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Tags ---

  Stream<List<Tag>> watchAllTags() => select(tags).watch();

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

class WomanWithTag {
  const WomanWithTag({required this.woman, this.tag});

  final Woman woman;
  final Tag? tag;
}
