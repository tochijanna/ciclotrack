import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/medication_validators.dart';
import 'medication_dao.dart';

class MedicationRepository {
  MedicationRepository(this._dao);
  final MedicationDao _dao;
  Stream<List<Medication>> watchAll() => _dao.watchAll();
  Stream<List<Medication>> watchByWoman(int womanId) =>
      _dao.watchByWoman(womanId);
  Stream<List<Medication>> watchEnabledByWoman(int womanId) =>
      _dao.watchEnabledByWoman(womanId);

  Future<int> save({
    int? id,
    required int womanId,
    required String name,
    required String dose,
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    final errors = [
      validateMedicationName(name),
      validateMedicationDose(dose),
      validateMedicationHour(hour),
      validateMedicationMinute(minute),
    ];
    for (final error in errors) {
      if (error != null) throw ArgumentError(error);
    }
    if (id == null) {
      return _dao.insert(
        MedicationsCompanion.insert(
          womanId: womanId,
          name: name.trim(),
          dose: Value(dose.trim()),
          hour: hour,
          minute: minute,
          enabled: Value(enabled),
        ),
      );
    }
    await _dao.updateMedication(
      Medication(
        id: id,
        womanId: womanId,
        name: name.trim(),
        dose: dose.trim(),
        hour: hour,
        minute: minute,
        enabled: enabled,
      ),
    );
    return id;
  }

  Future<void> setEnabled(Medication medication, bool enabled) =>
      _dao.updateMedication(medication.copyWith(enabled: enabled));
  Future<void> delete(int id) => _dao.deleteMedication(id);
}
