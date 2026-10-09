import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/backup_document.dart';

/// Horquilla de borrado, hijos primero. `woman_tags` y `encounter_women`
/// referencian a sus padres sin `cascade` (o con él, pero sin `PRAGMA
/// foreign_keys` no bastaría), por lo que se borran explícitamente antes.
const backupDeleteOrder = <String>[
  'woman_tags',
  'period_logs',
  'ovulation_logs',
  'symptoms',
  'encounter_women',
  'encounters',
  'reminders',
  'alert_settings',
  'medications',
  'women',
  'tags',
];

/// Orden de inserción, padres primero.
const backupInsertOrder = <String>[
  'women',
  'medications',
  'tags',
  'woman_tags',
  'period_logs',
  'ovulation_logs',
  'symptoms',
  'encounters',
  'encounter_women',
  'reminders',
  'alert_settings',
];

/// Lee las tablas completas y las convierte a documento de copia.
///
/// Las once lecturas corren dentro de una transacción: es el snapshot que
/// impide que una escritura (alta del usuario, planificador de alertas) se
/// cuele entre dos tablas y deje una copia con huérfanos o filas perdidas.
Future<BackupDocument> dumpDatabase(
  AppDatabase db, {
  required DateTime now,
}) async {
  final tables = <String, List<Map<String, Object?>>>{};
  await db.transaction(() async {
    for (final table in backupInsertOrder) {
      tables[table] = await _dumpTable(db, table);
    }
  });
  return BackupDocument(exportedAt: now, tables: tables);
}

/// Restaura el documento dentro de una transacción: borra todo en
/// [backupDeleteOrder], inserta todo en [backupInsertOrder] con los
/// identificadores originales y revierte por completo si algo falla.
Future<void> restoreDatabase(AppDatabase db, BackupDocument doc) {
  return db.transaction(() async {
    for (final table in backupDeleteOrder) {
      await _deleteTable(db, table);
    }
    for (final table in backupInsertOrder) {
      await _insertTable(db, table, doc.rows(table));
    }
  });
}

Future<List<Map<String, Object?>>> _dumpTable(
  AppDatabase db,
  String table,
) async {
  switch (table) {
    case 'medications':
      final rows = await db.select(db.medications).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'woman_id': row.womanId,
            'name': row.name,
            'dose': row.dose,
            'hour': row.hour,
            'minute': row.minute,
            'enabled': row.enabled,
          },
      ];
    case 'women':
      final rows = await db.select(db.women).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'name': row.name,
            'initials': row.initials,
            'emoji': row.emoji,
            'color': row.color,
            'private_notes': row.privateNotes,
            'sort_order': row.sortOrder,
            'created_at': row.createdAt,
          },
      ];
    case 'tags':
      final rows = await db.select(db.tags).get();
      return [
        for (final row in rows) {'id': row.id, 'name': row.name},
      ];
    case 'woman_tags':
      final rows = await db.select(db.womanTags).get();
      return [
        for (final row in rows)
          {'id': row.id, 'woman_id': row.womanId, 'tag_id': row.tagId},
      ];
    case 'period_logs':
      final rows = await db.select(db.periodLogs).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'woman_id': row.womanId,
            'start_date': row.startDate,
            'end_date': row.endDate,
            'flow_level': row.flowLevel,
            'notes': row.notes,
          },
      ];
    case 'ovulation_logs':
      final rows = await db.select(db.ovulationLogs).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'woman_id': row.womanId,
            'date': row.date,
            'temperature': row.temperature,
            'cervical_mucus': row.cervicalMucus,
            'lh_test': row.lhTest,
          },
      ];
    case 'symptoms':
      final rows = await db.select(db.symptoms).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'woman_id': row.womanId,
            'date': row.date,
            'type': row.type,
            'severity': row.severity,
            'notes': row.notes,
          },
      ];
    case 'encounters':
      final rows = await db.select(db.encounters).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'date_time': row.encounterTime,
            'protection': row.protection,
            'outcome': row.outcome,
            'notes': row.notes,
          },
      ];
    case 'encounter_women':
      final rows = await db.select(db.encounterWomen).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'encounter_id': row.encounterId,
            'woman_id': row.womanId,
            'relationship_type': row.relationshipType,
          },
      ];
    case 'reminders':
      final rows = await db.select(db.reminders).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'woman_id': row.womanId,
            'cycle_day_start': row.cycleDayStart,
            'cycle_day_end': row.cycleDayEnd,
            'message': row.message,
            'enabled': row.enabled,
          },
      ];
    case 'alert_settings':
      final rows = await db.select(db.alertSettings).get();
      return [
        for (final row in rows)
          {
            'id': row.id,
            'master_enabled': row.masterEnabled,
            'notify_hour': row.notifyHour,
            'notify_minute': row.notifyMinute,
            'enabled_types': row.enabledTypes,
            'horizon_days': row.horizonDays,
          },
      ];
    default:
      throw ArgumentError.value(table, 'table', 'Tabla desconocida');
  }
}

Future<void> _deleteTable(AppDatabase db, String table) async {
  switch (table) {
    case 'medications':
      await db.delete(db.medications).go();
    case 'women':
      await db.delete(db.women).go();
    case 'tags':
      await db.delete(db.tags).go();
    case 'woman_tags':
      await db.delete(db.womanTags).go();
    case 'period_logs':
      await db.delete(db.periodLogs).go();
    case 'ovulation_logs':
      await db.delete(db.ovulationLogs).go();
    case 'symptoms':
      await db.delete(db.symptoms).go();
    case 'encounters':
      await db.delete(db.encounters).go();
    case 'encounter_women':
      await db.delete(db.encounterWomen).go();
    case 'reminders':
      await db.delete(db.reminders).go();
    case 'alert_settings':
      await db.delete(db.alertSettings).go();
    default:
      throw ArgumentError.value(table, 'table', 'Tabla desconocida');
  }
}

Future<void> _insertTable(
  AppDatabase db,
  String table,
  List<Map<String, Object?>> rows,
) async {
  switch (table) {
    case 'medications':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.medications, [
          for (final row in rows)
            MedicationsCompanion(
              id: Value(row['id']! as int),
              womanId: Value(row['woman_id']! as int),
              name: Value(row['name']! as String),
              dose: Value(row['dose']! as String),
              hour: Value(row['hour']! as int),
              minute: Value(row['minute']! as int),
              enabled: Value(row['enabled']! as bool),
            ),
        ]);
      });
    case 'women':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.women, [for (final row in rows) _woman(row)]);
      });
    case 'tags':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.tags, [for (final row in rows) _tag(row)]);
      });
    case 'woman_tags':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.womanTags, [for (final row in rows) _womanTag(row)]);
      });
    case 'period_logs':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.periodLogs, [
          for (final row in rows) _periodLog(row),
        ]);
      });
    case 'ovulation_logs':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.ovulationLogs, [
          for (final row in rows) _ovulationLog(row),
        ]);
      });
    case 'symptoms':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.symptoms, [for (final row in rows) _symptom(row)]);
      });
    case 'encounters':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.encounters, [
          for (final row in rows) _encounter(row),
        ]);
      });
    case 'encounter_women':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.encounterWomen, [
          for (final row in rows) _encounterWoman(row),
        ]);
      });
    case 'reminders':
      if (rows.isEmpty) return;
      await db.batch((batch) {
        batch.insertAll(db.reminders, [for (final row in rows) _reminder(row)]);
      });
    case 'alert_settings':
      // Fila singleton (id=1): si la copia no la trae, se recrea por defecto.
      final companions = rows.isEmpty
          ? const [AlertSettingsCompanion(id: Value(1))]
          : [for (final row in rows) _alertSetting(row)];
      await db.batch((batch) {
        batch.insertAll(db.alertSettings, companions);
      });
    default:
      throw ArgumentError.value(table, 'table', 'Tabla desconocida');
  }
}

WomenCompanion _woman(Map<String, Object?> row) => WomenCompanion(
  id: Value(row['id']! as int),
  name: Value(row['name']! as String),
  initials: Value(row['initials']! as String),
  emoji: Value(row['emoji']! as String),
  color: Value(row['color']! as int),
  privateNotes: Value(row['private_notes']! as String),
  sortOrder: Value(row['sort_order']! as int),
  createdAt: Value(row['created_at']! as DateTime),
);

TagsCompanion _tag(Map<String, Object?> row) => TagsCompanion(
  id: Value(row['id']! as int),
  name: Value(row['name']! as String),
);

WomanTagsCompanion _womanTag(Map<String, Object?> row) => WomanTagsCompanion(
  id: Value(row['id']! as int),
  womanId: Value(row['woman_id']! as int),
  tagId: Value(row['tag_id']! as int),
);

PeriodLogsCompanion _periodLog(Map<String, Object?> row) => PeriodLogsCompanion(
  id: Value(row['id']! as int),
  womanId: Value(row['woman_id']! as int),
  startDate: Value(row['start_date']! as DateTime),
  endDate: Value(row['end_date'] as DateTime?),
  flowLevel: Value(row['flow_level'] as int?),
  notes: Value(row['notes']! as String),
);

OvulationLogsCompanion _ovulationLog(Map<String, Object?> row) =>
    OvulationLogsCompanion(
      id: Value(row['id']! as int),
      womanId: Value(row['woman_id']! as int),
      date: Value(row['date']! as DateTime),
      temperature: Value(row['temperature'] as double?),
      cervicalMucus: Value(row['cervical_mucus'] as String?),
      lhTest: Value(row['lh_test'] as bool?),
    );

SymptomsCompanion _symptom(Map<String, Object?> row) => SymptomsCompanion(
  id: Value(row['id']! as int),
  womanId: Value(row['woman_id']! as int),
  date: Value(row['date']! as DateTime),
  type: Value(row['type']! as String),
  severity: Value(row['severity']! as int),
  notes: Value(row['notes']! as String),
);

EncountersCompanion _encounter(Map<String, Object?> row) => EncountersCompanion(
  id: Value(row['id']! as int),
  encounterTime: Value(row['date_time']! as DateTime),
  protection: Value(row['protection']! as String),
  outcome: Value(row['outcome'] as String?),
  notes: Value(row['notes']! as String),
);

EncounterWomenCompanion _encounterWoman(Map<String, Object?> row) =>
    EncounterWomenCompanion(
      id: Value(row['id']! as int),
      encounterId: Value(row['encounter_id']! as int),
      womanId: Value(row['woman_id']! as int),
      relationshipType: Value(row['relationship_type']! as String),
    );

RemindersCompanion _reminder(Map<String, Object?> row) => RemindersCompanion(
  id: Value(row['id']! as int),
  womanId: Value(row['woman_id']! as int),
  cycleDayStart: Value(row['cycle_day_start']! as int),
  cycleDayEnd: Value(row['cycle_day_end']! as int),
  message: Value(row['message']! as String),
  enabled: Value(row['enabled']! as bool),
);

AlertSettingsCompanion _alertSetting(Map<String, Object?> row) =>
    AlertSettingsCompanion(
      id: Value(row['id']! as int),
      masterEnabled: Value(row['master_enabled']! as bool),
      notifyHour: Value(row['notify_hour']! as int),
      notifyMinute: Value(row['notify_minute']! as int),
      enabledTypes: Value(row['enabled_types']! as String),
      horizonDays: Value(row['horizon_days']! as int),
    );
