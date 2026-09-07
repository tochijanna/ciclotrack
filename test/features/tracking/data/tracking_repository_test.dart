import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_event.dart';

void main() {
  late AppDatabase db;
  late TrackingDao trackingDao;
  late TrackingRepository repo;
  late int womanId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    trackingDao = TrackingDao(db);
    repo = TrackingRepository(trackingDao);

    // Crear una mujer de prueba.
    final womenDao = WomenDao(db);
    final womenRepo = WomenRepository(womenDao);
    womanId = await womenRepo.create(
      const WomanDraft(name: 'María', initials: 'MR'),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('TrackingRepository - Periodos', () {
    test('createPeriod inserts and returns id', () async {
      final id = await repo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      expect(id, greaterThan(0));
    });

    test('createPeriod with end date and flow', () async {
      final id = await repo.createPeriod(
        womanId,
        PeriodDraft(
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 5),
          flowLevel: 3,
          notes: 'Test',
        ),
      );
      final log = await (db.select(
        db.periodLogs,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(log.endDate, DateTime(2026, 9, 5));
      expect(log.flowLevel, 3);
      expect(log.notes, 'Test');
    });

    test('updatePeriod modifies existing record', () async {
      final id = await repo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      final existing = await (db.select(
        db.periodLogs,
      )..where((t) => t.id.equals(id))).getSingle();
      await repo.updatePeriod(
        existing,
        PeriodDraft(
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 5),
          flowLevel: 4,
        ),
      );
      final updated = await (db.select(
        db.periodLogs,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(updated.endDate, DateTime(2026, 9, 5));
      expect(updated.flowLevel, 4);
    });

    test('deletePeriod removes record', () async {
      final id = await repo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      await repo.deletePeriod(id);
      final log = await (db.select(
        db.periodLogs,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      expect(log, isNull);
    });
  });

  group('TrackingRepository - Ovulación', () {
    test('createOvulation inserts and returns id', () async {
      final id = await repo.createOvulation(
        womanId,
        OvulationDraft(date: DateTime(2026, 9, 14)),
      );
      expect(id, greaterThan(0));
    });

    test('createOvulation with temperature and mucus', () async {
      final id = await repo.createOvulation(
        womanId,
        OvulationDraft(
          date: DateTime(2026, 9, 14),
          temperature: 36.7,
          cervicalMucus: 'Elástico',
          lhTest: true,
        ),
      );
      final log = await (db.select(
        db.ovulationLogs,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(log.temperature, 36.7);
      expect(log.cervicalMucus, 'Elástico');
      expect(log.lhTest, isTrue);
    });

    test('deleteOvulation removes record', () async {
      final id = await repo.createOvulation(
        womanId,
        OvulationDraft(date: DateTime(2026, 9, 14)),
      );
      await repo.deleteOvulation(id);
      final log = await (db.select(
        db.ovulationLogs,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      expect(log, isNull);
    });
  });

  group('TrackingRepository - Síntomas', () {
    test('createSymptom inserts and returns id', () async {
      final id = await repo.createSymptom(
        womanId,
        SymptomDraft(date: DateTime(2026, 9, 10), type: 'Acné', severity: 3),
      );
      expect(id, greaterThan(0));
    });

    test('createSymptom with all fields', () async {
      final id = await repo.createSymptom(
        womanId,
        SymptomDraft(
          date: DateTime(2026, 9, 10),
          type: 'Cansancio',
          severity: 4,
          notes: 'Mucho sueño',
        ),
      );
      final log = await (db.select(
        db.symptoms,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(log.type, 'Cansancio');
      expect(log.severity, 4);
      expect(log.notes, 'Mucho sueño');
    });

    test('deleteSymptom removes record', () async {
      final id = await repo.createSymptom(
        womanId,
        SymptomDraft(date: DateTime(2026, 9, 10), type: 'Acné'),
      );
      await repo.deleteSymptom(id);
      final log = await (db.select(
        db.symptoms,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      expect(log, isNull);
    });
  });

  group('TrackingRepository - Timeline', () {
    test(
      'getTimelineOnce returns combined events sorted by date desc',
      () async {
        await repo.createPeriod(
          womanId,
          PeriodDraft(startDate: DateTime(2026, 9, 1)),
        );
        await repo.createOvulation(
          womanId,
          OvulationDraft(date: DateTime(2026, 9, 14)),
        );
        await repo.createSymptom(
          womanId,
          SymptomDraft(date: DateTime(2026, 9, 10), type: 'Humor', severity: 2),
        );

        final events = await repo.getTimelineOnce(womanId);
        expect(events, hasLength(3));
        expect(events[0].type, TrackingEventType.ovulation);
        expect(events[1].type, TrackingEventType.symptom);
        expect(events[2].type, TrackingEventType.period);
      },
    );

    test('timeline only includes events for the specified woman', () async {
      final womenDao = WomenDao(db);
      final womenRepo = WomenRepository(womenDao);
      final otherId = await womenRepo.create(
        const WomanDraft(name: 'Ana', initials: 'AN'),
      );

      await repo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      await repo.createPeriod(
        otherId,
        PeriodDraft(startDate: DateTime(2026, 9, 5)),
      );

      final events = await repo.getTimelineOnce(womanId);
      expect(events, hasLength(1));
      expect(events[0].womanId, womanId);
    });

    test('timeline is empty when no events exist', () async {
      final events = await repo.getTimelineOnce(womanId);
      expect(events, isEmpty);
    });
  });

  group('TrackingRepository - watchTimeline (reactivo)', () {
    test('emits on period, ovulation and symptom changes', () async {
      final events = <List<TrackingEvent>>[];
      final sub = repo.watchTimeline(womanId).listen(events.add);

      await repo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );
      await pumpEventQueue();

      await repo.createOvulation(
        womanId,
        OvulationDraft(date: DateTime(2026, 9, 14)),
      );
      await pumpEventQueue();

      await repo.createSymptom(
        womanId,
        SymptomDraft(date: DateTime(2026, 9, 10), type: 'Humor', severity: 2),
      );
      await pumpEventQueue();

      await sub.cancel();

      // La última emisión debe reflejar los tres eventos.
      expect(events, isNotEmpty);
      expect(events.last, hasLength(3));
      final types = events.last.map((e) => e.type).toSet();
      expect(
        types,
        containsAll([
          TrackingEventType.period,
          TrackingEventType.ovulation,
          TrackingEventType.symptom,
        ]),
      );
    });

    test('emits updated timeline after deletion', () async {
      final periodId = await repo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );

      final events = <List<TrackingEvent>>[];
      final sub = repo.watchTimeline(womanId).listen(events.add);
      await pumpEventQueue();

      expect(events.last, hasLength(1));

      await repo.deletePeriod(periodId);
      await pumpEventQueue();

      await sub.cancel();

      expect(events.last, isEmpty);
    });

    test('emits ordered by date descending', () async {
      await repo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );

      final events = <List<TrackingEvent>>[];
      final sub = repo.watchTimeline(womanId).listen(events.add);
      await pumpEventQueue();

      await repo.createOvulation(
        womanId,
        OvulationDraft(date: DateTime(2026, 9, 20)),
      );
      await pumpEventQueue();

      await sub.cancel();

      final last = events.last;
      expect(last[0].type, TrackingEventType.ovulation);
      expect(last[1].type, TrackingEventType.period);
    });
  });
}
