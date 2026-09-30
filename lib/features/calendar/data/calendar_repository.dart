import '../../../core/async/combine_latest.dart';
import '../../encounters/data/encounter_repository.dart';
import '../../prediction/domain/cycle_timeline.dart';
import '../../prediction/domain/prediction_calculator.dart';
import '../../prediction/domain/prediction_engine.dart';
import '../../profiles/data/women_repository.dart';
import '../../tracking/data/tracking_dao.dart';
import '../../tracking/domain/tracking_event.dart';
import '../domain/calendar_board.dart';

/// Compone el tablero que consumen las vistas consolidadas.
///
/// Se suscribe una única vez a los cinco streams globales (perfiles, periodos,
/// ovulaciones, síntomas y encuentros) en lugar de consultar por mujer: evita
/// el patrón N+1 y mantiene el tablero reactivo ante cualquier cambio.
class CalendarRepository {
  CalendarRepository({
    required WomenRepository womenRepo,
    required TrackingDao trackingDao,
    required EncounterRepository encounterRepo,
    PredictionEngine? engine,
  }) : _womenRepo = womenRepo,
       _trackingDao = trackingDao,
       _encounterRepo = encounterRepo,
       _engine = engine ?? PredictionEngine();

  /// Horizonte de proyección de los ciclos futuros (~18 meses).
  static const defaultHorizonte = Duration(days: 550);

  final WomenRepository _womenRepo;
  final TrackingDao _trackingDao;
  final EncounterRepository _encounterRepo;
  final PredictionEngine _engine;

  /// Emite un tablero nuevo ante cualquier cambio de datos o de [today].
  Stream<CalendarBoard> watchBoard({
    required DateTime today,
    Duration horizonte = defaultHorizonte,
  }) {
    final limite = _addDays(_calendarDate(today), horizonte.inDays);

    return combineLatest5(
      _womenRepo.watchAllProfiles(),
      _trackingDao.watchAllPeriodLogs(),
      _trackingDao.watchAllOvulationLogs(),
      _trackingDao.watchAllSymptomLogs(),
      _encounterRepo.watchAll(),
      (profiles, periodos, ovulaciones, sintomas, encuentros) {
        final periodosPorMujer = <int, List<PeriodLogInput>>{};
        for (final periodo in periodos) {
          (periodosPorMujer[periodo.womanId] ??= <PeriodLogInput>[]).add(
            PeriodLogInput(
              startDate: periodo.startDate,
              endDate: periodo.endDate,
            ),
          );
        }

        final eventosPorMujer = <int, List<TrackingEvent>>{};
        for (final ovulacion in ovulaciones) {
          (eventosPorMujer[ovulacion.womanId] ??= <TrackingEvent>[]).add(
            TrackingEvent.ovulation(
              id: ovulacion.id,
              womanId: ovulacion.womanId,
              date: ovulacion.date,
              temperature: ovulacion.temperature,
              cervicalMucus: ovulacion.cervicalMucus,
              lhTest: ovulacion.lhTest,
            ),
          );
        }
        for (final sintoma in sintomas) {
          (eventosPorMujer[sintoma.womanId] ??= <TrackingEvent>[]).add(
            TrackingEvent.symptom(
              id: sintoma.id,
              womanId: sintoma.womanId,
              date: sintoma.date,
              type: sintoma.type,
              severity: sintoma.severity,
              notes: sintoma.notes,
            ),
          );
        }

        return CalendarBoard(
          women: [
            for (final profile in profiles)
              WomanCalendar(
                woman: CalendarWoman(
                  id: profile.woman.id,
                  name: profile.woman.name,
                  initials: profile.woman.initials,
                  emoji: profile.woman.emoji,
                  color: profile.woman.color,
                ),
                timeline: CycleTimeline.from(
                  logs: periodosPorMujer[profile.woman.id] ?? const [],
                  horizonte: limite,
                  engine: _engine,
                ),
                eventos: eventosPorMujer[profile.woman.id] ?? const [],
                periodos: periodosPorMujer[profile.woman.id] ?? const [],
              ),
          ],
          encuentros: encuentros,
        );
      },
    );
  }
}

DateTime _calendarDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _addDays(DateTime base, int days) =>
    DateTime(base.year, base.month, base.day + days);
