import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('schema', () {
    test('creates all tables', () async {
      final tables = db.allTables.map((t) => t.actualTableName).toSet();
      expect(
        tables,
        containsAll({
          'women',
          'period_logs',
          'ovulation_logs',
          'symptoms',
          'encounters',
          'encounter_women',
          'reminders',
        }),
      );
    });
  });

  group('women dao', () {
    test('inserts and reads a woman', () async {
      final id = await db
          .into(db.women)
          .insert(
            WomenCompanion.insert(
              name: 'María',
              initials: 'MR',
              createdAt: DateTime(2026, 9, 1),
            ),
          );

      final woman = await (db.select(
        db.women,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(woman.name, 'María');
      expect(woman.emoji, '👩');
      expect(woman.sortOrder, 0);
      expect(woman.tag, '');
    });
  });

  group('tracking dao', () {
    test('inserts period log referenced to a woman', () async {
      final womanId = await db
          .into(db.women)
          .insert(
            WomenCompanion.insert(
              name: 'Ana',
              initials: 'AN',
              createdAt: DateTime(2026, 9, 1),
            ),
          );

      final start = DateTime(2026, 9, 10);
      await db
          .into(db.periodLogs)
          .insert(
            PeriodLogsCompanion.insert(
              womanId: womanId,
              startDate: start,
              endDate: Value(DateTime(2026, 9, 14)),
              flowLevel: const Value(3),
            ),
          );

      final logs = await (db.select(db.periodLogs)).get();
      expect(logs, hasLength(1));
      expect(logs.single.womanId, womanId);
      expect(logs.single.startDate, start);
      expect(logs.single.flowLevel, 3);
    });
  });

  group('encounter dao', () {
    test('inserts an encounter with multiple women via transaction', () async {
      final mariaId = await db
          .into(db.women)
          .insert(
            WomenCompanion.insert(
              name: 'María',
              initials: 'MR',
              createdAt: DateTime(2026, 9, 1),
            ),
          );
      final anaId = await db
          .into(db.women)
          .insert(
            WomenCompanion.insert(
              name: 'Ana',
              initials: 'AN',
              createdAt: DateTime(2026, 9, 1),
            ),
          );

      final encounterId = await db.transaction(() async {
        final id = await db
            .into(db.encounters)
            .insert(
              EncountersCompanion.insert(
                encounterTime: DateTime(2026, 9, 5, 21, 30),
                protection: 'condom',
              ),
            );
        for (final entry in [
          EncounterWomenCompanion.insert(
            encounterId: id,
            womanId: mariaId,
            relationshipType: const Value('vaginal'),
          ),
          EncounterWomenCompanion.insert(
            encounterId: id,
            womanId: anaId,
            relationshipType: const Value('oral'),
          ),
        ]) {
          await db.into(db.encounterWomen).insert(entry);
        }
        return id;
      });

      final rows = await (db.select(
        db.encounterWomen,
      )..where((t) => t.encounterId.equals(encounterId))).get();
      expect(rows, hasLength(2));
    });
  });
}
