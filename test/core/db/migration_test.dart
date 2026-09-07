import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';

void main() {
  late AppDatabase db;
  late WomenDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = WomenDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('schema v2', () {
    test('schemaVersion is 2', () {
      expect(db.schemaVersion, 2);
    });

    test('tags and woman_tags tables exist', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();
      expect(tableNames, containsAll(['tags', 'woman_tags']));
      expect(tableNames.length, 9);
    });
  });

  group('tags N:M', () {
    test('create and link tags to a woman', () async {
      final womanId = await dao.insert(
        WomenCompanion.insert(
          name: 'María',
          initials: 'MR',
          createdAt: DateTime(2026, 9, 1),
        ),
      );

      await dao.replaceTags(womanId, ['Amiga', 'Relacionada']);

      final tags = await dao.watchTagsForWoman(womanId).first;
      final names = tags.map((t) => t.name).toList();
      expect(names, containsAll(['Amiga', 'Relacionada']));
    });

    test('replaceTags replaces existing links', () async {
      final womanId = await dao.insert(
        WomenCompanion.insert(
          name: 'Ana',
          initials: 'AN',
          createdAt: DateTime(2026, 9, 1),
        ),
      );

      await dao.replaceTags(womanId, ['Ex']);
      await dao.replaceTags(womanId, ['Amiga', 'Casual']);

      final tags = await dao.watchTagsForWoman(womanId).first;
      final names = tags.map((t) => t.name).toList();
      expect(names, containsAll(['Amiga', 'Casual']));
      expect(names, isNot(contains('Ex')));
    });

    test('getOrCreateTag reuses existing tag', () async {
      final id1 = await dao.getOrCreateTag('Amiga');
      final id2 = await dao.getOrCreateTag('Amiga');
      expect(id1, id2);

      final id3 = await dao.getOrCreateTag('Ex');
      expect(id3, isNot(id1));
    });

    test('delete woman cascades to woman_tags', () async {
      final womanId = await dao.insert(
        WomenCompanion.insert(
          name: 'Borrar',
          initials: 'BR',
          createdAt: DateTime(2026, 9, 1),
        ),
      );
      await dao.replaceTags(womanId, ['Amiga']);

      await dao.deleteWoman(womanId);

      final tags = await dao.watchTagsForWoman(womanId).first;
      expect(tags, isEmpty);

      // Tag itself still exists.
      final allTags = await dao.allTags();
      expect(allTags.map((t) => t.name), contains('Amiga'));
    });
  });
}
