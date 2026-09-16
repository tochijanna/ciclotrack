# Plan Técnico — Calendario Menstrual (Flutter)

## 0. Estado verificado

| Ítem | Estado |
|---|---|
| Proyecto | Flutter Android-only `ciclotrack`, en `develop` |
| Repositorio | GitHub: `https://github.com/tochijanna/ciclotrack.git` |
| Flutter | 3.32.7 en `.toolchain/` |
| Dart | 3.8.1 |
| Android SDK | 34/35 en `.toolchain/` |
| Java | OpenJDK 17 del sistema |
| Calidad | `flutter analyze` limpio, suite completa verde |
| APK debug | Compila correctamente |

Antes de cualquier comando Flutter/Dart:

```bash
source .toolchain/env.sh
```

La aplicación es 100 % local/offline. No utiliza nube, sincronización remota ni secretos.

---

## 1. Arquitectura

**Feature-first + separación en tres capas** por feature:

```
presentation/  → UI, pantallas, widgets y providers Riverpod
domain/        → lógica pura de negocio, sin Flutter ni Drift
data/          → DAOs, repositorios y acceso SQLite mediante Drift
```

Flujo principal:

```
UI → Provider/Notifier → Repository → DAO → Drift/SQLite
```

Las reglas de dominio requieren tests unitarios. Las fuentes reactivas usan `StreamProvider.autoDispose.family` cuando dependen de una mujer concreta.

---

## 2. Dependencias

| Paquete | Uso | Estado |
|---|---|---|
| `flutter_riverpod` | Estado y providers | Instalado |
| `drift` + `drift_flutter` | SQLite local y streams | Instalado, Drift 2.31.0 |
| `flutter_local_notifications` | Notificaciones locales | Instalado |
| `timezone` + `flutter_timezone` | Programación por zona horaria | Instalado |
| `table_calendar` | Vistas semana/mes | Pendiente, Fase 7 |
| `fl_chart` | Reportes/estadísticas | Pendiente, Fase 8 |
| `csv` + `pdf` + `file_picker` + `share_plus` | Backup manual | Pendiente, Fase 9 |
| `intl` | Fechas y localización es-ES | Pendiente según necesidad |
| `go_router` | Navegación avanzada | Pendiente según necesidad |
| `ReorderableListView` | Orden de perfiles | Nativo, implementado |

Después de modificar tablas o DAOs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

No actualizar Drift/Riverpod sin actualizar Dart: Drift está fijado en `2.31.0` para Dart 3.8.1.

---

## 3. Schema SQLite actual

Schema version **3**, con 10 tablas:

- **`women`** — perfiles, avatar, color, notas, orden y fecha de creación.
- **`tags`** — etiquetas únicas compartidas.
- **`woman_tags`** — relación N:M entre mujeres y etiquetas.
- **`period_logs`** — inicio, fin, flujo y notas por mujer.
- **`ovulation_logs`** — fecha, temperatura, moco cervical y LH.
- **`symptoms`** — tipo, fecha, intensidad y notas.
- **`encounters`** — fecha/hora, protección, resultado y notas.
- **`encounter_women`** — relación N:M encuentro-mujer con tipo de relación.
- **`reminders`** — recordatorios por día del ciclo.
- **`alert_settings`** — ajustes singleton de alertas: activación, hora, tipos y horizonte.

Las nuevas instalaciones tienen claves foráneas con cascade. Para bases antiguas, `WomenRepository.delete()` ejecuta una eliminación transaccional de todos los datos dependientes.

---

## 4. Predicción y ciclo

El motor puro está en `lib/features/prediction/domain/`.

- **Duración de ciclos:** diferencia entre inicios consecutivos de `period_logs`.
- **Sin datos:** ciclo por defecto 28, rango 24–32.
- **Con un solo periodo:** defaults con indicador de estimación por defecto.
- **Con ≥2 ciclos:** min/max/media reales.
- **Rango de ovulación:**
  - Inicio: `11 − (min − 10)`.
  - Fin: `17 + (max − 14)`.
- **Ventana fértil/riesgo:** ovulación estimada −5 días hasta +2 días.
- **Periodo previsto:** último inicio + duración media.
- **Fases:** menstruación, folicular, ventana fértil, ovulación, lútea, lútea tardía y retraso.
- **Humor/libido orientativos:** fase de ovulación → «Cachonda (pico)»; fase lútea tardía → «Irritable / mal humor».

La predicción se muestra en la tarjeta superior del tracking individual y se actualiza reactivamente al cambiar periodos.

---

## 5. Fases de implementación

| Fase | Contenido | Estado | Entregable |
|---|---|---|---|
| **0** | Flutter, Android SDK, scaffold y Gitflow | ✅ Completada | Proyecto funcional |
| **1** | Schema Drift, DAOs y motor de predicción | ✅ Completada | Datos y lógica base |
| **2** | Perfiles: CRUD, avatar, etiquetas, notas, orden y filtro | ✅ Completada | Gestión de mujeres |
| **3** | Tracking: periodos, ovulación, síntomas y timeline | ✅ Completada | Registro individual |
| **Estabilización** | Timeline reactiva, cascade transaccional y separación UI/data | ✅ Completada | Tracking robusto |
| **4** | Encuentros multi-mujer, protección, relación, resultado y notas | ✅ Completada | Registro de encuentros |
| **5** | Predicción visible, riesgo, fertilidad, periodo, humor y libido | ✅ Completada | Predicción por mujer |
| **6** | Alertas locales y ajustes persistidos en Drift | ✅ Completada | Notificaciones locales |
| **7** | Vistas consolidadas: Semana, Mes, Fertilidad y Encuentros | Pendiente | Dashboard |
| **8** | Reportes y estadísticas con gráficos | Pendiente | Análisis |
| **9** | Export/import manual JSON, CSV y PDF | Pendiente | Backup |
| **10** | Medicación, recordatorios personalizados, ajustes finales, iconos y pulido | Pendiente | Versión 1.0 |

### Fase 6: alcance actual

Implementadas 8 reglas de alerta automáticas:

1. Fertilidad inminente.
2. Día de riesgo.
3. Periodo inminente.
4. Fertilidad combinada.
5. Encuentro + fertilidad.
6. Advertencia post-encuentro.
7. Múltiples mujeres + fertilidad.
8. Ventana combinada.

La alerta de medicación se pospone a la Fase 10 porque requiere tabla y CRUD de medicamentos por mujer.

---

## 6. Verificación por fase

Antes de cada commit:

```bash
source .toolchain/env.sh
dart format lib test
flutter analyze
flutter test
```

Si se modifica configuración Android o plugins nativos:

```bash
flutter build apk --debug
```

Estado actual de calidad: análisis limpio, suite completa verde y APK debug compilable.

---

## 7. Riesgos y decisiones

- Las notificaciones exactas pueden requerir permiso adicional en Android 12+; el scheduler usa alarma exacta cuando está disponible y fallback inexacto en caso contrario.
- Las notificaciones locales deben reprogramarse al arrancar la aplicación y después de cambios en periodos o encuentros.
- Las predicciones de humor/libido son orientativas y se basan solo en la fase del ciclo; no representan certezas sobre una persona.
- La integración con wearables y las notificaciones push remotas no aplican al diseño offline actual.
- El backup manual debe incluir schema, perfiles, tracking, encuentros, ajustes y futuras configuraciones de alertas.

El orden sigue siendo incremental: cada fase debe ser usable, testeable y mergeada a `develop` antes de comenzar la siguiente.
