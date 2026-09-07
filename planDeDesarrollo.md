# Plan Técnico — Calendario Menstrual (Flutter)

## 0. Contexto verificado

| Ítem | Estado |
|---|---|
| Proyecto | Solo `Especificaciones.md` (114 líneas) — fase pre-implementación |
| Flutter | **No instalado** (requiere `flutter` + Android SDK) |
| Java | OpenJDK 17 ✓ |
| Android SDK | No detectado (`ANDROID_HOME` vacío) |

**Decisión de stack:** Flutter + SQLite local (spec cumple con "SQLite o similar", sin nube, offline completo).

---

## 1. Arquitectura

**Feature-first + Clean separación en 3 capas** por cada feature:

```
presentation/  → UI (screens, widgets), widgets con Riverpod (estado)
domain/        → lógica pura de negocio (motor de predicción, reglas), sin dependencias de Flutter
data/          → drift (SQLite), repositorios que exponen streams a Riverpod
```

**Flujo:** UI → `Notifier` (Riverpod) → `Repository` → drift table/dao → SQLite.

---

## 2. Dependencias

| Paquete | Uso |
|---|---|
| `flutter_riverpod` | State management |
| `drift` + `sqlite3_flutter_libs` + `path_provider` | BD SQLite con streaming |
| `flutter_local_notifications` + `timezone` | Alertas/notificaciones |
| `table_calendar` | Vistas semana/mes |
| `fl_chart` | Reportes/estadísticas |
| `csv` + `pdf` + `file_picker` + `share_plus` | Export/import (JSON/CSV/PDF) |
| `intl` | Fechas/es-ES |
| `go_router` | Navegación |
| `ReorderableListView` (nativo) | Orden de perfiles |
| `collection`, `meta` | Utilidades drift |

---

## 3. Esquema SQLite (tablas)

- **`women`** — id, name, initials, emoji, color, tag, private_notes, sort_order, created_at
- **`period_logs`** — id, woman_id→women, start_date, end_date?, flow_level (1-5), notes
- **`ovulation_logs`** — id, woman_id, date, temperature?, cervical_mucus?, lh_test?
- **`symptoms`** — id, woman_id, date, type (acné/pecho/cansancio/humor/antojos/abdominal), severity, notes
- **`encounters`** — id, date_time, protection (condón/pastilla/natural/ninguno), outcome?, notes
- **`encounter_women`** — id, encounter_id→encounters, woman_id→women, relationship_type (vaginal/oral/anal) *(junta N:M: un encuentro con varias mujeres)*
- **`reminders`** — id, woman_id, cycle_day_start, cycle_day_end, message, enabled

---

## 4. Motor de predicción (puro, testable en `domain/`)

- **Duración de ciclos:** diferencia entre inicios consecutivos de `period_logs`, por mujer.
- **Sin datos:** ciclo por defecto 28 (rango 24–32). Con ≥2 ciclos: usamos min/max/medio reales.
- **Fórmula spec:**
  - Inicio rango ovulación = `11 − (min − 10)`
  - Fin rango ovulación = `17 + (max − 14)`
- **Ventana fértil:** día ovulación estimado (media) `−5` días hasta `+2` días → se marca como **día de riesgo**.
- **Periodo previsto:** último inicio + duración media → próxima fecha de sangrado.
- Engine con **unit tests** (caso 28 días 24–32 de la spec, extremos, sin datos).

---

## 5. Fases de implementación (incremental)

| Fase | Contenido | Entregable |
|---|---|---|
| **0** | Instalar Flutter + Android SDK, `flutter create`, setup | Proyecto compila en emulador |
| **1** | Esquema drift completo + DAOs + tests del engine de predicción | Datos y lógica listos |
| **2** | Perfiles: CRUD, emoji/color, etiquetas, notas, orden drag&drop, filtro | Gestión de mujeres |
| **3** | Tracking: periodos, ovulación, síntomas, historial "timeline" por mujer | Registro completo |
| **4** | Encuentros multi-mujer (checkbox), protección, tipo relación, resultado, notas | Registro encuentros |
| **5** | Predicción en UI: ovulación, ventana fértil, días riesgo, periodo previsto | Predicción visible |
| **6** | Alertas/notificaciones (8 tipos de la spec) con `flutter_local_notifications` | Alertas |
| **7** | Vistas consolidadas: Semana, Mes, Fertilidad, Encuentros | Dashboard |
| **8** | Reportes/estadísticas (gráficos `fl_chart`) | Análisis |
| **9** | Export/import manual JSON+CSV+PDF, verificación del backup | Backup |
| **10** | Recordatorios personalizados, ajustes, pulido, iconos de app | Versión 1.0 |

*Orden pensado para que cada fase sea usable y testeable por sí sola.*

---

## 6. Riesgos / notas

- Flutter y Android SDK deben instalarse (sin ellos no se puede compilar ni testear).
- Notificaciones programadas requieren manejo de zonas horarias (`timezone`) con datos por horas en alarmas exactas.
- La integración con wearables (Google Fit) y notificaciones "push" remoto **no** aplican a una app offline local: las notificaciones serán locales (WorkManager/alarma). Lo señalo como interpretación.