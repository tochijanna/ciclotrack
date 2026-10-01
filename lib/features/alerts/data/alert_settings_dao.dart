import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/tables.dart';

part 'alert_settings_dao.g.dart';

@DriftAccessor(tables: [AlertSettings])
class AlertSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AlertSettingsDaoMixin {
  AlertSettingsDao(super.db);

  /// Obtiene la fila singleton (id=1), creándola si no existe.
  Future<AlertSetting> getOrCreate() => transaction(() async {
    final existing = await (select(
      alertSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (existing != null) return existing;
    await into(
      alertSettings,
    ).insert(const AlertSettingsCompanion(id: Value(1)));
    return await (select(
      alertSettings,
    )..where((t) => t.id.equals(1))).getSingle();
  });

  /// Stream reactivo de los ajustes.
  Stream<AlertSetting?> watchSettings() {
    return (select(alertSettings)..where((t) => t.id.equals(1))).watch().map(
      (list) => list.isNotEmpty ? list.first : null,
    );
  }

  /// Asegura que la fila singleton existe.
  Future<void> ensureCreated() async {
    await getOrCreate();
  }

  /// Actualiza los ajustes (fila singleton).
  Future<void> updateSettings(AlertSetting entry) =>
      (update(alertSettings)..where((t) => t.id.equals(1))).write(entry);
}
