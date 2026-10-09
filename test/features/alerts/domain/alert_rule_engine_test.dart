import 'package:ciclotrack/features/alerts/domain/alert_item.dart';
import 'package:ciclotrack/features/alerts/domain/alert_message.dart';
import 'package:ciclotrack/features/alerts/domain/alert_rule_engine.dart';
import 'package:ciclotrack/features/alerts/domain/alert_settings.dart';
import 'package:ciclotrack/features/alerts/domain/alert_types.dart';
import 'package:ciclotrack/features/alerts/domain/medication_alert_input.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_event.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_phase.dart';
import 'package:ciclotrack/features/prediction/domain/woman_prediction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = AlertRuleEngine();

  /// Helper para crear un WomanAlertContext con predicción básica.
  WomanAlertContext ctx(
    int id,
    String name, {
    String? initials,
    DateTime? ovulacion,
    DateTime? ventanaIni,
    DateTime? ventanaFin,
    DateTime? periodoPrevisto,
    EstadoRiesgo estado = EstadoRiesgo.fueraDeVentana,
    int? cicloActual,
  }) {
    return WomanAlertContext(
      womanId: id,
      name: name,
      initials: initials ?? name.substring(0, 1).toUpperCase(),
      prediction: WomanPrediction(
        estadoRiesgo: estado,
        faseHoy: CyclePhase.follicular,
        pronostico: const [],
        ovulacionEstimada: ovulacion,
        rangoOvulacionInicio: ovulacion?.subtract(const Duration(days: 3)),
        rangoOvulacionFin: ovulacion?.add(const Duration(days: 3)),
        ventanaFertilInicio: ventanaIni,
        ventanaFertilFin: ventanaFin,
        periodoPrevisto: periodoPrevisto,
        minCiclo: 24,
        maxCiclo: 32,
        mediaCiclo: 28,
        ciclosReales: 3,
        usaEstimacionPorDefecto: false,
        cicloActual: cicloActual,
      ),
    );
  }

  AlertSettings settings({
    bool master = true,
    int hour = 9,
    int minute = 0,
    Set<AlertType>? types,
  }) {
    return AlertSettings(
      masterEnabled: master,
      notifyHour: hour,
      notifyMinute: minute,
      enabledTypes: types ?? Set.from(AlertType.values),
    );
  }

  group('medicación', () {
    List<AlertItem> evaluate({
      int hour = 12,
      bool enabled = true,
      bool master = true,
      bool type = true,
      bool profile = true,
    }) => engine.evaluate(
      today: DateTime(2026, 9, 10, 10),
      women: profile ? [ctx(1, 'María', estado: EstadoRiesgo.sinDatos)] : [],
      encounters: [],
      medications: [
        MedicationAlertInput(
          id: 1,
          womanId: 1,
          name: 'Hierro',
          hour: hour,
          minute: 30,
          enabled: enabled,
        ),
      ],
      settings: settings(
        master: master,
        types: type ? {AlertType.medicacion} : {},
      ),
    );

    test('hora futura hoy y perfil sin periodos', () {
      final item = evaluate().single;
      expect(item.type, AlertType.medicacion);
      expect(item.fireDate, DateTime(2026, 9, 10, 12, 30));
      expect(item.message, isA<MedicationMessage>());
      expect((item.message as MedicationMessage).hour, 12);
      expect((item.message as MedicationMessage).minute, 30);
      expect(item.womanIds, [1]);
    });
    test('hora pasada se programa mañana', () {
      expect(evaluate(hour: 8).single.fireDate, DateTime(2026, 9, 11, 8, 30));
    });
    test('medicación es recurrente a diario', () {
      expect(evaluate().single.recurringDaily, isTrue);
    });
    test('respeta medicamento, tipo, maestro y perfil', () {
      expect(evaluate(enabled: false), isEmpty);
      expect(evaluate(type: false), isEmpty);
      expect(evaluate(master: false), isEmpty);
      expect(evaluate(profile: false), isEmpty);
    });
    test('conserva dos medicamentos de la misma mujer a la misma hora', () {
      final items = engine.evaluate(
        today: DateTime(2026, 9, 10, 10),
        women: [ctx(1, 'María')],
        encounters: [],
        medications: [
          for (final id in [1, 2])
            MedicationAlertInput(
              id: id,
              womanId: 1,
              name: 'Pastilla',
              hour: 12,
              minute: 0,
            ),
        ],
        settings: settings(types: {AlertType.medicacion}),
      );
      expect(items, hasLength(2));
      expect(items.map((a) => a.id).toSet(), hasLength(2));
    });
  });

  group('privacidad de los cuerpos (SEC-01-04)', () {
    test('los mensajes solo llevan iniciales, nunca nombres ni medicación', () {
      final today = DateTime(2026, 9, 10);
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'María',
            initials: 'MR',
            ovulacion: DateTime(2026, 9, 11),
            ventanaIni: DateTime(2026, 9, 9),
            ventanaFin: DateTime(2026, 9, 16),
            periodoPrevisto: DateTime(2026, 9, 27),
            estado: EstadoRiesgo.diaDeRiesgo,
          ),
        ],
        encounters: [
          EncounterWithWomen(
            encounterId: 1,
            encounterTime: DateTime(2026, 9, 8),
            protection: 'Condón',
            participants: [
              EncounterParticipant(
                womanId: 1,
                womanName: 'María',
                womanInitials: 'MR',
                womanEmoji: '👩',
                womanColor: 0xFFE91E63,
                relationshipType: 'Vaginal',
              ),
            ],
          ),
        ],
        medications: [
          MedicationAlertInput(
            id: 1,
            womanId: 1,
            name: 'Hierro',
            hour: 12,
            minute: 0,
          ),
        ],
        settings: settings(),
      );
      expect(alerts, isNotEmpty);
      final expuestos = <String>[];
      for (final a in alerts) {
        final msg = a.message;
        if (msg is FertilityImminentMessage) {
          expuestos.add(msg.initials);
        } else if (msg is RiskDayMessage) {
          expuestos.add(msg.initials);
        } else if (msg is PeriodImminentMessage) {
          expuestos.add(msg.initials);
        } else if (msg is CombinedFertilityMessage) {
          expuestos.addAll(msg.initials);
        } else if (msg is EncounterFertilityMessage) {
          expuestos.add(msg.initials);
        } else if (msg is PostEncounterWarningMessage) {
          expuestos.add(msg.initials);
        } else if (msg is MultiWomenFertilityMessage) {
          expuestos.addAll(msg.initials);
        } else if (msg is CombinedWindowMessage) {
          expuestos.addAll(msg.entries.map((e) => e.initials));
        }
        // MedicationMessage no expone el nombre del medicamento.
      }
      expect(expuestos, contains('MR'));
      expect(expuestos, everyElement(isNot('María')));
      expect(
        alerts
            .where((a) => a.type != AlertType.medicacion)
            .every((a) => !a.recurringDaily),
        isTrue,
      );
    });
  });

  group('AlertRuleEngine - fertilidadInminente', () {
    test('la "mañana" tras un cambio de hora es la fecha siguiente', () {
      // 2026-03-29 tiene 23 h en España; mañana sigue siendo el día siguiente.
      final alerts = engine.evaluate(
        today: DateTime(2026, 3, 28),
        women: [
          ctx(
            1,
            'María',
            ovulacion: DateTime(2026, 3, 29, 3),
            ventanaIni: DateTime(2026, 3, 24),
            ventanaFin: DateTime(2026, 3, 31),
            periodoPrevisto: DateTime(2026, 4, 12),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(),
      );
      expect(
        alerts.any((a) => a.type == AlertType.fertilidadInminente),
        isTrue,
      );
    });

    test('fires when ovulation is tomorrow', () {
      final today = DateTime(2026, 9, 10);
      final tomorrow = DateTime(2026, 9, 11);
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'María',
            ovulacion: tomorrow,
            ventanaIni: DateTime(2026, 9, 6),
            ventanaFin: DateTime(2026, 9, 13),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(),
      );
      final alert = alerts.firstWhere(
        (a) => a.type == AlertType.fertilidadInminente,
      );
      expect(alert.fireDate, DateTime(2026, 9, 10, 9));
    });

    test('does not fire when ovulation is not tomorrow', () {
      final today = DateTime(2026, 9, 10);
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'María',
            ovulacion: DateTime(2026, 9, 14),
            ventanaIni: DateTime(2026, 9, 9),
            ventanaFin: DateTime(2026, 9, 16),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(),
      );
      expect(
        alerts.where((a) => a.type == AlertType.fertilidadInminente),
        isEmpty,
      );
    });
  });

  group('AlertRuleEngine - diaDeRiesgo', () {
    test('fires when today is in fertile window', () {
      final today = DateTime(2026, 9, 10);
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'Ana',
            estado: EstadoRiesgo.diaDeRiesgo,
            ventanaIni: DateTime(2026, 9, 9),
            ventanaFin: DateTime(2026, 9, 16),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(hour: 8), // early enough to fire
      );
      expect(
        alerts,
        contains(predicate<AlertItem>((a) => a.type == AlertType.diaDeRiesgo)),
      );
    });
  });

  group('AlertRuleEngine - periodoInminente', () {
    test('fires when period is tomorrow', () {
      final today = DateTime(2026, 9, 26);
      final alerts = engine.evaluate(
        today: today,
        women: [ctx(1, 'María', periodoPrevisto: DateTime(2026, 9, 27))],
        medications: const [],
        encounters: const [],
        settings: settings(),
      );
      final alert = alerts.firstWhere(
        (a) => a.type == AlertType.periodoInminente,
      );
      expect(alert.fireDate, DateTime(2026, 9, 26, 9));
    });
  });

  group('AlertRuleEngine - fertilidadCombinada', () {
    test('fires when 2+ women are fertile', () {
      final today = DateTime(2026, 9, 10);
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'María',
            estado: EstadoRiesgo.diaDeRiesgo,
            ventanaIni: DateTime(2026, 9, 9),
            ventanaFin: DateTime(2026, 9, 16),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
          ctx(
            2,
            'Ana',
            estado: EstadoRiesgo.diaDeRiesgo,
            ventanaIni: DateTime(2026, 9, 8),
            ventanaFin: DateTime(2026, 9, 15),
            periodoPrevisto: DateTime(2026, 9, 26),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(hour: 8),
      );
      expect(
        alerts,
        contains(
          predicate<AlertItem>((a) => a.type == AlertType.fertilidadCombinada),
        ),
      );
    });

    test('does not fire with only 1 fertile woman', () {
      final today = DateTime(2026, 9, 10);
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'María',
            estado: EstadoRiesgo.diaDeRiesgo,
            ventanaIni: DateTime(2026, 9, 9),
            ventanaFin: DateTime(2026, 9, 16),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
          ctx(
            2,
            'Ana',
            estado: EstadoRiesgo.fueraDeVentana,
            ventanaIni: DateTime(2026, 9, 20),
            ventanaFin: DateTime(2026, 9, 27),
            periodoPrevisto: DateTime(2026, 10, 5),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(hour: 8),
      );
      expect(
        alerts.where((a) => a.type == AlertType.fertilidadCombinada),
        isEmpty,
      );
    });
  });

  group('AlertRuleEngine - encounters', () {
    test('encuentroFertilidad fires when recent encounter + woman fertile', () {
      final today = DateTime(2026, 9, 10);
      final encounters = [
        EncounterWithWomen(
          encounterId: 1,
          encounterTime: DateTime(2026, 9, 8),
          protection: 'Condón',
          participants: [
            EncounterParticipant(
              womanId: 1,
              womanName: 'María',
              womanInitials: 'MR',
              womanEmoji: '👩',
              womanColor: 0xFFE91E63,
              relationshipType: 'Vaginal',
            ),
          ],
        ),
      ];
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'María',
            estado: EstadoRiesgo.diaDeRiesgo,
            ventanaIni: DateTime(2026, 9, 6),
            ventanaFin: DateTime(2026, 9, 13),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
        ],
        medications: const [],
        encounters: encounters,
        settings: settings(hour: 8),
      );
      expect(
        alerts,
        contains(
          predicate<AlertItem>((a) => a.type == AlertType.encuentroFertilidad),
        ),
      );
    });
  });

  group('AlertRuleEngine - settings', () {
    test('returns empty when master disabled', () {
      final alerts = engine.evaluate(
        today: DateTime(2026, 9, 10),
        women: [
          ctx(
            1,
            'María',
            estado: EstadoRiesgo.diaDeRiesgo,
            ventanaIni: DateTime(2026, 9, 9),
            ventanaFin: DateTime(2026, 9, 16),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(master: false),
      );
      expect(alerts, isEmpty);
    });

    test('respects per-type toggle', () {
      final today = DateTime(2026, 9, 26);
      final alerts = engine.evaluate(
        today: today,
        women: [ctx(1, 'María', periodoPrevisto: DateTime(2026, 9, 27))],
        medications: const [],
        encounters: const [],
        settings: settings(
          types: {AlertType.diaDeRiesgo},
        ), // periodoInminente disabled
      );
      expect(
        alerts.where((a) => a.type == AlertType.periodoInminente),
        isEmpty,
      );
    });

    test('does not fire for past time today', () {
      final today = DateTime(2026, 9, 10, 15, 0); // 15:00
      final alerts = engine.evaluate(
        today: today,
        women: [
          ctx(
            1,
            'María',
            estado: EstadoRiesgo.diaDeRiesgo,
            ventanaIni: DateTime(2026, 9, 9),
            ventanaFin: DateTime(2026, 9, 16),
            periodoPrevisto: DateTime(2026, 9, 27),
          ),
        ],
        medications: const [],
        encounters: const [],
        settings: settings(hour: 9, minute: 0), // 09:00 already passed
      );
      expect(alerts.where((a) => a.type == AlertType.diaDeRiesgo), isEmpty);
    });
  });

  group('AlertRuleEngine - sinDatos', () {
    test('skips women with sinDatos', () {
      final alerts = engine.evaluate(
        today: DateTime(2026, 9, 10),
        women: [ctx(1, 'María', estado: EstadoRiesgo.sinDatos)],
        medications: const [],
        encounters: const [],
        settings: settings(),
      );
      expect(alerts, isEmpty);
    });
  });

  group('AlertItem - deterministic id', () {
    test('same inputs produce same id', () {
      final a = AlertItem(
        type: AlertType.diaDeRiesgo,
        fireDate: DateTime(2026, 9, 10, 9),
        message: const RiskDayMessage(initials: 'A', endsTomorrow: false),
        womanIds: [1],
      );
      final b = AlertItem(
        type: AlertType.diaDeRiesgo,
        fireDate: DateTime(2026, 9, 10, 9),
        message: const RiskDayMessage(initials: 'A', endsTomorrow: false),
        womanIds: [1],
      );
      expect(a.id, equals(b.id));
    });

    test('different dates produce different ids', () {
      final a = AlertItem(
        type: AlertType.diaDeRiesgo,
        fireDate: DateTime(2026, 9, 10, 9),
        message: const RiskDayMessage(initials: 'A', endsTomorrow: false),
        womanIds: [1],
      );
      final b = AlertItem(
        type: AlertType.diaDeRiesgo,
        fireDate: DateTime(2026, 9, 11, 9),
        message: const RiskDayMessage(initials: 'A', endsTomorrow: false),
        womanIds: [1],
      );
      expect(a.id, isNot(equals(b.id)));
    });
  });

  group('AlertSettings - CSV serialization', () {
    test('round-trips through CSV', () {
      final settings = AlertSettings(
        enabledTypes: {AlertType.diaDeRiesgo, AlertType.periodoInminente},
      );
      final csv = settings.enabledTypesToCsv();
      final restored = AlertSettings.enabledTypesFromCsv(csv);
      expect(restored, equals(settings.enabledTypes));
    });

    test('empty CSV returns all alert types for legacy defaults', () {
      expect(
        AlertSettings.enabledTypesFromCsv(''),
        containsAll(AlertType.values),
      );
    });

    test('ignores unknown CSV tokens', () {
      final restored = AlertSettings.enabledTypesFromCsv(
        'diaDeRiesgo,desconocido,periodoInminente',
      );
      expect(restored, contains(AlertType.diaDeRiesgo));
      expect(restored, contains(AlertType.periodoInminente));
      expect(restored, isNot(contains(AlertType.fertilidadInminente)));
    });

    test('none CSV disables all alert types', () {
      expect(AlertSettings.enabledTypesFromCsv('none'), isEmpty);
    });
  });
}
