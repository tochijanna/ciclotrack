import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/calendar/domain/calendar_board.dart';
import 'package:ciclotrack/features/calendar/domain/day_mark.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_event.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_phase.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_timeline.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_calculator.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_event.dart';

void main() {
  final limite = DateTime(2026, 12, 31);

  // Ana: ciclo real 1-5 sep; ventana fértil 9-16 sep; ovulación 14 sep.
  final ana = WomanCalendar(
    woman: const CalendarWoman(
      id: 1,
      name: 'Ana',
      initials: 'AN',
      emoji: '👩',
      color: 0xFFE91E63,
    ),
    timeline: CycleTimeline.from(
      logs: [
        PeriodLogInput(
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 5),
        ),
      ],
      horizonte: limite,
    ),
    eventos: [
      TrackingEvent.ovulation(
        id: 10,
        womanId: 1,
        date: DateTime(2026, 9, 13),
        temperature: 36.6,
      ),
      TrackingEvent.symptom(
        id: 11,
        womanId: 1,
        date: DateTime(2026, 9, 20),
        type: 'Acné',
      ),
    ],
  );

  // Bea: inicio registrado sin fin; ventana fértil 18-25 sep.
  final bea = WomanCalendar(
    woman: const CalendarWoman(
      id: 2,
      name: 'Bea',
      initials: 'BE',
      emoji: '👩',
      color: 0xFF2196F3,
    ),
    timeline: CycleTimeline.from(
      logs: [PeriodLogInput(startDate: DateTime(2026, 9, 10))],
      horizonte: limite,
    ),
    eventos: const [],
  );

  // Ce: sin registros.
  final ce = WomanCalendar(
    woman: const CalendarWoman(
      id: 3,
      name: 'Ce',
      initials: 'CE',
      emoji: '👩',
      color: 0xFF4CAF50,
    ),
    timeline: CycleTimeline.from(logs: const [], horizonte: limite),
    eventos: const [],
  );

  EncounterWithWomen encuentro(
    int id,
    DateTime time,
    List<CalendarWoman> participantes,
  ) => EncounterWithWomen(
    encounterId: id,
    encounterTime: time,
    protection: 'Condón',
    participants: [
      for (final mujer in participantes)
        EncounterParticipant(
          womanId: mujer.id,
          womanName: mujer.name,
          womanInitials: mujer.initials,
          womanEmoji: mujer.emoji,
          womanColor: mujer.color,
          relationshipType: 'Vaginal',
        ),
    ],
  );

  final board = CalendarBoard(
    women: [ana, bea, ce],
    encuentros: [
      encuentro(100, DateTime(2026, 9, 14, 21, 30), [ana.woman, bea.woman]),
      encuentro(101, DateTime(2026, 10, 5, 20), [ana.woman]),
    ],
  );

  List<DayMarkKind> kindsFor(
    Map<DateTime, List<DayMark>> marks,
    DateTime day,
    int womanId,
  ) => [
    for (final mark in marks[_calendar(day)] ?? const <DayMark>[])
      if (mark.womanId == womanId) mark.kind,
  ];

  List<DayMark> marksForAny(Map<DateTime, List<DayMark>> marks, DateTime day) =>
      marks[_calendar(day)] ?? const [];

  group('marksByDay', () {
    test('marca la menstruación registrada y solo dentro del rango', () {
      final marks = marksByDay(
        board,
        desde: DateTime(2026, 9, 1),
        hasta: DateTime(2026, 9, 7),
      );

      expect(kindsFor(marks, DateTime(2026, 9, 1), 1), [
        DayMarkKind.menstruacion,
      ]);
      expect(kindsFor(marks, DateTime(2026, 9, 5), 1), [
        DayMarkKind.menstruacion,
      ]);
      expect(kindsFor(marks, DateTime(2026, 9, 6), 1), isEmpty);
      expect(
        marks.keys,
        everyElement(
          predicate<DateTime>(
            (day) =>
                !day.isBefore(DateTime(2026, 9, 1)) &&
                !day.isAfter(DateTime(2026, 9, 7)),
          ),
        ),
      );
      expect(marks.containsKey(DateTime(2026, 9, 8)), isFalse);
    });

    test('marca la ventana fértil y separa el día de ovulación', () {
      final marks = marksByDay(
        board,
        desde: DateTime(2026, 9, 8),
        hasta: DateTime(2026, 9, 17),
      );

      expect(kindsFor(marks, DateTime(2026, 9, 8), 1), isEmpty);
      expect(kindsFor(marks, DateTime(2026, 9, 9), 1), [
        DayMarkKind.ventanaFertil,
      ]);
      expect(
        kindsFor(marks, DateTime(2026, 9, 14), 1),
        contains(DayMarkKind.ovulacion),
      );
      expect(
        kindsFor(marks, DateTime(2026, 9, 14), 1),
        isNot(contains(DayMarkKind.ventanaFertil)),
      );
      expect(kindsFor(marks, DateTime(2026, 9, 16), 1), [
        DayMarkKind.ventanaFertil,
      ]);
      expect(kindsFor(marks, DateTime(2026, 9, 17), 1), isEmpty);
    });

    test('añade los registros de ovulación y síntomas del día', () {
      final marks = marksByDay(
        board,
        desde: DateTime(2026, 9, 13),
        hasta: DateTime(2026, 9, 20),
      );

      expect(kindsFor(marks, DateTime(2026, 9, 13), 1), [
        DayMarkKind.ventanaFertil,
        DayMarkKind.ovulacionRegistrada,
      ]);
      expect(kindsFor(marks, DateTime(2026, 9, 20), 1), [DayMarkKind.sintoma]);
    });

    test('marca el encuentro a cada participante', () {
      final marks = marksByDay(
        board,
        desde: DateTime(2026, 9, 14),
        hasta: DateTime(2026, 9, 14),
      );

      expect(marksForAny(marks, DateTime(2026, 9, 14)), hasLength(4));
      expect(
        kindsFor(marks, DateTime(2026, 9, 14), 1),
        contains(DayMarkKind.encuentro),
      );
      expect(
        kindsFor(marks, DateTime(2026, 9, 14), 2),
        contains(DayMarkKind.encuentro),
      );
      expect(kindsFor(marks, DateTime(2026, 9, 14), 3), isEmpty);
    });

    test('distingue lo proyectado de lo registrado', () {
      final marks = marksByDay(
        board,
        desde: DateTime(2026, 9, 1),
        hasta: DateTime(2026, 11, 1),
      );

      DayMark markOf(int womanId, DateTime day) =>
          marksForAny(marks, day).firstWhere((mark) => mark.womanId == womanId);

      expect(markOf(1, DateTime(2026, 9, 1)).esEstimado, isFalse);
      expect(markOf(1, DateTime(2026, 9, 1)).kind, DayMarkKind.menstruacion);
      expect(markOf(1, DateTime(2026, 9, 29)).esEstimado, isTrue);
      expect(markOf(1, DateTime(2026, 9, 29)).kind, DayMarkKind.menstruacion);
    });

    test('una mujer sin datos no genera marcas', () {
      final marks = marksByDay(
        board,
        desde: DateTime(2026, 9, 1),
        hasta: DateTime(2026, 10, 31),
      );

      final deCe = [
        for (final delDia in marks.values)
          for (final mark in delDia)
            if (mark.womanId == 3) mark,
      ];
      expect(deCe, isEmpty);
    });
  });

  group('detailsFor', () {
    test('devuelve una entrada por mujer en el orden de los perfiles', () {
      final detalles = detailsFor(board, DateTime(2026, 9, 14));

      expect(detalles.map((d) => d.woman.id), [1, 2, 3]);
      expect(detalles[0].fase, CyclePhase.ovulacion);
      expect(detalles[0].fertil, isTrue);
      expect(detalles[1].fase, CyclePhase.menstruacion);
      expect(detalles[2].fase, isNull);
      expect(detalles[2].fertil, isFalse);
    });

    test('incluye los eventos y encuentros de ese día', () {
      final conEvento = detailsFor(board, DateTime(2026, 9, 13));
      expect(conEvento[0].eventos, hasLength(1));
      expect(conEvento[0].eventos.single.type, TrackingEventType.ovulation);

      final conEncuentro = detailsFor(board, DateTime(2026, 9, 14));
      expect(conEncuentro[0].encuentros, hasLength(1));
      expect(conEncuentro[1].encuentros, hasLength(1));

      final soloAna = detailsFor(board, DateTime(2026, 10, 5));
      expect(soloAna[0].encuentros, hasLength(1));
      expect(soloAna[1].encuentros, isEmpty);
    });

    test('la fertilidad coincide con la ventana de la línea temporal', () {
      expect(detailsFor(board, DateTime(2026, 9, 8))[0].fertil, isFalse);
      expect(detailsFor(board, DateTime(2026, 9, 9))[0].fertil, isTrue);
      expect(detailsFor(board, DateTime(2026, 9, 16))[0].fertil, isTrue);
      expect(detailsFor(board, DateTime(2026, 9, 17))[0].fertil, isFalse);
    });
  });

  group('startOfWeek', () {
    test('devuelve el lunes de la semana', () {
      expect(startOfWeek(DateTime(2026, 9, 14)), DateTime(2026, 9, 14));
      expect(startOfWeek(DateTime(2026, 9, 3)), DateTime(2026, 8, 31));
      expect(startOfWeek(DateTime(2026, 9, 20, 23, 30)), DateTime(2026, 9, 14));
    });
  });

  group('fertileInWeek', () {
    test('lista las ventanas que intersectan la semana, ordenadas', () {
      final entradas = fertileInWeek(board, DateTime(2026, 9, 14));

      expect(entradas.map((e) => e.woman.id), [1, 2]);
      expect(entradas[0].ventanaInicio, DateTime(2026, 9, 9));
      expect(entradas[0].ventanaFin, DateTime(2026, 9, 16));
      expect(entradas[0].ovulacion, DateTime(2026, 9, 14));
      expect(entradas[0].esEstimado, isFalse);
      expect(entradas[1].ventanaInicio, DateTime(2026, 9, 18));
      expect(entradas[1].ventanaFin, DateTime(2026, 9, 25));
    });

    test('ignora mujeres sin datos', () {
      final entradas = fertileInWeek(board, DateTime(2026, 9, 14));
      expect(entradas.any((e) => e.woman.id == 3), isFalse);
    });

    test('marca como estimadas las ventanas de ciclos proyectados', () {
      final entradas = fertileInWeek(board, DateTime(2026, 10, 5));

      expect(entradas, hasLength(1));
      expect(entradas.single.woman.id, 1);
      expect(entradas.single.ventanaInicio, DateTime(2026, 10, 7));
      expect(entradas.single.esEstimado, isTrue);
    });

    test('devuelve vacío cuando no hay ventana en la semana', () {
      final soloAna = CalendarBoard(women: [ana], encuentros: const []);

      expect(fertileInWeek(soloAna, DateTime(2026, 9, 17)), isEmpty);
    });
  });
}

DateTime _calendar(DateTime value) =>
    DateTime(value.year, value.month, value.day);
