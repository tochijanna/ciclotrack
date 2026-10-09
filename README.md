# CicloTrack

Aplicación Android personal para gestionar de forma privada los ciclos menstruales de varias mujeres: perfiles, tracking, encuentros, predicción de fertilidad y alertas locales. Una pantalla de ajustes reúne el acceso a alertas, copia de seguridad, informes, vistas y medicación, junto al «Acerca de». Todos los datos se quedan en el dispositivo; no hay nube, sincronización ni secretos.

## Manual de uso

Consulta el [manual de uso de CicloTrack](MANUAL_DE_USO.md) para aprender a gestionar perfiles, registrar periodos y encuentros, consultar predicciones y calendarios, configurar alertas, medicación y recordatorios, y exportar o restaurar copias.

## Estado

Versión publicada: **v1.2.0** (`1.2.0+4`). Fases 0–10 completadas (scaffold, base de datos + motor de predicción, perfiles, tracking, encuentros, alertas, vistas consolidadas, reportes, copia de seguridad manual, medicación, recordatorios personalizados y ajustes/pulido). Schema drift **v4 con 11 tablas**. La cabecera reúne Ajustes y Más opciones; la app tiene icono y etiqueta propios. Desde v1.1.0 hay bloqueo de acceso opcional con el PIN o la biometría del sistema (controla el acceso, no cifra los datos) y desde v1.2.0 la interfaz está en español e inglés. **Ninguna versión se ha probado en un dispositivo Android**: la entrega real de notificaciones, los permisos, el bloqueo, el selector de archivos y el icono están sin validar (ver [§8 del plan](planDeDesarrollo.md#8-limitaciones-de-dispositivo-y-backlog)). Estado vigente, historial de releases y detalle por fase en [`planDeDesarrollo.md`](planDeDesarrollo.md); requisitos funcionales en [`Especificaciones.md`](Especificaciones.md).

## Stack

| Capa | Tecnología |
|---|---|
| UI | Flutter 3.47.4 (Android-only), Material |
| Estado | Riverpod 2.6.1 |
| Datos | SQLite vía drift 2.35.1 + drift_flutter |
| Notificaciones | flutter_local_notifications 20.1.0, timezone + flutter_timezone |
| Bloqueo de acceso | local_auth 2.3.0 + shared_preferences 2.5.3 |
| Calendario | table_calendar 3.2.1 + intl 0.20.3 (es/en) |
| Gráficos | fl_chart 1.2.0 |
| Copia de seguridad | csv 8.0.0 + archive 4.0.9 + pdf 3.12.0 + file_picker 13.1.0 (selector del sistema, sin `share_plus`) |

Arquitectura feature-first con 3 capas por feature: `presentation/` (UI) → `domain/` (lógica pura, sin Flutter) → `data/` (drift), con flujo unidireccional UI → Notifier → Repository → drift. El código compartido vive en `lib/core/`.

## Entorno

El toolchain (Flutter 3.47.4, Android SDK 36, OpenJDK 17) vive en una carpeta `.toolchain/` ignorada por git; en esta máquina está en `/home/tochi/Proyectos/CalendarioMenstrual/.toolchain/` y los worktrees nuevos no la incluyen. Antes de cualquier comando Flutter/Dart:

```bash
source /home/tochi/Proyectos/CalendarioMenstrual/.toolchain/env.sh
```

Borrar `.toolchain/` desinstala Flutter/SDK por completo; no hay cambios a nivel de sistema.

## Comandos

```bash
source /home/tochi/Proyectos/CalendarioMenstrual/.toolchain/env.sh
dart format lib test                      # formato
flutter analyze                           # análisis estático (debe quedar limpio)
flutter test                              # suite completa
dart run build_runner build --delete-conflicting-outputs   # codegen tras tocar tablas/DAOs
flutter build apk --debug                 # APK de depuración
```

## Estructura

```
lib/
├── core/          # base de datos, providers y reloj inyectable
└── features/      # profiles, tracking, encounters, prediction, alerts, calendar, reports, backup, medications, settings
    └── <feature>/
        ├── presentation/   # pantallas, widgets y providers
        ├── domain/         # lógica pura (tests unitarios obligatorios)
        └── data/           # DAOs, repositorios y drift
```

## Convenciones

Commits en Conventional Commits, Gitflow completo y reglas de estilo en [`BUENAS_PRACTICAS.md`](BUENAS_PRACTICAS.md). El historial de fixes y sus decisiones queda en [`fixs.md`](fixs.md).
