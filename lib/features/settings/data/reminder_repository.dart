import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/reminder_validators.dart';
import 'reminder_dao.dart';

/// Repositorio de recordatorios personalizados por día del ciclo.
class ReminderRepository {
  ReminderRepository(this._dao, {Future<void> Function()? onChanged})
    : _onChanged = onChanged;

  final ReminderDao _dao;

  /// Reprograma las notificaciones tras cada escritura.
  final Future<void> Function()? _onChanged;

  // --- Observación ---

  /// Stream de los recordatorios de una mujer.
  Stream<List<CycleReminder>> watchByWoman(int womanId) =>
      _dao.watchByWoman(womanId).map(_toDomainList);

  /// Stream de los recordatorios activos de todas las mujeres.
  Stream<List<CycleReminder>> watchActive() => _dao.watchAll().map(
    (rows) => _toDomainList(rows.where((row) => row.enabled)),
  );

  // --- Mutación ---

  /// Crea un recordatorio y devuelve su id.
  Future<int> create(int womanId, ReminderDraft draft) async {
    _ensureValid(draft);
    final id = await _dao.insert(
      RemindersCompanion.insert(
        womanId: womanId,
        cycleDayStart: draft.cycleDayStart,
        cycleDayEnd: draft.cycleDayEnd,
        message: draft.message.trim(),
        enabled: Value(draft.enabled),
      ),
    );
    await _notifyChanged();
    return id;
  }

  /// Sustituye los datos de un recordatorio existente.
  Future<void> update(CycleReminder reminder, ReminderDraft draft) async {
    _ensureValid(draft);
    await _dao.updateReminder(
      Reminder(
        id: reminder.id,
        womanId: reminder.womanId,
        cycleDayStart: draft.cycleDayStart,
        cycleDayEnd: draft.cycleDayEnd,
        message: draft.message.trim(),
        enabled: draft.enabled,
      ),
    );
    await _notifyChanged();
  }

  /// Activa o desactiva un recordatorio.
  Future<void> setEnabled(CycleReminder reminder, bool enabled) async {
    await _dao.updateReminder(_toRow(reminder.copyWith(enabled: enabled)));
    await _notifyChanged();
  }

  /// Elimina un recordatorio.
  Future<void> delete(int id) async {
    await _dao.deleteReminder(id);
    await _notifyChanged();
  }

  void _ensureValid(ReminderDraft draft) {
    final error = validateReminderDraft(draft);
    if (error != null) throw ArgumentError(error);
  }

  Future<void> _notifyChanged() async {
    try {
      await _onChanged?.call();
    } catch (_) {
      // Un fallo al reprogramar no debe impedir guardar el recordatorio.
    }
  }

  List<CycleReminder> _toDomainList(Iterable<Reminder> rows) =>
      rows.map(_toDomain).toList();

  CycleReminder _toDomain(Reminder row) => CycleReminder(
    id: row.id,
    womanId: row.womanId,
    cycleDayStart: row.cycleDayStart,
    cycleDayEnd: row.cycleDayEnd,
    message: row.message,
    enabled: row.enabled,
  );

  Reminder _toRow(CycleReminder reminder) => Reminder(
    id: reminder.id,
    womanId: reminder.womanId,
    cycleDayStart: reminder.cycleDayStart,
    cycleDayEnd: reminder.cycleDayEnd,
    message: reminder.message,
    enabled: reminder.enabled,
  );
}
