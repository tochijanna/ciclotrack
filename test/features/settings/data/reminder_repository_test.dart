import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/settings/data/reminder_dao.dart';
import 'package:ciclotrack/features/settings/data/reminder_repository.dart';
import 'package:ciclotrack/features/settings/domain/reminder_validators.dart';

void main() {
  late AppDatabase db;
  late ReminderRepository repo;
  late int womanId;
  late int changes;

  const draft = ReminderDraft(
    message: 'Mejor evitar sexo',
    cycleDayStart: 5,
    cycleDayEnd: 7,
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    changes = 0;
    repo = ReminderRepository(
      ReminderDao(db),
      onChanged: () async => changes++,
    );
    womanId = await WomenRepository(
      WomenDao(db),
    ).create(const WomanDraft(name: 'María', initials: 'MR'));
  });

  tearDown(() async {
    await db.close();
  });

  test('create stores a trimmed reminder for the woman', () async {
    final id = await repo.create(
      womanId,
      const ReminderDraft(
        message: '  Mejor evitar sexo  ',
        cycleDayStart: 5,
        cycleDayEnd: 7,
      ),
    );

    final reminder = (await repo.watchByWoman(womanId).first).single;
    expect(reminder.id, id);
    expect(reminder.womanId, womanId);
    expect(reminder.message, 'Mejor evitar sexo');
    expect(reminder.cycleDayStart, 5);
    expect(reminder.cycleDayEnd, 7);
    expect(reminder.enabled, isTrue);
    expect(changes, 1);
  });

  test('create rejects an invalid draft without writing', () async {
    await expectLater(
      repo.create(
        womanId,
        const ReminderDraft(message: 'x', cycleDayStart: 7, cycleDayEnd: 5),
      ),
      throwsArgumentError,
    );

    expect(await repo.watchByWoman(womanId).first, isEmpty);
    expect(changes, 0);
  });

  test('update replaces message, days and state', () async {
    await repo.create(womanId, draft);
    final created = (await repo.watchByWoman(womanId).first).single;

    await repo.update(
      created,
      const ReminderDraft(
        message: 'Llevar flores',
        cycleDayStart: 20,
        cycleDayEnd: 20,
        enabled: false,
      ),
    );

    final updated = (await repo.watchByWoman(womanId).first).single;
    expect(updated.id, created.id);
    expect(updated.message, 'Llevar flores');
    expect(updated.cycleDayStart, 20);
    expect(updated.cycleDayEnd, 20);
    expect(updated.enabled, isFalse);
    expect(changes, 2);
  });

  test('setEnabled toggles the reminder and the active stream', () async {
    await repo.create(womanId, draft);
    final created = (await repo.watchByWoman(womanId).first).single;
    expect(await repo.watchActive().first, hasLength(1));

    await repo.setEnabled(created, false);

    expect(await repo.watchActive().first, isEmpty);
    expect((await repo.watchByWoman(womanId).first).single.enabled, isFalse);

    await repo.setEnabled(created, true);

    expect(await repo.watchActive().first, hasLength(1));
  });

  test('delete removes the reminder', () async {
    final id = await repo.create(womanId, draft);

    await repo.delete(id);

    expect(await repo.watchByWoman(womanId).first, isEmpty);
    expect(changes, 2);
  });

  test('watchByWoman only emits the reminders of that woman', () async {
    final otherId = await WomenRepository(
      WomenDao(db),
    ).create(const WomanDraft(name: 'Ana', initials: 'AN'));
    await repo.create(womanId, draft);
    await repo.create(otherId, draft);

    expect(await repo.watchByWoman(womanId).first, hasLength(1));
    expect(await repo.watchActive().first, hasLength(2));
  });

  test('streams emit again after each write', () async {
    final lengths = <int>[];
    final subscription = repo
        .watchByWoman(womanId)
        .listen((reminders) => lengths.add(reminders.length));
    await pumpEventQueue();

    final id = await repo.create(womanId, draft);
    await pumpEventQueue();
    await repo.delete(id);
    await pumpEventQueue();

    await subscription.cancel();
    expect(lengths, [0, 1, 0]);
  });

  test('a failing reschedule does not block the write', () async {
    final failing = ReminderRepository(
      ReminderDao(db),
      onChanged: () async => throw StateError('plugin no disponible'),
    );

    await failing.create(womanId, draft);

    expect(await failing.watchByWoman(womanId).first, hasLength(1));
  });
}
