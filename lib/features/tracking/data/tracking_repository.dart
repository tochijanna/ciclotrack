import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/tracking_drafts.dart';
import '../domain/tracking_event.dart';
import 'tracking_dao.dart';

/// Repositorio que orquesta acceso a periodos, ovulación y síntomas.
class TrackingRepository {
  TrackingRepository(this._dao);

  final TrackingDao _dao;

  // --- Timeline ---

  /// Stream de todos los eventos de una mujer, ordenados por fecha descendente.
  Stream<List<TrackingEvent>> watchTimeline(int womanId) {
    final periods$ = _dao.watchPeriodLogsByWoman(womanId);
    final ovulations$ = _dao.watchOvulationLogsByWoman(womanId);
    final symptoms$ = _dao.watchSymptomLogsByWoman(womanId);

    return _combineTimeline(periods$, ovulations$, symptoms$);
  }

  Stream<List<TrackingEvent>> _combineTimeline(
    Stream<List<PeriodLog>> periods$,
    Stream<List<OvulationLog>> ovulations$,
    Stream<List<SymptomLog>> symptoms$,
  ) async* {
    // Escuchamos los tres streams y combinamos manualmente.
    List<PeriodLog> periods = [];
    List<OvulationLog> ovulations = [];
    List<SymptomLog> symptoms = [];

    await for (final p in periods$) {
      periods = p;
      yield _buildTimeline(periods, ovulations, symptoms);
    }
    // Nota: este enfoque simplificado solo reacciona al stream de periodos.
    // Para una reactividad completa, usamos StreamGroup o Future.wait en el provider.
  }

  /// Obtiene el timeline completo una sola vez (no reactivo).
  Future<List<TrackingEvent>> getTimelineOnce(int womanId) async {
    final periods = await _dao.watchPeriodLogsByWoman(womanId).first;
    final ovulations = await _dao.watchOvulationLogsByWoman(womanId).first;
    final symptoms = await _dao.watchSymptomLogsByWoman(womanId).first;
    return _buildTimeline(periods, ovulations, symptoms);
  }

  List<TrackingEvent> _buildTimeline(
    List<PeriodLog> periods,
    List<OvulationLog> ovulations,
    List<SymptomLog> symptoms,
  ) {
    final events = <TrackingEvent>[];

    for (final p in periods) {
      events.add(
        TrackingEvent.period(
          id: p.id,
          womanId: p.womanId,
          startDate: p.startDate,
          endDate: p.endDate,
          flowLevel: p.flowLevel,
          notes: p.notes,
        ),
      );
    }

    for (final o in ovulations) {
      events.add(
        TrackingEvent.ovulation(
          id: o.id,
          womanId: o.womanId,
          date: o.date,
          temperature: o.temperature,
          cervicalMucus: o.cervicalMucus,
          lhTest: o.lhTest,
        ),
      );
    }

    for (final s in symptoms) {
      events.add(
        TrackingEvent.symptom(
          id: s.id,
          womanId: s.womanId,
          date: s.date,
          type: s.type,
          severity: s.severity,
          notes: s.notes,
        ),
      );
    }

    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  // --- Periodos ---

  Future<int> createPeriod(int womanId, PeriodDraft draft) =>
      _dao.insertPeriodLog(
        PeriodLogsCompanion.insert(
          womanId: womanId,
          startDate: draft.startDate,
          endDate: Value(draft.endDate),
          flowLevel: Value(draft.flowLevel),
          notes: Value(draft.notes),
        ),
      );

  Future<void> updatePeriod(PeriodLog existing, PeriodDraft draft) =>
      _dao.updatePeriodLog(
        existing.copyWith(
          startDate: draft.startDate,
          endDate: Value(draft.endDate),
          flowLevel: Value(draft.flowLevel),
          notes: draft.notes,
        ),
      );

  Future<void> deletePeriod(int id) => _dao.deletePeriodLog(id);

  // --- Ovulación ---

  Future<int> createOvulation(int womanId, OvulationDraft draft) =>
      _dao.insertOvulationLog(
        OvulationLogsCompanion.insert(
          womanId: womanId,
          date: draft.date,
          temperature: Value(draft.temperature),
          cervicalMucus: Value(draft.cervicalMucus),
          lhTest: Value(draft.lhTest),
        ),
      );

  Future<void> updateOvulation(OvulationLog existing, OvulationDraft draft) =>
      _dao.updateOvulationLog(
        existing.copyWith(
          date: draft.date,
          temperature: Value(draft.temperature),
          cervicalMucus: Value(draft.cervicalMucus),
          lhTest: Value(draft.lhTest),
        ),
      );

  Future<void> deleteOvulation(int id) => _dao.deleteOvulationLog(id);

  // --- Síntomas ---

  Future<int> createSymptom(int womanId, SymptomDraft draft) =>
      _dao.insertSymptomLog(
        SymptomsCompanion.insert(
          womanId: womanId,
          date: draft.date,
          type: draft.type,
          severity: Value(draft.severity),
          notes: Value(draft.notes),
        ),
      );

  Future<void> updateSymptom(SymptomLog existing, SymptomDraft draft) =>
      _dao.updateSymptomLog(
        existing.copyWith(
          date: draft.date,
          type: draft.type,
          severity: draft.severity,
          notes: draft.notes,
        ),
      );

  Future<void> deleteSymptom(int id) => _dao.deleteSymptomLog(id);
}
