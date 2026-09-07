import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';

void main() {
  late AppDatabase db;
  late WomenDao dao;
  late WomenRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = WomenDao(db);
    repo = WomenRepository(dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('WomenRepository', () {
    test('create inserts a woman and returns id', () async {
      const draft = WomanDraft(
        name: 'María',
        initials: 'MR',
        tags: ['Amiga', 'Ex'],
      );
      final id = await repo.create(draft);
      expect(id, greaterThan(0));

      final woman = await dao.getById(id);
      expect(woman, isNotNull);
      expect(woman!.name, 'María');
    });

    test('create links tags', () async {
      const draft = WomanDraft(
        name: 'Ana',
        initials: 'AN',
        tags: ['Relacionada', 'Amiga'],
      );
      final id = await repo.create(draft);

      final tags = await dao.watchTagsForWoman(id).first;
      final tagNames = tags.map((t) => t.name).toList();
      expect(tagNames, containsAll(['Relacionada', 'Amiga']));
    });

    test('update modifies woman and replaces tags', () async {
      const draft = WomanDraft(name: 'María', initials: 'MR', tags: ['Amiga']);
      final id = await repo.create(draft);

      const updated = WomanDraft(
        name: 'María Updated',
        initials: 'MU',
        tags: ['Ex'],
      );
      await repo.update(id, updated);

      final woman = await dao.getById(id);
      expect(woman!.name, 'María Updated');
      expect(woman.initials, 'MU');

      final tags = await dao.watchTagsForWoman(id).first;
      expect(tags.map((t) => t.name).toList(), ['Ex']);
    });

    test('delete removes woman and linked tags', () async {
      const draft = WomanDraft(name: 'Ana', initials: 'AN', tags: ['Amiga']);
      final id = await repo.create(draft);
      await repo.delete(id);

      final woman = await dao.getById(id);
      expect(woman, isNull);

      // Tags table still has the tag, but link is gone.
      final tags = await dao.watchTagsForWoman(id).first;
      expect(tags, isEmpty);
    });

    test('reorder persists sort order', () async {
      final id1 = await repo.create(const WomanDraft(name: 'B', initials: 'B'));
      final id2 = await repo.create(const WomanDraft(name: 'A', initials: 'A'));

      final w1 = (await dao.getById(id1))!;
      final w2 = (await dao.getById(id2))!;

      await repo.reorder([w2, w1]);

      final reordered1 = await dao.getById(id1);
      final reordered2 = await dao.getById(id2);
      expect(reordered1!.sortOrder, 1);
      expect(reordered2!.sortOrder, 0);
    });

    test('watchAllProfiles returns women with tags', () async {
      await repo.create(
        const WomanDraft(name: 'María', initials: 'MR', tags: ['Amiga']),
      );
      await repo.create(
        const WomanDraft(name: 'Ana', initials: 'AN', tags: ['Ex', 'Amiga']),
      );

      final profiles = await repo.watchAllProfiles().first;
      expect(profiles, hasLength(2));

      final maria = profiles.firstWhere((p) => p.woman.name == 'María');
      expect(maria.tags, ['Amiga']);

      final ana = profiles.firstWhere((p) => p.woman.name == 'Ana');
      expect(ana.tags, containsAll(['Ex', 'Amiga']));
    });
  });
}
