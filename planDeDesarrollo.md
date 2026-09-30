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
| `table_calendar` | Vistas semana/mes | Instalado (3.2.1) |
| `fl_chart` | Reportes/estadísticas | `1.0.0`, Fase 8 — 1.1.x declara `vector_math ^2.1` pero usa API de 2.2 y no compila |
| `csv` + `pdf` + `archive` + `file_picker` | Backup manual: ZIP de CSV, informe PDF e import/export por el selector del sistema | Instalado, Fase 9 — `pdf` 3.11.3 (3.12.x pide `vector_math ^2.2`), `archive` 3.6.1 (pdf exige `<4.1`), `csv` 6.0.0 y `file_picker` 11.0.3 |
| `intl` | Fechas y localización es-ES | Instalado (0.20.2) + `flutter_localizations` |
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
  - Sin datos: días `11–17`.
  - Con ciclos reales, inicio: `11 − (28 − min)`.
  - Con ciclos reales, fin: `17 + (max − 28)`.
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
| **7** | Vistas consolidadas: Semana, Mes, Fertilidad y Encuentros | ✅ Completada | Dashboard |
| **8** | Reportes y estadísticas con gráficos | ✅ Completada | Análisis |
| **9** | Export/import manual JSON, CSV y PDF | ✅ Completada | Backup |
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

### Fase 7: plan (dashboard de vistas consolidadas)

**Rama:** `feature/fase-7-vistas` desde `develop`. **Schema:** sin cambios (sigue en v3); no hay migración ni código generado nuevo (solo métodos escritos a mano en DAOs existentes). **Alcances de commit:** `calendar` (principal), con `core`, `prediction` y `tracking` en los cambios que caen dentro de esas features.

#### Alcance (Especificaciones.md §6)

| Vista | Requisito | Contenido del entregable |
|---|---|---|
| Semana | Todos los perfiles en un mismo calendario | Cuadrícula de 7 días con marcas por mujer + panel del día seleccionado |
| Mes | Todos los perfiles en un mismo mes | Cuadrícula mensual con las mismas marcas y navegación mes a mes |
| Fertilidad | Qué mujeres están en ventana de fertilidad esta semana | Lista de mujeres cuya ventana intersecta la semana en curso, con fechas exactas |
| Encuentros | Encuentros por mujer (quién se acostó con quién) | Lista descendente de encuentros con filtro por mujer y contador |

#### Decisiones

- **D1 — Feature nueva.** Todo vive en `lib/features/calendar/` con las 3 capas habituales; el dashboard no se cuelga de `profiles`.
- **D2 — Cuadrícula.** `table_calendar ^3.2.1` (dry-run verificado: resuelve con Dart 3.8.1 y añade `intl 0.20.2` + `simple_gesture_detector 0.2.1`). Semana = `CalendarFormat.week`, Mes = `CalendarFormat.month`; un único widget compartido con el formato como parámetro, para no duplicar `calendarBuilders` ni el `eventLoader`.
- **D3 — Localización.** Se añaden `intl ^0.20.2` y `flutter_localizations`; `main()` pasa a `async` con `initializeDateFormatting('es_ES')` y `MaterialApp` declara `locale`, `supportedLocales` y los delegates. Descartado mapear meses/días a mano: serían dos tablas de nombres que mantener y no cubriría el layout interno del calendario.
- **D4 — Fase por fecha arbitraria.** `WomanPrediction` **no sirve**: `faseHoy`/`estadoRiesgo`/`pronostico` están anclados a `today` (`prediction_calculator.dart:72` y `:194-196`, que además solo proyecta hacia delante). Se crea `CycleTimeline` en `prediction/domain/cycle_timeline.dart`: proyecta ciclos reales (inicios registrados) y estimados (último inicio + `mediaCiclo · k`) hasta un horizonte y responde por fecha reutilizando `phaseForCycleDay` (`cycle_phase.dart:23`) y `PredictionEngine` (`prediction_engine.dart:27-52`). Vive en `prediction` porque es matemática de ciclo, no presentación; `calendar` la importa (precedente: `alert_rule_engine.dart:1-2`, `tracking_screen.dart:4-6`).
- **D5 — Marcas por día.** Agregación pura en `calendar/domain/` sobre tipos de dominio ya puros (`TrackingEvent`, `EncounterWithWomen`) más una proyección `CalendarWoman` de `WomanProfile` (este último vive en `data/` y no puede entrar en `domain/`). Los días de una ventana fértil proyectada se marcan `esEstimado: true` y la UI los pinta como estimados: una ventana pasada o futura es una proyección con la media, no un hecho registrado.
- **D6 — Lecturas multi-mujer.** Hoy no existe ninguna para tracking (solo `...ByWoman`). Se añaden `watchAllPeriodLogs()`, `watchAllOvulationLogs()` y `watchAllSymptomLogs()` a `TrackingDao` y se filtra por rango en memoria. Descartado `...Between(desde, hasta)`: re-suscribiría el stream en cada cambio de mes sin reducir el volumen real de un dataset personal.
- **D7 — Composición reactiva.** `CalendarRepository.watchBoard()` combina 5 streams (perfiles, periodos, ovulaciones, síntomas, encuentros). El único combinador del proyecto es privado (`tracking_repository.dart:41-85`); se extrae a `lib/core/async/combine_latest.dart` (`combineLatest2..5`) y `TrackingRepository` pasa a usarlo, en vez de añadir una tercera copia.
- **D8 — Navegación.** Sin `go_router` (no está instalado y no hace falta): el dashboard se abre desde un icono nuevo en el `AppBar` de `WomenListScreen`, junto a la campana de alertas (`women_list_screen.dart:27-30`). El mes visible y el día seleccionado son `State` local del widget; **"hoy" sale siempre de `predictionDayProvider`**, que ya se inyecta con `clockProvider` en tests.
- **D9 — Reutilización.** La vista Encuentros usa `EncounterCard` (`encounters/presentation/widgets/encounter_card.dart`), read-only con `onTap`/`onLongPress` opcionales, siguiendo el precedente de `tracking_screen.dart:5`.

#### Contratos nuevos

```dart
// lib/core/async/combine_latest.dart
Stream<R> combineLatest2<A, B, R>(Stream<A>, Stream<B>, R Function(A, B));
Stream<R> combineLatest3<A, B, C, R>(Stream<A>, Stream<B>, Stream<C>, R Function(A, B, C));
Stream<R> combineLatest4<A, B, C, D, R>(…);
Stream<R> combineLatest5<A, B, C, D, E, R>(…);

// lib/features/prediction/domain/cycle_timeline.dart
class CycleSpan { DateTime start, periodEnd, ovulation, fertileStart, fertileEnd; bool esReal; }
class CycleTimeline {
  factory CycleTimeline.from({required List<PeriodLogInput> logs, required DateTime horizonte, PredictionEngine? engine});
  List<CycleSpan> get spans;
  CycleSpan? spanFor(DateTime day);
  CyclePhase? phaseOn(DateTime day);   // null cuando no hay datos
  bool isPeriodOn(DateTime day);
  bool isFertileOn(DateTime day);
  bool isOvulationOn(DateTime day);
  bool isEstimatedOn(DateTime day);
  DateTime? nextFertileStart(DateTime from);
}

// lib/features/calendar/domain/calendar_board.dart
class CalendarWoman { int id; String name, initials, emoji; int color; }
class WomanCalendar { CalendarWoman woman; CycleTimeline timeline; List<TrackingEvent> eventos; }
class CalendarBoard { List<WomanCalendar> women; List<EncounterWithWomen> encuentros; }
enum DayMarkKind { menstruacion, ventanaFertil, ovulacion, ovulacionRegistrada, sintoma, encuentro }
class DayMark { int womanId, color; DayMarkKind kind; bool esEstimado; }
class DayDetail { CalendarWoman woman; CyclePhase? fase; bool fertil; List<TrackingEvent> eventos; }

Map<DateTime, List<DayMark>> marksByDay(CalendarBoard board, DateTime desde, DateTime hasta);
List<DayDetail> detailsFor(CalendarBoard board, DateTime day);
List<WomanCalendar> fertileInWeek(CalendarBoard board, DateTime weekStart);

// lib/features/calendar/data/calendar_repository.dart
class CalendarRepository {
  CalendarRepository({required WomenRepository womenRepo, required TrackingDao trackingDao,
                      required EncounterRepository encounterRepo, PredictionEngine? engine});
  Stream<CalendarBoard> watchBoard({required DateTime today, Duration horizonte = const Duration(days: 550)});
}

// lib/features/calendar/presentation/providers/calendar_providers.dart
Provider<CalendarRepository> calendarRepositoryProvider;
StreamProvider.autoDispose<CalendarBoard> calendarBoardProvider;  // depende de predictionDayProvider
```

#### Ficheros

Nuevos: `lib/core/async/combine_latest.dart`; `lib/features/prediction/domain/cycle_timeline.dart`; `lib/features/calendar/domain/{calendar_board.dart,day_mark.dart}`; `lib/features/calendar/data/calendar_repository.dart`; `lib/features/calendar/presentation/providers/calendar_providers.dart`; `lib/features/calendar/presentation/screens/calendar_home_screen.dart`; `lib/features/calendar/presentation/views/{week_view.dart,month_view.dart,fertility_view.dart,encounters_view.dart}`; `lib/features/calendar/presentation/widgets/{board_calendar.dart,day_detail_panel.dart,calendar_legend.dart}`.

Modificados: `pubspec.yaml` (deps), `lib/main.dart` (locale + `initializeDateFormatting`), `lib/features/tracking/data/tracking_dao.dart` (3 lecturas globales), `lib/features/tracking/data/tracking_repository.dart` (usar el combinador de core), `lib/features/profiles/presentation/screens/women_list_screen.dart` (icono de entrada).

#### Olas

1. **Ola 0 — dependencias y localización.** `pubspec.yaml` + `main.dart`; `test/widget_test.dart` sigue verde.
   *Criterio:* `flutter test` verde y `MaterialApp` con `es_ES` (el test de arranque lo verifica).
2. **Ola 1 — `CycleTimeline`.** Timeline pura + `test/features/prediction/domain/cycle_timeline_test.dart`.
   *Criterio:* fase, ventana fértil, ovulación y menstruación correctas por fecha en rangos pasados y futuros; sin datos → todo `false`/`null`; fronteras (primer y último día de ventana, cambio de mes y de ciclo) y `esEstimado` distinguiendo periodos reales de proyectados.
3. **Ola 2 — lecturas globales, dominio y datos de calendar.** 3 métodos en `TrackingDao`, extracción de `combineLatest`, `calendar_board.dart`, `day_mark.dart`, `CalendarRepository` y providers. Tests: `calendar_board_test.dart` (agregación pura) y `calendar_repository_test.dart` (reactividad con DB en memoria: insertar periodo/ovulación/síntoma/encuentro re-emite).
   *Criterio:* una sola suscripción alimenta todo el dashboard; dos mujeres el mismo día producen dos marcas; un encuentro de dos mujeres marca el día para ambas; cambiar un dato emite un board nuevo sin consultas por mujer (N+1 evitado).
4. **Ola 3 — vistas Semana y Mes.** `board_calendar.dart` compartido, `day_detail_panel.dart`, `calendar_legend.dart`, `calendar_home_screen.dart` con `TabBar`, `week_view.dart`, `month_view.dart`. Tests: `calendar_home_test.dart` y `week_month_view_test.dart` con `clockProvider` fijado.
   *Criterio:* 7 días / mes completo con marcas por color de mujer (máx. 4 puntos + «+N»); seleccionar un día muestra fase y eventos de cada mujer; navegar de mes no vuelve a consultar la DB; mes sin datos se ve vacío sin crash.
5. **Ola 4 — vista Fertilidad.** `fertility_view.dart` + `fertility_view_test.dart`.
   *Criterio:* solo aparecen mujeres con ventana fértil que intersecta la semana en curso, con fechas exactas y etiqueta «estimado» cuando no hay ciclos reales; estado vacío con copy en español.
6. **Ola 5 — vista Encuentros.** `encounters_view.dart` + `encounters_view_test.dart`.
   *Criterio:* lista descendente reutilizando `EncounterCard`; chips «Todas» + una por mujer con contador; el filtro reduce la lista; estado vacío.
7. **Ola 6 — entrada al dashboard.** Icono en `WomenListScreen` + test de navegación (pulsa el icono y verifica que se monta `CalendarHomeScreen` con las 4 pestañas).
8. **Ola 7 — cierre.** `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, y `docs(calendar)` actualizando esta sección con el resultado real (patrón de `fixs.md`).

#### Extensiones del andamiaje de tests

`test/support/widget_harness.dart` gana `seedOvulation`, `seedSymptom` y un override de reloj fijo (`clockProvider`) para fechas deterministas. Se respetan las reglas vigentes: sembrar y leer dentro de `runReal`, cerrar con `closeTestDatabase` dentro del cuerpo del test, y `ensureVisible` + `pump` antes de pulsar widgets al final de un scroll.

#### Riesgos y límites aceptados

- Las ventanas fértiles de ciclos pasados o futuros son proyecciones con la media; se marcan como estimadas y la UI no las presenta como hechos.
- Horizonte de proyección de ~18 meses hacia delante: más allá no se pintan marcas estimadas (se documenta en la leyenda, no es un error).
- Sin rutas nombradas no hay deep links a una vista concreta; se asume (fuera de alcance).
- Mes con muchas mujeres: se limitan los puntos por día a 4 + contador para no romper el layout.
- `table_calendar` queda pineado; no se actualiza sin actualizar Dart.

### Fase 7: resultado

Cerrada en la rama `feature/fase-7-vistas` con **11 commits** y **55 tests nuevos** (257 en total), `flutter analyze` limpio y `flutter build apk --debug` correcto. Schema sin cambios (v3), sin migración ni código generado nuevo.

| Vista | Pestaña | Implementación |
|---|---|---|
| Semana | `Semana` | `BoardCalendar` en `CalendarFormat.week` + panel del día seleccionado |
| Mes | `Mes` | `BoardCalendar` en `CalendarFormat.month` |
| Fertilidad | `Fertilidad` | `FertilityView`: ventana que intersecta la semana, fechas, ovulación y cuenta atrás |
| Encuentros | `Encuentros` | `EncountersBoardView`: `EncounterCard` reutilizada y chips «Todas» + una por mujer con contador |

Entrada: icono `calendar_month_outlined` en el `AppBar` de `WomenListScreen`, junto a la campana de alertas. Composición: una única suscripción a los cinco streams globales (perfiles, periodos, ovulaciones, síntomas, encuentros) mediante `combineLatest5` en `lib/core/async/combine_latest.dart`.

Desviaciones respecto al plan, todas por simplificación y sin recortar alcance:

- Una sola `BoardView` con el `CalendarFormat` como parámetro, en lugar de `week_view.dart` + `month_view.dart`: los dos envoltorios no aportaban nada.
- `DayDetail` añade `encuentros` y `esEstimado`: el panel debía mostrar con quién se acostó ese día y distinguir las proyecciones.
- `fertileInWeek` devuelve `FertileWeekEntry` (mujer, fechas de la ventana, ovulación y `esEstimado`) en lugar de `WomanCalendar`, porque la vista necesita las fechas exactas.
- `startOfWeek` se añadió al dominio para que la vista y los tests compartan el criterio de lunes.
- El dashboard abre con dos pestañas y las olas 4 y 5 añaden la tercera y la cuarta, para no dejar pestañas vacías en ningún commit.
- Las marcas se calculan para el mes enfocado ± 45 días en cada build; si el número de perfiles o registros creciera, el siguiente paso sería memoizar por mes visible y mover el filtro de rango a SQL.

Límites que se mantienen: proyección de ciclos a ~18 meses (`CalendarRepository.defaultHorizonte`), máximo 4 glifos por celda y «+N», ventanas de ciclos proyectados atenuadas y etiquetadas como estimadas, y ausencia de deep links (sin `go_router`).

### Fase 8: plan (reportes y estadísticas)

**Rama:** `feature/fase-8-reportes` desde `develop`. **Schema:** sin cambios (sigue en v3); no hay migración ni código generado nuevo. **Alcances de commit:** `reports` (principal), con `calendar` en la extensión del tablero.

#### Alcance (Especificaciones.md §9)

| Punto de la spec | Entregable |
|---|---|
| Por mujer: gráficos de ciclos, duración media, síntomas recurrentes | Evolución de la duración del ciclo (línea), KPIs de duración media/mín/máx, síntomas ordenados por frecuencia (barras) |
| Por encuentro: resumen de encuentros por mujer (quién participó) | Barras de encuentros por mujer + reparto por tipo de protección + lista con total, último y resultados |
| Por mes: resumen de fertilidad y encuentros | Últimos 12 meses: encuentros, sin protección, días fértiles y periodos iniciados |
| Globales: días de fertilidad total, encuentros sin protección, etc. | KPIs: perfiles, ciclos, media de ciclo, encuentros, % sin protección, días fértiles en 12 meses y mujer con más encuentros |

#### Decisiones

- **D1 — Una sola fuente de datos.** Los reportes reutilizan `calendarBoardProvider` en lugar de componer su propio agregado. Para ello `WomanCalendar` gana `periodos` (`List<PeriodLogInput>`), que es lo único que faltaba: el tablero ya trae perfiles, líneas temporales, ovulaciones, síntomas y encuentros. Descartado un `ReportsRepository` con su propia combinación de los cinco streams: serían dos fuentes de verdad del mismo agregado (precedente de composición cross-feature: `alerts`). Si aparece un tercer consumidor, se extrae un lector compartido.
- **D2 — Todo el cálculo en dominio puro.** `reports/domain/` produce series y agregados como datos (`PuntoSerie`, `BarraValor`, `ReportKpis`); los widgets solo los pintan. Los gráficos no son testeables, los números sí: es la única forma de verificar de verdad un reporte (y cumple la regla de tests obligatorios en `domain/`).
- **D3 — `fl_chart` 1.0.0, pin exacto.** La resolución de versiones deja instalar 1.1.0 (declara `vector_math ^2.1`), pero **no compila**: usa `Matrix4.translateByDouble`, que solo existe en vector_math 2.2, y el SDK 3.32.7 fija 2.1.4. `flutter analyze` no lo detecta porque no analiza el código de las dependencias; lo destapó la compilación del primer test de widget. `fl_chart >=1.1.1` directamente no resuelve. Con `^1.0.0` pub volvería a elegir 1.1.0, por eso el pin es exacto: no se sube sin subir Flutter.
- **D4 — Ventana fija de 12 meses** (y últimos 12 ciclos por mujer). Sin selector de rango: la spec no lo pide y añadirlo multiplica estados y tests. Documentado como límite.
- **D5 — Tipos de gráfico acotados:** `LineChart` (duración del ciclo), `BarChart` (síntomas, encuentros por mes y por mujer), `PieChart` (reparto de protección) y tarjetas de KPI. Sin `RadarChart` ni `ScatterChart`: no aportan a lo pedido.
- **D6 — Selector de mujer** (`Todas` + una por perfil) en la propia pantalla: con «Todas» se ven los globales, el resumen por mes y los encuentros por mujer; al elegir una mujer, sus ciclos, sus síntomas y sus encuentros. Es lo que permite cubrir «por mujer» y «global» sin dos pantallas.
- **D7 — «Sin protección» = `protección == 'Ninguno'`.** «Natural» no se reinterpreta como sin protección: el reparto completo por tipo está en el gráfico de protección, y la tarjeta indica la definición.
- **D8 — Sin exportar.** CSV/PDF son la fase 9; esta fase solo agrega y pinta.
- **D9 — Entrada:** icono `insights_outlined` en el `AppBar` de `WomenListScreen`, junto al calendario y las alertas. Con cuatro acciones el `AppBar` queda justo en pantallas estrechas: si molesta, la fase 10 las colapsa en un menú overflow (nota, no trabajo de esta fase).

#### Contratos nuevos

```dart
// lib/features/reports/domain/report_models.dart
class PuntoSerie { final DateTime fecha; final double valor; }
class BarraValor { final String etiqueta; final double valor; }
class ReportKpis {
  int perfiles, ciclos, encuentros, encuentrosSinProteccion, diasFertilesAnio;
  double mediaCiclo, mediaMenstruacion, porcentajeSinProteccion;
  String? mujerConMasEncuentros; int maxEncuentros;
}
class WomanReport {
  CalendarWoman woman; ReportKpis kpis; List<PuntoSerie> ciclos;
  List<BarraValor> sintomas; DateTime? proximoPeriodo;
  List<BarraValor> proteccion; List<EncounterWithWomen> encuentros;
}
class MonthReport {
  DateTime mes; int encuentros, sinProteccion, diasFertiles, periodos;
}
class ReportsBoard {
  ReportKpis globales; ReportKpis? mujerSeleccionada; List<WomanReport> mujeres;
  List<MonthReport> meses; List<BarraValor> proteccion; List<BarraValor> encuentrosPorMujer;
}

ReportsBoard buildReports(CalendarBoard board, {required DateTime today, int meses = 12});

// lib/features/reports/presentation/providers/reports_providers.dart
final selectedWomanProvider = NotifierProvider<SelectedWomanNotifier, int?>;  // null = Todas
final reportsBoardProvider = Provider<AsyncValue<ReportsBoard>>;  // whenData sobre calendarBoardProvider + predictionDayProvider
```

Y en `lib/features/calendar/domain/calendar_board.dart`: `WomanCalendar` gana `List<PeriodLogInput> periodos` (poblado por `CalendarRepository` desde `watchAllPeriodLogs()`).

#### Ficheros

Nuevos: `lib/features/reports/domain/{report_models.dart,report_builder.dart}`; `lib/features/reports/presentation/providers/reports_providers.dart`; `lib/features/reports/presentation/screens/reports_screen.dart`; `lib/features/reports/presentation/widgets/{kpi_card.dart,ciclos_chart.dart,sintomas_chart.dart,meses_chart.dart,proteccion_chart.dart,encuentros_por_mujer_chart.dart}`.

Modificados: `pubspec.yaml` (`fl_chart`), `lib/features/calendar/domain/calendar_board.dart` y `lib/features/calendar/data/calendar_repository.dart` (periodos en el tablero), `lib/features/profiles/presentation/screens/women_list_screen.dart` (icono de entrada).

#### Olas

1. **Ola 0 — dependencia y periodos en el tablero.** `fl_chart ^1.1.0` + `WomanCalendar.periodos` (+ el poblado en `CalendarRepository`). *Criterio:* los tests del tablero siguen verdes y uno nuevo comprueba que cada mujer llega con sus periodos normalizados.
2. **Ola 1 — dominio de reportes.** `buildReports` con todas las series y KPIs + `test/features/reports/domain/report_builder_test.dart`. *Criterio:* duración de ciclo por ciclo y media/mín/máx correctas; síntomas ordenados por frecuencia y con severidad media; ventana de 12 meses con corte exacto (13 meses atrás queda fuera); agregado de encuentros con «sin protección» = «Ninguno»; días fértiles por mes contados con la línea temporal; sin datos → series vacías y KPIs a cero; un solo ciclo → línea sin puntos.
3. **Ola 2 — pantalla, KPIs y sección por mujer.** `reports_screen.dart` con el selector, tarjetas de KPI y los gráficos de ciclos y síntomas. Tests: `reports_screen_test.dart` (KPIs con datos sembrados, `LineChart`/`BarChart` presentes, el selector cambia el contenido, estado vacío sin perfiles).
4. **Ola 3 — mes, encuentros y globales.** Gráfico de meses con encuentros y sin protección, reparto de protección, encuentros por mujer y KPIs globales + tests.
5. **Ola 4 — entrada desde la lista de perfiles.** Icono + test de navegación.
6. **Ola 5 — cierre.** `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug` y `docs(reports)` con el resultado real (patrón de la fase 7).

#### Riesgos y límites aceptados

- `fl_chart` queda pineado en 1.0.0 mientras el SDK fije `vector_math 2.1.4`.
- Ventana fija de 12 meses, sin selector de rango; los meses anteriores al primer registro salen a cero (no es un error).
- La verificación de los gráficos es por presencia de widget y por el dominio: **no hay golden tests**, así que la forma exacta de las curvas se valida a mano sobre el APK.
- Los reportes heredan los límites del tablero: horizonte de ~18 meses para lo proyectado y filtrado por rango en memoria.
- Con cuatro acciones en el `AppBar` la cabecera queda justa en pantallas estrechas (se colapsa en la fase 10 si hace falta).

### Fase 8: resultado

Cerrada en la rama `feature/fase-8-reportes` con **9 commits** y **26 tests nuevos** (283 en total), `flutter analyze` limpio y `flutter build apk --debug` correcto. Schema sin cambios (v3), sin migración ni codegen. Los reportes se calculan sobre el tablero consolidado (extendido con los periodos registrados de cada mujer): una sola fuente de datos, sin un segundo agregado de los mismos cinco streams.

| Punto de la spec | Implementación |
|---|---|
| Por mujer | KPIs (ciclos, duración media de ciclo y menstruación, encuentros, sin protección, días fértiles, próximo periodo) + `LineChart` de duración por ciclo + `BarChart` de síntomas recurrentes |
| Por encuentro | `BarChart` de encuentros por mujer (con ceros) + `PieChart` de reparto por protección |
| Por mes | `BarChart` de encuentros y sin protección por mes + detalle de los 12 meses con días fértiles y periodos |
| Globales | KPIs de perfiles, ciclos, medias, encuentros, % sin protección, días fértiles y perfil con más encuentros |

Ventanas, explícitas en cada tarjeta: ciclos, medias y series usan **todo el historial** (la línea se recorta a 12 ciclos); encuentros, protección, síntomas, periodos y días fértiles usan los **últimos 12 meses naturales**, mes en curso incluido y con días fértiles proyectados.

Hallazgo relevante, aplicable a las fases siguientes: **`fl_chart` 1.1.0 no compila con el `vector_math 2.1.4` que fija el SDK** (usa `Matrix4.translateByDouble`, API de 2.2). `dart pub add --dry-run` lo daba por bueno porque la restricción declarada permite 2.1, y `flutter analyze` tampoco lo detecta porque no analiza el código de las dependencias: lo destapó la compilación del primer test de widget. El pin es exacto en **1.0.0** (con `^1.0.0` pub volvería a elegir 1.1.0, y 1.1.1+ ni resuelve). Lección: toda dependencia nueva se valida compilando un test **y** el APK, no solo resolviendo versiones.

Desviaciones respecto al plan, por simplificación y sin recortar alcance:

- Los cinco gráficos viven en `report_charts.dart` y las tarjetas en `kpi_card.dart`, en lugar de seis ficheros: comparten estilo, ejes y leyenda.
- Las secciones de la pantalla son widgets privados de `reports_screen.dart` (solo se usan ahí).
- El informe individual no lista sus encuentros (los KPIs y el reparto de protección los resumen; el listado está en la pestaña Encuentros del calendario).
- Caso límite explícito: si una mujer tiene menos de dos ciclos cerrados, el gráfico de línea avisa en lugar de dibujar un punto suelto.

Límites que se mantienen: ventana fija de 12 meses sin selector de rango, sin golden tests (la forma exacta de las curvas se valida a mano sobre el APK; los tests cubren los números y la presencia de los gráficos), y el `AppBar` de la lista de perfiles acumula ya cuatro acciones.

### Fase 9: resultado

Cerrada en la rama `feature/fase-9-backup` con **4 commits** y **51 tests nuevos** (335 en total), `flutter analyze` limpio y `flutter build apk --debug` correcto. Schema sin cambios (v3), sin migración ni codegen: la copia se hace con `select` de drift y se restaura con los `Companion` generados.

| Punto de la spec | Implementación |
|---|---|
| Copiar toda la base a un archivo local (JSON, CSV, PDF) | Pantalla propia con tres exportaciones: JSON completo, ZIP con un CSV por tabla (`manifest.json` incluido) e informe PDF A4 |
| Importar desde un archivo | Solo JSON, el único formato completo y sin pérdidas; validación estricta y confirmación explícita antes de sustituir |

Arquitectura: `domain/backup_document.dart` define el esquema de la copia (10 tablas, columnas con el nombre SQL drift, fecha `YYYY-MM-DD` e instante ISO local) y valida con mensajes en español; `data/backup_serializer.dart` traduce filas drift ↔ mapas JSON; `domain/csv_export.dart` y `domain/pdf_report.dart` son puros (`csv`/`archive`/`pdf` lo son); `data/backup_repository.dart` compone y `data/backup_file_gateway.dart` aísla el selector del sistema (SAF en Android, mismo patrón que `NotificationScheduler`). Los bytes nunca tocan el disco: se entregan y se leen en memoria.

Detalles de comportamiento verificados con tests:

- **Ida y vuelta exacta.** Drift guarda `DateTime` como segundos unix y lo devuelve en local; ida y vuelta conserva el segundo y reconstruye el mapa completo, emojis y acentos incluidos.
- **Restauración atómica.** Un solo `transaction`: borrado de hijos a padres (`encounter_women` antes que `encounters`, porque esa FK no tiene cascade) e inserción de padres a hijos con los ids originales. Si algo falla (por ejemplo un `woman_tags` huérfano) revierte y la base destino queda intacta. Tras importar, `sqlite_sequence` avanza, así que un alta nueva recibe `maxId + 1`.
- **Singleton de alertas.** Si la copia no trae fila de `alert_settings`, se recrea la fila por defecto `id=1`.
- **Refresco tras importar.** `womenListProvider` (lee `.first`) y `availableTagsProvider` (cacheado) se refrescan a mano; las alertas se reprograman solas porque `AlertsCoordinator` escucha los cambios de las tablas relevantes.

Hallazgos relevantes:

- **`pdf` queda en 3.11.3, no en 3.12.** 3.12.x declara `vector_math ^2.2` y el SDK fija 2.1.4: mismo caso que `fl_chart` en la fase 8. Además `pdf` exige `archive >=3.4.0 <4.1.0`, así que el plan de añadir `archive ^4.3.0` no resuelve: se usa **`archive 3.6.1`**, que sí permite el ZIP en memoria (`ZipEncoder`/`ZipDecoder`) y evita el *fallback* de un único CSV.
- **`utf8.decode` descarta el BOM.** Los CSV del ZIP llevan `EF BB BF` en crudo (y así se verifica), pero `utf8.decode` elimina el `U+FEFF` de cabecera; recortar un carácter «de más» rompía el encabezado.
- **`ListToCsvConverter` escribe `null` literal** para las celdas nulas: los nulos se convierten a cadena vacía antes de convertir.
- **Fuentes del PDF.** Helvetica usa WinAnsi, así que todo el texto pasa por un saneador que sustituye lo que quede por encima de Latin-1 por `?`: los emojis de perfiles y notas no aparecen en el informe.
- **`pw.TableHelper.fromTextArray`** sustituye a `Table.fromTextArray`, ya deprecado.

Desviaciones respecto al plan, por simplificación y sin recortar alcance:

- **No se añade `share_plus`**: el selector de `FilePicker.saveFile` ya permite escribir en Descargas, Drive o cualquier proveedor registrado, y la spec solo pide copiar a un archivo local.
- `buildPdfBlocks` recibe solo `(documento, tablero)`: el `today` que pedía el plan era redundante, porque el tablero ya trae el próximo periodo calculado.
- `ImportSummary` devuelve solo los recuentos: la fecha de exportación ya la conoce quien aporta el documento.
- Las secciones del informe PDF van en bloques con subtítulo propio (`Periodos registrados`, `Síntomas (12 meses)`) en lugar de dos tablas bajo el mismo encabezado.

Límites aceptados: la restauración es destructiva (por eso pide confirmación y nunca se ejecuta sola); CSV y PDF son de solo lectura humana; el recorte del informe es de 200 encuentros y las notas de periodo se truncan a 60 caracteres; el `AppBar` de la lista de perfiles acumula ya cinco acciones (se colapsa en la fase 10, donde llega la pantalla de ajustes).

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
- La restauración de una copia sustituye todos los datos: se hace solo bajo confirmación explícita del usuario y dentro de una transacción, nunca de forma automática ni parcial.

El orden sigue siendo incremental: cada fase debe ser usable, testeable y mergeada a `develop` antes de comenzar la siguiente.
