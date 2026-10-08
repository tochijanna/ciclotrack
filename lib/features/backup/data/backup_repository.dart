import 'dart:typed_data';

import 'package:ciclotrack/l10n/app_localizations.dart';

import '../../../core/db/app_database.dart';
import '../../reports/domain/report_models.dart';
import '../domain/backup_document.dart';
import '../domain/csv_export.dart';
import 'backup_file_gateway.dart';
import 'backup_serializer.dart';
import 'pdf_report.dart';

/// Resumen de una importación: filas restauradas por tabla.
class ImportSummary {
  const ImportSummary({required this.counts});

  final Map<String, int> counts;
}

/// Copias de seguridad de la base local.
///
/// Todo el trabajo ocurre en memoria: el repositorio devuelve los bytes y el
/// gateway decide dónde escribirlos o de dónde leerlos.
class BackupRepository {
  const BackupRepository(this._db, this._l10n);

  final AppDatabase _db;
  final AppLocalizations _l10n;

  /// Documento completo de la base actual.
  Future<BackupDocument> dump({required DateTime now}) =>
      dumpDatabase(_db, now: now);

  Future<BackupFile> exportJson({required DateTime now}) async {
    final doc = await dump(now: now);
    return BackupFile(
      name: 'ciclotrack-backup-${backupStamp(now)}.json',
      bytes: Uint8List.fromList(doc.toUtf8Bytes()),
    );
  }

  Future<BackupFile> exportCsv({required DateTime now}) async {
    final doc = await dump(now: now);
    return BackupFile(
      name: 'ciclotrack-csv-${backupStamp(now)}.zip',
      bytes: Uint8List.fromList(buildCsvBundle(doc)),
    );
  }

  Future<BackupFile> exportPdf({
    required ReportsBoard board,
    required DateTime now,
  }) async {
    final doc = await dump(now: now);
    final bytes = await renderPdf(
      buildPdfBlocks(doc, board, l10n: _l10n),
      generadoEn: now,
      l10n: _l10n,
    );
    return BackupFile(
      name: 'ciclotrack-informe-${backupStamp(now)}.pdf',
      bytes: bytes,
    );
  }

  /// Solo JSON: es el único formato completo y sin pérdidas; CSV y PDF son de
  /// solo lectura humana. Sustituye todos los datos actuales y devuelve el
  /// resumen de lo restaurado.
  Future<ImportSummary> importJson(BackupDocument doc) async {
    await restoreDatabase(_db, doc);
    return ImportSummary(counts: doc.counts);
  }
}
