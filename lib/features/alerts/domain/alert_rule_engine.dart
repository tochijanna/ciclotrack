import '../../encounters/domain/encounter_event.dart';
import '../../prediction/domain/woman_prediction.dart';
import 'alert_item.dart';
import 'alert_settings.dart';
import 'alert_types.dart';

/// Contexto de una mujer para la evaluación de alertas.
class WomanAlertContext {
  const WomanAlertContext({
    required this.womanId,
    required this.name,
    required this.prediction,
  });

  final int womanId;
  final String name;
  final WomanPrediction prediction;
}

/// Motor puro de reglas de alerta.
/// Todas las dependencias se inyectan; «hoy» es un parámetro testeable.
class AlertRuleEngine {
  const AlertRuleEngine();

  /// Evalúa todas las reglas y devuelve las alertas a programar.
  List<AlertItem> evaluate({
    required DateTime today,
    required List<WomanAlertContext> women,
    required List<EncounterWithWomen> encounters,
    required AlertSettings settings,
  }) {
    if (!settings.masterEnabled) return [];

    final alerts = <AlertItem>[];
    final todayDate = DateTime(today.year, today.month, today.day);
    final tomorrow = todayDate.add(const Duration(days: 1));
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
            ? ventFin.difference(ventIni).inDays + 1
            : 7;
        alerts.add(
          AlertItem(
            type: AlertType.fertilidadInminente,
            fireDate: _fireTodayOrSoon(today, todayDate, settings),
            title: 'Fertilidad inminente',
            body:
                'Mañana es día de ovulación de ${w.name}. Ventana de fertilidad: $dias días',
            womanIds: [w.womanId],
          ),
        );
      }

      // 2. Día de riesgo: hoy dentro de ventana fértil
      if (settings.isEnabled(AlertType.diaDeRiesgo) &&
          p.estadoRiesgo == EstadoRiesgo.diaDeRiesgo &&
          ventFin != null) {
        final finTexto = _sameDay(ventFin, tomorrow)
            ? 'termina mañana'
            : 'termina el ${_formatShort(ventFin)}';
        final fire = _atTime(todayDate, settings);
        if (fire.isAfter(today)) {
          alerts.add(
            AlertItem(
              type: AlertType.diaDeRiesgo,
              fireDate: fire,
              title: 'Día de riesgo',
              body:
                  'Hoy es día de riesgo con ${w.name}. Su ventana de fertilidad $finTexto',
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
            title: 'Periodo inminente',
            body: 'El periodo de ${w.name} empieza mañana',
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
        final nombres = fertiles.map((w) => w.name).join(' y ');
        final fire = _atTime(todayDate, settings);
        if (fire.isAfter(today)) {
          alerts.add(
            AlertItem(
              type: AlertType.fertilidadCombinada,
              fireDate: fire,
              title: 'Fertilidad combinada',
              body: 'Esta semana hay fertilidad con $nombres',
              womanIds: fertiles.map((w) => w.womanId).toList(),
            ),
          );
        }
      }
    }

    // 5–6. Encuentro + fertilidad / advertencia post-encuentro
    for (final e in encounters) {
      final diasDesdeEncuentro = todayDate
          .difference(
            DateTime(
              e.encounterTime.year,
              e.encounterTime.month,
              e.encounterTime.day,
            ),
          )
          .inDays;
      final diaSemana = _weekdayName(e.encounterTime);

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
          final diasRestantes = p.ventanaFertilFin
              ?.difference(todayDate)
              .inDays;
          final extra = diasRestantes != null ? ' + $diasRestantes días' : '';
          final fire = _atTime(todayDate, settings);
          if (fire.isAfter(today)) {
            alerts.add(
              AlertItem(
                type: AlertType.encuentroFertilidad,
                fireDate: fire,
                title: 'Encuentro + fertilidad',
                body:
                    'Te acostaste con ${w.name} el $diaSemana y su ventana de fertilidad es hoy$extra',
                womanIds: [w.womanId],
              ),
            );
          }
        }

        // 6. Advertencia post-encuentro
        if (settings.isEnabled(AlertType.advertenciaPostEncuentro) &&
            diasDesdeEncuentro >= 12 &&
            p.periodoPrevisto != null) {
          final diasHastaPeriodo = p.periodoPrevisto!
              .difference(todayDate)
              .inDays;
          if (diasHastaPeriodo >= 0 && diasHastaPeriodo <= 3) {
            final fire = _atTime(todayDate, settings);
            if (fire.isAfter(today)) {
              alerts.add(
                AlertItem(
                  type: AlertType.advertenciaPostEncuentro,
                  fireDate: fire,
                  title: 'Advertencia post-encuentro',
                  body:
                      'Te acostaste con ${w.name} el $diaSemana. Su periodo debería empezar el ${_formatShort(p.periodoPrevisto!)}. Si no hay embarazo, es probable que tenga sangrado a esa fecha.',
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
          final nombres = e.participants
              .map((p) {
                final ctx = women.where((w) => w.womanId == p.womanId);
                return ctx.isNotEmpty ? ctx.first.name : '?';
              })
              .join(' y ');
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
                title: 'Múltiples mujeres + fertilidad',
                body:
                    'Te acostaste con $nombres el ${_weekdayName(e.encounterTime)}. Ambas tienen ventana de fertilidad activa. Alto riesgo.',
                womanIds: e.participants.map((p) => p.womanId).toList(),
              ),
            );
          }
        }
      }
    }

    // 8. Ventana combinada: resumen semanal
    if (settings.isEnabled(AlertType.ventanaCombinada)) {
      final resumen = <String>[];
      for (final w in women) {
        final p = w.prediction;
        if (p.ventanaFertilInicio != null && p.ventanaFertilFin != null) {
          resumen.add(
            '${w.name} es fértil del ${_formatShort(p.ventanaFertilInicio!)} al ${_formatShort(p.ventanaFertilFin!)}',
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
            title: 'Ventana combinada',
            body: '${resumen.join('. ')}.',
            womanIds: women.map((w) => w.womanId).toList(),
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

  String _formatShort(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _weekdayName(DateTime d) {
    const days = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    return days[d.weekday - 1];
  }
}
