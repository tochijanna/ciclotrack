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

### F-04 — Corregir el momento de las alertas de “mañana”

- **Archivo:** `lib/features/alerts/domain/alert_rule_engine.dart`
- **Problema:** las alertas de ovulación y periodo de mañana se programan para mañana aunque el texto avise sobre mañana.
- **Impacto:** el usuario recibe el aviso cuando el evento ya está ocurriendo.
- **Fix:** programar esas alertas para hoy a la hora configurada; si la hora ya pasó, programarlas inmediatamente o para el siguiente ciclo según la política elegida.
- **Pruebas:** comprobar `fireDate` para ovulación/periodo mañana antes y después de la hora configurada.

### F-05 — Normalizar fechas de tracking a día calendario

- **Archivos:** formularios de tracking, `tracking_validators.dart`, `prediction_engine.dart`, `prediction_calculator.dart`
- **Problema:** algunos registros conservan la hora actual y otros se guardan a medianoche.
- **Impacto:** ciclos, duraciones y rangos pueden desplazarse un día; el mismo día puede parecer un rango inválido.
- **Fix:** normalizar fechas de periodo, ovulación y síntomas a `DateTime(year, month, day)` antes de persistir y comparar.
- **Pruebas:** inicios con horas distintas, fin el mismo día, duración inclusiva y cambios alrededor de medianoche.

### F-06 — Evitar periodos duplicados y solapados

- **Archivos:** `lib/core/db/tables.dart`, dominio/repositorio de tracking
- **Problema:** no existe restricción ni validación para dos periodos iguales o solapados.
- **Impacto:** ciclos de cero o pocos días pueden invalidar predicciones y alertas.
- **Fix:** validar por mujer: no duplicar `startDate`, no solapar periodos y aceptar solo duraciones/ciclos dentro de límites razonables. Añadir índice único si se decide como regla permanente.
- **Pruebas:** duplicado exacto, solapamiento, ciclo mínimo, ciclo extremo y edición de un registro existente.

### F-07 — Evitar duplicados por doble envío

- **Archivos:** formularios de perfiles, tracking y encuentros
- **Problema:** los botones Guardar permanecen activos durante operaciones asíncronas.
- **Impacto:** doble inserción y múltiples `Navigator.pop()`.
- **Fix:** añadir estado `_saving`, deshabilitar botones durante la operación, capturar errores y cerrar solo si la operación termina correctamente.
- **Pruebas:** doble tap rápido, error del repositorio y guardado correcto.

### F-08 — Eliminar encuentros sin participantes al borrar una mujer

- **Archivo:** `lib/features/profiles/data/women_dao.dart`
- **Problema:** `deleteWomanCascade()` elimina las relaciones `encounter_women`, pero deja el encuentro padre vacío.
- **Impacto:** aparecen encuentros inválidos y se altera el cálculo de alertas.
- **Fix:** dentro de la misma transacción, identificar encuentros cuyo único participante es la mujer eliminada y borrarlos; conservar los encuentros que aún tengan otras participantes.
- **Pruebas:** encuentro con una participante, encuentro con dos participantes y borrado de una de ellas.

### F-09 — Reordenar correctamente con filtro activo

- **Archivo:** `lib/features/profiles/presentation/screens/women_list_screen.dart`
- **Problema:** se reasignan posiciones desde cero usando solo la lista filtrada.
- **Impacto:** se alteran perfiles ocultos y puede haber colisiones de `sortOrder`.
- **Fix:** deshabilitar drag & drop con filtro activo o reordenar la lista global manteniendo las posiciones de perfiles no visibles. Recomendación: deshabilitarlo mientras haya filtro.
- **Pruebas:** reordenación sin filtro, con filtro, limpiar filtro y comprobar orden global.

### F-10 — Implementar migraciones reales en tests

- **Archivo:** `test/core/db/migration_test.dart`
- **Problema:** los tests crean directamente una base con schema actual y no ejecutan upgrades v1→v2→v3.
- **Impacto:** no se detectan errores al migrar datos reales ni pérdida de columnas/relaciones.
- **Fix:** crear una base SQLite con DDL v1/v2, insertar datos representativos, abrirla con `AppDatabase` v3 y verificar migración de tags, alert settings y claves foráneas.
- **Pruebas:** datos v1 con `women.tag`, datos v2 con tags N:M y migración final a v3.

## Media

### F-11 — Hacer reactivos tags y encuentros enriquecidos

- **Archivos:** `women_dao.dart`, `women_repository.dart`, `encounter_dao.dart`, `encounter_repository.dart`
- **Problema:** `watchAllTags()` usa `get().asStream()` y los datos enriquecidos se cargan con `.first`.
- **Impacto:** cambios en tags, participantes o nombres no actualizan las pantallas abiertas.
- **Fix:** usar consultas Drift con joins reactivos o combinar streams correctamente.
- **Pruebas:** mantener una suscripción y modificar únicamente relaciones, nombres o colores.

### F-12 — Validar correctamente temperatura decimal

- **Archivo:** `lib/features/tracking/presentation/screens/ovulation_form_screen.dart`
- **Problema:** cualquier texto no numérico se convierte en `null` y se acepta como campo vacío.
- **Impacto:** entradas como `abc` se guardan silenciosamente sin avisar.
- **Fix:** distinguir entre campo vacío y parseo fallido; aceptar coma decimal normalizándola a punto.
- **Pruebas:** vacío, `36.5`, `36,5`, `abc`, valores fuera de 34–40 °C.

### F-13 — Actualizar predicción al cambiar el día

- **Archivo:** `lib/features/prediction/data/prediction_repository.dart`
- **Problema:** la predicción solo se recalcula al cambiar `period_logs`.
- **Impacto:** Tracking puede mostrar el estado de riesgo y fase del día anterior si permanece abierto durante la noche.
- **Fix:** invalidar al volver la app a foreground y añadir una señal de fecha al provider; no depender solo del stream de base de datos.
- **Pruebas:** cambiar el día inyectando `today`, resume de app y transición de ventana fértil/retraso.

### F-14 — Revisar rango de ovulación

- **Archivos:** `prediction_engine.dart`, tests del motor, `Especificaciones.md`
- **Problema:** con defaults el rango puede ser 1–32, mientras la explicación visual de la spec muestra 11–17.
- **Impacto:** la UI puede mostrar un rango demasiado amplio y poco útil.
- **Fix:** confirmar la fórmula funcional con la spec y ajustar el cálculo o la documentación; actualizar tests después de decidir.
- **Pruebas:** defaults, ciclos cortos/largos y límites del rango.

### F-15 — Usar el final real del último periodo

- **Archivo:** `prediction_calculator.dart`
- **Problema:** `periodoEnCurso` usa la duración media/default, aunque el último periodo tenga `endDate` explícito.
- **Impacto:** puede indicar periodo en curso después de que haya terminado.
- **Fix:** priorizar el `endDate` del último periodo cuando exista; usar la duración estimada solo para ciclos futuros.
- **Pruebas:** último periodo corto/largo con historial de duración diferente.

### F-16 — Garantizar singleton de `alert_settings`

- **Archivos:** `tables.dart`, `alert_settings_dao.dart`, `alerts_providers.dart`
- **Problema:** la tabla permite varias filas y `ensureCreated()` no se espera antes de `getOrCreate()`.
- **Impacto:** pueden crearse múltiples filas de ajustes.
- **Fix:** imponer id fijo/clave única para la fila singleton y centralizar una operación `getOrCreate()` transaccional.
- **Pruebas:** acceso concurrente inicial y comprobación de una sola fila.

### F-17 — Hacer segura la reprogramación de notificaciones

- **Archivo:** `lib/features/alerts/data/alerts_repository.dart`
- **Problema:** primero se ejecuta `cancelAll()` y después se programan alertas una a una.
- **Impacto:** un fallo intermedio deja al usuario sin alertas o con un conjunto parcial.
- **Fix:** calcular y validar primero; programar el conjunto nuevo; cancelar ids obsoletos al final. Limitar cancelaciones al canal de CicloTrack.
- **Pruebas:** fallo del scheduler en mitad del lote, reintento e idempotencia.

### F-18 — Corregir participantes del mensaje multi-mujer

- **Archivo:** `alert_rule_engine.dart`
- **Problema:** la regla comprueba dos mujeres fértiles, pero construye el mensaje con todas las participantes del encuentro.
- **Impacto:** el mensaje puede afirmar riesgo para una mujer que no está fértil.
- **Fix:** separar participantes fértiles de no fértiles y usar solo las fértiles en el texto y `womanIds` de la alerta.
- **Pruebas:** encuentro con tres mujeres, solo dos fértiles.

### F-19 — Ignorar tokens CSV desconocidos

- **Archivo:** `lib/features/alerts/domain/alert_settings.dart`
- **Problema:** un token desconocido se transforma silenciosamente en `fertilidadInminente`.
- **Impacto:** una migración o configuración corrupta activa una alerta incorrecta.
- **Fix:** ignorar tokens desconocidos y, opcionalmente, registrar/normalizar la configuración.
- **Pruebas:** CSV vacío, válido, duplicado y con tipos inexistentes.

## Cobertura pendiente

- Tests widget de formularios de tracking.
- Tests widget de encuentros.
- Tests de doble envío y errores de repositorio.
- Tests de reactividad de tags y encuentros enriquecidos.
- Tests de timestamps con horas distintas y fechas cerca de medianoche.
- Tests de inicialización, permisos y reprogramación de notificaciones.
- Tests de migración real v1→v2→v3.
- Tests de borrado de la única participante de un encuentro.
- Tests de cambio de día/resume para predicciones.

## Orden recomendado

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
