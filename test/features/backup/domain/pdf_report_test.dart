import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/backup/domain/backup_document.dart';
import 'package:ciclotrack/features/backup/domain/pdf_report.dart';
import 'package:ciclotrack/features/calendar/domain/calendar_board.dart';
import 'package:ciclotrack/features/prediction/domain/cycle_timeline.dart';
import 'package:ciclotrack/features/prediction/domain/prediction_calculator.dart';
import 'package:ciclotrack/features/reports/domain/report_builder.dart';

void main() {
  final hoy = DateTime(2026, 9, 30);
  final generadoEn = DateTime(2026, 9, 30, 21, 15);

  CalendarWoman mujer(int id, String name) => CalendarWoman(
    id: id,
    name: name,
    initials: name.substring(0, 2).toUpperCase(),
    emoji: '👩',
    color: 0xFFE91E63,
  );

  final ana = mujer(1, 'Ana');
  final bea = mujer(2, 'Bea');

  WomanCalendar conPeriodos(
    CalendarWoman woman,
    List<PeriodLogInput> periodos,
  ) => WomanCalendar(
    woman: woman,
    timeline: CycleTimeline.from(
      logs: periodos,
      horizonte: DateTime(2028, 1, 1),
    ),
    eventos: const [],
    periodos: periodos,
  );

  CalendarBoard tablero() => CalendarBoard(
    women: [
      conPeriodos(ana, [
        PeriodLogInput(
          startDate: DateTime(2026, 8, 4),
          endDate: DateTime(2026, 8, 8),
        ),
        PeriodLogInput(
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 5),
        ),
      ]),
      conPeriodos(bea, [PeriodLogInput(startDate: DateTime(2026, 9, 10))]),
    ],
    encuentros: const [],
  );

  /// Dos perfiles, uno con emoji en el nombre y notas con emoji.
  BackupDocument documento() => BackupDocument(
    exportedAt: generadoEn,
    tables: {
      'women': [
        {
          'id': 1,
          'name': 'Ana 👩',
          'initials': 'AN',
          'emoji': '👩',
          'color': 4294198070,
          'private_notes': 'nota con 😀',
          'sort_order': 0,
          'created_at': DateTime(2026, 9, 30, 21),
        },
        {
          'id': 2,
          'name': 'Bea',
          'initials': 'BE',
          'emoji': '👩',
          'color': 4278255360,
          'private_notes': '',
          'sort_order': 1,
          'created_at': DateTime(2026, 8, 1, 8, 30),
        },
        {
          'id': 3,
          'name': 'Zoe 😀',
          'initials': 'ZO',
          'emoji': '👩',
          'color': 4278190080,
          'private_notes': '',
          'sort_order': 2,
          'created_at': DateTime(2026, 8, 2, 9),
        },
      ],
      'period_logs': [
        {
          'id': 1,
          'woman_id': 1,
          'start_date': DateTime(2026, 8, 4),
          'end_date': DateTime(2026, 8, 8),
          'flow_level': 1,
          'notes': '',
        },
        {
          'id': 2,
          'woman_id': 1,
          'start_date': DateTime(2026, 9, 1),
          'end_date': DateTime(2026, 9, 5),
          'flow_level': 2,
          'notes': 'flujo "medio"',
        },
        {
          'id': 3,
          'woman_id': 1,
          'start_date': DateTime(2026, 9, 29),
          'end_date': null,
          'flow_level': null,
          'notes': 'a' * 80,
        },
        {
          'id': 4,
          'woman_id': 2,
          'start_date': DateTime(2026, 9, 10),
          'end_date': null,
          'flow_level': null,
          'notes': '',
        },
      ],
      'encounters': [
        {
          'id': 1,
          'date_time': DateTime(2026, 9, 5, 21, 30),
          'protection': 'Condón',
          'outcome': 'Nada',
          'notes': '',
        },
        {
          'id': 2,
          'date_time': DateTime(2026, 9, 20, 22),
          'protection': 'Ninguno',
          'outcome': null,
          'notes': '',
        },
      ],
      'encounter_women': [
        {
          'id': 1,
          'encounter_id': 1,
          'woman_id': 1,
          'relationship_type': 'Vaginal',
        },
        {
          'id': 2,
          'encounter_id': 1,
          'woman_id': 2,
          'relationship_type': 'Oral',
        },
        {
          'id': 3,
          'encounter_id': 2,
          'woman_id': 3,
          'relationship_type': 'Vaginal',
        },
      ],
    },
  );

  List<String> textosDe(List<PdfBlock> blocks) => [
    for (final block in blocks) ...[
      block.titulo,
      ...block.parrafos,
      for (final fila in block.tabla ?? const <List<dynamic>>[])
        for (final celda in fila) '$celda',
    ],
  ];

  bool tieneEmoji(String value) => value.runes.any((rune) => rune > 0xFF);

  group('bloques', () {
    test('llevan el resumen, un apartado por perfil y los encuentros', () {
      final blocks = buildPdfBlocks(
        documento(),
        buildReports(tablero(), today: hoy),
      );

      expect(blocks.first.titulo, 'Resumen');
      expect(blocks.first.parrafos, contains('Perfiles: 2'));
      expect(blocks.first.parrafos, contains('Encuentros (12 meses): 0'));
      expect(blocks.map((block) => block.titulo), [
        'Resumen',
        'Ana (AN)',
        'Periodos registrados',
        'Síntomas (12 meses)',
        'Bea (BE)',
        'Periodos registrados',
        'Síntomas (12 meses)',
        'Medicación',
        'Encuentros',
      ]);
      expect(blocks.last.titulo, 'Encuentros');
      expect(blocks.last.cabeceras, [
        'Fecha',
        'Mujeres',
        'Protección',
        'Resultado',
      ]);
      // Del más reciente al más antiguo.
      expect(blocks.last.tabla!.first.first, '20/09/2026 22:00');
      expect(blocks.last.tabla!.first[1], 'Zoe ?');
      expect(blocks.last.tabla!.last[1], 'Ana, Bea');
      expect(blocks.last.tabla!.last[3], 'Nada');
    });

    test('no dejan ningún carácter fuera de Latin-1', () {
      final blocks = buildPdfBlocks(
        documento(),
        buildReports(tablero(), today: hoy),
      );

      final sospechosos = textosDe(blocks).where(tieneEmoji).toList();

      expect(sospechosos, isEmpty);
      expect(blocks.last.tabla!.first[1], 'Zoe ?');
    });

    test('cada tabla de periodos trae solo las filas de su perfil', () {
      final blocks = buildPdfBlocks(
        documento(),
        buildReports(tablero(), today: hoy),
      );

      final tablas = [
        for (final block in blocks)
          if (block.titulo == 'Periodos registrados') block.tabla!,
      ];

      expect(tablas, hasLength(2));
      expect(tablas.first, [
        ['04/08/2026', '08/08/2026', '1', ''],
        ['01/09/2026', '05/09/2026', '2', 'flujo "medio"'],
        ['29/09/2026', '', '', '${'a' * 57}...'],
      ]);
      expect(tablas.last, [
        ['10/09/2026', '', '', ''],
      ]);
    });

    test('las tablas sin datos llevan solo el encabezado', () {
      final vacio = BackupDocument(exportedAt: generadoEn, tables: const {});
      final sinDatos = buildReports(
        const CalendarBoard(women: [], encuentros: []),
        today: hoy,
      );

      final blocks = buildPdfBlocks(vacio, sinDatos);

      expect(blocks.first.parrafos, contains('Perfiles: 0'));
      expect(blocks.first.parrafos, contains('Duración media del ciclo: -'));
      expect(blocks.last.tabla, isEmpty);
      expect(blocks.last.cabeceras, isNotNull);
    });

    test('recorta los encuentros a los 200 más recientes', () {
      final doc = BackupDocument(
        exportedAt: generadoEn,
        tables: {
          'encounters': [
            for (var i = 0; i < 250; i++)
              {
                'id': i + 1,
                'date_time': DateTime(2026, 1, 1 + i),
                'protection': 'Condón',
                'outcome': null,
                'notes': '',
              },
          ],
        },
      );

      final blocks = buildPdfBlocks(
        doc,
        buildReports(
          const CalendarBoard(women: [], encuentros: []),
          today: hoy,
        ),
      );

      expect(blocks.last.tabla, hasLength(pdfMaxEncuentros));
      expect(blocks.last.parrafos, [
        'Se muestran los últimos 200 de 250 encuentros.',
      ]);
      expect(blocks.last.tabla!.first.first, '07/09/2026 00:00');
    });
  });

  group('PDF', () {
    test('sale con el encabezado %PDF- y contenido suficiente', () async {
      final bytes = await renderPdf(
        buildPdfBlocks(documento(), buildReports(tablero(), today: hoy)),
        generadoEn: generadoEn,
      );

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });

    test('con una copia vacía genera un PDF válido', () async {
      final vacio = BackupDocument(exportedAt: generadoEn, tables: const {});
      final bytes = await renderPdf(
        buildPdfBlocks(
          vacio,
          buildReports(
            const CalendarBoard(women: [], encuentros: []),
            today: hoy,
          ),
        ),
        generadoEn: generadoEn,
      );

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });
  });
}
