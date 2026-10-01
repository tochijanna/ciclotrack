import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/calendar/domain/calendar_board.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_event.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_options.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_timeline.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_calculator.dart';
import 'package:ciclotrack/features/reports/domain/report_builder.dart';
import 'package:ciclotrack/features/reports/domain/report_models.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_event.dart';

void main() {
  final hoy = DateTime(2026, 9, 14);

  CalendarWoman mujer(int id, String name) => CalendarWoman(
    id: id,
    name: name,
    initials: name.substring(0, 2).toUpperCase(),
    emoji: '👩',
    color: 0xFFE91E63,
  );

  final ana = mujer(1, 'Ana');
  final bea = mujer(2, 'Bea');
  final ce = mujer(3, 'Ce');

  WomanCalendar conPeriodos(
    CalendarWoman woman,
    List<PeriodLogInput> periodos, {
    List<TrackingEvent> eventos = const [],
  }) => WomanCalendar(
    woman: woman,
    timeline: CycleTimeline.from(
      logs: periodos,
      horizonte: DateTime(2028, 1, 1),
    ),
    eventos: eventos,
    periodos: periodos,
  );

  PeriodLogInput periodo(int year, int month, int day, {int? duracionDias}) =>
      PeriodLogInput(
        startDate: DateTime(year, month, day),
        endDate: duracionDias == null
            ? null
            : DateTime(year, month, day + duracionDias - 1),
      );

  EncounterWithWomen encuentro(
    int id,
    DateTime time,
    List<CalendarWoman> participantes, {
    String proteccion = 'Condón',
  }) => EncounterWithWomen(
    encounterId: id,
    encounterTime: time,
    protection: proteccion,
    participants: [
      for (final participante in participantes)
        EncounterParticipant(
          womanId: participante.id,
          womanName: participante.name,
          womanInitials: participante.initials,
          womanEmoji: participante.emoji,
          womanColor: participante.color,
          relationshipType: 'Vaginal',
        ),
    ],
  );

  TrackingEvent sintoma(
    int id,
    CalendarWoman woman,
    DateTime date,
    String type,
  ) => TrackingEvent.symptom(
    id: id,
    womanId: woman.id,
    date: date,
    type: type,
    severity: 3,
  );

  group('ciclos', () {
    test('calcula la duración de cada ciclo y sus medias', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(ana, [
            periodo(2026, 1, 1, duracionDias: 5),
            periodo(2026, 1, 29, duracionDias: 5),
            periodo(2026, 2, 27, duracionDias: 4),
          ]),
        ],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.ciclos.map((p) => p.valor), [28, 29]);
      expect(informe.mujeres.single.ciclos.map((p) => p.fecha), [
        DateTime(2026, 1, 29),
        DateTime(2026, 2, 27),
      ]);
      expect(informe.mujeres.single.kpis.ciclos, 2);
      expect(informe.mujeres.single.kpis.mediaCiclo, 28.5);
      expect(informe.globales.ciclos, 2);
      expect(informe.globales.mediaCiclo, 28.5);
    });

    test('recorta la serie a los últimos 12 ciclos pero cuenta todos', () {
      final periodos = [
        for (var i = 0; i < 15; i++)
          periodo(2026, 1, 1 + i * 28, duracionDias: 5),
      ];
      final board = CalendarBoard(
        women: [conPeriodos(ana, periodos)],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.ciclos, hasLength(12));
      expect(informe.mujeres.single.kpis.ciclos, 14);
      expect(informe.mujeres.single.ciclos.last.valor, 28);
    });

    test('sin periodos no hay ciclos ni periodo previsto', () {
      final board = CalendarBoard(
        women: [conPeriodos(ce, const [])],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.ciclos, isEmpty);
      expect(informe.mujeres.single.kpis.ciclos, 0);
      expect(informe.mujeres.single.kpis.mediaCiclo, 0);
      expect(informe.mujeres.single.proximoPeriodo, isNull);
    });

    test('la media de la menstruación solo usa periodos cerrados', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(ana, [
            periodo(2026, 1, 1, duracionDias: 5),
            periodo(2026, 1, 29),
          ]),
        ],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.kpis.mediaMenstruacion, 5);
      expect(informe.globales.mediaMenstruacion, 5);
    });

    test('proyecta el próximo periodo a partir del último inicio', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(ana, [periodo(2026, 9, 1, duracionDias: 5)]),
        ],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.proximoPeriodo, DateTime(2026, 9, 29));
    });
  });

  group('ventana de meses', () {
    test('cubre 12 meses naturales y deja fuera el decimotercero', () {
      final board = CalendarBoard(
        women: [conPeriodos(ana, const [])],
        encuentros: [
          encuentro(1, DateTime(2025, 9, 30, 22), [ana]),
          encuentro(2, DateTime(2025, 10, 1, 8), [ana]),
        ],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.meses, hasLength(12));
      expect(informe.meses.first.mes, DateTime(2025, 10, 1));
      expect(informe.meses.last.mes, DateTime(2026, 9, 1));
      expect(informe.globales.encuentros, 1);
      expect(informe.meses.first.encuentros, 1);
    });

    test('resume encuentros y sin protección por mes', () {
      final board = CalendarBoard(
        women: [conPeriodos(ana, const [])],
        encuentros: [
          encuentro(1, DateTime(2026, 9, 14, 21), [
            ana,
          ], proteccion: noProtection),
          encuentro(2, DateTime(2026, 9, 20, 21), [ana]),
          encuentro(3, DateTime(2026, 8, 1, 21), [
            ana,
          ], proteccion: noProtection),
        ],
      );

      final informe = buildReports(board, today: hoy);

      final septiembre = informe.meses.last;
      final agosto = informe.meses[informe.meses.length - 2];
      expect(septiembre.encuentros, 2);
      expect(septiembre.sinProteccion, 1);
      expect(agosto.encuentros, 1);
      expect(agosto.sinProteccion, 1);
      expect(informe.globales.encuentrosSinProteccion, 2);
      expect(informe.globales.porcentajeSinProteccion, closeTo(66.67, 0.01));
    });

    test('cuenta los periodos iniciados en cada mes de la ventana', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(ana, [
            periodo(2025, 9, 1, duracionDias: 5),
            periodo(2025, 10, 5, duracionDias: 5),
          ]),
        ],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.meses.first.mes, DateTime(2025, 10, 1));
      expect(informe.meses.first.periodos, 1);
      expect(
        informe.meses.fold<int>(0, (total, mes) => total + mes.periodos),
        1,
      );
    });

    test('cuenta los días fértiles de cada mes con la línea temporal', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(ana, [periodo(2026, 9, 1, duracionDias: 5)]),
        ],
        encuentros: const [],
      );

      // Con "hoy" en octubre, septiembre trae la ventana real del ciclo
      // registrado (9-16 sep) y octubre la proyectada (7-14 oct).
      final informe = buildReports(board, today: DateTime(2026, 10, 15));

      MonthReport mes(int year, int month) => informe.meses.firstWhere(
        (m) => m.mes.year == year && m.mes.month == month,
      );

      expect(mes(2026, 9).diasFertiles, 8);
      expect(mes(2026, 10).diasFertiles, 8);
      expect(mes(2026, 8).diasFertiles, 0);
      expect(
        informe.globales.diasFertiles,
        informe.meses.fold<int>(0, (total, m) => total + m.diasFertiles),
      );
    });
  });

  group('encuentros', () {
    final board = CalendarBoard(
      women: [
        conPeriodos(ana, const []),
        conPeriodos(bea, const []),
        conPeriodos(ce, const []),
      ],
      encuentros: [
        encuentro(1, DateTime(2026, 9, 14, 21), [
          ana,
        ], proteccion: noProtection),
        encuentro(2, DateTime(2026, 9, 13, 21), [ana, bea]),
        encuentro(3, DateTime(2026, 9, 12, 21), [bea], proteccion: 'Pastilla'),
        encuentro(4, DateTime(2026, 8, 1, 21), [ana], proteccion: 'Natural'),
      ],
    );

    test('solo «Ninguno» cuenta como sin protección', () {
      final informe = buildReports(board, today: hoy);

      expect(informe.globales.encuentros, 4);
      expect(informe.globales.encuentrosSinProteccion, 1);
      expect(informe.globales.porcentajeSinProteccion, 25);
      expect(
        informe.mujeres.first.kpis.porcentajeSinProteccion,
        closeTo(33.33, 0.01),
      );
    });

    test('reparte la protección en orden canónico', () {
      final informe = buildReports(board, today: hoy);

      expect(informe.proteccion.map((b) => b.etiqueta), [
        'Condón',
        'Pastilla',
        'Natural',
        noProtection,
      ]);
      expect(informe.proteccion.first.valor, 1);
    });

    test('cuenta los encuentros por mujer, con ceros y descendente', () {
      final informe = buildReports(board, today: hoy);

      expect(informe.encuentrosPorMujer.map((b) => b.etiqueta), [
        'Ana',
        'Bea',
        'Ce',
      ]);
      expect(informe.encuentrosPorMujer.map((b) => b.valor), [3, 2, 0]);
      expect(informe.globales.mujerConMasEncuentros, 'Ana');
      expect(informe.globales.maxEncuentros, 3);
    });

    test(
      'ordena los encuentros de la mujer del más reciente al más antiguo',
      () {
        final informe = buildReports(board, today: hoy);

        expect(informe.mujeres.first.encuentros.map((e) => e.encounterId), [
          1,
          2,
          4,
        ]);
        expect(informe.mujeres.first.kpis.encuentros, 3);
      },
    );

    test('sin encuentros el porcentaje es cero y no hay destacada', () {
      final informe = buildReports(
        CalendarBoard(
          women: [conPeriodos(ana, const [])],
          encuentros: const [],
        ),
        today: hoy,
      );

      expect(informe.globales.porcentajeSinProteccion, 0);
      expect(informe.globales.mujerConMasEncuentros, isNull);
      expect(informe.proteccion, isEmpty);
    });

    test('resuelve el informe por id y devuelve null si no está', () {
      final informe = buildReports(board, today: hoy);

      expect(informe.womanById(2)?.woman.name, 'Bea');
      expect(informe.womanById(null), isNull);
      expect(informe.womanById(99), isNull);
    });
  });

  group('síntomas', () {
    test('cuenta por tipo en la ventana, de mayor a menor', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(
            ana,
            [periodo(2026, 9, 1, duracionDias: 5)],
            eventos: [
              sintoma(1, ana, DateTime(2026, 9, 10), 'Acné'),
              sintoma(2, ana, DateTime(2026, 9, 12), 'Acné'),
              sintoma(3, ana, DateTime(2026, 9, 11), 'Cansancio'),
              sintoma(4, ana, DateTime(2025, 9, 1), 'Acné'),
            ],
          ),
        ],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.sintomas.map((b) => b.etiqueta), [
        'Acné',
        'Cansancio',
      ]);
      expect(informe.mujeres.single.sintomas.map((b) => b.valor), [2, 1]);
    });

    test('desempata por orden alfabético', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(
            ana,
            [periodo(2026, 9, 1, duracionDias: 5)],
            eventos: [
              sintoma(1, ana, DateTime(2026, 9, 10), 'Cansancio'),
              sintoma(2, ana, DateTime(2026, 9, 11), 'Acné'),
            ],
          ),
        ],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.sintomas.map((b) => b.etiqueta), [
        'Acné',
        'Cansancio',
      ]);
    });

    test('ignora ovulaciones y síntomas fuera de la ventana', () {
      final board = CalendarBoard(
        women: [
          conPeriodos(
            ana,
            [periodo(2026, 9, 1, duracionDias: 5)],
            eventos: [
              TrackingEvent.ovulation(
                id: 1,
                womanId: ana.id,
                date: DateTime(2026, 9, 13),
              ),
              sintoma(2, ana, DateTime(2025, 6, 1), 'Humor'),
            ],
          ),
        ],
        encuentros: const [],
      );

      final informe = buildReports(board, today: hoy);

      expect(informe.mujeres.single.sintomas, isEmpty);
    });
  });

  group('tablero sin datos', () {
    final board = CalendarBoard(
      women: [conPeriodos(ce, const [])],
      encuentros: const [],
    );

    test('deja los indicadores y las series a cero', () {
      final informe = buildReports(board, today: hoy);

      expect(informe.globales.perfiles, 1);
      expect(informe.globales.ciclos, 0);
      expect(informe.globales.encuentros, 0);
      expect(informe.globales.diasFertiles, 0);
      expect(informe.globales.mediaCiclo, 0);
      expect(informe.globales.mediaMenstruacion, 0);
      expect(informe.globales.porcentajeSinProteccion, 0);
      expect(informe.mujeres.single.ciclos, isEmpty);
      expect(informe.mujeres.single.sintomas, isEmpty);
      expect(informe.mujeres.single.encuentros, isEmpty);
      expect(informe.meses, hasLength(12));
      expect(
        informe.meses.every(
          (mes) =>
              mes.encuentros == 0 &&
              mes.sinProteccion == 0 &&
              mes.diasFertiles == 0 &&
              mes.periodos == 0,
        ),
        isTrue,
      );
    });

    test('sin perfiles el informe global queda vacío', () {
      final informe = buildReports(
        const CalendarBoard(women: [], encuentros: []),
        today: hoy,
      );

      expect(informe.globales.perfiles, 0);
      expect(informe.mujeres, isEmpty);
      expect(informe.encuentrosPorMujer, isEmpty);
      expect(informe.mujeres.every((m) => m.kpis.ciclos == 0), isTrue);
    });
  });
}
