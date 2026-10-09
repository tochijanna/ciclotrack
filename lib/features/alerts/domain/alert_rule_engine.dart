import '../../../../core/time/calendar_days.dart';
import '../../encounters/domain/encounter_event.dart';
import '../../prediction/domain/woman_prediction.dart';
import 'alert_item.dart';
import 'alert_message.dart';
import 'alert_settings.dart';
import 'alert_types.dart';
import 'medication_alert_input.dart';

/// Contexto de una mujer para la evaluación de alertas.
class WomanAlertContext {
  const WomanAlertContext({
    required this.womanId,
    required this.name,
    required this.initials,
    required this.prediction,
  });

  final int womanId;
  final String name;
  final String initials;
  final WomanPrediction prediction;
}

/// Motor puro de reglas de alerta.
/// Todas las dependencias se inyectan; «hoy» es un parámetro testeable.
///
/// Produce mensajes estructurados ([AlertMessage]); el texto visible se
/// localiza en la capa de datos.
class AlertRuleEngine {
  const AlertRuleEngine();

  /// Evalúa todas las reglas y devuelve las alertas a programar.
  List<AlertItem> evaluate({
    required DateTime today,
    required List<WomanAlertContext> women,
    required List<EncounterWithWomen> encounters,
    required List<MedicationAlertInput> medications,
    required AlertSettings settings,
  }) {
    if (!settings.masterEnabled) return [];

    final alerts = <AlertItem>[];
    final todayDate = calendarDate(today);
    final tomorrow = addDays(todayDate, 1);
    final endHorizon = todayDate.add(Duration(days: settings.horizonDays));

    for (final w in women) {
      final p = w.prediction;
      if (p.estadoRiesgo == EstadoRiesgo.sinDatos) continue;
      if (p.periodoPrevisto == null) continue;

      final previsto = p.periodoPrevisto!;
      final ovulacion = p.ovulacionEstimada;
      final ventIni = p.ventanaFertilInicio;
      final ventFin = p.ventanaFertilFin;

      // 1. Fertilidad inminente: mañana = ovulación estimada
      if (settings.isEnabled(AlertType.fertilidadInminente) &&
          ovulacion != null &&
          _sameDay(ovulacion, tomorrow)) {
        final dias = ventFin != null && ventIni != null
            ? daysBetween(ventIni, ventFin) + 1
            : 7;
        alerts.add(
          AlertItem(
            type: AlertType.fertilidadInminente,
            fireDate: _fireTodayOrSoon(today, todayDate, settings),
            message: FertilityImminentMessage(initials: w.initials, days: dias),
            womanIds: [w.womanId],
          ),
        );
      }

      // 2. Día de riesgo: hoy dentro de ventana fértil
      if (settings.isEnabled(AlertType.diaDeRiesgo) &&
          p.estadoRiesgo == EstadoRiesgo.diaDeRiesgo &&
          ventFin != null) {
        final fire = _atTime(todayDate, settings);
        if (fire.isAfter(today)) {
          alerts.add(
            AlertItem(
              type: AlertType.diaDeRiesgo,
              fireDate: fire,
              message: RiskDayMessage(
                initials: w.initials,
                endsTomorrow: _sameDay(ventFin, tomorrow),
                endsOn: ventFin,
              ),
              womanIds: [w.womanId],
            ),
          );
        }
      }

      // 3. Periodo inminente: mañana = periodo previsto
      if (settings.isEnabled(AlertType.periodoInminente) &&
          _sameDay(previsto, tomorrow)) {
        alerts.add(
          AlertItem(
            type: AlertType.periodoInminente,
            fireDate: _fireTodayOrSoon(today, todayDate, settings),
            message: PeriodImminentMessage(initials: w.initials),
            womanIds: [w.womanId],
          ),
        );
      }
    }

    // 4. Fertilidad combinada: ≥2 mujeres fértiles esta semana
    if (settings.isEnabled(AlertType.fertilidadCombinada)) {
      final fertiles = women
          .where(
            (w) =>
                w.prediction.estadoRiesgo == EstadoRiesgo.diaDeRiesgo ||
                (w.prediction.ventanaFertilInicio != null &&
                    w.prediction.ventanaFertilInicio!.isBefore(endHorizon) &&
                    w.prediction.ventanaFertilFin != null &&
                    w.prediction.ventanaFertilFin!.isAfter(todayDate)),
          )
          .toList();
      if (fertiles.length >= 2) {
        final fire = _atTime(todayDate, settings);
        if (fire.isAfter(today)) {
          alerts.add(
            AlertItem(
              type: AlertType.fertilidadCombinada,
              fireDate: fire,
              message: CombinedFertilityMessage(
                initials: fertiles.map((w) => w.initials).toList(),
              ),
              womanIds: fertiles.map((w) => w.womanId).toList(),
            ),
          );
        }
      }
    }

    // 5–6. Encuentro + fertilidad / advertencia post-encuentro
    for (final e in encounters) {
      final diasDesdeEncuentro = daysBetween(
        DateTime(
          e.encounterTime.year,
          e.encounterTime.month,
          e.encounterTime.day,
        ),
        todayDate,
      );

      for (final part in e.participants) {
        final ctx = women.where((w) => w.womanId == part.womanId);
        if (ctx.isEmpty) continue;
        final w = ctx.first;
        final p = w.prediction;

        // 5. Encuentro + fertilidad
        if (settings.isEnabled(AlertType.encuentroFertilidad) &&
            diasDesdeEncuentro <= 7 &&
            diasDesdeEncuentro >= 0 &&
            p.estadoRiesgo == EstadoRiesgo.diaDeRiesgo) {
          final diasRestantes = p.ventanaFertilFin == null
              ? null
              : daysBetween(todayDate, p.ventanaFertilFin!);
          final fire = _atTime(todayDate, settings);
          if (fire.isAfter(today)) {
            alerts.add(
              AlertItem(
                type: AlertType.encuentroFertilidad,
                fireDate: fire,
                message: EncounterFertilityMessage(
                  initials: w.initials,
                  encounterOn: e.encounterTime,
                  extraDays: diasRestantes,
                ),
                womanIds: [w.womanId],
              ),
            );
          }
        }

        // 6. Advertencia post-encuentro
        if (settings.isEnabled(AlertType.advertenciaPostEncuentro) &&
            diasDesdeEncuentro >= 12 &&
            p.periodoPrevisto != null) {
          final diasHastaPeriodo = daysBetween(todayDate, p.periodoPrevisto!);
          if (diasHastaPeriodo >= 0 && diasHastaPeriodo <= 3) {
            final fire = _atTime(todayDate, settings);
            if (fire.isAfter(today)) {
              alerts.add(
                AlertItem(
                  type: AlertType.advertenciaPostEncuentro,
                  fireDate: fire,
                  message: PostEncounterWarningMessage(
                    initials: w.initials,
                    encounterOn: e.encounterTime,
                    periodOn: p.periodoPrevisto!,
                  ),
                  womanIds: [w.womanId],
                ),
              );
            }
          }
        }
      }
    }

    // 7. Múltiples mujeres + fertilidad (encuentro multi-mujer con ≥2 fértiles)
    if (settings.isEnabled(AlertType.multiplesMujeresFertilidad)) {
      for (final e in encounters) {
        if (e.participants.length < 2) continue;
        final fertilesEnEncuentro = e.participants.where((part) {
          final ctx = women.where((w) => w.womanId == part.womanId);
          if (ctx.isEmpty) return false;
          return ctx.first.prediction.estadoRiesgo == EstadoRiesgo.diaDeRiesgo;
        }).toList();
        if (fertilesEnEncuentro.length >= 2) {
          final nombres = fertilesEnEncuentro.map((p) {
            final ctx = women.where((w) => w.womanId == p.womanId);
            return ctx.isNotEmpty ? ctx.first.initials : '?';
          }).toList();
          final fire = _atTime(
            DateTime(
              e.encounterTime.year,
              e.encounterTime.month,
              e.encounterTime.day,
            ).add(const Duration(days: 1)),
            settings,
          );
          if (fire.isAfter(today)) {
            alerts.add(
              AlertItem(
                type: AlertType.multiplesMujeresFertilidad,
                fireDate: fire,
                message: MultiWomenFertilityMessage(
                  initials: nombres,
                  encounterOn: e.encounterTime,
                ),
                womanIds: fertilesEnEncuentro.map((p) => p.womanId).toList(),
              ),
            );
          }
        }
      }
    }

    // 8. Ventana combinada: resumen semanal
    if (settings.isEnabled(AlertType.ventanaCombinada)) {
      final resumen = <FertileRangeEntry>[];
      for (final w in women) {
        final p = w.prediction;
        if (p.ventanaFertilInicio != null && p.ventanaFertilFin != null) {
          resumen.add(
            FertileRangeEntry(
              initials: w.initials,
              from: p.ventanaFertilInicio!,
              to: p.ventanaFertilFin!,
            ),
          );
        }
      }
      if (resumen.length >= 2) {
        // Programar para mañana (resumen semanal)
        final fire = _atTime(tomorrow, settings);
        alerts.add(
          AlertItem(
            type: AlertType.ventanaCombinada,
            fireDate: fire,
            message: CombinedWindowMessage(entries: resumen),
            womanIds: women.map((w) => w.womanId).toList(),
          ),
        );
      }
    }

    if (settings.isEnabled(AlertType.medicacion)) {
      for (final medication in medications) {
        if (!medication.enabled) continue;
        final profiles = women.where((w) => w.womanId == medication.womanId);
        if (profiles.isEmpty) continue;
        final scheduled = DateTime(
          today.year,
          today.month,
          today.day,
          medication.hour,
          medication.minute,
        );
        final fire = scheduled.isBefore(today)
            ? DateTime(
                today.year,
                today.month,
                today.day + 1,
                medication.hour,
                medication.minute,
              )
            : scheduled;
        alerts.add(
          AlertItem(
            type: AlertType.medicacion,
            fireDate: fire,
            message: MedicationMessage(
              hour: medication.hour,
              minute: medication.minute,
            ),
            womanIds: [medication.womanId],
            medicationId: medication.id,
            recurringDaily: true,
          ),
        );
      }
    }

    // Deduplicar por id
    final seen = <int>{};
    return alerts.where((a) => seen.add(a.id)).toList();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _atTime(DateTime date, AlertSettings settings) => DateTime(
    date.year,
    date.month,
    date.day,
    settings.notifyHour,
    settings.notifyMinute,
  );

  DateTime _fireTodayOrSoon(
    DateTime now,
    DateTime today,
    AlertSettings settings,
  ) {
    final configured = _atTime(today, settings);
    return configured.isAfter(now)
        ? configured
        : now.add(const Duration(minutes: 1));
  }
}
