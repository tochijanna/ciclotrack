import '../domain/alert_item.dart';

/// Interfaz abstracta para programar notificaciones locales.
/// Permite usar un FakeScheduler en tests.
abstract class NotificationScheduler {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<bool> canScheduleExact();
  Future<void> schedule(AlertItem item);
  Future<void> cancel(List<int> ids);
  Future<void> cancelAll();
  Future<List<PendingNotification>> pending();
}

/// Representación de una notificación pendiente.
class PendingNotification {
  const PendingNotification({
    required this.id,
    required this.title,
    required this.body,
  });

  final int id;
  final String title;
  final String body;
}
