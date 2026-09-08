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
    AlertSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(tags);
        await m.createTable(womanTags);
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
        await customStatement('ALTER TABLE women DROP COLUMN tag');
      }
      if (from < 3) {
        await m.createTable(alertSettings);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(name: 'ciclotrack');
}
