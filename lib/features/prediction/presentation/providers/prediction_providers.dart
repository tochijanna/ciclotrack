import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database_provider.dart';
import '../../data/prediction_dao.dart';
import '../../data/prediction_repository.dart';
import '../../domain/prediction_calculator.dart';
import '../../domain/prediction_engine.dart';
import '../../domain/woman_prediction.dart';
import 'prediction_day_provider.dart';

// --- Providers base ---

final predictionEngineProvider = Provider<PredictionEngine>((ref) {
  return PredictionEngine();
});

final predictionDaoProvider = Provider<PredictionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PredictionDao(db);
});

final predictionCalculatorProvider = Provider<PredictionCalculator>((ref) {
  final engine = ref.watch(predictionEngineProvider);
  return PredictionCalculator(engine: engine);
});

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  final dao = ref.watch(predictionDaoProvider);
  final calculator = ref.watch(predictionCalculatorProvider);
  return PredictionRepository(dao, calculator: calculator);
});

// --- Predicción por mujer ---

final womanPredictionProvider = StreamProvider.autoDispose
    .family<WomanPrediction?, int>((ref, womanId) {
      final repo = ref.watch(predictionRepositoryProvider);
      final day = ref.watch(predictionDayProvider);
      return repo.watchPrediction(womanId, today: day);
    });
