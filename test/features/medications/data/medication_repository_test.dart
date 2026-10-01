import 'dart:async';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/medications/data/medication_dao.dart';
import 'package:ciclotrack/features/medications/data/medication_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MedicationRepository repo;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MedicationRepository(MedicationDao(db));
    for (final name in ['Ana', 'Bea']) {
      await db
          .into(db.women)
          .insert(
            WomenCompanion.insert(
              name: name,
              initials: name[0],
              createdAt: DateTime(2026, 9, 1),
            ),
          );
    }
  });
  tearDown(() => db.close());
  Future<int> create(int womanId) => repo.save(
    womanId: womanId,
    name: 'Hierro',
    dose: '20 mg',
    hour: 23,
    minute: 59,
    enabled: true,
  );

  test('alta, edición, activación, filtro por mujer y borrado', () async {
    final id = await create(1);
    await create(2);
    var medication = (await repo.watchByWoman(1).first).single;
    expect(medication.name, 'Hierro');
    await repo.save(
      id: id,
      womanId: 1,
      name: 'Vitamina',
      dose: '',
      hour: 8,
      minute: 15,
      enabled: false,
    );
    medication = (await repo.watchByWoman(1).first).single;
    expect(medication.name, 'Vitamina');
    expect(medication.hour, 8);
    expect(await repo.watchEnabledByWoman(1).first, isEmpty);
    await repo.setEnabled(medication, true);
    expect(await repo.watchEnabledByWoman(1).first, hasLength(1));
    await repo.delete(id);
    expect(await repo.watchByWoman(1).first, isEmpty);
    expect(await repo.watchAll().first, hasLength(1));
  });

  test('watchByWoman emite al insertar y borrar', () async {
    final initial = Completer<void>();
    final inserted = Completer<void>();
    final deleted = Completer<void>();
    var sawInsert = false;
    final sub = repo.watchByWoman(1).listen((rows) {
      if (!initial.isCompleted) initial.complete();
      if (rows.isNotEmpty) {
        sawInsert = true;
        if (!inserted.isCompleted) inserted.complete();
      } else if (sawInsert && !deleted.isCompleted) {
        deleted.complete();
      }
    });
    try {
      await initial.future;
      final id = await create(1);
      await inserted.future;
      await repo.delete(id);
      await deleted.future;
    } finally {
      await sub.cancel();
    }
  });

  test('rechaza datos inválidos y borra en cascada con el perfil', () async {
    await expectLater(
      repo.save(
        womanId: 1,
        name: '',
        dose: '',
        hour: 24,
        minute: 60,
        enabled: true,
      ),
      throwsArgumentError,
    );
    await create(1);
    await (db.delete(db.women)..where((w) => w.id.equals(1))).go();
    expect(await repo.watchAll().first, isEmpty);
  });
}
