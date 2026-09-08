import 'alert_types.dart';

/// Ajustes de alertas (modelo de dominio, independiente de Drift).
class AlertSettings {
  const AlertSettings({
    this.masterEnabled = true,
    this.notifyHour = 9,
    this.notifyMinute = 0,
    this.enabledTypes = const {},
    this.horizonDays = 7,
  });

  final bool masterEnabled;
  final int notifyHour;
  final int notifyMinute;
  final Set<AlertType> enabledTypes;
  final int horizonDays;

  bool isEnabled(AlertType type) =>
      masterEnabled && enabledTypes.contains(type);

  AlertSettings copyWith({
    bool? masterEnabled,
    int? notifyHour,
    int? notifyMinute,
    Set<AlertType>? enabledTypes,
    int? horizonDays,
  }) {
    return AlertSettings(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      notifyHour: notifyHour ?? this.notifyHour,
      notifyMinute: notifyMinute ?? this.notifyMinute,
      enabledTypes: enabledTypes ?? this.enabledTypes,
      horizonDays: horizonDays ?? this.horizonDays,
    );
  }

  /// Serializa enabledTypes a CSV para persistencia.
  String enabledTypesToCsv() => enabledTypes.map((t) => t.name).join(',');

  /// Deserializa CSV a Set de AlertType.
  static Set<AlertType> enabledTypesFromCsv(String csv) {
    if (csv.trim().isEmpty) return {};
    return csv
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map(
          (s) => AlertType.values.firstWhere(
            (t) => t.name == s,
            orElse: () => AlertType.fertilidadInminente,
          ),
        )
        .toSet();
  }
}
