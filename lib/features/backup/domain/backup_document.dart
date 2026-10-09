import 'dart:convert';

import '../../medications/domain/medication_validators.dart';
import '../../settings/domain/reminder_validators.dart';
import '../../tracking/domain/tracking_validators.dart';

/// Identificador que firma los documentos de copia de CicloTrack.
const backupAppId = 'ciclotrack';

/// Versión del schema que sabe leer y escribir esta copia (drift v4).
const backupSchemaVersion = 4;

/// Tamaño máximo aceptado al importar, en bytes. La medición de TOC-17 dio
/// ~930 kB de JSON por ~4 500 filas (pico de RSS +27 MB); 8 MB cubre con
/// holgura el peor caso realista (~2 MB para 5 perfiles × 10 años) acotando
/// el pico de memoria del decodificado a ~200 MB.
/// ponytail: tope fijo; se revisa si un uso real lo alcanza.
const backupMaxBytes = 8 * 1024 * 1024;

/// Tablas incluidas, en el orden del esquema. El volcado y la restauración
/// usan además [backupDeleteOrder] y [backupInsertOrder], marcados por las
/// claves foráneas.
const backupTables = <String>[
  'women',
  'tags',
  'woman_tags',
  'period_logs',
  'ovulation_logs',
  'symptoms',
  'encounters',
  'encounter_women',
  'reminders',
  'alert_settings',
  'medications',
];

/// Tipo lógico de cada columna dentro del documento de copia.
enum _ColumnKind {
  /// Entero JSON.
  entero,

  /// Cadena JSON.
  texto,

  /// Booleano JSON.
  booleano,

  /// Número JSON (se normaliza a `double`).
  real,

  /// Fecha natural `YYYY-MM-DD` (se lee como medianoche local).
  fecha,

  /// Instante ISO-8601 sin offset, interpretado en la zona local.
  instante,
}

/// Columna del documento: tipo lógico y si admite `null`.
class _Column {
  const _Column(this.kind, {this.nullable = false});

  final _ColumnKind kind;
  final bool nullable;
}

/// Esquema de la copia. El nombre JSON de cada columna es el nombre SQL de la
/// columna drift (snake_case), sin abreviaturas, y su orden es el del
/// encabezado CSV. Única fuente de verdad de [backupColumns].
const _schema = <String, Map<String, _Column>>{
  'women': {
    'id': _Column(_ColumnKind.entero),
    'name': _Column(_ColumnKind.texto),
    'initials': _Column(_ColumnKind.texto),
    'emoji': _Column(_ColumnKind.texto),
    'color': _Column(_ColumnKind.entero),
    'private_notes': _Column(_ColumnKind.texto),
    'sort_order': _Column(_ColumnKind.entero),
    'created_at': _Column(_ColumnKind.instante),
  },
  'tags': {
    'id': _Column(_ColumnKind.entero),
    'name': _Column(_ColumnKind.texto),
  },
  'woman_tags': {
    'id': _Column(_ColumnKind.entero),
    'woman_id': _Column(_ColumnKind.entero),
    'tag_id': _Column(_ColumnKind.entero),
  },
  'period_logs': {
    'id': _Column(_ColumnKind.entero),
    'woman_id': _Column(_ColumnKind.entero),
    'start_date': _Column(_ColumnKind.fecha),
    'end_date': _Column(_ColumnKind.fecha, nullable: true),
    'flow_level': _Column(_ColumnKind.entero, nullable: true),
    'notes': _Column(_ColumnKind.texto),
  },
  'ovulation_logs': {
    'id': _Column(_ColumnKind.entero),
    'woman_id': _Column(_ColumnKind.entero),
    'date': _Column(_ColumnKind.fecha),
    'temperature': _Column(_ColumnKind.real, nullable: true),
    'cervical_mucus': _Column(_ColumnKind.texto, nullable: true),
    'lh_test': _Column(_ColumnKind.booleano, nullable: true),
  },
  'symptoms': {
    'id': _Column(_ColumnKind.entero),
    'woman_id': _Column(_ColumnKind.entero),
    'date': _Column(_ColumnKind.fecha),
    'type': _Column(_ColumnKind.texto),
    'severity': _Column(_ColumnKind.entero),
    'notes': _Column(_ColumnKind.texto),
  },
  'encounters': {
    'id': _Column(_ColumnKind.entero),
    'date_time': _Column(_ColumnKind.instante),
    'protection': _Column(_ColumnKind.texto),
    'outcome': _Column(_ColumnKind.texto, nullable: true),
    'notes': _Column(_ColumnKind.texto),
  },
  'encounter_women': {
    'id': _Column(_ColumnKind.entero),
    'encounter_id': _Column(_ColumnKind.entero),
    'woman_id': _Column(_ColumnKind.entero),
    'relationship_type': _Column(_ColumnKind.texto),
  },
  'reminders': {
    'id': _Column(_ColumnKind.entero),
    'woman_id': _Column(_ColumnKind.entero),
    'cycle_day_start': _Column(_ColumnKind.entero),
    'cycle_day_end': _Column(_ColumnKind.entero),
    'message': _Column(_ColumnKind.texto),
    'enabled': _Column(_ColumnKind.booleano),
  },
  'medications': {
    'id': _Column(_ColumnKind.entero),
    'woman_id': _Column(_ColumnKind.entero),
    'name': _Column(_ColumnKind.texto),
    'dose': _Column(_ColumnKind.texto),
    'hour': _Column(_ColumnKind.entero),
    'minute': _Column(_ColumnKind.entero),
    'enabled': _Column(_ColumnKind.booleano),
  },
  'alert_settings': {
    'id': _Column(_ColumnKind.entero),
    'master_enabled': _Column(_ColumnKind.booleano),
    'notify_hour': _Column(_ColumnKind.entero),
    'notify_minute': _Column(_ColumnKind.entero),
    'enabled_types': _Column(_ColumnKind.texto),
    'horizon_days': _Column(_ColumnKind.entero),
  },
};

/// Columnas por tabla, en el orden del encabezado CSV.
final Map<String, List<String>> backupColumns = {
  for (final entry in _schema.entries) entry.key: entry.value.keys.toList(),
};

/// Motivos de rechazo de una copia, independientes del idioma.
enum BackupFormatError {
  invalidJson,
  tooLarge,
  notCicloTrack,
  unsupportedVersion,
  invalidExportDate,
  noTables,
  missingTable,
  invalidRow,
  invalidValue,
  periodOverlap,
}

/// Error de formato de una copia. El mensaje visible se localiza en la
/// capa de presentación a partir de [error] y, cuando aplica, [detail].
class BackupFormatException implements Exception {
  const BackupFormatException(this.error, [this.detail]);

  final BackupFormatError error;
  final String? detail;

  @override
  String toString() => 'BackupFormatException($error, $detail)';
}

/// Copia completa de la base de datos en estructuras JSON-friendly.
class BackupDocument {
  BackupDocument({
    required this.exportedAt,
    required this.tables,
    this.schemaVersion = backupSchemaVersion,
  });

  final int schemaVersion;
  final DateTime exportedAt;

  /// Filas por tabla; cada fila usa los nombres de [backupColumns].
  final Map<String, List<Map<String, Object?>>> tables;

  /// Documento con las claves en el orden canónico. Las columnas de fecha se
  /// escriben como `YYYY-MM-DD` y las de instante como ISO-8601 local, de modo
  /// que [fromJson] reconstruye exactamente los mismos valores.
  Map<String, Object?> toJson() => {
    'app': backupAppId,
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'tables': {for (final table in backupTables) table: jsonRows(table)},
  };

  /// Filas de [table] con los valores ya normalizados a su forma JSON (las
  /// fechas como `YYYY-MM-DD` y los instantes como ISO-8601 local). Es la
  /// representación que consumen JSON y CSV.
  List<Map<String, Object?>> jsonRows(String table) => [
    for (final row in rows(table)) _encodeRow(table, row),
  ];

  /// Serializa la copia completa con sangrado de 2 espacios y sin escapar
  /// caracteres no ASCII (los emojis se conservan tal cual).
  List<int> toUtf8Bytes() =>
      utf8.encode(const JsonEncoder.withIndent('  ').convert(toJson()));

  /// Lee una copia desde bytes UTF-8, envolviendo cualquier error de
  /// `dart:convert` en [BackupFormatException].
  static BackupDocument fromBytes(List<int> bytes) {
    if (bytes.length > backupMaxBytes) {
      throw const BackupFormatException(BackupFormatError.tooLarge);
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const BackupFormatException(BackupFormatError.invalidJson);
    }
    if (decoded is! Map<String, Object?>) {
      throw const BackupFormatException(BackupFormatError.invalidJson);
    }
    return fromJson(decoded);
  }

  /// Valida y normaliza un documento. Lanza [BackupFormatException] con el
  /// motivo exacto del rechazo.
  static BackupDocument fromJson(Map<String, Object?> json) {
    if (json['app'] != backupAppId) {
      throw const BackupFormatException(BackupFormatError.notCicloTrack);
    }

    final version = json['schemaVersion'];
    if (version is! int || (version < 3 || version > backupSchemaVersion)) {
      throw BackupFormatException(
        BackupFormatError.unsupportedVersion,
        '$version',
      );
    }

    final exported = json['exportedAt'];
    final exportedAt = exported is String ? DateTime.tryParse(exported) : null;
    if (exportedAt == null) {
      throw const BackupFormatException(BackupFormatError.invalidExportDate);
    }

    final rawTables = json['tables'];
    if (rawTables is! Map) {
      throw const BackupFormatException(BackupFormatError.noTables);
    }

    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in backupTables) {
      if (version == 3 &&
          table == 'medications' &&
          !rawTables.containsKey(table)) {
        tables[table] = [];
        continue;
      }
      if (!rawTables.containsKey(table)) {
        throw BackupFormatException(BackupFormatError.missingTable, table);
      }
      final rawRows = rawTables[table];
      if (rawRows is! List) {
        throw BackupFormatException(BackupFormatError.invalidRow, table);
      }
      tables[table] = [for (final rawRow in rawRows) _parseRow(table, rawRow)];
    }

    _validateInvariants(tables);

    return BackupDocument(
      exportedAt: exportedAt,
      tables: tables,
      schemaVersion: version,
    );
  }

  /// Coherencia de negocio sobre las filas ya normalizadas: la validez
  /// estructural no garantiza que los registros restaurados sean válidos.
  /// Reutiliza los validadores de cada funcionalidad para no duplicar los
  /// rangos que la propia aplicación admite; cualquier incumplimiento
  /// rechaza la copia con [BackupFormatError.invalidValue] y detalle
  /// `tabla.columna` (nombres técnicos, nunca datos del usuario).
  static void _validateInvariants(
    Map<String, List<Map<String, Object?>>> tables,
  ) {
    for (final row in tables['period_logs'] ?? const []) {
      final start = calendarDate(row['start_date']! as DateTime);
      final end = row['end_date'] == null
          ? start
          : calendarDate(row['end_date']! as DateTime);
      if (!isValidDateRange(start, end)) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'period_logs.end_date',
        );
      }
      if (!isValidFlowLevel(row['flow_level'] as int?)) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'period_logs.flow_level',
        );
      }
    }
    _rejectPeriodOverlap(tables['period_logs'] ?? const []);

    for (final row in tables['ovulation_logs'] ?? const []) {
      if (!isValidTemperature(row['temperature'] as double?)) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'ovulation_logs.temperature',
        );
      }
    }

    for (final row in tables['symptoms'] ?? const []) {
      if (!isValidSeverity(row['severity']! as int)) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'symptoms.severity',
        );
      }
    }

    for (final row in tables['medications'] ?? const []) {
      if (validateMedicationHour(row['hour']! as int) != null) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'medications.hour',
        );
      }
      if (validateMedicationMinute(row['minute']! as int) != null) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'medications.minute',
        );
      }
    }

    for (final row in tables['reminders'] ?? const []) {
      final start = row['cycle_day_start']! as int;
      if (validateCycleDayStart(start) != null) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'reminders.cycle_day_start',
        );
      }
      if (validateCycleDayEnd(start, row['cycle_day_end']! as int) != null) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'reminders.cycle_day_end',
        );
      }
    }

    for (final row in tables['alert_settings'] ?? const []) {
      final hour = row['notify_hour']! as int;
      final minute = row['notify_minute']! as int;
      if (hour < 0 || hour > 23) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'alert_settings.notify_hour',
        );
      }
      if (minute < 0 || minute > 59) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'alert_settings.notify_minute',
        );
      }
      if ((row['horizon_days']! as int) < 1) {
        throw const BackupFormatException(
          BackupFormatError.invalidValue,
          'alert_settings.horizon_days',
        );
      }
    }
  }

  /// Dos periodos del mismo perfil no pueden compartir un día: misma
  /// semántica inclusiva que `_ensurePeriodDoesNotOverlap`, con
  /// `end_date` nulo equivalente al día de inicio.
  static void _rejectPeriodOverlap(List<Map<String, Object?>> rows) {
    final porMujer = <int, List<Map<String, Object?>>>{};
    for (final row in rows) {
      porMujer.putIfAbsent(row['woman_id']! as int, () => []).add(row);
    }
    for (final periodos in porMujer.values) {
      periodos.sort(
        (a, b) => (a['start_date']! as DateTime).compareTo(
          b['start_date']! as DateTime,
        ),
      );
      for (var i = 1; i < periodos.length; i++) {
        final anterior = periodos[i - 1];
        final finAnterior = calendarDate(
          anterior['end_date'] as DateTime? ??
              anterior['start_date']! as DateTime,
        );
        final inicio = calendarDate(periodos[i]['start_date']! as DateTime);
        if (!inicio.isAfter(finAnterior)) {
          throw const BackupFormatException(
            BackupFormatError.periodOverlap,
            'period_logs',
          );
        }
      }
    }
  }

  /// Filas de [table]; lista vacía si la tabla no está en el documento.
  List<Map<String, Object?>> rows(String table) => tables[table] ?? const [];

  /// Número de filas por tabla, en el orden de [backupTables].
  Map<String, int> get counts => {
    for (final table in backupTables) table: rows(table).length,
  };

  static Map<String, Object?> _encodeRow(
    String table,
    Map<String, Object?> row,
  ) {
    final schema = _schema[table]!;
    return {
      for (final column in backupColumns[table]!)
        column: _encodeValue(table, column, schema[column]!, row[column]),
    };
  }

  /// Convierte los valores en memoria a su forma JSON. Los tipos simples pasan
  /// tal cual; [fromJson] los valida al leerlos.
  static Object? _encodeValue(
    String table,
    String column,
    _Column spec,
    Object? value,
  ) {
    if (value == null) {
      if (spec.nullable) return null;
      throw BackupFormatException(
        BackupFormatError.invalidValue,
        '$table.$column',
      );
    }

    switch (spec.kind) {
      case _ColumnKind.entero:
      case _ColumnKind.texto:
      case _ColumnKind.booleano:
      case _ColumnKind.real:
        return value;
      case _ColumnKind.fecha:
        if (value is! DateTime) break;
        return formatBackupDate(value);
      case _ColumnKind.instante:
        if (value is! DateTime) break;
        return value.toIso8601String();
    }

    throw BackupFormatException(
      BackupFormatError.invalidValue,
      '$table.$column',
    );
  }

  static Map<String, Object?> _parseRow(String table, Object? raw) {
    if (raw is! Map) {
      throw BackupFormatException(BackupFormatError.invalidRow, table);
    }
    final columns = backupColumns[table]!;
    if (raw.length != columns.length || !columns.every(raw.containsKey)) {
      throw BackupFormatException(BackupFormatError.invalidRow, table);
    }
    final schema = _schema[table]!;
    return {
      for (final column in columns)
        column: _parseValue(table, column, schema[column]!, raw[column]),
    };
  }

  static Object? _parseValue(
    String table,
    String column,
    _Column spec,
    Object? raw,
  ) {
    if (raw == null) {
      if (spec.nullable) return null;
      throw BackupFormatException(
        BackupFormatError.invalidValue,
        '$table.$column',
      );
    }

    switch (spec.kind) {
      case _ColumnKind.entero:
        if (raw is! int) break;
        return raw;
      case _ColumnKind.texto:
        if (raw is! String) break;
        return raw;
      case _ColumnKind.booleano:
        if (raw is! bool) break;
        return raw;
      case _ColumnKind.real:
        if (raw is! num) break;
        return raw.toDouble();
      case _ColumnKind.fecha:
        if (raw is! String) break;
        final date = parseBackupDate(raw);
        if (date == null) break;
        return date;
      case _ColumnKind.instante:
        if (raw is! String) break;
        final instant = DateTime.tryParse(raw);
        if (instant == null) break;
        return instant;
    }

    throw BackupFormatException(
      BackupFormatError.invalidValue,
      '$table.$column',
    );
  }
}

/// Marca temporal para nombres de fichero: `20260930-211500`.
String backupStamp(DateTime now) =>
    '${_pad(now.year, 4)}${_pad(now.month, 2)}${_pad(now.day, 2)}'
    '-${_pad(now.hour, 2)}${_pad(now.minute, 2)}${_pad(now.second, 2)}';

/// Fecha natural local como `YYYY-MM-DD`.
String formatBackupDate(DateTime day) =>
    '${_pad(day.year, 4)}-${_pad(day.month, 2)}-${_pad(day.day, 2)}';

/// Día natural local de un `YYYY-MM-DD`, o `null` si no encaja.
DateTime? parseBackupDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime(year, month, day);
  if (date.month != month || date.day != day) return null;
  return date;
}

String _pad(int value, int width) => value.toString().padLeft(width, '0');
