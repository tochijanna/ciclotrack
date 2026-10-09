# Fixtures históricas (TOC-16)

Bases SQLite reales de los esquemas v1/v2/v3, creadas con el código drift
**de cada commit histórico** (no con DDL a mano ni degradando una v4).
Contienen datos representativos idénticos en las tablas compartidas, para
que `migration_test.dart` aserta lo mismo sobre las tres.

| Fixture | Commit | schemaVersion | Tablas nuevas |
|---------|--------|---------------|----------------|
| `v1.sqlite` | `de64402` | 1 | women (con `tag`), period_logs, ovulation_logs, symptoms, encounters, encounter_women, reminders |
| `v2.sqlite` | `7479fce` | 2 | + tags, woman_tags (women sin `tag`) |
| `v3.sqlite` | `0c86d66` | 3 | + alert_settings (fila con valores no default) |

## Regenerar

Nunca editar los `.sqlite` a mano. Regenerar con:

```bash
git worktree add --detach /tmp/toc16-v1 de64402
cd /tmp/toc16-v1
source /home/tochi/Proyectos/CalendarioMenstrual/.toolchain/env.sh
flutter pub get
# test/make_fixture_test.dart: abre AppDatabase.forTesting(NativeDatabase(<esta
> ruta>/vN.sqlite)), siembra los datos con drift y cierra.
flutter test test/make_fixture_test.dart
git worktree remove --force /tmp/toc16-v1
```

Repetir con `7479fce` (v2) y `0c86d66` (v3). El script generador vive solo
en el worktree temporal; esta receta es la fuente de verdad del sembrado.

## Datos sembrados (iguales en las tres versiones donde la tabla existe)

- 3 mujeres: Ana (tag `Amiga`), Berta (tag `Amiga` compartido, emoji/color/
  notas/orden no default), Clara (tag vacío en v1; `Familia` en v2/v3).
- 4 periodos (con/sin `end_date`, `flow_level` 1–3), 2 ovulaciones (una con
  temperatura/moco/LH), 2 síntomas, 1 encuentro con 2 mujeres (N:M), 2
  recordatorios (uno `enabled=false`).
- v1: los tags viven en `women.tag` → la migración v1→v2 debe hacer backfill.
- v3: `alert_settings` con `master_enabled=0, notify_hour=21, notify_minute=30,
  enabled_types='periodo,ovulacion', horizon_days=14`.
