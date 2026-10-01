# CicloTrack

Aplicación Android personal para gestionar de forma privada los ciclos menstruales de varias mujeres: perfiles, tracking, encuentros, predicción de fertilidad y alertas locales. Una pantalla de ajustes reúne el acceso a alertas, copia de seguridad, informes y vistas, junto al «Acerca de». Todos los datos se quedan en el dispositivo; no hay nube, sincronización ni secretos.

## Manual de uso

Consulta el [manual de uso de CicloTrack](MANUAL_DE_USO.md) para aprender a gestionar perfiles, registrar periodos y encuentros, consultar predicciones y calendarios, y configurar las alertas.

## Estado

Fases 0–9 completadas (scaffold, base de datos + motor de predicción, perfiles, tracking, encuentros, alertas, vistas consolidadas de calendario, reportes con gráficos y copia de seguridad manual). Schema drift **v3 con 10 tablas**. Fase 10 **en curso**: ya están la pantalla de ajustes, la cabecera de la lista de perfiles colapsada (ajustes + menú de más opciones) y el icono y la etiqueta propios de la app; queda pendiente el resto de la fase (medicación, recordatorios personalizados y pulido final). Detalle en [`planDeDesarrollo.md`](planDeDesarrollo.md); requisitos funcionales en [`Especificaciones.md`](Especificaciones.md).

## Stack

| Capa | Tecnología |
|---|---|
| UI | Flutter 3.32.7 (Android-only), Material |
| Estado | Riverpod 2.6.1 |
| Datos | SQLite vía drift 2.31.0 + drift_flutter |
| Notificaciones | flutter_local_notifications 20.1.0, timezone + flutter_timezone |
| Calendario | table_calendar 3.2.1 + intl 0.20.2 (es-ES) |
| Gráficos | fl_chart 1.0.0 (pin exacto: 1.1.x no compila con el `vector_math` del SDK) |
| Copia de seguridad | csv 6.0.0 + archive 3.6.1 + pdf 3.11.3 + file_picker 11.0.3 (selector del sistema, sin `share_plus`) |

Arquitectura feature-first con 3 capas por feature: `presentation/` (UI) → `domain/` (lógica pura, sin Flutter) → `data/` (drift), con flujo unidireccional UI → Notifier → Repository → drift. El código compartido vive en `lib/core/`.

## Entorno

El toolchain (Flutter 3.32.7, Android SDK 34/35, OpenJDK 17) vive en `.toolchain/` y está ignorado por git. Antes de cualquier comando Flutter/Dart:

```bash
source .toolchain/env.sh
```

Borrar `.toolchain/` desinstala Flutter/SDK por completo; no hay cambios a nivel de sistema.

## Comandos

```bash
source .toolchain/env.sh
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
└── features/      # profiles, tracking, encounters, prediction, alerts, calendar, reports, backup
    └── <feature>/
        ├── presentation/   # pantallas, widgets y providers
        ├── domain/         # lógica pura (tests unitarios obligatorios)
        └── data/           # DAOs, repositorios y drift
```

## Convenciones

Commits en Conventional Commits, Gitflow completo y reglas de estilo en [`BUENAS_PRACTICAS.md`](BUENAS_PRACTICAS.md). El historial de fixes y sus decisiones queda en [`fixs.md`](fixs.md).
