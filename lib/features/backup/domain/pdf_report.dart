import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../reports/domain/report_models.dart';
import 'backup_document.dart';

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
List<PdfBlock> buildPdfBlocks(BackupDocument doc, ReportsBoard board) {
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
    PdfBlock(titulo: 'Resumen', parrafos: _resumen(board.globales)),
    for (final report in board.mujeres) ...[
      PdfBlock(
        titulo: '${report.woman.name} (${report.woman.initials})',
        parrafos: _kpisDe(report),
      ),
      PdfBlock(
        titulo: 'Periodos registrados',
        cabeceras: const ['Inicio', 'Fin', 'Flujo', 'Notas'],
        tabla: _periodosDe(doc, report.woman.id),
      ),
      PdfBlock(
        titulo: 'Síntomas (12 meses)',
        cabeceras: const ['Tipo', 'Frecuencia'],
        tabla: [
          for (final sintoma in report.sintomas)
            [_safe(sintoma.etiqueta), '${sintoma.valor.toInt()}'],
        ],
      ),
    ],
    PdfBlock(
      titulo: 'Encuentros',
      parrafos: encuentros.length > pdfMaxEncuentros
          ? [
              'Se muestran los últimos $pdfMaxEncuentros de '
                  '${encuentros.length} encuentros.',
            ]
          : const [],
      cabeceras: const ['Fecha', 'Mujeres', 'Protección', 'Resultado'],
      tabla: _encuentrosDe(doc, visibles, nombres),
    ),
  ];
}

/// Renderiza los bloques a un PDF A4 con el pie de página numerado.
Future<Uint8List> renderPdf(
  List<PdfBlock> blocks, {
  required DateTime generadoEn,
}) async {
  final document = pw.Document(
    title: 'CicloTrack — copia de seguridad',
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
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
      build: (context) => [
        pw.Text('Informe generado el ${_fechaHora(generadoEn)}'),
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

List<String> _resumen(ReportKpis kpis) => [
  'Perfiles: ${kpis.perfiles}',
  'Ciclos registrados: ${kpis.ciclos}',
  'Duración media del ciclo: ${_dias(kpis.mediaCiclo)}',
  'Duración media de la menstruación: ${_dias(kpis.mediaMenstruacion)}',
  'Encuentros (12 meses): ${kpis.encuentros}',
  'Sin protección: ${kpis.porcentajeSinProteccion.round()} % '
      '(${kpis.encuentrosSinProteccion} de ${kpis.encuentros})',
  'Días fértiles (12 meses, con proyecciones): ${kpis.diasFertiles}',
  if (kpis.mujerConMasEncuentros != null)
    'Más encuentros: ${_safe(kpis.mujerConMasEncuentros!)} '
        '(${kpis.maxEncuentros})',
];

List<String> _kpisDe(WomanReport report) {
  final kpis = report.kpis;
  final proximo = report.proximoPeriodo;
  return [
    'Ciclos registrados: ${kpis.ciclos}',
    'Duración media del ciclo: ${_dias(kpis.mediaCiclo)}',
    'Duración media de la menstruación: ${_dias(kpis.mediaMenstruacion)}',
    'Encuentros (12 meses): ${kpis.encuentros}',
    'Sin protección: ${kpis.porcentajeSinProteccion.round()} % '
        '(${kpis.encuentrosSinProteccion} de ${kpis.encuentros})',
    'Días fértiles (12 meses, con proyecciones): ${kpis.diasFertiles}',
    'Próximo periodo: ${proximo == null ? '-' : _fecha(proximo)}',
  ];
}

List<List<dynamic>> _periodosDe(BackupDocument doc, int womanId) {
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
  BackupDocument doc,
  List<Map<String, Object?>> encuentros,
  Map<int, String> nombres,
) {
  final participantes = <int, List<String>>{};
  for (final row in doc.rows('encounter_women')) {
    final id = row['encounter_id']! as int;
    final womanId = row['woman_id']! as int;
    (participantes[id] ??= <String>[]).add(
      nombres[womanId] ?? 'Perfil $womanId',
    );
  }

  return [
    for (final row in encuentros)
      [
        _fechaHora(row['date_time']! as DateTime),
        _safe((participantes[row['id']! as int] ?? const []).join(', ')),
        _safe(row['protection']! as String),
        row['outcome'] == null ? '' : _safe(row['outcome']! as String),
      ],
  ];
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

String _dias(double valor) => valor == 0 ? '-' : '${valor.round()} días';

String _fecha(DateTime value) =>
    '${_dos(value.day)}/${_dos(value.month)}/${value.year.toString().padLeft(4, '0')}';

String _fechaHora(DateTime value) =>
    '${_fecha(value)} ${_dos(value.hour)}:${_dos(value.minute)}';

String _dos(int value) => value.toString().padLeft(2, '0');
