import 'package:ciclotrack/features/settings/data/reminder_notifier.dart';

/// Notificación de recordatorio registrada por [FakeReminderNotifier].
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime when;
  final String title;
  final String body;
}

/// Notificador en memoria: guarda lo programado sin tocar el plugin real.
class FakeReminderNotifier implements ReminderNotifier {
  FakeReminderNotifier({this.permissionGranted = true});

  final bool permissionGranted;
  int initializeCalls = 0;
  int permissionRequests = 0;
  final scheduled = <int, ScheduledReminder>{};
  final cancelledIds = <int>[];

  @override
  Future<void> initialize() async => initializeCalls++;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    scheduled[id] = ScheduledReminder(
      id: id,
      when: when,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> cancel(List<int> ids) async {
    cancelledIds.addAll(ids);
    ids.forEach(scheduled.remove);
  }

  @override
  Future<List<int>> pendingIds() async => scheduled.keys.toList();
}
