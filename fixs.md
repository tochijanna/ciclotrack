# Backlog de Fixes

Hallazgos de la revisión técnica posterior a la Fase 6. Ordenados por impacto y riesgo.

F-01, F-02 y F-03 fueron corregidos en el ciclo de estabilización de alertas.

## Críticos

### F-01 — Inicializar notificaciones y solicitar permisos ✅ Resuelto

- **Archivos:** `lib/main.dart`, `lib/features/alerts/data/local_notification_scheduler.dart`
- **Problema:** `initialize()` y `requestPermission()` nunca se invocan.
- **Impacto:** en Android 13+ las notificaciones pueden no aparecer y el scheduler puede no estar inicializado.
- **Fix:** inicializar el scheduler durante el arranque de la aplicación y solicitar permisos mediante un flujo explícito desde la pantalla de alertas.
- **Pruebas:** verificar inicialización, permiso concedido/denegado y comportamiento sin permisos.

### F-02 — Unificar el significado de tipos de alerta vacíos ✅ Resuelto

- **Archivos:** `lib/features/alerts/domain/alert_settings.dart`, `lib/features/alerts/presentation/screens/alerts_screen.dart`, `lib/features/alerts/data/alerts_repository.dart`
- **Problema:** la UI interpreta `enabledTypes == ''` como todos activos, pero el dominio lo interpreta como ninguno.
- **Impacto:** una instalación nueva muestra alertas activadas pero no programa ninguna.
- **Fix:** definir una única política. Recomendación: normalizar una fila nueva a todos los tipos activos y persistir siempre el CSV completo.
- **Pruebas:** ajustes por defecto, desactivar el último tipo, recargar la pantalla y evaluar el motor.

### F-03 — Reprogramar alertas cuando cambien datos o ajustes ✅ Resuelto

- **Archivos:** `lib/features/alerts/data/alerts_repository.dart`, formularios de tracking y encuentros, `lib/features/alerts/presentation/screens/alerts_screen.dart`, `lib/main.dart`
- **Problema:** `refreshAlerts()` solo se ejecuta mediante botones manuales.
- **Impacto:** las notificaciones pendientes quedan obsoletas después de cambiar periodos, encuentros, hora o toggles.
- **Fix:** centralizar un servicio de refresco e invocarlo al arrancar, después de guardar/borrar periodos y encuentros, y después de modificar ajustes. Desactivar el maestro debe cancelar las pendientes inmediatamente.
- **Pruebas:** cambiar una fecha, borrar un encuentro, cambiar la hora y desactivar alertas; verificar que el scheduler refleja el nuevo estado.

## Alta

### F-04 — Corregir el momento de las alertas de “mañana” ✅ Resuelto

- **Archivo:** `lib/features/alerts/domain/alert_rule_engine.dart`
- **Problema:** las alertas de ovulación y periodo de mañana se programan para mañana aunque el texto avise sobre mañana.
- **Impacto:** el usuario recibe el aviso cuando el evento ya está ocurriendo.
- **Fix:** programar esas alertas para hoy a la hora configurada; si la hora ya pasó, programarlas inmediatamente o para el siguiente ciclo según la política elegida.
- **Pruebas:** comprobar `fireDate` para ovulación/periodo mañana antes y después de la hora configurada.

### F-05 — Normalizar fechas de tracking a día calendario ✅ Resuelto

- **Archivos:** formularios de tracking, `tracking_validators.dart`, `prediction_engine.dart`, `prediction_calculator.dart`
- **Problema:** algunos registros conservan la hora actual y otros se guardan a medianoche.
- **Impacto:** ciclos, duraciones y rangos pueden desplazarse un día; el mismo día puede parecer un rango inválido.
- **Fix:** normalizar fechas de periodo, ovulación y síntomas a `DateTime(year, month, day)` antes de persistir y comparar.
- **Pruebas:** inicios con horas distintas, fin el mismo día, duración inclusiva y cambios alrededor de medianoche.

### F-06 — Evitar periodos duplicados y solapados ✅ Resuelto

- **Archivos:** `lib/core/db/tables.dart`, dominio/repositorio de tracking
- **Problema:** no existe restricción ni validación para dos periodos iguales o solapados.
- **Impacto:** ciclos de cero o pocos días pueden invalidar predicciones y alertas.
- **Fix:** validar por mujer: no duplicar `startDate`, no solapar periodos y aceptar solo duraciones/ciclos dentro de límites razonables. Añadir índice único si se decide como regla permanente.
- **Pruebas:** duplicado exacto, solapamiento, ciclo mínimo, ciclo extremo y edición de un registro existente.

### F-07 — Evitar duplicados por doble envío ✅ Resuelto

- **Archivos:** formularios de perfiles, tracking y encuentros
- **Problema:** los botones Guardar permanecen activos durante operaciones asíncronas.
- **Impacto:** doble inserción y múltiples `Navigator.pop()`.
- **Fix:** añadir estado `_saving`, deshabilitar botones durante la operación, capturar errores y cerrar solo si la operación termina correctamente.
- **Pruebas:** doble tap rápido, error del repositorio y guardado correcto.

### F-08 — Eliminar encuentros sin participantes al borrar una mujer ✅ Resuelto

- **Archivo:** `lib/features/profiles/data/women_dao.dart`
- **Problema:** `deleteWomanCascade()` elimina las relaciones `encounter_women`, pero deja el encuentro padre vacío.
- **Impacto:** aparecen encuentros inválidos y se altera el cálculo de alertas.
- **Fix:** dentro de la misma transacción, identificar encuentros cuyo único participante es la mujer eliminada y borrarlos; conservar los encuentros que aún tengan otras participantes.
- **Pruebas:** encuentro con una participante, encuentro con dos participantes y borrado de una de ellas.

### F-09 — Reordenar correctamente con filtro activo ✅ Resuelto

- **Archivo:** `lib/features/profiles/presentation/screens/women_list_screen.dart`
- **Problema:** se reasignan posiciones desde cero usando solo la lista filtrada.
- **Impacto:** se alteran perfiles ocultos y puede haber colisiones de `sortOrder`.
- **Fix:** deshabilitar drag & drop con filtro activo o reordenar la lista global manteniendo las posiciones de perfiles no visibles. Recomendación: deshabilitarlo mientras haya filtro.
- **Pruebas:** reordenación sin filtro, con filtro, limpiar filtro y comprobar orden global.

### F-10 — Implementar migraciones reales en tests ✅ Resuelto

- **Archivo:** `test/core/db/migration_test.dart`
- **Problema:** los tests crean directamente una base con schema actual y no ejecutan upgrades v1→v2→v3.
- **Impacto:** no se detectan errores al migrar datos reales ni pérdida de columnas/relaciones.
- **Fix:** crear una base SQLite con DDL v1/v2, insertar datos representativos, abrirla con `AppDatabase` v3 y verificar migración de tags, alert settings y claves foráneas.
- **Pruebas:** datos v1 con `women.tag`, datos v2 con tags N:M y migración final a v3.

## Media

### F-11 — Hacer reactivos tags y encuentros enriquecidos ✅ Resuelto

- **Archivos:** `women_dao.dart`, `women_repository.dart`, `encounter_dao.dart`, `encounter_repository.dart`
- **Problema:** `watchAllTags()` usa `get().asStream()` y los datos enriquecidos se cargan con `.first`.
- **Impacto:** cambios en tags, participantes o nombres no actualizan las pantallas abiertas.
- **Fix:** usar consultas Drift con joins reactivos o combinar streams correctamente.
- **Pruebas:** mantener una suscripción y modificar únicamente relaciones, nombres o colores.

### F-12 — Validar correctamente temperatura decimal ✅ Resuelto

- **Archivo:** `lib/features/tracking/presentation/screens/ovulation_form_screen.dart`
- **Problema:** cualquier texto no numérico se convierte en `null` y se acepta como campo vacío.
- **Impacto:** entradas como `abc` se guardan silenciosamente sin avisar.
- **Fix:** distinguir entre campo vacío y parseo fallido; aceptar coma decimal normalizándola a punto.
- **Pruebas:** vacío, `36.5`, `36,5`, `abc`, valores fuera de 34–40 °C.

### F-13 — Actualizar predicción al cambiar el día ✅ Resuelto

- **Archivo:** `lib/features/prediction/data/prediction_repository.dart`
- **Problema:** la predicción solo se recalcula al cambiar `period_logs`.
- **Impacto:** Tracking puede mostrar el estado de riesgo y fase del día anterior si permanece abierto durante la noche.
- **Fix:** invalidar al volver la app a foreground y añadir una señal de fecha al provider; no depender solo del stream de base de datos.
- **Pruebas:** cambiar el día inyectando `today`, resume de app y transición de ventana fértil/retraso.

### F-14 — Revisar rango de ovulación ✅ Resuelto

- **Archivos:** `prediction_engine.dart`, tests del motor, `Especificaciones.md`
- **Problema:** con defaults el rango puede ser 1–32, mientras la explicación visual de la spec muestra 11–17.
- **Impacto:** la UI puede mostrar un rango demasiado amplio y poco útil.
- **Fix:** confirmar la fórmula funcional con la spec y ajustar el cálculo o la documentación; actualizar tests después de decidir.
- **Pruebas:** defaults, ciclos cortos/largos y límites del rango.

### F-15 — Usar el final real del último periodo ✅ Resuelto

- **Archivo:** `prediction_calculator.dart`
- **Problema:** `periodoEnCurso` usa la duración media/default, aunque el último periodo tenga `endDate` explícito.
- **Impacto:** puede indicar periodo en curso después de que haya terminado.
- **Fix:** priorizar el `endDate` del último periodo cuando exista; usar la duración estimada solo para ciclos futuros.
- **Pruebas:** último periodo corto/largo con historial de duración diferente.

### F-16 — Garantizar singleton de `alert_settings` ✅ Resuelto

- **Archivos:** `tables.dart`, `alert_settings_dao.dart`, `alerts_providers.dart`
- **Problema:** la tabla permite varias filas y `ensureCreated()` no se espera antes de `getOrCreate()`.
- **Impacto:** pueden crearse múltiples filas de ajustes.
- **Fix:** imponer id fijo/clave única para la fila singleton y centralizar una operación `getOrCreate()` transaccional.
- **Pruebas:** acceso concurrente inicial y comprobación de una sola fila.

### F-17 — Hacer segura la reprogramación de notificaciones ✅ Resuelto

- **Archivo:** `lib/features/alerts/data/alerts_repository.dart`
- **Problema:** primero se ejecuta `cancelAll()` y después se programan alertas una a una.
- **Impacto:** un fallo intermedio deja al usuario sin alertas o con un conjunto parcial.
- **Fix:** calcular y validar primero; programar el conjunto nuevo; cancelar ids obsoletos al final. Limitar cancelaciones al canal de CicloTrack.
- **Pruebas:** fallo del scheduler en mitad del lote, reintento e idempotencia.

### F-18 — Corregir participantes del mensaje multi-mujer ✅ Resuelto

- **Archivo:** `alert_rule_engine.dart`
- **Problema:** la regla comprueba dos mujeres fértiles, pero construye el mensaje con todas las participantes del encuentro.
- **Impacto:** el mensaje puede afirmar riesgo para una mujer que no está fértil.
- **Fix:** separar participantes fértiles de no fértiles y usar solo las fértiles en el texto y `womanIds` de la alerta.
- **Pruebas:** encuentro con tres mujeres, solo dos fértiles.

### F-19 — Ignorar tokens CSV desconocidos ✅ Resuelto

- **Archivo:** `lib/features/alerts/domain/alert_settings.dart`
- **Problema:** un token desconocido se transforma silenciosamente en `fertilidadInminente`.
- **Impacto:** una migración o configuración corrupta activa una alerta incorrecta.
- **Fix:** ignorar tokens desconocidos y, opcionalmente, registrar/normalizar la configuración.
- **Pruebas:** CSV vacío, válido, duplicado y con tipos inexistentes.

### F-20 — Volcado transaccional y límite de tamaño al importar ✅ Resuelto (TOC-17)

- **Archivo:** `lib/features/backup/data/backup_serializer.dart`, `lib/features/backup/domain/backup_document.dart`
- **Problema:** `dumpDatabase()` lanzaba once `SELECT` sueltos sin transacción; al ser la app mono-isolate, una escritura del usuario o del planificador podía colarse entre dos tablas y la copia salía con huérfanos o filas perdidas. Además, el import aceptaba cualquier tamaño de archivo: el `jsonDecode` de un fichero enorme podía tumbar la app por memoria.
- **Impacto:** una copia exportada durante uso activo no siempre restauraba los datos tal como estaban al pulsar «Exportar».
- **Fix:** las once lecturas corren dentro de `db.transaction()` (snapshot atómico, las escrituras externas quedan en cola hasta el commit). El import rechaza antes de decodificar todo archivo mayor que `backupMaxBytes` (8 MB) con el nuevo `BackupFormatError.tooLarge` y su texto en es/en. La medición (base sintética de 4 497 filas: JSON de 927 kB, export 89 ms, import 134 ms, pico de RSS +27 MB) justifica el tope: ×8 sobre el peor caso realista (~2 MB) con pico acotado a ~200 MB.
- **Pruebas:** volcados concurrentes con altas en bucle, comprobando que cada copia sale referencialmente cerrada; archivo sobre el tope → `tooLarge`; ida y vuelta dump → JSON → restore → dump con las once tablas (incluida `medications`) idénticas.

## Cobertura — plan de trabajo y resultado

### Estado de partida (rama `feature/coverage-backlog`, 2026-09-29)

`flutter test`: 159 pasan, 4 fallan. `flutter analyze`: 2 errores.

- `test/features/tracking/presentation/tracking_forms_test.dart` **no compila**: `unchecked_use_of_nullable_value` en líneas 30 y 73 (el retorno de `tester.runAsync` es `T?`).
- `test/features/encounters/presentation/encounters_screen_test.dart` falla con `A Timer is still pending even after the widget tree was disposed` y agota el timeout de 10 minutos.
  - Causa raíz: drift difiere el cierre de las consultas observadas con `Timer.run` (`drift/lib/src/runtime/executor/stream_queries.dart:154`, comentario explícito sobre tests de widgets). Con `addTearDown(db.close)` el `close()` se ejecuta cuando el `FakeAsync` del test ya terminó y el tick nunca corre.
  - Patrón correcto ya establecido en `test/features/tracking/presentation/tracking_screen_test.dart`: sembrar y leer la DB dentro de `await tester.runAsync(...)`, renderizar con `pump()` + `pump(const Duration(milliseconds: 100))` y cerrar con `await tester.runAsync(() async { await db.close(); })` **al final del cuerpo del test**, nunca con `addTearDown`.
- Los tests añadidos en esta rama a `women_repository_test.dart` (reactividad de tags) y `encounter_repository_test.dart` (reactividad de participantes) sí pasan.

### Resultado (misma fecha)

- `flutter analyze`: 0 issues. `flutter test`: **202 tests, todos verdes** (11 s). `flutter build apk --debug`: OK.
- Los 9 puntos quedan cubiertos (detalle en la tabla y en las olas).
- Andamiaje nuevo: `test/support/widget_harness.dart` con base en memoria, montaje con `appDatabaseProvider` overridado, siembra de mujeres/encuentros/periodos y cierre seguro.
- `lib/core/time/clock.dart` pasa a exportar `clockProvider`; `PredictionDayNotifier` ya no expone `refreshForTest()`.

Decisiones tomadas al ejecutar el plan:

- Los tests de doble envío y error de repositorio viven en el fichero de test de su propia pantalla (`tracking_forms_test.dart`, `encounters_screen_test.dart`, `woman_form_test.dart`), no en ficheros `*_submit_test.dart`.
- Reglas del andamiaje que hay que respetar en tests nuevos: cerrar la base con `closeTestDatabase` (nunca `addTearDown(db.close)`), usar `settleProviders` tras montar pantallas con `FutureProvider`, y hacer `ensureVisible` + `pump` antes de pulsar botones que viven al final de un `SingleChildScrollView`.
- `prediction_day_provider_test.dart` usa `test()` con `TestWidgetsFlutterBinding.ensureInitialized()` (no `testWidgets`): bajo el `FakeAsync` de `testWidgets` las consultas de drift no completan. El resume se simula con `WidgetsBinding.instance.handleAppLifecycleStateChanged(inactive)` + `resumed`, así que no queda API solo-para-tests en producción.

### Mapa de los 9 puntos

| ID | Punto del backlog | Estado | Evidencia |
| --- | --- | --- | --- |
| C-01 | Widget de formularios de tracking | Hecho | `tracking_forms_test.dart` (12 tests: guardado, edición, rango invertido, decimales, rango de temperatura, síntomas) |
| C-02 | Widget de encuentros | Hecho | `encounters_screen_test.dart` (8 tests: vacío, lista, borrado, cancelación, participantes, sin participantes, doble tap, error) |
| C-03 | Doble envío y errores de repositorio | Hecho | doble tap + fake que falla en `tracking_forms_test.dart`, `encounters_screen_test.dart` y `woman_form_test.dart` |
| C-04 | Reactividad de tags y encuentros enriquecidos | Hecho | `women_repository_test.dart` (10 tests), `encounter_repository_test.dart` (11) |
| C-05 | Timestamps con horas distintas y medianoche | Hecho | `tracking_repository_test.dart` (25 tests) |
| C-06 | Inicialización, permisos y reprogramación de notificaciones | Hecho | `alerts_coordinator_test.dart` (init, reprogramación, maestro off) + `alerts_screen_test.dart` (permiso concedido/denegado) |
| C-07 | Migración real v1→v2→v3 | Hecho | `migration_test.dart` (commit `54b043e`) |
| C-08 | Borrado de la única participante del encuentro | Hecho | `cascade_delete_test.dart:25,102` |
| C-09 | Cambio de día / resume en predicciones | Hecho | `prediction_day_provider_test.dart` (3 tests, incluye el cruce del límite de la ventana fértil) |

### Ola 0 — suite verde y base compartida (bloqueante) ✅ Hecho

1. Cerrar la DB siempre con `tester.runAsync` en los tests de widget; eliminar `addTearDown(db.close)` de los archivos nuevos.
2. Arreglar la nulabilidad de `tester.runAsync` en `tracking_forms_test.dart`.
3. Extraer el andamiaje repetido (`ProviderScope` con `appDatabaseProvider` overridado, siembra de mujeres, cierre de DB) a `test/support/widget_harness.dart` y reutilizarlo en los archivos de test de widget actuales y nuevos.

Criterio: `flutter analyze` limpio y `flutter test` verde antes de añadir casos nuevos.

### Ola 1 — C-01, C-02, C-03 (formularios, doble envío, errores) ✅ Hecho

`test/features/tracking/presentation/tracking_forms_test.dart`:

- Periodo: guarda normalizado, rango invertido (evento con `endDate` anterior) → SnackBar y sin persistir, edición de un periodo existente (`updatePeriodById`), doble tap → una sola fila. La fecha futura queda cubierta a nivel de dominio (`tracking_validators_test`): el `showDatePicker` no permite seleccionarla.
- Ovulación: `abc` rechazado, `36,5` → 36.5, `36.5` → 36.5, vacío permitido, `33` rechazado (el límite superior 41 se cubre en `tracking_validators_test`).
- Síntoma: tipo por defecto persistido, tipo elegido + notas.

`test/features/encounters/presentation/encounters_screen_test.dart`:

- Estado vacío (ya escrito, corregir cierre de DB), lista con tarjeta, borrado con confirmación (diálogo → `repo.delete` → lista vacía), cancelar borrado, formulario con 2 participantes (ya existe), 0 participantes → no guarda.

Doble envío y errores de repositorio (C-03), dentro del fichero de test de cada pantalla, sobrescribiendo `womenRepositoryProvider` / `trackingRepositoryProvider` / `encounterRepositoryProvider` con un fake que lance:

- Doble tap rápido en Guardar → una sola inserción; el camino de error deja el formulario abierto.
- Error del repositorio → SnackBar "No se pudo guardar …" y el formulario sigue en pantalla.
- Periodo duplicado: cubierto en `tracking_repository_test` (`PeriodConflictException`); la UI muestra el mismo SnackBar genérico.

### Ola 2 — C-04, C-05, C-06 (reactividad, fechas, notificaciones) ✅ Hecho

- C-04, `women_repository_test.dart`: emisión al cambiar nombre/color, al desvincular tags y al renombrar una etiqueta global (la consulta usa join con `tags`). `encounter_repository_test.dart`: emisión al quitar participantes y al cambiar el nombre de una participante (join con `women`), además de `watchByWoman`.
- C-05, `tracking_repository_test.dart`: `DateTime(2026,9,1,0,0)` y `DateTime(2026,9,1,23,59)` → mismo `startDate` normalizado; fin a las 00:00 del día siguiente con duración inclusiva; ciclos con inicios a horas distintas (normalizados por `calendarDate` en `tracking_validators.dart:13`) idénticos a los de medianoche; `validators` con `endDate` del día siguiente.
- C-06, `test/features/alerts/presentation/alerts_screen_test.dart`: maestro ON con `requestPermission() == false` → SnackBar "Permiso de notificaciones no concedido" y ajuste sin activar; con `true` → persiste y llama a `refreshNow()`. Fake de `notificationSchedulerProvider` con flag de permiso.
- C-06 (opcional): descartado. El fake de `NotificationScheduler` ya fija el contrato que consume el coordinador; el wrapper del plugin queda sin test de canal.
- C-04 no incluye el cambio de color (sí nombre, tags y nombre de participante) ni el caso de emisión al renombrar participante en `watchByWoman`; el resto de caminos están cubiertos.

### Ola 3 — C-09 (día y resume) ✅ Hecho

`test/features/prediction/presentation/prediction_day_provider_test.dart`:

- Con `clockProvider` (movido a `lib/core/time/clock.dart`) sobrescrito por un `FakeClock`: el estado inicial es la medianoche local del reloj.
- Avanzar el reloj un día y disparar `resume` → el estado pasa al día nuevo y `womanPredictionProvider` re-emite (3.er test: DB en memoria, cruce del inicio de la ventana fértil).
- El resume se simula con `WidgetsBinding.instance.handleAppLifecycleStateChanged(inactive)` + `resumed`, así que no hace falta hook `@visibleForTesting`; `refreshForTest()` se ha eliminado.
- `Clock`/`clockProvider` viven ya en `lib/core/time/`, listos para que otras features inyecten el reloj.

### Verificación por ola

```bash
source .toolchain/env.sh
dart format lib test
flutter analyze
flutter test
```

Commits sugeridos (Conventional Commits, un bloque por ola): `test(tracking): ...`, `test(encounters): ...`, `test(alerts): ...`, `test(prediction): ...`; el movimiento del reloj a core, en `refactor(prediction): ...`. C-07 y C-08 ya están cubiertos; no requieren trabajo nuevo.

## Orden recomendado

> Histórico: F-01 a F-19 están resueltos. El trabajo activo es el plan de cobertura anterior.

1. F-01, F-02, F-03 y F-04: hacer funcionales las alertas.
2. F-05, F-06 y F-07: corregir fechas, duplicados y doble envío.
3. F-08, F-09 y F-10: proteger integridad de datos y migraciones.
4. F-11 a F-19: completar reactividad, validaciones y calidad de mensajes.
5. Ejecutar tras cada bloque:

```bash
source .toolchain/env.sh
flutter analyze
flutter test
flutter build apk --debug
```
