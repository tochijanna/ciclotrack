import 'dart:async';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/tracking_drafts.dart';
import '../domain/tracking_event.dart';
import '../domain/tracking_validators.dart';
import 'tracking_dao.dart';

/// Repositorio que orquesta acceso a periodos, ovulación y síntomas.
class TrackingRepository {
  TrackingRepository(this._dao);

  final TrackingDao _dao;

  // --- Timeline ---

  /// Stream reactivo de todos los eventos de una mujer, ordenados por fecha
  /// descendente. Emite de nuevo ante cualquier cambio en periodos, ovulación
  /// o síntomas.
  Stream<List<TrackingEvent>> watchTimeline(int womanId) {
    final periods$ = _dao.watchPeriodLogsByWoman(womanId);
    final ovulations$ = _dao.watchOvulationLogsByWoman(womanId);
    final symptoms$ = _dao.watchSymptomLogsByWoman(womanId);

    return _combineLatest3(periods$, ovulations$, symptoms$, _buildTimeline);
  }

  /// Obtiene el timeline completo una sola vez (no reactivo).
  Future<List<TrackingEvent>> getTimelineOnce(int womanId) async {
    final periods = await _dao.watchPeriodLogsByWoman(womanId).first;
    final ovulations = await _dao.watchOvulationLogsByWoman(womanId).first;
    final symptoms = await _dao.watchSymptomLogsByWoman(womanId).first;
    return _buildTimeline(periods, ovulations, symptoms);
  }

  /// Combina tres streams emitiendo siempre que cualquiera de ellos cambie.
  /// Emite una primera vez tan pronto como los tres hayan emitido al menos una
  /// vez. Las suscripciones se cancelan al cerrarse el stream resultante.
  Stream<T> _combineLatest3<A, B, C, T>(
    Stream<A> a$,
    Stream<B> b$,
    Stream<C> c$,
    T Function(A, B, C) combine,
  ) {
    late StreamController<T> controller;
    A? a;
    B? b;
    C? c;
    var aReady = false;
    var bReady = false;
    var cReady = false;

    void emitIfReady() {
      if (aReady && bReady && cReady && !controller.isClosed) {
        controller.add(combine(a as A, b as B, c as C));
      }
    }

    controller = StreamController<T>(
      onListen: () {
        final subA = a$.listen((v) {
          a = v;
          aReady = true;
          emitIfReady();
        });
        final subB = b$.listen((v) {
          b = v;
          bReady = true;
          emitIfReady();
        });
        final subC = c$.listen((v) {
          c = v;
          cReady = true;
          emitIfReady();
        });

        controller.onCancel = () async {
          await subA.cancel();
          await subB.cancel();
          await subC.cancel();
        };
      },
    );

    return controller.stream;
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

  Future<PeriodLog?> getPeriodById(int id) => _dao.getPeriodLogById(id);

  Future<int> createPeriod(int womanId, PeriodDraft draft) async {
    await _ensurePeriodDoesNotOverlap(womanId, draft);
    return _dao.insertPeriodLog(
      PeriodLogsCompanion.insert(
        womanId: womanId,
        startDate: calendarDate(draft.startDate),
        endDate: Value(
          draft.endDate == null ? null : calendarDate(draft.endDate!),
        ),
        flowLevel: Value(draft.flowLevel),
        notes: Value(draft.notes),
      ),
    );
  }

  Future<void> updatePeriod(PeriodLog existing, PeriodDraft draft) async {
    await _ensurePeriodDoesNotOverlap(existing.womanId, draft, existing.id);
    await _dao.updatePeriodLog(
      existing.copyWith(
        startDate: calendarDate(draft.startDate),
        endDate: Value(
          draft.endDate == null ? null : calendarDate(draft.endDate!),
        ),
        flowLevel: Value(draft.flowLevel),
        notes: draft.notes,
      ),
    );
  }

  Future<void> updatePeriodById(int id, PeriodDraft draft) async {
    final existing = await _dao.getPeriodLogById(id);
    if (existing == null) return;
    await updatePeriod(existing, draft);
  }

  Future<void> deletePeriod(int id) => _dao.deletePeriodLog(id);

  Future<void> _ensurePeriodDoesNotOverlap(
    int womanId,
    PeriodDraft draft, [
    int? excludedId,
  ]) async {
    final start = calendarDate(draft.startDate);
    final end = draft.endDate == null ? start : calendarDate(draft.endDate!);
    final existing = await _dao.getPeriodLogsByWoman(womanId);
    final conflict = existing.any((period) {
      if (period.id == excludedId) return false;
      final existingStart = calendarDate(period.startDate);
      final existingEnd = period.endDate == null
          ? existingStart
          : calendarDate(period.endDate!);
      return !end.isBefore(existingStart) && !start.isAfter(existingEnd);
    });
    if (conflict) {
      throw const PeriodConflictException(
        'El periodo se solapa con otro registro existente',
      );
    }
  }

  // --- Ovulación ---

  Future<OvulationLog?> getOvulationById(int id) =>
      _dao.getOvulationLogById(id);

  Future<int> createOvulation(int womanId, OvulationDraft draft) =>
      _dao.insertOvulationLog(
        OvulationLogsCompanion.insert(
          womanId: womanId,
          date: calendarDate(draft.date),
          temperature: Value(draft.temperature),
          cervicalMucus: Value(draft.cervicalMucus),
          lhTest: Value(draft.lhTest),
        ),
      );

  Future<void> updateOvulation(OvulationLog existing, OvulationDraft draft) =>
      _dao.updateOvulationLog(
        existing.copyWith(
          date: calendarDate(draft.date),
          temperature: Value(draft.temperature),
          cervicalMucus: Value(draft.cervicalMucus),
          lhTest: Value(draft.lhTest),
        ),
      );

  Future<void> updateOvulationById(int id, OvulationDraft draft) async {
    final existing = await _dao.getOvulationLogById(id);
    if (existing == null) return;
    await updateOvulation(existing, draft);
  }

  Future<void> deleteOvulation(int id) => _dao.deleteOvulationLog(id);

  // --- Síntomas ---

  Future<SymptomLog?> getSymptomById(int id) => _dao.getSymptomLogById(id);

  Future<int> createSymptom(int womanId, SymptomDraft draft) =>
      _dao.insertSymptomLog(
        SymptomsCompanion.insert(
          womanId: womanId,
          date: calendarDate(draft.date),
          type: draft.type,
          severity: Value(draft.severity),
          notes: Value(draft.notes),
        ),
      );

  Future<void> updateSymptom(SymptomLog existing, SymptomDraft draft) =>
      _dao.updateSymptomLog(
        existing.copyWith(
          date: calendarDate(draft.date),
          type: draft.type,
          severity: draft.severity,
          notes: draft.notes,
        ),
      );

  Future<void> updateSymptomById(int id, SymptomDraft draft) async {
    final existing = await _dao.getSymptomLogById(id);
    if (existing == null) return;
    await updateSymptom(existing, draft);
  }

  Future<void> deleteSymptom(int id) => _dao.deleteSymptomLog(id);
}
