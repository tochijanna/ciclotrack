import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/alerts/data/alert_settings_dao.dart';
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

  group('schema v3', () {
    test('schemaVersion is 3', () {
      expect(db.schemaVersion, 3);
    });

    test('alert_settings table exists', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();
      expect(tableNames, contains('alert_settings'));
      expect(tableNames.length, 10);
    });
  });

  group('alert_settings', () {
    test('getOrCreate creates singleton row', () async {
      final settingsDao = AlertSettingsDao(db);
      final settings = await settingsDao.getOrCreate();
      expect(settings.id, 1);
      expect(settings.masterEnabled, true);
      expect(settings.notifyHour, 9);
      expect(settings.notifyMinute, 0);
      expect(settings.horizonDays, 7);
    });

    test('getOrCreate returns existing row on second call', () async {
      final settingsDao = AlertSettingsDao(db);
      final first = await settingsDao.getOrCreate();
      await settingsDao.updateSettings(first.copyWith(masterEnabled: false));
      final second = await settingsDao.getOrCreate();
      expect(second.masterEnabled, false);
    });

    test('watchSettings emits updates', () async {
      final settingsDao = AlertSettingsDao(db);
      await settingsDao.ensureCreated();

      final values = <bool>[];
      final sub = settingsDao.watchSettings().listen((s) {
        if (s != null) values.add(s.masterEnabled);
      });

      await settingsDao.updateSettings(
        (await settingsDao.getOrCreate()).copyWith(masterEnabled: false),
      );
      await pumpEventQueue();

      await sub.cancel();
      expect(values, contains(false));
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
