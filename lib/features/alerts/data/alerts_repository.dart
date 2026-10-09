import 'package:ciclotrack/l10n/app_localizations.dart';

import '../../../core/privacy/discreet_notices.dart';
import '../../encounters/data/encounter_repository.dart';
import '../../medications/data/medication_dao.dart';
import '../../prediction/data/prediction_repository.dart';
import '../../profiles/data/women_repository.dart';
import '../domain/alert_item.dart';
import '../domain/alert_rule_engine.dart';
import '../domain/alert_settings.dart' as domain;
import '../domain/alert_types.dart';
import '../domain/medication_alert_input.dart';
import 'alert_settings_dao.dart';
import 'alert_text.dart';
import 'notification_scheduler.dart';

/// Repositorio que orquesta la evaluación y programación de alertas.
class AlertsRepository {
  AlertsRepository({
    required this.scheduler,
    required this.settingsDao,
    required this.predictionRepo,
    required this.encounterRepo,
    required this.womenRepo,
    required this.medicationDao,
    required this.l10n,
    this.engine = const AlertRuleEngine(),
    this.discreet = readDiscreetNotices,
  });

  final NotificationScheduler scheduler;
  final AlertSettingsDao settingsDao;
  final PredictionRepository predictionRepo;
  final EncounterRepository encounterRepo;
  final WomenRepository womenRepo;
  final MedicationDao medicationDao;
  final AppLocalizations l10n;
  final AlertRuleEngine engine;

  /// Si los avisos se programan con texto genérico (PRIV-04).
  final Future<bool> Function() discreet;

  /// Recalcula y reprograma todas las alertas.
  Future<void> refreshAlerts({DateTime? today}) async {
    final now = today ?? DateTime.now();

    // Cargar ajustes.
    final dbSettings = await settingsDao.getOrCreate();
    final settings = _toDomain(dbSettings);

    if (!settings.masterEnabled) {
      final ids = (await scheduler.pending())
          .map((item) => item.id)
          .where(isAlertNotificationId)
          .toList();
      await scheduler.cancel(ids);
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
            initials: profile.woman.initials,
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
      medications: await _medications(),
      settings: settings,
    );

    // Programar primero; así un fallo no deja al usuario sin las anteriores.
    final oldIds = (await scheduler.pending())
        .map((item) => item.id)
        .where(isAlertNotificationId)
        .toSet();
    final newIds = items.map((item) => item.id).toSet();
    final generic = await discreet();
    for (final item in items) {
      await scheduler.schedule(
        item,
        generic ? discreetNoticeTitle : alertTypeLabel(l10n, item.type),
        generic ? l10n.discreetNoticeBody : alertBody(l10n, item.message),
      );
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
            initials: profile.woman.initials,
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
      medications: await _medications(),
      settings: settings,
    );
  }

  Future<List<MedicationAlertInput>> _medications() async =>
      (await medicationDao.watchAll().first)
          .map(
            (m) => MedicationAlertInput(
              id: m.id,
              womanId: m.womanId,
              name: m.name,
              hour: m.hour,
              minute: m.minute,
              enabled: m.enabled,
            ),
          )
          .toList();

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
