import '../../encounters/data/encounter_repository.dart';
import '../../prediction/data/prediction_repository.dart';
import '../../profiles/data/women_repository.dart';
import '../domain/alert_item.dart';
import '../domain/alert_rule_engine.dart';
import '../domain/alert_settings.dart' as domain;
import '../domain/alert_types.dart';
import 'alert_settings_dao.dart';
import 'notification_scheduler.dart';

/// Repositorio que orquesta la evaluación y programación de alertas.
class AlertsRepository {
  AlertsRepository({
    required this.scheduler,
    required this.settingsDao,
    required this.predictionRepo,
    required this.encounterRepo,
    required this.womenRepo,
    this.engine = const AlertRuleEngine(),
  });

  final NotificationScheduler scheduler;
  final AlertSettingsDao settingsDao;
  final PredictionRepository predictionRepo;
  final EncounterRepository encounterRepo;
  final WomenRepository womenRepo;
  final AlertRuleEngine engine;

  /// Recalcula y reprograma todas las alertas.
  Future<void> refreshAlerts({DateTime? today}) async {
    final now = today ?? DateTime.now();

    // Cargar ajustes.
    final dbSettings = await settingsDao.getOrCreate();
    final settings = _toDomain(dbSettings);

    if (!settings.masterEnabled) {
      await scheduler.cancelAll();
      return;
    }

    // Cargar mujeres con predicciones.
    final profiles = await womenRepo.watchAllProfiles().first;
    final women = <WomanAlertContext>[];
    for (final profile in profiles) {
      final pred = await predictionRepo.watchPrediction(profile.woman.id).first;
      if (pred != null) {
        women.add(
          WomanAlertContext(
            womanId: profile.woman.id,
            name: profile.woman.name,
            prediction: pred,
          ),
        );
      }
    }

    // Cargar encuentros.
    final encounters = await encounterRepo.watchAll().first;

    // Evaluar reglas.
    final items = engine.evaluate(
      today: now,
      women: women,
      encounters: encounters,
      settings: settings,
    );

    // Programar primero; así un fallo no deja al usuario sin las anteriores.
    final oldIds = (await scheduler.pending()).map((item) => item.id).toSet();
    final newIds = items.map((item) => item.id).toSet();
    for (final item in items) {
      await scheduler.schedule(item);
    }
    await scheduler.cancel(oldIds.difference(newIds).toList());
  }

  /// Vista previa de alertas sin programar (para la UI).
  Future<List<AlertItem>> watchUpcomingAlerts({DateTime? today}) async {
    final now = today ?? DateTime.now();
    final dbSettings = await settingsDao.getOrCreate();
    final settings = _toDomain(dbSettings);

    final profiles = await womenRepo.watchAllProfiles().first;
    final women = <WomanAlertContext>[];
    for (final profile in profiles) {
      final pred = await predictionRepo.watchPrediction(profile.woman.id).first;
      if (pred != null) {
        women.add(
          WomanAlertContext(
            womanId: profile.woman.id,
            name: profile.woman.name,
            prediction: pred,
          ),
        );
      }
    }

    final encounters = await encounterRepo.watchAll().first;

    return engine.evaluate(
      today: now,
      women: women,
      encounters: encounters,
      settings: settings,
    );
  }

  /// Actualiza un ajuste individual.
  Future<void> updateMasterEnabled(bool value) async {
    final current = await settingsDao.getOrCreate();
    await settingsDao.updateSettings(current.copyWith(masterEnabled: value));
  }

  Future<void> updateNotifyTime(int hour, int minute) async {
    final current = await settingsDao.getOrCreate();
    await settingsDao.updateSettings(
      current.copyWith(notifyHour: hour, notifyMinute: minute),
    );
  }

  Future<void> updateEnabledTypes(Set<AlertType> types) async {
    final current = await settingsDao.getOrCreate();
    final csv = types.isEmpty ? 'none' : types.map((t) => t.name).join(',');
    await settingsDao.updateSettings(current.copyWith(enabledTypes: csv));
  }

  domain.AlertSettings _toDomain(dynamic db) {
    return domain.AlertSettings(
      masterEnabled: db.masterEnabled,
      notifyHour: db.notifyHour,
      notifyMinute: db.notifyMinute,
      enabledTypes: domain.AlertSettings.enabledTypesFromCsv(db.enabledTypes),
      horizonDays: db.horizonDays,
    );
  }
}
