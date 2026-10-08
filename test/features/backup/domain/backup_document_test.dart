import 'dart:convert';

import 'package:ciclotrack/features/backup/domain/backup_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Copia con las diez tablas, emojis, acentos, comas y saltos de línea.
  BackupDocument muestra() => BackupDocument(
    exportedAt: DateTime(2026, 9, 30, 21, 15),
    tables: {
      'women': [
        {
          'id': 1,
          'name': 'Ana',
          'initials': 'A',
          'emoji': '👩',
          'color': 4294198070,
          'private_notes': 'Ñ, comas,\ny saltos de línea',
          'sort_order': 0,
          'created_at': DateTime(2026, 9, 30, 21, 0, 5),
        },
        {
          'id': 2,
          'name': 'Bea',
          'initials': 'B',
          'emoji': '👩‍🦰',
          'color': 4278255360,
          'private_notes': '',
          'sort_order': 1,
          'created_at': DateTime(2026, 8, 1, 8, 30),
        },
      ],
      'tags': [
        {'id': 1, 'name': 'Pareja'},
        {'id': 2, 'name': 'Amiga'},
      ],
      'woman_tags': [
        {'id': 1, 'woman_id': 1, 'tag_id': 1},
        {'id': 2, 'woman_id': 2, 'tag_id': 2},
      ],
      'period_logs': [
        {
          'id': 1,
          'woman_id': 1,
          'start_date': DateTime(2026, 9, 1),
          'end_date': DateTime(2026, 9, 5),
          'flow_level': 2,
          'notes': 'flujo medio',
        },
        {
          'id': 2,
          'woman_id': 2,
          'start_date': DateTime(2026, 9, 10),
          'end_date': null,
          'flow_level': null,
          'notes': '',
        },
      ],
      'ovulation_logs': [
        {
          'id': 1,
          'woman_id': 1,
          'date': DateTime(2026, 9, 14),
          'temperature': 36.6,
          'cervical_mucus': 'Cristalino',
          'lh_test': true,
        },
      ],
      'symptoms': [
        {
          'id': 1,
          'woman_id': 1,
          'date': DateTime(2026, 9, 12),
          'type': 'Acné',
          'severity': 3,
          'notes': 'leve',
        },
      ],
      'encounters': [
        {
          'id': 1,
          'date_time': DateTime(2026, 9, 5, 21, 30, 12),
          'protection': 'Condón',
          'outcome': 'Nada',
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
      ],
      'medications': [
        {
          'id': 1,
          'woman_id': 1,
          'name': 'Hierro',
          'dose': '20 mg',
          'hour': 23,
          'minute': 59,
          'enabled': true,
        },
      ],
      'reminders': [
        {
          'id': 1,
          'woman_id': 1,
          'cycle_day_start': 1,
          'cycle_day_end': 3,
          'message': 'Tomar hierro',
          'enabled': true,
        },
      ],
      'alert_settings': [
        {
          'id': 1,
          'master_enabled': false,
          'notify_hour': 9,
          'notify_minute': 0,
          'enabled_types': 'fertilidadInminente',
          'horizon_days': 7,
        },
      ],
    },
  );

  group('ida y vuelta', () {
    test('conserva todas las filas, emojis y acentos', () {
      final original = muestra();

      final leido = BackupDocument.fromBytes(original.toUtf8Bytes());

      expect(leido.schemaVersion, backupSchemaVersion);
      expect(leido.exportedAt, DateTime(2026, 9, 30, 21, 15));
      expect(leido.tables, original.tables);
      expect(leido.rows('women').first['emoji'], '👩');
      expect(
        leido.rows('women').first['private_notes'],
        'Ñ, comas,\ny saltos de línea',
      );
    });

    test('los instantes conservan el segundo exacto', () {
      final original = muestra();

      final leido = BackupDocument.fromJson(original.toJson());

      final creado = leido.rows('women').first['created_at']! as DateTime;
      expect(creado, DateTime(2026, 9, 30, 21, 0, 5));
      expect(creado.isUtc, false);

      final encuentro =
          leido.rows('encounters').first['date_time']! as DateTime;
      expect(encuentro, DateTime(2026, 9, 5, 21, 30, 12));
      expect(encuentro.isUtc, false);
    });

    test('las columnas de fecha salen como YYYY-MM-DD', () {
      final json =
          jsonDecode(utf8.decode(muestra().toUtf8Bytes()))
              as Map<String, Object?>;
      final tablas = json['tables']! as Map<String, Object?>;

      final periodo =
          (tablas['period_logs']! as List<Object?>).first
              as Map<String, Object?>;
      expect(periodo['start_date'], '2026-09-01');
      expect(periodo['end_date'], '2026-09-05');
      expect(
        ((tablas['period_logs']! as List<Object?>).last
            as Map<String, Object?>)['end_date'],
        isNull,
      );
    });

    test('cuenta las filas por tabla', () {
      final copia = muestra();

      expect(copia.counts['women'], 2);
      expect(copia.counts['period_logs'], 2);
      expect(copia.counts['symptoms'], 1);
      expect(copia.counts.length, backupTables.length);
    });

    test('un documento vacío solo tiene listas vacías', () {
      final vacio = BackupDocument(
        exportedAt: DateTime(2026, 9, 30),
        tables: {for (final tabla in backupTables) tabla: const []},
      );

      final leido = BackupDocument.fromJson(vacio.toJson());

      expect(leido.counts.values.every((n) => n == 0), isTrue);
    });
  });

  test('lee v3 sin medications y rechaza v4 incompleto', () {
    final json = muestra().toJson()..['schemaVersion'] = 3;
    (json['tables']! as Map<String, Object?>).remove('medications');
    final document = BackupDocument.fromJson(json);
    expect(document.rows('medications'), isEmpty);
    expect(document.rows('women'), hasLength(2));
    json['schemaVersion'] = 4;
    expect(
      () => BackupDocument.fromJson(json),
      throwsA(isA<BackupFormatException>()),
    );
  });

  group('validación', () {
    test('rechaza un archivo que no es de CicloTrack', () {
      final json = muestra().toJson()..['app'] = 'otra-app';

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupFormatError.notCicloTrack,
          ),
        ),
      );
    });

    test('rechaza una versión de schema distinta', () {
      final json = muestra().toJson()..['schemaVersion'] = 5;

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupFormatError.unsupportedVersion,
          ),
        ),
      );
    });

    test('rechaza una tabla ausente', () {
      final json = muestra().toJson();
      (json['tables']! as Map<String, Object?>).remove('reminders');

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupFormatError.missingTable,
          ),
        ),
      );
    });

    test('rechaza una fila con columnas de más o de menos', () {
      final json = muestra().toJson();
      final mujeres =
          (json['tables']! as Map<String, Object?>)['women']! as List<Object?>;
      (mujeres.first! as Map<String, Object?>)['extra'] = 1;

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupFormatError.invalidRow,
          ),
        ),
      );
    });

    test('rechaza un valor de tipo incorrecto', () {
      final json = muestra().toJson();
      final mujeres =
          (json['tables']! as Map<String, Object?>)['women']! as List<Object?>;
      (mujeres.first! as Map<String, Object?>)['id'] = 'uno';

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupFormatError.invalidValue,
          ),
        ),
      );
    });

    test('rechaza una fecha mal formada', () {
      final json = muestra().toJson();
      final periodos =
          (json['tables']! as Map<String, Object?>)['period_logs']!
              as List<Object?>;
      (periodos.first! as Map<String, Object?>)['start_date'] = '01/09/2026';

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupFormatError.invalidValue,
          ),
        ),
      );
    });

    test('rechaza un nulo en una columna obligatoria', () {
      final json = muestra().toJson();
      final mujeres =
          (json['tables']! as Map<String, Object?>)['women']! as List<Object?>;
      (mujeres.first! as Map<String, Object?>)['name'] = null;

      expect(
        () => BackupDocument.fromJson(json),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('envuelve un JSON ilegible sin lanzar FormatException', () {
      expect(
        () => BackupDocument.fromBytes(utf8.encode('{no es json')),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupFormatError.invalidJson,
          ),
        ),
      );
      expect(
        () => BackupDocument.fromBytes(utf8.encode('[1, 2, 3]')),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  group('marca de tiempo', () {
    test('formatea como 20260930-211500', () {
      expect(backupStamp(DateTime(2026, 9, 30, 21, 15, 0)), '20260930-211500');
      expect(backupStamp(DateTime(2026, 1, 2, 3, 4, 5)), '20260102-030405');
    });

    test('formatea y lee fechas naturales', () {
      expect(formatBackupDate(DateTime(2026, 9, 1)), '2026-09-01');
      expect(parseBackupDate('2026-9-1'), isNull);
      expect(parseBackupDate('2026-02-30'), isNull);
      expect(parseBackupDate('2026-02-28'), DateTime(2026, 2, 28));
    });
  });
}
