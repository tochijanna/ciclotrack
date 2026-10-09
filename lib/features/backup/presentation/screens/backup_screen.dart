import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/clock.dart';
import '../../../profiles/presentation/providers/women_providers.dart';
import '../../../reports/presentation/providers/reports_providers.dart';
import '../../data/backup_file_gateway.dart';
import '../../domain/backup_document.dart';
import '../providers/backup_providers.dart';

/// Copia de seguridad manual y explícita: exportar la base completa (JSON),
/// un ZIP de CSVs o un informe PDF, y restaurar desde un JSON.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // El informe necesita los datos ya cargados; el resto de acciones no.
    final board = ref.watch(reportsBoardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupTitle),
        bottom: _working
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView(
        children: [
          _Seccion(l10n.backupSectionExport),
          ListTile(
            leading: const Icon(Icons.data_object),
            title: Text(l10n.backupExportJsonTitle),
            subtitle: Text(l10n.backupExportJsonSubtitle),
            enabled: !_working,
            onTap: _exportarJson,
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: Text(l10n.backupExportCsvTitle),
            subtitle: Text(l10n.backupExportCsvSubtitle),
            enabled: !_working,
            onTap: _exportarCsv,
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.backupExportPdfTitle),
            subtitle: Text(l10n.backupExportPdfSubtitle),
            enabled: !_working && board.value != null,
            onTap: _exportarPdf,
          ),
          const Divider(),
          _Seccion(l10n.backupSectionImport),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l10n.backupImportJsonTitle),
            subtitle: Text(l10n.backupImportJsonSubtitle),
            enabled: !_working,
            onTap: _importar,
          ),
        ],
      ),
    );
  }

  Future<void> _exportarJson() {
    final repo = ref.read(backupRepositoryProvider);
    return _exportar(
      extensions: const ['json'],
      build: (now) => repo.exportJson(now: now),
    );
  }

  Future<void> _exportarCsv() {
    final repo = ref.read(backupRepositoryProvider);
    return _exportar(
      extensions: const ['zip'],
      build: (now) => repo.exportCsv(now: now),
    );
  }

  Future<void> _exportarPdf() {
    final l10n = AppLocalizations.of(context);
    final board = ref.read(reportsBoardProvider).value;
    if (board == null) {
      _aviso(l10n.backupNotReady);
      return Future<void>.value();
    }

    final repo = ref.read(backupRepositoryProvider);
    return _exportar(
      extensions: const ['pdf'],
      build: (now) => repo.exportPdf(board: board, now: now),
    );
  }

  Future<void> _exportar({
    required List<String> extensions,
    required Future<BackupFile> Function(DateTime now) build,
  }) async {
    final l10n = AppLocalizations.of(context);
    final gateway = ref.read(backupFileGatewayProvider);
    final now = ref.read(clockProvider).now();
    // Ningún formato va cifrado: sin aceptar el aviso no se escribe nada.
    if (await _confirmarSinCifrar() != true) return;
    if (!mounted) return;
    setState(() => _working = true);

    try {
      final file = await build(now);
      final destino = await gateway.save(
        fileName: file.name,
        bytes: file.bytes,
        extensions: extensions,
      );
      if (!mounted) return;
      _aviso(destino == null ? l10n.backupCancelled : l10n.backupSaved);
    } catch (error) {
      if (!mounted) return;
      _aviso(l10n.backupSaveFailed(_motivo(error)));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _importar() async {
    final l10n = AppLocalizations.of(context);
    final gateway = ref.read(backupFileGatewayProvider);
    setState(() => _working = true);

    try {
      final bytes = await gateway.pick(extensions: const ['json']);
      if (bytes == null) {
        if (mounted) _aviso(l10n.backupImportCancelled);
        return;
      }

      final doc = BackupDocument.fromBytes(bytes);
      final confirmado = await _confirmar(
        await ref.read(backupRepositoryProvider).perfilesActuales(),
        doc.counts['women'] ?? 0,
      );
      if (confirmado != true) return;

      final resumen = await ref.read(backupRepositoryProvider).importJson(doc);

      // Ni la lista de perfiles (lee `.first`) ni las etiquetas (FutureProvider)
      // se refrescan solas; las alertas sí, porque su coordinador escucha los
      // cambios de las tablas relevantes.
      await ref.read(womenListProvider.notifier).refresh();
      ref.invalidate(availableTagsProvider);
      if (!mounted) return;
      _aviso(
        l10n.backupRestoredSummary(
          resumen.counts['women'] ?? 0,
          resumen.counts['period_logs'] ?? 0,
          resumen.counts['encounters'] ?? 0,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _aviso(l10n.backupImportFailed(_motivo(error)));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<bool?> _confirmarSinCifrar() {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupUnencryptedTitle),
        content: Text(l10n.backupUnencryptedWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupUnencryptedAction),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmar(int actuales, int entrantes) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupRestoreTitle),
        content: Text(l10n.backupRestoreConfirm(actuales, entrantes)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupRestoreAction),
          ),
        ],
      ),
    );
  }

  /// Mensaje sin datos sensibles: nunca incluye nombres ni notas.
  String _motivo(Object error) {
    if (error is BackupFormatException) {
      return backupFormatErrorText(AppLocalizations.of(context), error);
    }
    return '$error';
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(titulo, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// Mensaje localizado de un error de formato de copia. Los identificadores de
/// tabla/columna son nombres técnicos y no se traducen.
String backupFormatErrorText(AppLocalizations l10n, BackupFormatException e) {
  switch (e.error) {
    case BackupFormatError.invalidJson:
      return l10n.backupInvalidJson;
    case BackupFormatError.notCicloTrack:
      return l10n.backupNotCicloTrack;
    case BackupFormatError.unsupportedVersion:
      return l10n.backupUnsupportedVersion(e.detail ?? '');
    case BackupFormatError.invalidExportDate:
      return l10n.backupInvalidExportDate;
    case BackupFormatError.noTables:
      return l10n.backupNoTables;
    case BackupFormatError.missingTable:
      return l10n.backupMissingTable(e.detail ?? '');
    case BackupFormatError.invalidRow:
      return l10n.backupInvalidRow(e.detail ?? '');
    case BackupFormatError.invalidValue:
      return l10n.backupInvalidValue(e.detail ?? '');
  }
}
