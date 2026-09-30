import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/features/backup/domain/backup_document.dart';
import 'package:ciclotrack/features/backup/domain/csv_export.dart';

void main() {
  BackupDocument documento() => BackupDocument(
    exportedAt: DateTime(2026, 9, 30, 21, 15),
    tables: {
      'women': [
        {
          'id': 1,
          'name': 'Ana',
          'initials': 'A',
          'emoji': '👩',
          'color': 4294198070,
          'private_notes': 'Ñ, comas,\ny saltos',
          'sort_order': 0,
          'created_at': DateTime(2026, 9, 30, 21, 0, 5),
        },
      ],
      'period_logs': [
        {
          'id': 1,
          'woman_id': 1,
          'start_date': DateTime(2026, 9, 1),
          'end_date': null,
          'flow_level': null,
          'notes': 'flujo "medio"',
        },
      ],
    },
  );

  Archive descomprimir(List<int> bytes) => ZipDecoder().decodeBytes(bytes);

  ArchiveFile miembro(Archive archive, String nombre) {
    final file = archive.findFile(nombre);
    expect(file, isNotNull, reason: nombre);
    return file!;
  }

  /// `utf8.decode` ya descarta el BOM de cabecera; el recorte cubre la ruta
  /// en memoria, que sí lo conserva.
  List<List<dynamic>> parsear(String csv) => const CsvToListConverter(
    shouldParseNumbers: false,
  ).convert(csv.startsWith('\uFEFF') ? csv.substring(1) : csv);

  String contenido(Archive archive, String nombre) =>
      utf8.decode(miembro(archive, nombre).content as List<int>);

  group('bundle', () {
    test('contiene el manifest y un CSV por cada una de las diez tablas', () {
      final archive = descomprimir(buildCsvBundle(documento()));

      expect(archive.files, hasLength(backupTables.length + 1));
      expect(archive.files.map((file) => file.name).toSet(), {
        'manifest.json',
        for (final table in backupTables) '$table.csv',
      });
    });

    test('el manifest declara la app y el schema', () {
      final archive = descomprimir(buildCsvBundle(documento()));

      final manifest =
          jsonDecode(contenido(archive, 'manifest.json'))
              as Map<String, Object?>;

      expect(manifest['app'], 'cicloTrack'.toLowerCase());
      expect(manifest['schemaVersion'], 3);
      expect(manifest['exportedAt'], '2026-09-30T21:15:00.000');
    });

    test('los CSV del ZIP llevan el BOM UTF-8 en crudo', () {
      final archive = descomprimir(buildCsvBundle(documento()));

      final bytes = miembro(archive, 'women.csv').content as List<int>;
      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    });

    test('cada miembro declara su tamaño real en bytes', () {
      final archive = descomprimir(buildCsvBundle(documento()));

      for (final file in archive.files) {
        final bytes = file.content as List<int>;
        // Con el tamaño en caracteres (lo que hace `ArchiveFile.string`), los
        // emojis y acentos dejan el encabezado del ZIP corto y los lectores
        // estrictos ven un CRC roto.
        expect(file.size, bytes.length, reason: file.name);
      }
    });

    test('las tablas sin filas llevan solo el encabezado', () {
      final archive = descomprimir(buildCsvBundle(documento()));

      final filas = parsear(contenido(archive, 'tags.csv'));

      expect(filas, hasLength(1));
      expect(filas.single, backupColumns['tags']);
    });
  });

  group('CSV de una tabla', () {
    test('empieza por BOM y el encabezado es el orden de las columnas', () {
      final csv = buildTableCsv('women', documento().jsonRows('women'));

      expect(csv.codeUnitAt(0), 0xFEFF);
      expect(csv.contains('﻿id,name,initials,emoji,color'), isTrue);
      expect(parsear(csv).first, backupColumns['women']);
    });

    test('las fechas salen como YYYY-MM-DD y los nulos vacíos', () {
      final csv = buildTableCsv(
        'period_logs',
        documento().jsonRows('period_logs'),
      );

      final filas = parsear(csv);

      expect(filas[1], ['1', '1', '2026-09-01', '', '', 'flujo "medio"']);
    });

    test('una nota con comas y saltos de línea sobrevive al ida y vuelta', () {
      final original = documento();
      final csv = buildTableCsv('women', original.jsonRows('women'));

      final filas = parsear(csv);
      final fila = {
        for (var i = 0; i < backupColumns['women']!.length; i++)
          backupColumns['women']![i]: filas[1][i],
      };

      expect(fila['private_notes'], 'Ñ, comas,\ny saltos');
      expect(fila['emoji'], '👩');
      expect(fila['created_at'], '2026-09-30T21:00:05.000');
    });
  });
}
