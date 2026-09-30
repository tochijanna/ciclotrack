import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/calendar/data/calendar_repository.dart';
import 'package:ciclotrack/features/calendar/domain/calendar_board.dart';
import 'package:ciclotrack/features/calendar/domain/day_mark.dart';
import 'package:ciclotrack/features/encounters/data/encounter_dao.dart';
import 'package:ciclotrack/features/encounters/data/encounter_repository.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_draft.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_options.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_phase.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';

void main() {
  late AppDatabase db;
  late WomenRepository womenRepo;
  late TrackingRepository trackingRepo;
  late EncounterRepository encounterRepo;
  late CalendarRepository repo;

  final today = DateTime(2026, 9, 14);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final trackingDao = TrackingDao(db);
    womenRepo = WomenRepository(WomenDao(db));
    trackingRepo = TrackingRepository(trackingDao);
    encounterRepo = EncounterRepository(EncounterDao(db));
    repo = CalendarRepository(
      womenRepo: womenRepo,
      trackingDao: trackingDao,
      encounterRepo: encounterRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedAna({int color = 0xFFE91E63}) =>
      womenRepo.create(WomanDraft(name: 'Ana', initials: 'AN', color: color));

  Future<void> addEncounter(List<int> womanIds) => encounterRepo.create(
    EncounterDraft(
      encounterTime: DateTime(2026, 9, 14, 21, 30),
      protection: protectionOptions.first,
      participants: [
        for (final womanId in womanIds)
          EncounterParticipantDraft(
            womanId: womanId,
            relationshipType: relationshipTypeOptions.first,
          ),
      ],
    ),
  );

  List<DayMarkKind> kindsOf(
    Map<DateTime, List<DayMark>> marks,
    DateTime day,
    int womanId,
  ) => [
    for (final mark
        in marks[DateTime(day.year, day.month, day.day)] ?? const [])
      if (mark.womanId == womanId) mark.kind,
  ];

  test('compone perfil, registros de tracking y encuentros', () async {
    final id = await seedAna(color: 0xFF123456);
    await trackingRepo.createPeriod(
      id,
      PeriodDraft(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 5),
      ),
    );
    await trackingRepo.createOvulation(
      id,
      OvulationDraft(date: DateTime(2026, 9, 13), temperature: 36.6),
    );
    await trackingRepo.createSymptom(
      id,
      SymptomDraft(date: DateTime(2026, 9, 20), type: 'Acné'),
    );
    await addEncounter([id]);

    final board = await repo.watchBoard(today: today).first;

    expect(board.women, hasLength(1));
    expect(board.women.single.woman.name, 'Ana');
    expect(board.women.single.woman.color, 0xFF123456);
    expect(board.women.single.eventos, hasLength(2));
    expect(board.encuentros, hasLength(1));
    expect(board.women.single.periodos, hasLength(1));
    expect(board.women.single.periodos.single.startDate, DateTime(2026, 9, 1));
    expect(board.women.single.periodos.single.endDate, DateTime(2026, 9, 5));

    final marks = marksByDay(
      board,
      desde: DateTime(2026, 9, 1),
      hasta: DateTime(2026, 9, 20),
    );
    expect(kindsOf(marks, DateTime(2026, 9, 1), id), [
      DayMarkKind.menstruacion,
    ]);
    expect(kindsOf(marks, DateTime(2026, 9, 13), id), [
      DayMarkKind.ventanaFertil,
      DayMarkKind.ovulacionRegistrada,
    ]);
    expect(kindsOf(marks, DateTime(2026, 9, 14), id), [
      DayMarkKind.ovulacion,
      DayMarkKind.encuentro,
    ]);
    expect(kindsOf(marks, DateTime(2026, 9, 20), id), [DayMarkKind.sintoma]);
  });

  test('acota la proyección de ciclos al horizonte indicado', () async {
    final id = await seedAna();
    await trackingRepo.createPeriod(
      id,
      PeriodDraft(startDate: DateTime(2026, 9, 1)),
    );

    final corto = await repo
        .watchBoard(
          today: DateTime(2026, 9, 1),
          horizonte: const Duration(days: 30),
        )
        .first;
    final largo = await repo.watchBoard(today: DateTime(2026, 9, 1)).first;

    expect(corto.women.single.timeline.spanFor(DateTime(2026, 12, 1)), isNull);
    expect(
      largo.women.single.timeline.spanFor(DateTime(2026, 12, 1)),
      isNotNull,
    );
  });

  test('compone varias mujeres con líneas temporales independientes', () async {
    final ana = await seedAna();
    final bea = await womenRepo.create(
      const WomanDraft(name: 'Bea', initials: 'BE'),
    );
    await trackingRepo.createPeriod(
      ana,
      PeriodDraft(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 5),
      ),
    );
    await trackingRepo.createPeriod(
      bea,
      PeriodDraft(
        startDate: DateTime(2026, 9, 10),
        endDate: DateTime(2026, 9, 14),
      ),
    );

    final board = await repo.watchBoard(today: today).first;

    expect(board.women.map((w) => w.woman.name), ['Ana', 'Bea']);
    final detalles = detailsFor(board, DateTime(2026, 9, 14));
    expect(detalles[0].fase, CyclePhase.ovulacion);
    expect(detalles[1].fase, CyclePhase.menstruacion);
    expect(detalles[1].fertil, isFalse);
  });

  test('una mujer sin registros no aporta marcas ni fase', () async {
    await womenRepo.create(const WomanDraft(name: 'Bea', initials: 'BE'));

    final board = await repo.watchBoard(today: today).first;

    expect(board.women.single.timeline.spans, isEmpty);
    expect(board.women.single.periodos, isEmpty);
    expect(marksByDay(board, desde: today, hasta: today), isEmpty);
    expect(detailsFor(board, today).single.fase, isNull);
  });

  test('re-emite al añadir un periodo', () async {
    final id = await seedAna();
    final emissions = <CalendarBoard>[];
    final sub = repo.watchBoard(today: today).listen(emissions.add);
    await pumpEventQueue();

    await trackingRepo.createPeriod(
      id,
      PeriodDraft(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 5),
      ),
    );
    await pumpEventQueue();
    await sub.cancel();

    expect(emissions.first.women.single.timeline.spans, isEmpty);
    expect(
      emissions.last.women.single.timeline.isPeriodOn(DateTime(2026, 9, 1)),
      isTrue,
    );
  });

  test('re-emite al añadir un encuentro', () async {
    final id = await seedAna();
    final emissions = <CalendarBoard>[];
    final sub = repo.watchBoard(today: today).listen(emissions.add);
    await pumpEventQueue();

    await addEncounter([id]);
    await pumpEventQueue();
    await sub.cancel();

    expect(emissions.first.encuentros, isEmpty);
    expect(emissions.last.encuentros, hasLength(1));
    expect(
      marksByDay(
        emissions.last,
        desde: today,
        hasta: today,
      )[DateTime(2026, 9, 14)]!.map((mark) => mark.kind),
      contains(DayMarkKind.encuentro),
    );
  });

  test('re-emite al añadir un síntoma', () async {
    final id = await seedAna();
    final emissions = <CalendarBoard>[];
    final sub = repo.watchBoard(today: today).listen(emissions.add);
    await pumpEventQueue();

    await trackingRepo.createSymptom(
      id,
      SymptomDraft(date: DateTime(2026, 9, 14), type: 'Acné'),
    );
    await pumpEventQueue();
    await sub.cancel();

    expect(emissions.first.women.single.eventos, isEmpty);
    expect(emissions.last.women.single.eventos, hasLength(1));
  });
}
