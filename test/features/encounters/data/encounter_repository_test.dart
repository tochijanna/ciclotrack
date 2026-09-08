import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_draft.dart';

void main() {
  late AppDatabase db;
  late EncounterDao encounterDao;
  late EncounterRepository repo;
  late int womanId1;
  late int womanId2;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    encounterDao = EncounterDao(db);
    repo = EncounterRepository(encounterDao);

    final womenDao = WomenDao(db);
    final womenRepo = WomenRepository(womenDao);
    womanId1 = await womenRepo.create(
      const WomanDraft(name: 'María', initials: 'MR'),
    );
    womanId2 = await womenRepo.create(
      const WomanDraft(name: 'Ana', initials: 'AN'),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('EncounterRepository', () {
    test('create inserts encounter with one woman', () async {
      final id = await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 5, 21, 30),
          protection: 'Condón',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Vaginal',
            ),
          ],
        ),
      );
      expect(id, greaterThan(0));

      final encounter = await repo.getById(id);
      expect(encounter, isNotNull);
      expect(encounter!.participants, hasLength(1));
      expect(encounter.participants.first.womanName, 'María');
      expect(encounter.participants.first.relationshipType, 'Vaginal');
      expect(encounter.protection, 'Condón');
    });

    test('create inserts encounter with multiple women', () async {
      final id = await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 5, 21, 30),
          protection: 'Natural',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Vaginal',
            ),
            EncounterParticipantDraft(
              womanId: womanId2,
              relationshipType: 'Oral',
            ),
          ],
          notes: 'Test',
        ),
      );

      final encounter = await repo.getById(id);
      expect(encounter, isNotNull);
      expect(encounter!.participants, hasLength(2));
      expect(encounter.notes, 'Test');
    });

    test('create with different relationship types per woman', () async {
      final id = await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 5),
          protection: 'Ninguno',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Vaginal',
            ),
            EncounterParticipantDraft(
              womanId: womanId2,
              relationshipType: 'Anal',
            ),
          ],
        ),
      );

      final encounter = await repo.getById(id);
      final p1 = encounter!.participants.firstWhere(
        (p) => p.womanId == womanId1,
      );
      final p2 = encounter.participants.firstWhere(
        (p) => p.womanId == womanId2,
      );
      expect(p1.relationshipType, 'Vaginal');
      expect(p2.relationshipType, 'Anal');
    });

    test('update replaces participants', () async {
      final id = await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 5),
          protection: 'Condón',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Vaginal',
            ),
          ],
        ),
      );

      await repo.update(
        id,
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 6),
          protection: 'Pastilla',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Oral',
            ),
            EncounterParticipantDraft(
              womanId: womanId2,
              relationshipType: 'Vaginal',
            ),
          ],
        ),
      );

      final encounter = await repo.getById(id);
      expect(encounter!.encounterTime.day, 6);
      expect(encounter.protection, 'Pastilla');
      expect(encounter.participants, hasLength(2));
    });

    test('delete removes encounter and participants', () async {
      final id = await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 5),
          protection: 'Condón',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Vaginal',
            ),
          ],
        ),
      );

      await repo.delete(id);

      expect(await repo.getById(id), isNull);
      expect(await db.select(db.encounterWomen).get(), isEmpty);
    });

    test('watchByWoman returns only encounters of that woman', () async {
      await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 1),
          protection: 'Condón',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Vaginal',
            ),
          ],
        ),
      );
      await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 2),
          protection: 'Natural',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId2,
              relationshipType: 'Oral',
            ),
          ],
        ),
      );

      final maria = await repo.watchByWoman(womanId1).first;
      expect(maria, hasLength(1));
      expect(maria.first.participants.first.womanName, 'María');
    });

    test('watchAll returns all encounters ordered by date desc', () async {
      await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 1),
          protection: 'Condón',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId1,
              relationshipType: 'Vaginal',
            ),
          ],
        ),
      );
      await repo.create(
        EncounterDraft(
          encounterTime: DateTime(2026, 9, 10),
          protection: 'Natural',
          participants: [
            EncounterParticipantDraft(
              womanId: womanId2,
              relationshipType: 'Oral',
            ),
          ],
        ),
      );

      final all = await repo.watchAll().first;
      expect(all, hasLength(2));
      expect(all.first.encounterTime.day, 10);
    });
  });
}
