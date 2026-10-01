/// Base del rango de ids de notificación reservado a los recordatorios
/// (ids >= 1000000). Las alertas usan ids por debajo de este valor.
const int reminderNotificationIdBase = 1000000;

/// Interfaz abstracta para notificar recordatorios personalizados.
/// Permite usar un notificador falso en tests.
abstract class ReminderNotifier {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  });
  Future<void> cancel(List<int> ids);

  /// Ids de las notificaciones de recordatorio pendientes (no de las alertas).
  Future<List<int>> pendingIds();
}
