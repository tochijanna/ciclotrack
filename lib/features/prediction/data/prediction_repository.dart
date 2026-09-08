import '../domain/prediction_calculator.dart';
import '../domain/woman_prediction.dart';
import 'prediction_dao.dart';

/// Repositorio reactivo que calcula la predicción para cada mujer.
class PredictionRepository {
  PredictionRepository(this._dao, {PredictionCalculator? calculator})
    : _calculator = calculator ?? PredictionCalculator();

  final PredictionDao _dao;
  final PredictionCalculator _calculator;

  /// Stream reactivo de la predicción de una mujer.
  /// Recalcula automáticamente ante cualquier cambio en periodos.
  Stream<WomanPrediction?> watchPrediction(int womanId) {
    return _dao.watchPeriodLogsByWoman(womanId).map((logs) {
      final inputs = logs
          .map(
            (l) => PeriodLogInput(startDate: l.startDate, endDate: l.endDate),
          )
          .toList();
      return _calculator.calculate(periodLogs: inputs);
    });
  }
}
