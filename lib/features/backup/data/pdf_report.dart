import 'dart:typed_data';

import 'package:ciclotrack/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../reports/domain/report_models.dart';
import '../domain/backup_document.dart';

/// Bloque del informe: título, párrafos y tabla opcional.
class PdfBlock {
  const PdfBlock({
    required this.titulo,
    this.parrafos = const [],
    this.cabeceras,
    this.tabla,
  });

  final String titulo;
  final List<String> parrafos;

  /// Encabezado de la tabla; `null` cuando el bloque solo lleva texto.
  final List<String>? cabeceras;

  /// Filas ya formateadas de la tabla; `null` cuando el bloque solo lleva texto.
  final List<List<dynamic>>? tabla;
}

/// Encuentros listados como máximo en el informe.
const pdfMaxEncuentros = 200;

/// Longitud máxima de una nota de periodo en la tabla.
const pdfMaxNota = 60;

/// Bloques del informe, en el orden del documento: resumen global, una
/// sección por perfil (KPIs, periodos y síntomas) y el listado de encuentros.
///
/// El informe es de solo lectura humana: para restaurar datos solo sirve el
/// JSON.
List<PdfBlock> buildPdfBlocks(
  BackupDocument doc,
  ReportsBoard board, {
  required AppLocalizations l10n,
}) {
  final nombres = <int, String>{
    for (final row in doc.rows('women'))
      row['id']! as int: row['name']! as String,
  };
  for (final report in board.mujeres) {
    nombres[report.woman.id] = report.woman.name;
  }

  final encuentros = [...doc.rows('encounters')]
    ..sort(
      (a, b) =>
          (b['date_time']! as DateTime).compareTo(a['date_time']! as DateTime),
    );
  final visibles = encuentros.length > pdfMaxEncuentros
      ? encuentros.sublist(0, pdfMaxEncuentros)
      : encuentros;

  return [
    PdfBlock(titulo: l10n.pdfSummary, parrafos: _resumen(l10n, board.globales)),
    for (final report in board.mujeres) ...[
      PdfBlock(
        titulo: '${report.woman.name} (${report.woman.initials})',
        parrafos: _kpisDe(l10n, report),
      ),
      PdfBlock(
        titulo: l10n.pdfRegisteredPeriods,
        cabeceras: [
          l10n.pdfColStart,
          l10n.pdfColEnd,
          l10n.pdfColFlow,
          l10n.pdfColNotes,
        ],
        tabla: _periodosDe(l10n, doc, report.woman.id),
      ),
      PdfBlock(
        titulo: l10n.pdfSymptoms12,
        cabeceras: [l10n.pdfColType, l10n.pdfColFrequency],
        tabla: [
          for (final sintoma in report.sintomas)
            [_safe(sintoma.etiqueta), '${sintoma.valor.toInt()}'],
        ],
      ),
    ],
    PdfBlock(
      titulo: l10n.pdfMedication,
      cabeceras: [
        l10n.pdfColWoman,
        l10n.pdfColMedication,
        l10n.pdfColDose,
        l10n.pdfColTime,
        l10n.pdfColState,
      ],
      tabla: [
        for (final row in doc.rows('medications'))
          [
            _safe(nombres[row['woman_id']] ?? '?'),
            _safe(row['name']! as String),
            _safe(row['dose']! as String),
            '${(row['hour']! as int).toString().padLeft(2, '0')}:${(row['minute']! as int).toString().padLeft(2, '0')}',
            row['enabled'] == true ? l10n.active : l10n.inactive,
          ],
      ],
    ),
    PdfBlock(
      titulo: l10n.pdfEncounters,
      parrafos: encuentros.length > pdfMaxEncuentros
          ? [l10n.pdfShowsLast(pdfMaxEncuentros, encuentros.length)]
          : const [],
      cabeceras: [
        l10n.pdfColDate,
        l10n.pdfColWomen,
        l10n.pdfColProtection,
        l10n.pdfColOutcome,
      ],
      tabla: _encuentrosDe(l10n, doc, visibles, nombres),
    ),
  ];
}

/// Renderiza los bloques a un PDF A4 con el pie de página numerado.
Future<Uint8List> renderPdf(
  List<PdfBlock> blocks, {
  required DateTime generadoEn,
  required AppLocalizations l10n,
}) async {
  final document = pw.Document(
    title: l10n.pdfDocumentTitle,
    author: 'CicloTrack',
  );

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      // Un informe con muchas filas puede ocupar más de las 20 páginas que el
      // paquete pone por defecto.
      maxPages: 1000,
      header: (context) => pw.Header(level: 0, text: 'CicloTrack'),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          l10n.pdfFooterPage(context.pageNumber, context.pagesCount),
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
      build: (context) => [
        pw.Text(l10n.pdfGeneratedOn(_fechaHora(generadoEn))),
        pw.SizedBox(height: 8),
        for (final block in blocks) ...[
          pw.Header(level: 1, text: _safe(block.titulo)),
          for (final parrafo in block.parrafos) pw.Text(_safe(parrafo)),
          if (block.cabeceras != null && block.tabla != null)
            pw.TableHelper.fromTextArray(
              headers: block.cabeceras,
              data: block.tabla!,
            ),
          pw.SizedBox(height: 16),
        ],
      ],
    ),
  );

  return document.save();
}

List<String> _resumen(AppLocalizations l10n, ReportKpis kpis) => [
  l10n.pdfProfiles(kpis.perfiles),
  l10n.pdfCycles(kpis.ciclos),
  l10n.pdfAvgCycle(_dias(l10n, kpis.mediaCiclo)),
  l10n.pdfAvgMenstruation(_dias(l10n, kpis.mediaMenstruacion)),
  l10n.pdfEncounters12(kpis.encuentros),
  l10n.pdfUnprotected(
    kpis.porcentajeSinProteccion.round(),
    kpis.encuentrosSinProteccion,
    kpis.encuentros,
  ),
  l10n.pdfFertileDays12(kpis.diasFertiles),
  if (kpis.mujerConMasEncuentros != null)
    l10n.pdfMostEncounters(kpis.mujerConMasEncuentros!, kpis.maxEncuentros),
];

List<String> _kpisDe(AppLocalizations l10n, WomanReport report) {
  final kpis = report.kpis;
  final proximo = report.proximoPeriodo;
  return [
    l10n.pdfCycles(kpis.ciclos),
    l10n.pdfAvgCycle(_dias(l10n, kpis.mediaCiclo)),
    l10n.pdfAvgMenstruation(_dias(l10n, kpis.mediaMenstruacion)),
    l10n.pdfEncounters12(kpis.encuentros),
    l10n.pdfUnprotected(
      kpis.porcentajeSinProteccion.round(),
      kpis.encuentrosSinProteccion,
      kpis.encuentros,
    ),
    l10n.pdfFertileDays12(kpis.diasFertiles),
    l10n.pdfNextPeriod(proximo == null ? '-' : _fecha(proximo)),
  ];
}

List<List<dynamic>> _periodosDe(
  AppLocalizations l10n,
  BackupDocument doc,
  int womanId,
) {
  final filas =
      [
        for (final row in doc.rows('period_logs'))
          if (row['woman_id'] == womanId) row,
      ]..sort(
        (a, b) => (a['start_date']! as DateTime).compareTo(
          b['start_date']! as DateTime,
        ),
      );

  return [
    for (final row in filas)
      [
        _fecha(row['start_date']! as DateTime),
        row['end_date'] == null ? '' : _fecha(row['end_date']! as DateTime),
        row['flow_level']?.toString() ?? '',
        _recorta(_safe(row['notes']! as String)),
      ],
  ];
}

List<List<dynamic>> _encuentrosDe(
  AppLocalizations l10n,
  BackupDocument doc,
  List<Map<String, Object?>> encuentros,
  Map<int, String> nombres,
) {
  final participantes = <int, List<String>>{};
  for (final row in doc.rows('encounter_women')) {
    final id = row['encounter_id']! as int;
    final womanId = row['woman_id']! as int;
    (participantes[id] ??= <String>[]).add(
      nombres[womanId] ?? l10n.pdfProfileFallback(womanId),
    );
  }

  return [
    for (final row in encuentros)
      [
        _fechaHora(row['date_time']! as DateTime),
        _safe((participantes[row['id']! as int] ?? const []).join(', ')),
        _safe(_protectionLabel(l10n, row['protection']! as String)),
        row['outcome'] == null
            ? ''
            : _safe(_outcomeLabel(l10n, row['outcome']! as String)),
      ],
  ];
}

String _protectionLabel(AppLocalizations l10n, String value) {
  switch (value) {
    case 'Condón':
      return l10n.protectionCondom;
    case 'Pastilla':
      return l10n.protectionPill;
    case 'Natural':
      return l10n.protectionNatural;
    case 'Ninguno':
      return l10n.protectionNone;
    default:
      return value;
  }
}

String _outcomeLabel(AppLocalizations l10n, String value) {
  switch (value) {
    case 'Nada':
      return l10n.outcomeNothing;
    case 'Embarazo':
      return l10n.outcomePregnancy;
    case 'Aborto':
      return l10n.outcomeAbortion;
    case 'Desconocido':
      return l10n.outcomeUnknown;
    default:
      return value;
  }
}

/// Las fuentes Helvetica del paquete `pdf` usan WinAnsi: todo lo que quede por
/// encima de Latin-1 (emojis incluidos) se sustituye por `?`.
String _safe(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    buffer.write(rune > 0xFF ? '?' : String.fromCharCode(rune));
  }
  return buffer.toString();
}

String _recorta(String value) => value.length <= pdfMaxNota
    ? value
    : '${value.substring(0, pdfMaxNota - 3)}...';

String _dias(AppLocalizations l10n, double valor) =>
    valor == 0 ? '-' : l10n.daysCount(valor.round());

String _fecha(DateTime value) =>
    '${_dos(value.day)}/${_dos(value.month)}/${value.year.toString().padLeft(4, '0')}';

String _fechaHora(DateTime value) =>
    '${_fecha(value)} ${_dos(value.hour)}:${_dos(value.minute)}';

String _dos(int value) => value.toString().padLeft(2, '0');
