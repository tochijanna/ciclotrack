import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/features/profiles/data/women_dao.dart';
import 'package:ciclotrack/features/profiles/data/women_repository.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/prediction/data/prediction_dao.dart';
import 'package:ciclotrack/features/prediction/data/prediction_repository.dart';
import 'package:ciclotrack/features/prediction/domain/woman_prediction.dart';
import 'package:ciclotrack/features/tracking/data/tracking_dao.dart';
import 'package:ciclotrack/features/tracking/data/tracking_repository.dart';
import 'package:ciclotrack/features/tracking/domain/tracking_drafts.dart';

void main() {
  late AppDatabase db;
  late PredictionRepository predRepo;
  late TrackingRepository trackRepo;
  late int womanId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    predRepo = PredictionRepository(PredictionDao(db));
    trackRepo = TrackingRepository(TrackingDao(db));

    final womenRepo = WomenRepository(WomenDao(db));
    womanId = await womenRepo.create(
      const WomanDraft(name: 'María', initials: 'MR'),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('PredictionRepository', () {
    test('emits sinDatos when no periods exist', () async {
      final pred = await predRepo.watchPrediction(womanId).first;
      expect(pred, isNotNull);
      expect(pred!.estadoRiesgo, EstadoRiesgo.sinDatos);
    });

    test('emits prediction after period is inserted', () async {
      await trackRepo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );

      final pred = await predRepo.watchPrediction(womanId).first;
      expect(pred, isNotNull);
      expect(pred!.estadoRiesgo, isNot(EstadoRiesgo.sinDatos));
      expect(pred.usaEstimacionPorDefecto, isTrue);
    });

    test('updates prediction when new period is added', () async {
      await trackRepo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 8, 1)),
      );
      final pred1 = await predRepo.watchPrediction(womanId).first;
      expect(pred1!.usaEstimacionPorDefecto, isTrue);

      await trackRepo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 8, 29)),
      );
      final pred2 = await predRepo.watchPrediction(womanId).first;
      expect(pred2!.usaEstimacionPorDefecto, isFalse);
      expect(pred2.ciclosReales, 1);
    });

    test('predictions are isolated per woman', () async {
      final womenRepo = WomenRepository(WomenDao(db));
      final otherId = await womenRepo.create(
        const WomanDraft(name: 'Ana', initials: 'AN'),
      );

      await trackRepo.createPeriod(
        womanId,
        PeriodDraft(startDate: DateTime(2026, 9, 1)),
      );

      final predMaria = await predRepo.watchPrediction(womanId).first;
      final predAna = await predRepo.watchPrediction(otherId).first;

      expect(predMaria!.estadoRiesgo, isNot(EstadoRiesgo.sinDatos));
      expect(predAna!.estadoRiesgo, EstadoRiesgo.sinDatos);
    });
  });
}
