import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

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

  test('upgrades a real v1 database through v2 to v3', () async {
    await db.close();
    final directory = await Directory.systemTemp.createTemp(
      'ciclotrack_migration_',
    );
    final file = File('${directory.path}/legacy.sqlite');

    final legacy = sqlite3.sqlite3.open(file.path);
    legacy.execute('''
          CREATE TABLE women (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            initials TEXT NOT NULL,
            emoji TEXT NOT NULL DEFAULT '👩',
            color INTEGER NOT NULL DEFAULT 0xFFE91E63,
            tag TEXT NOT NULL DEFAULT '',
            private_notes TEXT NOT NULL DEFAULT '',
            sort_order INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
    legacy.execute('''
          CREATE TABLE period_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            woman_id INTEGER NOT NULL,
            start_date INTEGER NOT NULL,
            end_date INTEGER,
            flow_level INTEGER,
            notes TEXT NOT NULL DEFAULT ''
          )
        ''');
    legacy.execute("""
          INSERT INTO women
            (name, initials, tag, created_at)
          VALUES ('Legacy', 'LG', 'Amiga', 1798848000000)
        """);
    legacy.execute('''
          INSERT INTO period_logs (woman_id, start_date, notes)
          VALUES (1, 1798848000000, 'periodo legacy')
        ''');
    legacy.execute('PRAGMA user_version = 1');
    legacy.dispose();

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(() async {
      await upgraded.close();
      await directory.delete(recursive: true);
    });

    expect(upgraded.schemaVersion, 3);
    final women = await upgraded.select(upgraded.women).get();
    expect(women, hasLength(1));
    expect(women.single.name, 'Legacy');
    expect(await upgraded.select(upgraded.periodLogs).get(), hasLength(1));
    expect(await upgraded.select(upgraded.tags).get(), hasLength(1));
    expect(await upgraded.select(upgraded.womanTags).get(), hasLength(1));
    expect(await upgraded.select(upgraded.alertSettings).get(), isEmpty);

    final columns = await upgraded
        .customSelect('PRAGMA table_info(women)')
        .get();
    expect(columns.map((row) => row.data['name']), isNot(contains('tag')));

    final settingsDao = AlertSettingsDao(upgraded);
    final settings = await settingsDao.getOrCreate();
    expect(settings.id, 1);
    expect(settings.masterEnabled, isFalse);
  });

  group('alert_settings', () {
    test('getOrCreate creates singleton row', () async {
      final settingsDao = AlertSettingsDao(db);
      final settings = await settingsDao.getOrCreate();
      expect(settings.id, 1);
      expect(settings.masterEnabled, false);
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
