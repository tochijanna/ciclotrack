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
    // El informe necesita los datos ya cargados; el resto de acciones no.
    final board = ref.watch(reportsBoardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Copia de seguridad'),
        bottom: _working
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView(
        children: [
          const _Seccion('Exportar'),
          ListTile(
            leading: const Icon(Icons.data_object),
            title: const Text('Copia completa (JSON)'),
            subtitle: const Text('Todos los datos en un archivo JSON'),
            enabled: !_working,
            onTap: _exportarJson,
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: const Text('Tablas (CSV)'),
            subtitle: const Text('Un CSV por tabla, comprimidos en un ZIP'),
            enabled: !_working,
            onTap: _exportarCsv,
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Informe (PDF)'),
            subtitle: const Text(
              'Resumen imprimible de perfiles, ciclos y encuentros',
            ),
            enabled: !_working && board.value != null,
            onTap: _exportarPdf,
          ),
          const Divider(),
          const _Seccion('Importar'),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar desde JSON'),
            subtitle: const Text('Reemplaza todos los datos actuales'),
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
    final board = ref.read(reportsBoardProvider).value;
    if (board == null) {
      _aviso('No se pudo guardar: los datos aún se están cargando');
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
    final gateway = ref.read(backupFileGatewayProvider);
    final now = ref.read(clockProvider).now();
    setState(() => _working = true);

    try {
      final file = await build(now);
      final destino = await gateway.save(
        fileName: file.name,
        bytes: file.bytes,
        extensions: extensions,
      );
      if (!mounted) return;
      _aviso(destino == null ? 'Exportación cancelada' : 'Copia guardada');
    } catch (error) {
      if (!mounted) return;
      _aviso('No se pudo guardar: ${_motivo(error)}');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _importar() async {
    final gateway = ref.read(backupFileGatewayProvider);
    setState(() => _working = true);

    try {
      final bytes = await gateway.pick(extensions: const ['json']);
      if (bytes == null) {
        if (mounted) _aviso('Importación cancelada');
        return;
      }

      final doc = BackupDocument.fromBytes(bytes);
      final confirmado = await _confirmar(doc.counts['women'] ?? 0);
      if (confirmado != true) return;

      final resumen = await ref.read(backupRepositoryProvider).importJson(doc);

      // Ni la lista de perfiles (lee `.first`) ni las etiquetas (FutureProvider)
      // se refrescan solas; las alertas sí, porque su coordinador escucha los
      // cambios de las tablas relevantes.
      await ref.read(womenListProvider.notifier).refresh();
      ref.invalidate(availableTagsProvider);
      if (!mounted) return;
      _aviso(
        'Copia restaurada: ${resumen.counts['women']} perfiles, '
        '${resumen.counts['period_logs']} periodos, '
        '${resumen.counts['encounters']} encuentros',
      );
    } catch (error) {
      if (!mounted) return;
      _aviso('No se pudo importar: ${_motivo(error)}');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<bool?> _confirmar(int perfiles) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restaurar copia'),
      content: Text(
        '¿Reemplazar todos los datos actuales? Se borrarán los $perfiles '
        'perfiles y todos sus registros.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Restaurar'),
        ),
      ],
    ),
  );

  /// Mensaje sin datos sensibles: nunca incluye nombres ni notas.
  String _motivo(Object error) =>
      error is BackupFormatException ? error.message : '$error';

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
