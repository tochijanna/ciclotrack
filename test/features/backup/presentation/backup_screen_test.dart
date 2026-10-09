import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciclotrack/core/db/app_database.dart';
import 'package:ciclotrack/core/db/app_database_provider.dart';
import 'package:ciclotrack/core/l10n/app_locale.dart';
import 'package:ciclotrack/features/backup/data/backup_file_gateway.dart';
import 'package:ciclotrack/features/backup/data/backup_serializer.dart';
import 'package:ciclotrack/features/backup/domain/backup_document.dart';
import 'package:ciclotrack/features/backup/presentation/providers/backup_providers.dart';
import 'package:ciclotrack/features/backup/presentation/screens/backup_screen.dart';
import 'package:ciclotrack/features/profiles/presentation/providers/women_providers.dart';
import 'package:ciclotrack/l10n/app_localizations.dart';

import '../../../support/widget_harness.dart';

/// Gateway en memoria: guarda lo que se le pide y devuelve lo que se le dice.
class _FakeGateway implements BackupFileGateway {
  final guardados = <BackupFile>[];
  List<String>? ultimasExtensiones;
  Uint8List? aLeer;
  bool cancelarGuardado = false;

  @override
  Future<Uri?> save({
    required String fileName,
    required Uint8List bytes,
    required List<String> extensions,
  }) async {
    if (cancelarGuardado) return null;
    ultimasExtensiones = extensions;
    guardados.add(BackupFile(name: fileName, bytes: bytes));
    return Uri.parse('/tmp/$fileName');
  }

  @override
  Future<Uint8List?> pick({required List<String> extensions}) async {
    ultimasExtensiones = extensions;
    return aLeer;
  }
}

/// Espía del listado de perfiles: demuestra que la importación lo refresca.
class _Perfiles extends ConsumerWidget {
  const _Perfiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfiles = ref.watch(womenListProvider);
    final nombres =
        perfiles.value?.map((p) => p.woman.name).join(',') ?? 'cargando';
    return Text('perfiles: $nombres');
  }
}

void main() {
  final now = DateTime(2026, 9, 30, 21, 15);

  late AppDatabase db;
  late _FakeGateway gateway;

  setUp(() {
    db = createTestDatabase();
    gateway = _FakeGateway();
  });

  /// Deja correr las consultas y las transacciones reales de drift.
  Future<void> asentar(WidgetTester tester, [int veces = 3]) async {
    for (var i = 0; i < veces; i++) {
      await settleProviders(tester);
    }
  }

  Future<void> pumpBackup(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appLocaleProvider.overrideWithValue(const Locale('es')),
          fixedClock(now),
          backupFileGatewayProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: const BackupScreen()),
                _Perfiles(),
              ],
            ),
          ),
        ),
      ),
    );
    await asentar(tester);
  }

  Future<void> pulsar(WidgetTester tester, String texto) async {
    await tester.tap(find.text(texto));
    await asentar(tester);
  }

  /// Elige un formato y acepta el aviso de archivo sin cifrar.
  Future<void> exportar(WidgetTester tester, String texto) async {
    await pulsar(tester, texto);
    expect(find.text('Archivo sin cifrar'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Exportar'));
    await asentar(tester);
  }

  testWidgets('PRIV-06: sin aceptar el aviso de sin cifrar no exporta nada', (
    tester,
  ) async {
    await seedWoman(tester, db, name: 'Ana');
    await pumpBackup(tester);

    for (final formato in [
      'Copia completa (JSON)',
      'Tablas (CSV)',
      'Informe (PDF)',
    ]) {
      await pulsar(tester, formato);
      expect(find.textContaining('se guardará sin cifrar'), findsOneWidget);
      expect(find.textContaining('bloqueo de acceso'), findsOneWidget);
      await pulsar(tester, 'Cancelar');
      expect(find.text('Archivo sin cifrar'), findsNothing);
    }

    expect(gateway.guardados, isEmpty);
    expect(gateway.ultimasExtensiones, isNull);

    await closeTestDatabase(tester, db);
  });

  testWidgets('exporta la copia completa en JSON', (tester) async {
    await seedWoman(tester, db, name: 'Ana');
    await pumpBackup(tester);

    await exportar(tester, 'Copia completa (JSON)');

    expect(gateway.ultimasExtensiones, ['json']);
    expect(gateway.guardados, hasLength(1));
    final file = gateway.guardados.single;
    expect(file.name, 'ciclotrack-backup-20260930-211500.json');
    expect(utf8.decode(file.bytes.take(1).toList()), '{');
    expect(find.text('Copia guardada'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('avisa cuando el usuario cancela el guardado', (tester) async {
    gateway.cancelarGuardado = true;
    await pumpBackup(tester);

    await exportar(tester, 'Copia completa (JSON)');

    expect(gateway.guardados, isEmpty);
    expect(find.text('Exportación cancelada'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('exporta las tablas como ZIP con BOM', (tester) async {
    await seedWoman(tester, db, name: 'Ana');
    await pumpBackup(tester);

    await exportar(tester, 'Tablas (CSV)');

    expect(gateway.ultimasExtensiones, ['zip']);
    final file = gateway.guardados.single;
    expect(file.name, 'ciclotrack-csv-20260930-211500.zip');
    expect(String.fromCharCodes(file.bytes.take(2)), 'PK');
    expect(find.text('Copia guardada'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('exporta el informe PDF cuando el tablero está cargado', (
    tester,
  ) async {
    await seedWoman(tester, db, name: 'Ana');
    await pumpBackup(tester);

    await exportar(tester, 'Informe (PDF)');

    expect(gateway.ultimasExtensiones, ['pdf']);
    final file = gateway.guardados.single;
    expect(file.name, 'ciclotrack-informe-20260930-211500.pdf');
    expect(String.fromCharCodes(file.bytes.take(5)), '%PDF-');
    expect(find.text('Copia guardada'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });

  testWidgets('restaura una copia y refresca la lista de perfiles', (
    tester,
  ) async {
    await seedWoman(tester, db, name: 'Zoe');
    final copia = createTestDatabase();
    final ana = await seedWoman(tester, copia, name: 'Ana');
    await seedPeriod(
      tester,
      copia,
      womanId: ana,
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 5),
    );
    final doc = await runReal(tester, () => dumpDatabase(copia, now: now));
    await closeTestDatabase(tester, copia);
    gateway.aLeer = Uint8List.fromList(doc.toUtf8Bytes());

    await pumpBackup(tester);
    expect(find.text('perfiles: Zoe'), findsOneWidget);

    await tester.tap(find.text('Restaurar desde JSON'));
    await asentar(tester);

    expect(find.text('Restaurar copia'), findsOneWidget);
    expect(
      find.text(
        '¿Reemplazar todos los datos actuales? Se borrarán los 1 perfiles '
        'actuales y todos sus registros. La copia contiene 1.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Restaurar'));
    await asentar(tester);

    expect(
      find.text('Copia restaurada: 1 perfiles, 1 periodos, 0 encuentros'),
      findsOneWidget,
    );
    expect(find.text('perfiles: Ana'), findsOneWidget);
    final mujeres = await runReal(tester, () => db.select(db.women).get());
    expect(mujeres.single.name, 'Ana');
    final periodos = await runReal(
      tester,
      () => db.select(db.periodLogs).get(),
    );
    expect(periodos, hasLength(1));

    await closeTestDatabase(tester, db);
  });

  testWidgets('avisa cuando se cancela la importación y no toca la base', (
    tester,
  ) async {
    await seedWoman(tester, db, name: 'Zoe');
    await pumpBackup(tester);

    await pulsar(tester, 'Restaurar desde JSON');

    expect(find.text('Importación cancelada'), findsOneWidget);
    final mujeres = await runReal(tester, () => db.select(db.women).get());
    expect(mujeres.single.name, 'Zoe');

    await closeTestDatabase(tester, db);
  });

  testWidgets('rechaza un archivo ajeno sin tocar la base', (tester) async {
    await seedWoman(tester, db, name: 'Zoe');
    gateway.aLeer = Uint8List.fromList(
      utf8.encode(jsonEncode({'app': 'otra-app'})),
    );
    await pumpBackup(tester);

    await pulsar(tester, 'Restaurar desde JSON');

    expect(
      find.text(
        'No se pudo importar: El archivo no es una copia de CicloTrack',
      ),
      findsOneWidget,
    );
    expect(find.text('Restaurar copia'), findsNothing);
    final mujeres = await runReal(tester, () => db.select(db.women).get());
    expect(mujeres.single.name, 'Zoe');

    await closeTestDatabase(tester, db);
  });

  testWidgets('rechaza periodos solapados sin tocar la base', (tester) async {
    await seedWoman(tester, db, name: 'Zoe');
    gateway.aLeer = Uint8List.fromList(
      utf8.encode(
        jsonEncode(
          BackupDocument(
            exportedAt: now,
            tables: {
              'women': [
                {
                  'id': 1,
                  'name': 'Ana',
                  'initials': 'AN',
                  'emoji': '👩',
                  'color': 4294198070,
                  'private_notes': '',
                  'sort_order': 0,
                  'created_at': now,
                },
              ],
              'period_logs': [
                {
                  'id': 1,
                  'woman_id': 1,
                  'start_date': DateTime(2026, 9, 1),
                  'end_date': DateTime(2026, 9, 5),
                  'flow_level': null,
                  'notes': '',
                },
                {
                  'id': 2,
                  'woman_id': 1,
                  'start_date': DateTime(2026, 9, 4),
                  'end_date': null,
                  'flow_level': null,
                  'notes': '',
                },
              ],
            },
          ).toJson(),
        ),
      ),
    );
    await pumpBackup(tester);

    await pulsar(tester, 'Restaurar desde JSON');

    expect(
      find.text('No se pudo importar: La copia contiene periodos solapados'),
      findsOneWidget,
    );
    final mujeres = await runReal(tester, () => db.select(db.women).get());
    expect(mujeres.single.name, 'Zoe');

    await closeTestDatabase(tester, db);
  });

  testWidgets('cancelar el diálogo deja la copia sin aplicar', (tester) async {
    await seedWoman(tester, db, name: 'Zoe');
    gateway.aLeer = Uint8List.fromList(
      utf8.encode(
        jsonEncode(
          BackupDocument(
            exportedAt: now,
            tables: {
              'women': [
                {
                  'id': 1,
                  'name': 'Ana',
                  'initials': 'AN',
                  'emoji': '👩',
                  'color': 4294198070,
                  'private_notes': '',
                  'sort_order': 0,
                  'created_at': now,
                },
              ],
            },
          ).toJson(),
        ),
      ),
    );
    await pumpBackup(tester);

    await tester.tap(find.text('Restaurar desde JSON'));
    await asentar(tester);
    await tester.tap(find.text('Cancelar'));
    await asentar(tester);

    final mujeres = await runReal(tester, () => db.select(db.women).get());
    expect(mujeres.single.name, 'Zoe');
    expect(find.textContaining('Copia restaurada'), findsNothing);

    await closeTestDatabase(tester, db);
  });

  testWidgets('el diálogo distingue perfiles actuales de entrantes', (
    tester,
  ) async {
    // 2 perfiles actuales; la copia trae solo 1.
    await seedWoman(tester, db, name: 'Zoe');
    await seedWoman(tester, db, name: 'Ruth');
    gateway.aLeer = Uint8List.fromList(
      utf8.encode(
        jsonEncode(
          BackupDocument(
            exportedAt: now,
            tables: {
              'women': [
                {
                  'id': 1,
                  'name': 'Ana',
                  'initials': 'AN',
                  'emoji': '👩',
                  'color': 4294198070,
                  'private_notes': '',
                  'sort_order': 0,
                  'created_at': now,
                },
              ],
            },
          ).toJson(),
        ),
      ),
    );
    await pumpBackup(tester);

    await pulsar(tester, 'Restaurar desde JSON');

    expect(
      find.text(
        '¿Reemplazar todos los datos actuales? Se borrarán los 2 perfiles '
        'actuales y todos sus registros. La copia contiene 1.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancelar'));
    await asentar(tester);

    final mujeres = await runReal(tester, () => db.select(db.women).get());
    expect(mujeres.map((m) => m.name), ['Zoe', 'Ruth']);
    expect(find.textContaining('Copia restaurada'), findsNothing);

    await closeTestDatabase(tester, db);
  });

  testWidgets('las cuatro acciones están enunciadas', (tester) async {
    await pumpBackup(tester);

    expect(find.text('Copia de seguridad'), findsOneWidget);
    expect(find.text('Exportar'), findsOneWidget);
    expect(find.text('Importar'), findsOneWidget);
    expect(find.text('Tablas (CSV)'), findsOneWidget);
    expect(find.text('Informe (PDF)'), findsOneWidget);
    expect(find.text('Restaurar desde JSON'), findsOneWidget);

    await closeTestDatabase(tester, db);
  });
}
