import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
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
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Create new tag tables.
        await m.createTable(tags);
        await m.createTable(womanTags);

        // Migrate existing single-tag values to the new N:M structure.
        await customStatement(
          "INSERT INTO tags (name) SELECT DISTINCT tag FROM women "
          "WHERE tag <> '' AND tag IS NOT NULL",
        );
        await customStatement(
          'INSERT INTO woman_tags (woman_id, tag_id) '
          'SELECT w.id, t.id FROM women w '
          'INNER JOIN tags t ON w.tag = t.name '
          "WHERE w.tag <> '' AND w.tag IS NOT NULL",
        );

        // Remove the old single-tag column.
        await customStatement('ALTER TABLE women DROP COLUMN tag');

        // Note: onDelete cascade applies to fresh installs (onCreate).
        // Existing installs keep old FK constraints; cascade is enforced
        // at the repository level for those cases.
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(name: 'ciclotrack');
}
