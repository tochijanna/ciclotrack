import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/settings/presentation/providers/reminder_providers.dart';
import 'package:ciclotrack/features/settings/presentation/screens/reminder_form_screen.dart';
import 'package:ciclotrack/features/settings/presentation/screens/reminders_screen.dart';
import 'package:ciclotrack/features/tracking/presentation/screens/tracking_screen.dart';

import '../../../support/fake_reminder_notifier.dart';
import '../../../support/widget_harness.dart';

void main() {
  late AppDatabase db;
  late FakeReminderNotifier notifier;

  List<Override> overrides({bool permissionGranted = true}) {
    notifier = FakeReminderNotifier(permissionGranted: permissionGranted);
    return [
      reminderNotifierProvider.overrideWithValue(notifier),
      fixedClock(DateTime(2026, 9, 2, 12)),
    ];
  }

  Future<List<Reminder>> readReminders(WidgetTester tester) =>
      runReal(tester, () => db.select(db.reminders).get());

  /// Pulsa y deja terminar la escritura y la reprogramación en drift, y
  /// después la transición de la ruta que se abre o se cierra.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 4; i++) {
      await settleProviders(tester);
    }
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('shows the empty state in Spanish', (tester) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');

    await pumpScreen(
      tester,
      db,
      RemindersScreen(womanId: womanId, womanName: 'María'),
      overrides: overrides(),
    );

    expect(find.text('Recordatorios de María'), findsOneWidget);
    expect(find.text('Sin recordatorios'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('lists message, cycle days and state of each reminder', (
    tester,
  ) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    final otherId = await seedWoman(tester, db, name: 'Ana');
    await seedReminder(
      tester,
      db,
      womanId: womanId,
      message: 'Mejor evitar sexo',
      cycleDayStart: 5,
      cycleDayEnd: 7,
    );
    await seedReminder(
      tester,
      db,
      womanId: womanId,
      message: 'Llevar flores',
      cycleDayStart: 20,
      enabled: false,
    );
    await seedReminder(tester, db, womanId: otherId, message: 'De Ana');

    await pumpScreen(
      tester,
      db,
      RemindersScreen(womanId: womanId, womanName: 'María'),
      overrides: overrides(),
    );

    expect(find.text('Mejor evitar sexo'), findsOneWidget);
    expect(find.text('Días 5-7 del ciclo'), findsOneWidget);
    expect(find.text('Llevar flores'), findsOneWidget);
    expect(find.text('Día 20 del ciclo · Desactivado'), findsOneWidget);
    expect(find.text('De Ana'), findsNothing);

    await closeTestDatabase(tester, db);
  });

  testWidgets('form validates message and cycle days inline', (tester) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(
      tester,
      db,
      ReminderFormScreen(womanId: womanId),
      overrides: overrides(),
    );

    await tester.tap(find.text('Crear recordatorio'));
    await tester.pump();

    expect(find.text('Escribe un mensaje'), findsOneWidget);
    expect(find.text('Introduce un día del ciclo'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('reminder_message')), 'Aviso');
    await tester.enterText(find.byKey(const Key('reminder_day_start')), '0');
    await tester.pump();
    expect(find.text('El día inicial debe ser 1 o mayor'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('reminder_day_start')), '7');
    await tester.enterText(find.byKey(const Key('reminder_day_end')), '5');
    await tester.pump();
    expect(
      find.text('El día final no puede ser anterior al inicial'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('reminder_day_end')), '61');
    await tester.pump();
    expect(find.text('El día final no puede superar 60'), findsOneWidget);

    await tester.tap(find.text('Crear recordatorio'));
    await tester.pump();
    expect(await readReminders(tester), isEmpty);

    await closeTestDatabase(tester, db);
  });

  testWidgets('creates a reminder from the tracking screen and schedules it', (
    tester,
  ) async {
    db = createTestDatabase();
    final profile = await seedProfile(tester, db, name: 'María');
    await seedPeriod(
      tester,
      db,
      womanId: profile.woman.id,
      startDate: DateTime(2026, 9, 1),
    );
    await pumpScreen(
      tester,
      db,
      TrackingScreen(profile: profile),
      overrides: overrides(),
    );

    await tapAndSettle(tester, find.byTooltip('Recordatorios'));
    expect(find.text('Sin recordatorios'), findsOneWidget);

    await tapAndSettle(tester, find.text('Nuevo recordatorio'));
    await tester.enterText(
      find.byKey(const Key('reminder_message')),
      'Mejor evitar sexo',
    );
    await tester.enterText(find.byKey(const Key('reminder_day_start')), '5');
    await tester.enterText(find.byKey(const Key('reminder_day_end')), '7');
    await tapAndSettle(tester, find.text('Crear recordatorio'));

    final saved = (await readReminders(tester)).single;
    expect(saved.womanId, profile.woman.id);
    expect(saved.message, 'Mejor evitar sexo');
    expect(saved.cycleDayStart, 5);
    expect(saved.cycleDayEnd, 7);
    expect(saved.enabled, isTrue);

    expect(find.text('Mejor evitar sexo'), findsOneWidget);
    expect(find.text('Días 5-7 del ciclo'), findsOneWidget);

    expect(notifier.permissionRequests, 1);
    final item = notifier.scheduled.values.single;
    expect(item.id, 1000000 + saved.id);
    expect(item.when, DateTime(2026, 9, 5, 9));
    expect(item.body, 'Mejor evitar sexo (días 5-7 del ciclo)');

    await closeTestDatabase(tester, db);
  });

  testWidgets('a single-day reminder saves without a final day', (
    tester,
  ) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(
      tester,
      db,
      ReminderFormScreen(womanId: womanId),
      overrides: overrides(),
    );

    await tester.enterText(find.byKey(const Key('reminder_message')), 'Aviso');
    await tester.enterText(find.byKey(const Key('reminder_day_start')), '12');
    await tapAndSettle(tester, find.text('Crear recordatorio'));

    final saved = (await readReminders(tester)).single;
    expect(saved.cycleDayStart, 12);
    expect(saved.cycleDayEnd, 12);

    await closeTestDatabase(tester, db);
  });

  testWidgets('saves and warns when the notification permission is denied', (
    tester,
  ) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await pumpScreen(
      tester,
      db,
      RemindersScreen(womanId: womanId, womanName: 'María'),
      overrides: overrides(permissionGranted: false),
    );

    await tapAndSettle(tester, find.text('Nuevo recordatorio'));
    await tester.enterText(find.byKey(const Key('reminder_message')), 'Aviso');
    await tester.enterText(find.byKey(const Key('reminder_day_start')), '5');
    await tapAndSettle(tester, find.text('Crear recordatorio'));

    expect(await readReminders(tester), hasLength(1));
    expect(
      find.textContaining('sin permiso de notificaciones'),
      findsOneWidget,
    );

    await closeTestDatabase(tester, db);
  });

  testWidgets('edits an existing reminder', (tester) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await seedReminder(tester, db, womanId: womanId, message: 'Original');
    await pumpScreen(
      tester,
      db,
      RemindersScreen(womanId: womanId, womanName: 'María'),
      overrides: overrides(),
    );

    await tapAndSettle(tester, find.text('Original'));
    expect(find.text('Editar recordatorio'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('reminder_message')),
      'Corregido',
    );
    await tester.enterText(find.byKey(const Key('reminder_day_end')), '9');
    await tapAndSettle(tester, find.text('Guardar cambios'));

    final saved = (await readReminders(tester)).single;
    expect(saved.message, 'Corregido');
    expect(saved.cycleDayStart, 5);
    expect(saved.cycleDayEnd, 9);
    expect(find.text('Días 5-9 del ciclo'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('toggles a reminder off and cancels its notification', (
    tester,
  ) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await seedPeriod(
      tester,
      db,
      womanId: womanId,
      startDate: DateTime(2026, 9, 1),
    );
    final id = await seedReminder(tester, db, womanId: womanId);
    await pumpScreen(
      tester,
      db,
      RemindersScreen(womanId: womanId, womanName: 'María'),
      overrides: overrides(),
    );

    await tapAndSettle(tester, find.byType(Switch));
    expect((await readReminders(tester)).single.enabled, isFalse);
    expect(find.text('Día 5 del ciclo · Desactivado'), findsOneWidget);
    expect(notifier.scheduled, isEmpty);

    await tapAndSettle(tester, find.byType(Switch));
    expect((await readReminders(tester)).single.enabled, isTrue);
    expect(notifier.scheduled.keys, [1000000 + id]);

    await closeTestDatabase(tester, db);
  });

  testWidgets('deletes a reminder after confirmation', (tester) async {
    db = createTestDatabase();
    final womanId = await seedWoman(tester, db, name: 'María');
    await seedReminder(tester, db, womanId: womanId, message: 'Borrar');
    await pumpScreen(
      tester,
      db,
      RemindersScreen(womanId: womanId, womanName: 'María'),
      overrides: overrides(),
    );

    await tapAndSettle(tester, find.byTooltip('Eliminar'));
    expect(find.text('Eliminar recordatorio'), findsOneWidget);
    await tapAndSettle(tester, find.widgetWithText(TextButton, 'Cancelar'));
    expect(await readReminders(tester), hasLength(1));

    await tapAndSettle(tester, find.byTooltip('Eliminar'));
    await tapAndSettle(tester, find.widgetWithText(TextButton, 'Eliminar'));

    expect(await readReminders(tester), isEmpty);
    expect(find.text('Sin recordatorios'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });
}
