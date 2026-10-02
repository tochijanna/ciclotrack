import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';

import 'backup_document.dart';

/// ZIP con un `<tabla>.csv` por tabla más `manifest.json`
/// (`{"app","schemaVersion","exportedAt"}`).
///
/// Nunca se escriben ficheros sueltos en disco: el ZIP viaja en memoria hasta
/// que el usuario elige el destino.
List<int> buildCsvBundle(BackupDocument doc) {
  final archive = Archive();
  for (final table in backupTables) {
    _addText(archive, '$table.csv', buildTableCsv(table, doc.jsonRows(table)));
  }
  _addText(archive, 'manifest.json', _manifest(doc));

  return ZipEncoder().encode(archive);
}

/// Añade texto como UTF-8 con el tamaño en **bytes**: `ArchiveFile.bytes`
/// usa los bytes reales, no la longitud en caracteres.
void _addText(Archive archive, String name, String content) {
  final bytes = Uint8List.fromList(utf8.encode(content));
  archive.addFile(ArchiveFile.bytes(name, bytes));
}

/// CSV de una tabla: BOM UTF-8 + encabezado + filas, RFC-4180 vía
/// `Csv`. Los valores nulos van vacíos.
String buildTableCsv(String table, List<Map<String, Object?>> rows) {
  final columns = backupColumns[table] ?? const <String>[];
  final data = <List<Object?>>[
    columns,
    for (final row in rows) [for (final column in columns) _cell(row[column])],
  ];
  // El BOM hace que Excel respete los acentos; el resto es UTF-8.
  return '\uFEFF${Csv().encode(data)}';
}

String _manifest(BackupDocument doc) =>
    const JsonEncoder.withIndent('  ').convert({
      'app': backupAppId,
      'schemaVersion': doc.schemaVersion,
      'exportedAt': doc.exportedAt.toIso8601String(),
    });

/// Celda CSV: los nulos van vacíos (`Csv` escribiría `null`).
String _cell(Object? value) => value?.toString() ?? '';
